#!/bin/bash
# Setup and Start Backend - Complete One-Shot Script

set -e  # Exit on any error

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$PROJECT_DIR/backend_env"
FIREBASE_CRED="$PROJECT_DIR/Secret/stock-prediction-realtime-firebase-adminsdk-fbsvc-6d0f85bf5b.json"

echo "=========================================="
echo "GGRM Stock Prediction Backend - Setup"
echo "=========================================="

# 1. Create venv if not exists
if [ ! -d "$VENV_DIR" ]; then
    echo ""
    echo "1. Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
    echo "   ✓ Virtual environment created"
else
    echo ""
    echo "1. Virtual environment already exists"
fi

# 2. Activate venv
echo ""
echo "2. Activating virtual environment..."
source "$VENV_DIR/bin/activate"
echo "   ✓ Activated: $(which python)"

# 3. Install dependencies
echo ""
echo "3. Installing dependencies (this may take 3-5 minutes)..."
pip install -q --upgrade pip
pip install -q \
    fastapi>=0.100 \
    uvicorn>=0.24 \
    tensorflow>=2.13 \
    numpy>=1.25 \
    pandas>=2.0 \
    scikit-learn>=1.3 \
    yfinance>=0.2 \
    joblib>=1.3 \
    firebase-admin>=6.0 \
    pydantic>=2.0 \
    matplotlib>=3.8 \
    plotly>=5.0 \
    h5py>=3.8
echo "   ✓ Dependencies installed"

# 4. Check Firebase credentials
echo ""
echo "4. Checking Firebase credentials..."
if [ -f "$FIREBASE_CRED" ]; then
    export FIREBASE_CREDENTIALS="$FIREBASE_CRED"
    echo "   ✓ Firebase credentials found"
else
    echo "   ⚠ Firebase credentials not found at: $FIREBASE_CRED"
    echo "   Firebase will be disabled, but API will still work"
fi

# 5. Verify model and scaler files
echo ""
echo "5. Checking model files..."
if [ -f "$PROJECT_DIR/stock_model.keras" ] && [ -f "$PROJECT_DIR/scaler_ggrm.pkl" ]; then
    echo "   ✓ Model and scaler found"
else
    echo "   ⚠ Model or scaler missing. Please train model first:"
    echo "     cd $PROJECT_DIR && python train_model.py"
fi

# 6. Start backend
echo ""
echo "=========================================="
echo "Starting FastAPI Backend"
echo "=========================================="
echo ""
echo "🚀 API running on: http://0.0.0.0:8000"
echo "📚 Docs: http://localhost:8000/docs"
echo "📖 ReDoc: http://localhost:8000/redoc"
echo ""
echo "Press Ctrl+C to stop"
echo ""

cd "$PROJECT_DIR"
python -m uvicorn backend_api:app --reload --host 0.0.0.0 --port 8000
