# Manual Backend Setup & Run

Jika environment setup mengalami hambatan, ikuti panduan manual ini.

## Quick Start (Troubleshooting)

### 1. Setup Manual Install

```bash
cd /home/berkuiii/Documents/stock-predict-backend-main

# Install satu per satu jika ada dependency conflict
python -m pip install fastapi uvicorn --no-cache-dir
python -m pip install tensorflow --no-cache-dir
python -m pip install numpy pandas scikit-learn --no-cache-dir
python -m pip install yfinance joblib firebase-admin --no-cache-dir
python -m pip install pydantic matplotlib --no-cache-dir
```

### 2. Verify Installation

```bash
python -c "import fastapi, uvicorn, tensorflow as tf, firebase_admin; print('✓ All imports OK'); print(f'TF Version: {tf.__version__}')"
```

### 3. Set Firebase Path

```bash
export FIREBASE_CREDENTIALS=/home/berkuiii/Documents/stock-predict-backend-main/Secret/stock-prediction-realtime-firebase-adminsdk-fbsvc-6d0f85bf5b.json
```

### 4. Run Backend

#### Option A: Using `python -m` (recommended if `uvicorn` not in PATH)

```bash
cd /home/berkuiii/Documents/stock-predict-backend-main
export FIREBASE_CREDENTIALS=$PWD/Secret/stock-prediction-realtime-firebase-adminsdk-fbsvc-6d0f85bf5b.json
python -m uvicorn backend_api:app --reload --host 0.0.0.0 --port 8000
```

#### Option B: Direct uvicorn (if installed in PATH)

```bash
cd /home/berkuiii/Documents/stock-predict-backend-main
export FIREBASE_CREDENTIALS=$PWD/Secret/stock-prediction-realtime-firebase-adminsdk-fbsvc-6d0f85bf5b.json
uvicorn backend_api:app --reload --host 0.0.0.0 --port 8000
```

#### Option C: Using Python script

```bash
cd /home/berkuiii/Documents/stock-predict-backend-main
bash start_backend.sh
```

### 5. Test Backend

Akses di browser atau curl:

```bash
# Health check
curl http://localhost:8000/status

# API Docs (interactive)
open http://localhost:8000/docs
```

Expected output `/status`:
```json
{
  "model": "LSTM",
  "ticker": "GGRM.JK",
  "metadata": {...},
  "scaler_type": "MinMaxScaler",
  "features": ["Close", "Open", "High", "Low", "Volume", "return1", "ma7", "ma21", "std7"]
}
```

## Troubleshooting

### Error: `ModuleNotFoundError: No module named 'uvicorn'`

**Solution A:** Gunakan `python -m uvicorn` instead of `uvicorn`
```bash
python -m uvicorn backend_api:app --reload --host 0.0.0.0 --port 8000
```

**Solution B:** Add pip location to PATH
```bash
export PATH="/var/data/python/bin:$PATH"
uvicorn backend_api:app --reload --host 0.0.0.0 --port 8000
```

### Error: `ModuleNotFoundError: No module named 'numpy'` / TensorFlow

**Solution:** Install Keras + TensorFlow together
```bash
python -m pip install tensorflow --no-cache-dir
# Wait 5-10 minutes for TensorFlow to compile
```

### Error: `No module named 'backend_api'`

**Solution:** Make sure you're in the correct directory
```bash
cd /home/berkuiii/Documents/stock-predict-backend-main
ls -la backend_api.py  # Should exist
python -m uvicorn backend_api:app --host 0.0.0.0 --port 8000
```

### Firebase not connecting

**Solution:** Verify env var is set
```bash
echo $FIREBASE_CREDENTIALS
# Should print: /home/berkuiii/Documents/stock-predict-backend-main/Secret/stock-prediction-realtime-firebase-adminsdk-fbsvc-6d0f85bf5b.json

# Test file exists
ls -la "$FIREBASE_CREDENTIALS"
```

## Production Deployment

For production, use:
```bash
python -m uvicorn backend_api:app --host 0.0.0.0 --port 8000 --workers 4
```

Or with Gunicorn:
```bash
gunicorn -w 4 -k uvicorn.workers.UvicornWorker backend_api:app --bind 0.0.0.0:8000
```

---

**Last updated:** 2024-01-12
