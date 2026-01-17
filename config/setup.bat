@echo off
REM Quick Setup Script untuk GGRM Stock Prediction - Windows

echo ==========================================
echo GGRM Stock Prediction - Windows Setup
echo ==========================================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python tidak terinstall atau tidak di PATH
    echo Silakan download dari: https://www.python.org/downloads/
    pause
    exit /b 1
)

echo ✅ Python terdeteksi:
python --version
echo.

REM Check pip
pip --version >nul 2>&1
if errorlevel 1 (
    echo ❌ pip tidak terinstall
    exit /b 1
)

echo ✅ pip terdeteksi
echo.

REM Install dependencies
echo 📦 Installing dependencies...
pip install -r requirements.txt

if errorlevel 1 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo ✅ Dependencies installed successfully
echo.

echo ==========================================
echo Setup Complete!
echo ==========================================
echo.
echo 📚 Available Commands:
echo.
echo 1. Train model GGRM:
echo    python train_model.py
echo.
echo 2. Validate model:
echo    python validate_ggrm_model.py
echo.
echo 3. Retrain dengan data terbaru:
echo    python retrain_ggrm.py
echo.
echo 4. Daily prediction:
echo    python daily_prediction.py
echo.
echo 5. Run API Server:
echo    uvicorn backend_api:app --reload
echo.
echo 6. Check model status:
echo    curl http://localhost:8000/status
echo.
echo 📖 Documentation: README_GGRM.md
echo.
echo ==========================================
pause
