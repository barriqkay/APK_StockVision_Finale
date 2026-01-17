#!/bin/bash
# Train & Validate Model Script

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "GGRM ML Model Training & Validation"
echo "=========================================="
echo ""

# 1. Verify venv exists
if [ ! -d "$PROJECT_DIR/backend_env" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$PROJECT_DIR/backend_env"
fi

# 2. Activate venv
echo "Activating virtual environment..."
source "$PROJECT_DIR/backend_env/bin/activate"

# 3. Install/upgrade dependencies
echo ""
echo "Installing dependencies..."
pip install -q --upgrade pip
pip install -q \
    tensorflow>=2.13 \
    numpy>=1.25 \
    pandas>=2.0 \
    scikit-learn>=1.3 \
    yfinance>=0.2 \
    joblib>=1.3 \
    matplotlib>=3.8

echo "✓ Dependencies installed"

# 4. Train model
echo ""
echo "=========================================="
echo "Training Model"
echo "=========================================="
echo ""

cd "$PROJECT_DIR"
python train_model.py

# 5. Check if model was created
if [ -f "$PROJECT_DIR/stock_model.keras" ] && [ -f "$PROJECT_DIR/scaler_ggrm.pkl" ]; then
    echo ""
    echo "✅ Model and scaler successfully created!"
    ls -lh stock_model.keras scaler_ggrm.pkl
else
    echo ""
    echo "❌ Model training failed!"
    exit 1
fi

# 6. Validate model
echo ""
echo "=========================================="
echo "Validating Model"
echo "=========================================="
echo ""

python validate_ggrm_model.py

# 7. Check test results
if [ -f "$PROJECT_DIR/test_results.json" ]; then
    echo ""
    echo "✅ Validation completed!"
    echo ""
    echo "Test Results:"
    python -m json.tool < test_results.json | head -30
else
    echo "⚠ No validation results found"
fi

echo ""
echo "=========================================="
echo "✅ Training & Validation Complete!"
echo "=========================================="
