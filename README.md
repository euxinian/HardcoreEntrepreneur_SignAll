# ✋ SignAll | Real-Time Sign Language Detection

**SignAll** is a full-stack mobile application that detects Sign Language gestures in real time using a custom-trained AI model. The system consists of a Flutter Android app and a cloud-hosted FastAPI backend, connected over a secure HTTPS API.

Built by **Team SkyLine** for **Hardcore Entrepreneur 6.0**.

> ❗ The backend is hosted on Railway for the duration of the evaluation. Running it locally requires changes to the API code and direct access to the PyTorch model weights. Please use the hosted version.

> Note: Detection accuracy degrades in poor lighting conditions - both very dark environments and scenes with strong direct light or glare. For best results, use the app in a normally lit indoor setting.


---

## 📁 Repository Structure

```
HardcoreEntrepreneur_SignAll/
├── Backend/ - FastAPI inference server
├── Deliverables/ - APK file, PDF with Demo and Pitch video links, PDF with business plan
└── SourceCode/ - Flutter Android application
```

---

## 📱 SourceCode - Flutter Android App

The mobile frontend is built with Flutter and targets Android.

### How it works

The app opens the front-facing camera and captures a JPEG frame every **200 milliseconds**. Each frame is uploaded as a multipart HTTP POST to the `/predict` endpoint. The server responds with bounding box coordinates, a sign label, and a confidence score - all rendered over the live camera feed in real time via a 60 fps animated painter.

### Two-tier detection

Detection results are rendered in two simultaneous visual layers:

| Tier | Threshold | Visual | Behaviour |
|------|-----------|--------|-----------|
| **Tracking** | > 0.45 | Dashed white outline | Appears whenever a hand-like region is detected and gives immediate feedback before a sign is confirmed |
| **Confirmed** | > 0.90 | Coloured border + label chip | Shown only when the model reaches high confidence on a specific sign |

The confirmed label is additionally passed through a **temporal smoother**: the same sign must appear in at least **3 of the last 5 frames** before it is shown in the panel. This eliminates single-frame false positives without adding noticeable latency.

### Key files

| File | Purpose |
|------|---------|
| `lib/screens/camera_screen.dart` | Camera lifecycle, API polling loop, temporal smoothing |
| `lib/widgets/detection_painter.dart` | Animated bounding box renderer with  transitions |
| `lib/widgets/detection_panel.dart` | Bottom panel showing the confirmed sign label and confidence bar |
| `lib/constants/api_constants.dart` | Server URL and API key (injected at build time, never in source) |

### Security

The API constants are **never stored in source code**. They are injected at compile time via Flutter's `--dart-define` flag.

---

## ⚙️ Backend - FastAPI Inference Server

A Python FastAPI server that receives camera frames, runs them through the DETR model, and returns structured JSON. Deployed on **Railway** as a Docker container.

### Startup

On first launch, the server downloads the trained model weights from a **private Hugging Face repository** (`euxinian/SignAll`) and loads them into memory. Subsequent restarts use the locally cached weights.

> The first request after a fresh deployment takes **60–90 seconds** while PyTorch loads the model. 

### Endpoints

#### `GET /health`
Returns server and model status. Pinged by the app on launch.

```json
{ "status": "ok", "model_loaded": true }
```

#### `POST /predict`
Accepts a JPEG image (multipart form). Returns two lists:

```json
{
  "detections": [
    {
      "label":      "Hello", # Name from config.json
      "confidence": 0.9341, # Model Confidence Level
      "color":      [255, 180, 0], # Color from config.json
      "box":        [312.4, 180.1, 701.2, 689.3] # The coordinates on screen
    }
  ],
  "tracking": [
    {
      "label":      "",
      "confidence": 0.5812,
      "color":      [160, 160, 160],
      "box":        [290.1, 160.4, 720.0, 710.1]
    }
  ]
}
```

- **`detections`** - signs confirmed above the high-confidence threshold (0.90). Rendered as coloured boxes with labels.
- **`tracking`** - lower-confidence detections (0.45–0.90) rendered as dim dashed outlines with no label.

Box coordinates are expressed on a **1000×1000 virtual grid** and scaled to the device screen by the Flutter painter.

### Inference pipeline

```
JPEG received
  → EXIF orientation corrected
  → Converted to BGR
  → SmallestMaxSize(224) + CenterCrop(224)   ← matches training preprocessing exactly
  → Normalised with ImageNet mean/std
  → DETR forward pass (async thread, non-blocking)
  → Softmax on logits → per-query class probabilities
  → Queries split by threshold (tracking: 0.45 / confirmed: 0.90)
  → Boxes rescaled to 1000×1000 virtual grid
  → NMS (IoU 0.5) applied per tier
  → JSON response
```

### Key files

| File | Purpose |
|------|---------|
| `src/api.py` | FastAPI app, authentication, full inference pipeline |
| `src/model.py` | DETR architecture (ResNet-50 backbone + Transformer) |
| `src/config.json` | Sign class names and display colours |
| `src/utils/boxes.py` | Bounding box coordinate conversion utilities |
| `Dockerfile` | Container definition for Railway deployment |
| `requirements-prod.txt` | Pinned production Python dependencies |

---

## 🧠 Model

The detection model is a **DETR (Detection Transformer)** with a ResNet-50 backbone, trained on a custom Sign Language dataset.

**Architecture highlights:**
- ResNet-50 feature extractor (ImageNet pre-trained)
- 2D sinusoidal positional encodings
- Separate classification and bounding box prediction heads
- Inference size: 224×224

Model weights are hosted on a **private Hugging Face repository** and are not stored in this repository.

The original DETR architecture is based on the **SignDETR** project by Nick Renotte (MIT License), adapted and retrained by Team SkyLine.

### Detectable signs (Demo)

| Sign | 🇩🇪 German | 🇫🇷 French |Emoji |
|------|-----------|-------|-------|
| Hello | Hallo  |Bonjour|✋ |
| Thank You | Danke |Merci| 🙏 |
| I Love You | Ich liebe dich |Je t'aime| ❤️ |
| Please | Bitte | S'il te plaît|🤲 |
| No | Nein |Non|🚫 |
| Sad | Traurig |Triste| 😢 |

---

## 📄 License

Original SignDETR architecture - MIT License, Nick Renotte.  
SignAll application, API, and trained model - Team SkyLine.