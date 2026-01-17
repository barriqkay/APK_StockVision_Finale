#!/bin/bash
# Quick Start Script untuk GGRM Stock Prediction
# Dengan Virtual Environment Support

echo "=========================================="
echo "GGRM Stock Prediction - Quick Start"
echo "=========================================="
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 tidak terinstall"
    exit 1
fi

echo "✅ Python terdeteksi: $(python3 --version)"
echo ""

# Check pip
if ! command -v pip &> /dev/null; then
    echo "❌ pip tidak terinstall"
    exit 1
fi

echo "✅ pip terdeteksi"
echo ""

# Create virtual environment if it doesn't exist
VENV_DIR="backend_env"
echo "📦 Setting up virtual environment..."
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv $VENV_DIR
    echo "✅ Virtual environment created di $VENV_DIR"
else
    echo "ℹ️  Virtual environment already exists di $VENV_DIR"
fi

# Activate virtual environment
source $VENV_DIR/bin/activate
echo "✅ Virtual environment activated"

# Upgrade pip
echo "📦 Upgrading pip..."
pip install --upgrade pip > /dev/null 2>&1

# Install dependencies
echo "📦 Installing dependencies..."
pip install -r requirements.txt

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    deactivate
    exit 1
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "📚 Available Commands:"
echo ""
echo "1. Activate environment:"
echo "   source $VENV_DIR/bin/activate"
echo ""
echo "2. Train model GGRM:"
echo "   python train_model.py"
echo ""
echo "3. Validate model:"
echo "   python validate_ggrm_model.py"
echo ""
echo "4. Retrain dengan data terbaru:"
echo "   python retrain_ggrm.py"
echo ""
echo "5. Run API Server:"
echo "   uvicorn backend_api:app --reload"
echo ""
echo "6. Check model status:"
echo "   curl http://localhost:8000/status"
echo ""
echo "📖 Documentation: README_GGRM.md"
echo ""
echo "=========================================="
