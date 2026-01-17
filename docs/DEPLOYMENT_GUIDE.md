# Deployment & Build Guide

Complete guide untuk deploy backend dan build mobile app.

## 📋 Pre-requisites

### Backend Requirements
- Python 3.10+ ✓
- pip ✓
- yfinance connectivity ✓
- Firebase credentials ✓

### Mobile Requirements
- Flutter SDK (untuk native Android APK)
- OR Expo CLI (untuk quick testing)
- Android SDK (untuk emulator/device testing)

---

## 🚀 Phase 1: Train & Validate Model

**Automated Script:**
```bash
cd /home/berkuiii/Documents/stock-predict-backend-main
bash train_and_validate.sh
```

**Manual Steps:**
```bash
cd /home/berkuiii/Documents/stock-predict-backend-main
source backend_env/bin/activate
python train_model.py      # ~5-10 minutes
python validate_ggrm_model.py  # ~2-3 minutes
```

**Output:**
- ✓ `stock_model.keras` (LSTM model)
- ✓ `scaler_ggrm.pkl` (MinMaxScaler)
- ✓ `test_results.json` (evaluation metrics)

---

## 🌐 Phase 2: Start Backend API

**Automated:**
```bash
bash run_backend.sh
```

**Manual:**
```bash
cd /home/berkuiii/Documents/stock-predict-backend-main
source backend_env/bin/activate
export FIREBASE_CREDENTIALS=$PWD/Secret/stock-prediction-realtime-firebase-adminsdk-fbsvc-6d0f85bf5b.json
python -m uvicorn backend_api:app --reload --host 0.0.0.0 --port 8000
```

**Test:**
```bash
curl http://localhost:8000/docs  # Open in browser
curl http://localhost:8000/status  # Health check
```

---

## 🐳 Phase 3: Docker & Production Deployment

### Option A: Docker Build & Run

```bash
cd /home/berkuiii/Documents/stock-predict-backend-main
bash build_docker.sh
```

### Option B: Docker-Compose (Recommended for Production)

**Prerequisite:** Ensure Firebase credentials file exists at:
```
./Secret/stock-prediction-realtime-firebase-adminsdk-fbsvc-6d0f85bf5b.json
```

**Start services:**
```bash
cd /home/berkuiii/Documents/stock-predict-backend-main
docker-compose up -d
```

**Services included:**
- ✓ FastAPI backend (port 8000)
- ✓ PostgreSQL (port 5432) - for storing predictions
- ✓ Nginx (port 80, 443) - reverse proxy & HTTPS

**Monitor:**
```bash
docker-compose logs -f ggrm-api    # View backend logs
docker-compose ps                   # View all services
```

**Stop:**
```bash
docker-compose down
```

---

## 📱 Phase 4: Build Mobile App

### Option A: Flutter (Native Android APK)

**Prerequisites:**
```bash
# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$(pwd)/flutter/bin"
flutter doctor  # Verify setup
```

**Build APK:**
```bash
cd /home/berkuiii/Documents/stock-predict-backend-main
bash build_apk.sh
```

**Output:**
- Debug APK: `build/app/outputs/apk/debug/app-debug.apk`
- Release APK: `build/app/outputs/apk/release/app-release.apk`

**Install on device/emulator:**
```bash
adb install -r build/app/outputs/apk/debug/app-debug.apk
```

### Option B: Expo (Faster for Testing)

```bash
cd /home/berkuiii/Documents/stock-predict-backend-main/mobile_app

# Install Expo CLI
npm install -g expo-cli

# Start expo dev server
expo start

# Build APK using Expo cloud build
expo build:android --release-channel production
```

---

## 🌍 Phase 5: Production Deployment (Cloud)

### Option A: Render.com (Recommended - Free tier)

```bash
# 1. Create Render account at render.com
# 2. Connect GitHub repo
# 3. Create new Web Service
#    - Build Command: `pip install -r requirements.txt`
#    - Start Command: `python -m uvicorn backend_api:app --host 0.0.0.0 --port $PORT`
# 4. Set Environment Variables:
#    - FIREBASE_CREDENTIALS=<paste service account JSON>
# 5. Deploy!
```

### Option B: Google Cloud Run

```bash
# 1. Install Google Cloud SDK
curl https://sdk.cloud.google.com | bash

# 2. Build & deploy
gcloud run deploy ggrm-predictor \
  --source . \
  --platform managed \
  --region us-central1 \
  --set-env-vars FIREBASE_CREDENTIALS=/run/secrets/firebase-creds.json
```

### Option C: Heroku (Requires Credit Card)

```bash
# 1. Install Heroku CLI
# 2. Login
heroku login

# 3. Create app
heroku create ggrm-predictor

# 4. Set environment variables
heroku config:set FIREBASE_CREDENTIALS="$(cat Secret/stock-prediction-realtime-firebase-adminsdk-fbsvc-6d0f85bf5b.json)"

# 5. Deploy
git push heroku main
```

---

## 📊 Configuration Files

### `.env` Example
```env
FIREBASE_CREDENTIALS=/path/to/firebase-service-account.json
TICKER=GGRM.JK
DATA_PERIOD=5y
LOG_LEVEL=INFO
```

### `nginx.conf` (For Reverse Proxy)
```nginx
upstream backend {
    server ggrm-api:8000;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## 🔍 Monitoring & Debugging

### Backend Health Check
```bash
curl http://localhost:8000/status | python -m json.tool
```

### View Logs
```bash
# Docker
docker-compose logs -f ggrm-api

# Local
tail -f ggrm_prediction.log
```

### Test Prediction Endpoint
```bash
curl -X POST http://localhost:8000/predict-next \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ID_TOKEN" \
  -d '{"ticker":"GGRM.JK"}'
```

---

## ✅ Deployment Checklist

- [ ] Train model (`train_and_validate.sh`)
- [ ] Test backend locally (`run_backend.sh`)
- [ ] Verify API endpoints at `/docs`
- [ ] Update Firebase credentials in docker-compose.yml
- [ ] Build Docker image (`docker build -t ggrm-predictor .`)
- [ ] Start with docker-compose (`docker-compose up -d`)
- [ ] Build mobile app (`build_apk.sh`)
- [ ] Test mobile app with backend API
- [ ] Deploy backend to cloud (Render/GCP/Heroku)
- [ ] Update mobile app with production backend URL
- [ ] Publish app to Google Play Store

---

## 🆘 Troubleshooting

### "No space left on device"
```bash
# Clean Docker
docker system prune -a
docker volume prune
```

### TensorFlow build fails
```bash
# Use pre-built wheel
pip install tensorflow --only-binary :all:
```

### Flutter build fails
```bash
flutter clean
flutter pub get
flutter build apk
```

### Backend can't connect to Firestore
```bash
# Verify credentials
echo $FIREBASE_CREDENTIALS
test -f "$FIREBASE_CREDENTIALS" && echo "OK" || echo "NOT FOUND"
```

---

## 📱 Mobile Configuration

### Connect to Backend
Update `lib/services/api_service.dart`:
```dart
final String baseUrl = 'http://YOUR_BACKEND_IP:8000';
// or for production:
final String baseUrl = 'https://your-backend.example.com';
```

### Firebase Setup
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/`
3. Update `android/build.gradle`
4. Rebuild app

---

**Last Updated:** 2024-01-12
