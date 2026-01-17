# Stock Vision - Project Structure Guide

## Overview
This document describes the organized folder structure of the Stock Vision project - a comprehensive stock prediction system combining Python backend, Flutter mobile frontend, and ML models.

---

## Directory Structure

```
stock-predict-backend-main/
├── scripts/                 # Python & Shell scripts
├── models/                  # Trained ML models & scalers
├── docs/                    # Documentation & guides
├── config/                  # Configuration files
├── archive/                 # Legacy & backup files
├── tests/                   # Test files
├── ggrm_stock_app/          # Flutter mobile app
├── mobile_app/              # React Native app (legacy)
├── backend_env/             # Python virtual environment
├── Secret/                  # Firebase credentials (⚠️ Keep secure)
├── __pycache__/             # Python cache (auto-generated)
├── pubspec.yaml             # Flutter dependencies
└── lib/                     # Dart library files (legacy)
```

---

## Folder Details

### 📁 `scripts/` - Python & Shell Scripts
**Purpose:** All executable Python scripts and shell automation

**Key Files:**
- `app.py` - Main Flask API server (Port 5000)
- `predict_ggrm.py` - LSTM prediction engine
- `retrain_ggrm.py` - Model training pipeline
- `daily_prediction.py` - Scheduled prediction runner
- `scrape_to_firebase.py` - Data collection script
- `run_backend.sh` - Backend startup script
- `build_apk.sh` - Android build automation
- `train_and_validate.sh` - Model validation pipeline

**Usage:**
```bash
# Start backend API
bash scripts/run_backend.sh

# Train/retrain model
python3 scripts/retrain_ggrm.py

# Build Android APK
bash scripts/build_apk.sh
```

---

### 📁 `models/` - Machine Learning Models
**Purpose:** Trained LSTM models and preprocessing utilities

**Key Files:**
- `stock_model.keras` (1.6 MB) - Trained LSTM neural network
- `scaler_ggrm.pkl` - MinMaxScaler for feature normalization
- `model_metadata.json` - Training metrics and configuration

**Model Specifications:**
- Architecture: LSTM with 2 layers + Dropout + Dense
- Input: 60-day time series of GGRM.JK stock prices
- Output: 7-day forward price predictions
- Trained on: 5 years of Yahoo Finance data

---

### 📁 `docs/` - Documentation
**Purpose:** Complete project documentation and guides

**Key Documents:**
- `README_STOCK_VISION.md` - Main product guide
- `PREDICTION_API_GUIDE.md` - API setup and usage
- `FLUTTER_INTEGRATION.md` - Mobile app integration
- `DEPLOYMENT_GUIDE.md` - Production deployment
- `BUILD_CHECKLIST.md` - Pre-build verification
- `PROJECT_STRUCTURE.md` - This file

**Development Docs:**
- `BACKEND_DATA_PIPELINE.md` - Data flow architecture
- `BACKEND_ENHANCEMENT_SUMMARY.md` - Backend changes
- `FLUTTER_MIGRATION.md` - Flutter refactoring

---

### 📁 `config/` - Configuration Files
**Purpose:** Application configuration and dependencies

**Key Files:**
- `requirements.txt` - Python package dependencies
- `setup.sh` - Linux/Mac setup script
- `setup.bat` - Windows setup script
- `docker-compose.yml` - Docker container orchestration
- `Dockerfile` - Docker image definition
- `*.json` - Configuration files

**Installed Packages:**
- Flask, Flask-CORS (API)
- TensorFlow, Keras (ML)
- pandas, numpy, scikit-learn (Data processing)
- yfinance (Yahoo Finance integration)
- firebase-admin (Firebase integration)

---

### 📁 `archive/` - Legacy & Backups
**Purpose:** Previous versions and backup files

**Contents:**
- `assets_backup/` - Old asset files
- Legacy configuration files
- Deprecated script versions
- Build output artifacts

**Note:** These files are kept for reference but not actively used. Safe to delete if storage is needed.

---

### 📁 `tests/` - Test Files
**Purpose:** Testing and validation scripts

**Files:**
- `test_api.py` - API endpoint testing
- `quick_test.py` - Quick validation tests
- `run_test.sh` - Test runner script

**Usage:**
```bash
python3 tests/test_api.py          # Test API endpoints
bash tests/run_test.sh             # Run all tests
```

---

### 📁 `Secret/` - Credentials & Secrets
**Purpose:** Firebase authentication and API keys

⚠️ **SECURITY ALERT:**
- **Never commit to git** - Add to `.gitignore`
- **Keep secure** - Limit access to authorized developers only
- **Rotate regularly** - Update Firebase service accounts periodically

**Files:**
- `stock-prediction-realtime-firebase-adminsdk-*.json` - Firebase Admin SDK credentials

---

### 📁 `ggrm_stock_app/` - Flutter Mobile App
**Purpose:** Main Flutter application for Android/iOS

**Structure:**
```
ggrm_stock_app/
├── lib/                    # Dart source code
│   ├── main.dart          # App entry point
│   ├── screens/           # UI screens
│   ├── services/          # API services
│   └── widgets/           # Custom widgets
├── android/               # Android native code
├── ios/                   # iOS native code
├── pubspec.yaml           # Flutter dependencies
└── assets/                # App images/resources
```

**Key Classes:**
- `main.dart` - Stateful app with theme management
- `home_screen.dart` - Stock data display & predictions
- `settings_screen.dart` - User settings & dark mode toggle
- `api_service.dart` - REST API client (singleton)

