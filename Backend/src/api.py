import asyncio
import io
import json
import os
import time
from concurrent.futures import ThreadPoolExecutor
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Optional

os.environ.setdefault("OMP_NUM_THREADS",       "1")
os.environ.setdefault("MKL_NUM_THREADS",        "1")
os.environ.setdefault("OPENBLAS_NUM_THREADS",   "1")
os.environ.setdefault("VECLIB_MAXIMUM_THREADS", "1")
os.environ.setdefault("NUMEXPR_NUM_THREADS",    "1")

import cv2
import numpy as np
import torch
import torchvision.ops as ops
import albumentations as A
import logging
from albumentations.pytorch import ToTensorV2
from fastapi import FastAPI, File, HTTPException, Request, UploadFile, Depends, Security
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import APIKeyHeader
from huggingface_hub import hf_hub_download
from PIL import Image, ImageOps, UnidentifiedImageError
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

from model import DETR
from utils.boxes import rescale_bboxes

torch.set_num_threads(1)
torch.set_num_interop_threads(1)

SRC_DIR        = Path(__file__).parent
CONFIG_PATH    = SRC_DIR / "config.json"
PRETRAINED_DIR = SRC_DIR.parent / "LatestModel"

HF_REPO_ID  = "euxinian/SignAll"
HF_FILENAME = "18April.pt"
HF_TOKEN    = os.getenv("HF_TOKEN")

TRACKING_THRESHOLD = 0.35
CONFIRM_THRESHOLD  = 0.70   

INFERENCE_SIZE = 224
VIRTUAL_GRID   = 1000

MAX_CONFIRMED  = 5
MAX_TRACKING   = 5

LUMA_OVEREXPOSED      = 165.0
LUMA_SEVERELY_OVEREXP = 200.0
LUMA_LOW_CONTRAST_STD = 35.0
GAMMA_CORRECTION      = 0.7

logger = logging.getLogger("signall")

_GAMMA_LUT = np.array(
    [((i / 255.0) ** GAMMA_CORRECTION) * 255 for i in range(256)],
    dtype=np.uint8,
)

_CLAHE = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))


API_KEY        = os.environ.get("SIGNALL_API_KEY")
if not API_KEY:
    raise RuntimeError(
        "SIGNALL_API_KEY env var is not set. "
    )
api_key_header = APIKeyHeader(name="X-API-Key")

def verify_api_key(api_key: str = Security(api_key_header)) -> str:
    if api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API Key")
    return api_key


transform = A.Compose([
    A.Resize(INFERENCE_SIZE, INFERENCE_SIZE),
    A.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    ToTensorV2(),
])

class AppState:
    model:                Optional[DETR] = None
    classes:              list            = []
    colors:               list            = []
    last_inference_ms:    float           = 0.0
    last_mean_luminance:  float           = 0.0
    last_clahe_applied:   bool            = False

state = AppState()

_executor = ThreadPoolExecutor(max_workers=1, thread_name_prefix="inference")

def load_config() -> tuple[list, list]:
    try:
        with open(CONFIG_PATH) as f:
            data = json.load(f)
        return data["classes"], data["colors"]
    except Exception as exc:
        raise RuntimeError(f"Failed to load config.json: {exc}") from exc

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Starting SignAll Server…")
    PRETRAINED_DIR.mkdir(parents=True, exist_ok=True)
    local_model_path = PRETRAINED_DIR / HF_FILENAME

    if not local_model_path.exists():
        print(f"Downloading {HF_FILENAME} from Hugging Face…")
        hf_hub_download(
            repo_id=HF_REPO_ID,
            filename=HF_FILENAME,
            local_dir=PRETRAINED_DIR,
            token=HF_TOKEN,
        )
        print("Download complete.")

    classes, colors = load_config()
    model = DETR(num_classes=len(classes))
    checkpoint = torch.load(local_model_path, map_location="cpu", weights_only=True)
    model.load_state_dict(checkpoint, strict=False)
    model.eval()

    with torch.inference_mode():
        dummy = torch.zeros(1, 3, INFERENCE_SIZE, INFERENCE_SIZE)
        model(dummy)
    print("Model warmed up and ready.")

    state.model   = model
    state.classes = classes
    state.colors  = colors

    yield

    state.model = None
    _executor.shutdown(wait=False)

MAX_UPLOAD_BYTES = 10 * 1024 * 1024          

Image.MAX_IMAGE_PIXELS = 50_000_000

limiter = Limiter(key_func=get_remote_address)
app = FastAPI(title="SignAll API", lifespan=lifespan)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health_check():
    return {
        "status":               "ok",
        "model_loaded":         state.model is not None,
    }

