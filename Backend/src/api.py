import asyncio
import os
from contextlib import asynccontextmanager
from pathlib import Path
import io
import json

import cv2
import numpy as np
import torch
import torchvision.ops as ops
import albumentations as A
from albumentations.pytorch import ToTensorV2
from fastapi import FastAPI, File, HTTPException, UploadFile, Depends, Security
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import APIKeyHeader
from PIL import Image, ImageOps
from huggingface_hub import hf_hub_download

from model import DETR
from utils.boxes import rescale_bboxes

SRC_DIR        = Path(__file__).parent
CONFIG_PATH    = SRC_DIR / "config.json"
PRETRAINED_DIR = SRC_DIR.parent / "LatestModel"

TRACKING_THRESHOLD = 0.45
CONFIRM_THRESHOLD  = 0.88

INFERENCE_SIZE = 224
VIRTUAL_GRID   = 1000

API_KEY        = os.getenv("SIGNALL_API_KEY", "local-key")
api_key_header = APIKeyHeader(name="X-API-Key")

def verify_api_key(api_key: str = Security(api_key_header)):
    if api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API Key")
    return api_key

HF_REPO_ID  = "euxinian/SignAll"
HF_FILENAME = "18April.pt"
HF_TOKEN    = os.getenv("HF_TOKEN")

def load_config() -> tuple[list, list]:
    try:
        with open(CONFIG_PATH) as f:
            data = json.load(f)
        return data["classes"], data["colors"]
    except Exception as e:
        raise RuntimeError(f"Failed to load config.json: {e}")

class AppState:
    def __init__(self):
        self.model   = None
        self.classes = []
        self.colors  = []

state = AppState()

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Starting SignAll Server...")
    PRETRAINED_DIR.mkdir(parents=True, exist_ok=True)
    local_model_path = PRETRAINED_DIR / HF_FILENAME

    if not local_model_path.exists():
        print(f"Downloading {HF_FILENAME} from Hugging Face...")
        hf_hub_download(
            repo_id=HF_REPO_ID,
            filename=HF_FILENAME,
            local_dir=PRETRAINED_DIR,
            token=HF_TOKEN,
        )
        print("Download complete!")

    classes, colors = load_config()
    model = DETR(num_classes=len(classes))
    checkpoint = torch.load(local_model_path, map_location="cpu", weights_only=True)
    model.load_state_dict(checkpoint, strict=False)
    model.eval()

    state.model   = model
    state.classes = classes
    state.colors  = colors
    yield
    state.model = None

app = FastAPI(title="SignAll API", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

transform = A.Compose([
    A.Resize(INFERENCE_SIZE, INFERENCE_SIZE),
    A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    ToTensorV2(),
])

@app.get("/health")
def health_check():
    return {"status": "ok", "model_loaded": state.model is not None}

@app.post("/predict")
async def predict(
    file: UploadFile = File(...),
    api_key: str = Depends(verify_api_key),
):
    if state.model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")

    try:
        image_bytes = await file.read()
        image = Image.open(io.BytesIO(image_bytes))
        image = ImageOps.exif_transpose(image)
        image = image.convert("RGB")
        frame_bgr = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)
        input_tensor = transform(image=frame_bgr)["image"].unsqueeze(0)

        def run_inference(tensor):
            with torch.no_grad():
                return state.model(tensor)

        result = await asyncio.to_thread(run_inference, input_tensor)

        probabilities          = result["pred_logits"].softmax(-1)[0, :, :-1]
        max_probs, max_classes = probabilities.max(-1)

        tracking_indices = torch.where(max_probs > TRACKING_THRESHOLD)[0]
        confirm_indices  = torch.where(max_probs > CONFIRM_THRESHOLD)[0]

        def _build(indices, labelled: bool) -> list:
            if len(indices) == 0:
                return []
            raw_boxes = result["pred_boxes"][0, indices, :]
            scores    = max_probs[indices]
            bboxes    = rescale_bboxes(raw_boxes, (VIRTUAL_GRID, VIRTUAL_GRID))
            keep_nms  = ops.nms(boxes=bboxes, scores=scores, iou_threshold=0.5)
            out = []
            for nms_idx in keep_nms:
                q_idx    = indices[nms_idx]
                label_id = int(max_classes[q_idx])
                box      = bboxes[nms_idx].tolist()
                if labelled:
                    out.append({
                        "label":      state.classes[label_id] if label_id < len(state.classes) else "Unknown",
                        "confidence": round(float(max_probs[q_idx]), 4),
                        "color":      state.colors[label_id]  if label_id < len(state.colors)  else [255, 255, 255],
                        "box":        box,
                    })
                else:
                    out.append({
                        "label":      "",
                        "confidence": round(float(max_probs[q_idx]), 4),
                        "color":      [160, 160, 160],
                        "box":        box,
                    })
            return out

        confirmed = _build(confirm_indices, labelled=True)

        confirmed_set = set(confirm_indices.tolist())
        tracking_only = torch.tensor(
            [i.item() for i in tracking_indices if i.item() not in confirmed_set],
            dtype=torch.long,
        )
        tracking = _build(tracking_only, labelled=False)

        return {"detections": confirmed, "tracking": tracking}

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))