**Theme Support:**
- Light theme: White background with blue accent
- Dark theme: Dark gray (#1A1A1A) with dim UI components

---

### 📁 `backend_env/` - Python Virtual Environment
**Purpose:** Isolated Python environment with all dependencies

**Usage:**
```bash
# Activate environment
source backend_env/bin/activate

# Verify activation
which python  # Should show backend_env path

# Install packages
pip install -r config/requirements.txt

# Deactivate when done
deactivate
```

---

### 📁 `mobile_app/` - React Native App (Legacy)
**Purpose:** Alternative React Native implementation (not actively maintained)

**Status:** ⚠️ Deprecated - Use `ggrm_stock_app/` (Flutter) instead

---

### 📁 `lib/` - Dart Libraries (Legacy)
**Purpose:** Old standalone Dart library files

**Status:** ⚠️ Deprecated - Code migrated to `ggrm_stock_app/lib/`

---

## Quick Start Guide

### 1. Setup Environment
```bash
cd /home/berkuiii/Documents/stock-predict-backend-main

# Activate Python environment
source backend_env/bin/activate

# Install/update dependencies
pip install -r config/requirements.txt
```

### 2. Start Backend API
```bash
# Navigate to project root
cd /home/berkuiii/Documents/stock-predict-backend-main

# Run Flask API server
python3 scripts/app.py
# Server runs on http://localhost:5000
```

### 3. Test Predictions
```bash
# Test API with curl
curl http://localhost:5000/api/predict

# Run Python tests
python3 tests/test_api.py
```

### 4. Build Flutter App
```bash
cd ggrm_stock_app

# Get dependencies
flutter pub get

# Run app (Android emulator)
flutter run -d emulator-5554

# Build APK
flutter build apk --release
```

### 5. Retrain Model (if needed)
```bash
python3 scripts/retrain_ggrm.py
# New model saved to models/stock_model.keras
```

---

## API Endpoints

All endpoints served by `scripts/app.py` on **Port 5000**:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/predict` | GET | Get 7-day stock predictions |
| `/api/health` | GET | API health check |
| `/api/info` | GET | API information |

### Example Response
```json
{
  "ticker": "GGRM.JK",
  "last_price": 50000,
  "predictions": [
    {
      "date": "2024-01-20",
      "price": 50500,
      "day_ahead": 1,
      "change_percent": 1.0
    }
  ]
}
```

---

## Data Flow

```
Yahoo Finance (yfinance)
        ↓
  scripts/predict_ggrm.py
        ↓
  models/stock_model.keras (LSTM)
        ↓
  scripts/app.py (Flask API)
        ↓
  ggrm_stock_app (Flutter Frontend)
        ↓
  User Interface
```

---

## File Organization Rules

### What goes where?

| File Type | Location | Example |
|-----------|----------|---------|
| Python scripts | `scripts/` | `app.py`, `predict_ggrm.py` |
| ML models | `models/` | `stock_model.keras` |
| Documentation | `docs/` | `README.md`, guides |
| Config files | `config/` | `requirements.txt`, `.yml` |
| Test files | `tests/` | `test_api.py` |
| Flutter app | `ggrm_stock_app/` | Mobile app source |
| Backups | `archive/` | Old versions |
| Secrets | `Secret/` | Firebase keys ⚠️ |

---

## Maintenance Checklist

- [ ] Keep `Secret/` out of git (add to `.gitignore`)
- [ ] Archive old files instead of deleting
- [ ] Update `docs/` when changing features
- [ ] Test after moving/reorganizing files
- [ ] Keep `config/requirements.txt` up to date
- [ ] Monitor `archive/` size for cleanup opportunities
- [ ] Review model performance periodically

---

## Common Commands Reference

```bash
# Activate environment
source backend_env/bin/activate

# Install dependencies
pip install -r config/requirements.txt

# Start backend
python3 scripts/app.py

# Retrain model
python3 scripts/retrain_ggrm.py

# Run tests
python3 tests/test_api.py

# Build APK
bash scripts/build_apk.sh

# View logs
tail -f backend.log
```

---

## Storage Summary

| Folder | Size | Purpose |
|--------|------|---------|
| `ggrm_stock_app/` | 358 MB | Flutter app with build artifacts |
| `backend_env/` | 6.6 MB | Python environment & packages |
| `models/` | 2.0 MB | ML models |
| `docs/` | 252 KB | Documentation |
| `scripts/` | 136 KB | Python scripts |
| `archive/` | 72 KB | Backup files |
| **Total** | ~367 MB | Complete project |

---

## Troubleshooting

### API not responding?
1. Check if Flask is running: `lsof -i :5000`
2. Verify environment is activated: `which python`
3. Check logs: `tail -f backend.log`
4. Restart: `python3 scripts/app.py`

### Model file missing?
1. Check models folder: `ls -la models/`
2. Retrain if needed: `python3 scripts/retrain_ggrm.py`
3. Verify scaler: `ls -la models/scaler_*`

### Flutter connection issues?
1. Ensure API is running on port 5000
2. Check device networking: `adb shell ifconfig`
3. Android emulator: Use `10.0.2.2:5000`
4. Physical device: Use `192.168.x.x:5000` (local network)

---

## Next Steps

1. ✅ Complete - Project files organized
2. ⏳ Optional - Create CI/CD pipeline
3. ⏳ Optional - Add unit tests
4. ⏳ Optional - Setup automatic model retraining
5. ⏳ Optional - Add database persistence

---

**Last Updated:** January 2024
**Project Status:** Production Ready ✅
**Main Branch:** Ready for deployment