@app.post("/predict")
@limiter.limit("10/second;200/minute")
async def predict(
    request: Request,
    file: UploadFile = File(...),
    api_key: str = Depends(verify_api_key),
):
    if state.model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    image_bytes = await file.read()

    if len(image_bytes) > MAX_UPLOAD_BYTES:
        raise HTTPException(status_code=413, detail="Image Exceeds Limit")

    try:
        Image.open(io.BytesIO(image_bytes)).verify()
        image = Image.open(io.BytesIO(image_bytes))
        image = ImageOps.exif_transpose(image)
        image = image.convert("RGB")
    except Exception as exc:
        raise HTTPException(
            status_code=422, detail="Cannot decode image"
        ) from exc

    frame_bgr = np.array(image)[:, :, ::-1].copy()

    t0 = time.perf_counter()
    result, mean_l, clahe_applied = await asyncio.get_running_loop().run_in_executor(
        _executor,
        lambda: _preprocess_and_infer(frame_bgr),
    )
    state.last_inference_ms   = (time.perf_counter() - t0) * 1000
    state.last_mean_luminance = mean_l
    state.last_clahe_applied  = clahe_applied

    probabilities          = result["pred_logits"].softmax(-1)[0, :, :-1]
    max_probs, max_classes = probabilities.max(-1)

    confirm_indices  = torch.where(max_probs > CONFIRM_THRESHOLD)[0]
    tracking_indices = torch.where(max_probs > TRACKING_THRESHOLD)[0]

    confirmed = _build_detections(
        result, confirm_indices, max_probs, max_classes,
        labelled=True, cap=MAX_CONFIRMED,
    )

    confirmed_set = set(confirm_indices.tolist())
    tracking_only = torch.tensor(
        [i.item() for i in tracking_indices if i.item() not in confirmed_set],
        dtype=torch.long,
    )
    tracking = _build_detections(
        result, tracking_only, max_probs, max_classes,
        labelled=False, cap=MAX_TRACKING,
    )

    return {"detections": confirmed, "tracking": tracking}

def _preprocess_and_infer(
    frame_bgr: np.ndarray,
) -> tuple[dict, float, bool]:

    frame_bgr, mean_l, clahe_applied = _normalise_lighting(frame_bgr)

    input_tensor = transform(image=frame_bgr)["image"].unsqueeze(0)

    with torch.inference_mode():
        result = state.model(input_tensor)

    return result, mean_l, clahe_applied


def _normalise_lighting(
    frame_bgr: np.ndarray,
) -> tuple[np.ndarray, float, bool]:
   
    lab       = cv2.cvtColor(frame_bgr, cv2.COLOR_BGR2LAB)
    l_channel = lab[:, :, 0]
    mean_l    = float(l_channel.mean())
    std_l     = float(l_channel.std())

    needs_clahe = mean_l > LUMA_OVEREXPOSED or std_l < LUMA_LOW_CONTRAST_STD
    if not needs_clahe:
        return frame_bgr, mean_l, False

    lab[:, :, 0] = _CLAHE.apply(l_channel)
    out = cv2.cvtColor(lab, cv2.COLOR_LAB2BGR)

    if mean_l > LUMA_SEVERELY_OVEREXP:
        out = cv2.LUT(out, _GAMMA_LUT)

    return out, mean_l, True


def _build_detections(
    result:      dict,
    indices:     torch.Tensor,
    max_probs:   torch.Tensor,
    max_classes: torch.Tensor,
    labelled:    bool,
    cap:         int,
) -> list:

    if len(indices) == 0:
        return []

    raw_boxes = result["pred_boxes"][0, indices, :]
    scores    = max_probs[indices]
    bboxes    = rescale_bboxes(raw_boxes, (VIRTUAL_GRID, VIRTUAL_GRID))

    widths  = bboxes[:, 2] - bboxes[:, 0]
    heights = bboxes[:, 3] - bboxes[:, 1]
    valid   = (widths > 5) & (heights > 5)
    if not valid.any():
        return []
    bboxes  = bboxes[valid]
    scores  = scores[valid]
    indices = indices[valid]

    keep_nms    = ops.nms(boxes=bboxes, scores=scores, iou_threshold=0.6)
    sorted_keep = keep_nms[scores[keep_nms].argsort(descending=True)][:cap]

    out = []
    for nms_idx in sorted_keep:
        q_idx    = indices[nms_idx].item()
        label_id = int(max_classes[q_idx])
        box      = bboxes[nms_idx].tolist()
        conf     = float(max_probs[q_idx])

        if labelled:
            out.append({
                "label":      state.classes[label_id] if label_id < len(state.classes) else "Unknown",
                "confidence": round(conf, 4),
                "color":      state.colors[label_id]  if label_id < len(state.colors)  else [255, 255, 255],
                "box":        box,
            })
        else:
            out.append({
                "label":      "",
                "confidence": round(conf, 4),
                "color":      [160, 160, 160],
                "box":        box,
            })

    return out