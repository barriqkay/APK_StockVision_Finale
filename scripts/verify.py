#!/usr/bin/env python3
"""
Verification script untuk memastikan GGRM model setup lengkap
"""

import sys
import os
from pathlib import Path
import importlib.util

def check_python_version():
    """Check Python version"""
    print("\n📌 Python Version Check")
    print("-" * 60)
    
    version = sys.version_info
    print(f"Python {version.major}.{version.minor}.{version.micro}")
    
    if version.major >= 3 and version.minor >= 8:
        print("✅ Version OK (3.8+)")
        return True
    else:
        print("❌ Python 3.8+ required")
        return False

def check_dependencies():
    """Check if required packages are installed"""
    print("\n📦 Dependencies Check")
    print("-" * 60)
    
    required_packages = {
        'tensorflow': 'TensorFlow',
        'numpy': 'NumPy',
        'pandas': 'Pandas',
        'sklearn': 'Scikit-learn',
        'yfinance': 'YFinance',
        'joblib': 'Joblib',
        'fastapi': 'FastAPI',
        'uvicorn': 'Uvicorn'
    }
    
    all_installed = True
    for package, name in required_packages.items():
        try:
            spec = importlib.util.find_spec(package)
            if spec is not None:
                print(f"✅ {name}")
            else:
                print(f"❌ {name} NOT FOUND")
                all_installed = False
        except ImportError:
            print(f"❌ {name} NOT FOUND")
            all_installed = False
    
    return all_installed

def check_files():
    """Check if important files exist"""
    print("\n📁 Files Check")
    print("-" * 60)
    
    required_files = {
        'train_model.py': 'Training script',
        'backend_api.py': 'API server',
        'requirements.txt': 'Dependencies',
        'retrain_ggrm.py': 'Retrain script',
        'daily_prediction.py': 'Daily prediction',
        'validate_ggrm_model.py': 'Validation script',
        'monitor.py': 'Monitor script',
    }
    
    optional_files = {
        'stock_model.keras': 'Trained model',
        'scaler_ggrm.pkl': 'Feature scaler',
        'model_metadata.json': 'Model metadata',
    }
    
    print("Required files:")
    required_ok = True
    for filename, description in required_files.items():
        exists = Path(filename).exists()
        status = "✅" if exists else "❌"
        print(f"{status} {filename} ({description})")
        if not exists:
            required_ok = False
    
    print("\nOptional files (for inference):")
    optional_ok = True
    for filename, description in optional_files.items():
        exists = Path(filename).exists()
        status = "✅" if exists else "⚠️ "
        print(f"{status} {filename} ({description})")
        if not exists:
            optional_ok = False
    
    return required_ok, optional_ok

def check_ggrm_data():
    """Test GGRM data fetching"""
    print("\n🔗 GGRM Data Check")
    print("-" * 60)
    
    try:
        import yfinance as yf
        print("Fetching GGRM.JK data (1 day)...")
        
        df = yf.download('GGRM.JK', period='1d', interval='1d', progress=False)
        
        if df.empty:
            print("❌ No data returned from Yahoo Finance")
            print("   Check internet connection or Yahoo Finance availability")
            return False
        else:
            latest = df.iloc[-1]
            print(f"✅ Data fetched successfully")
            print(f"   Latest Close: Rp {latest['Close']:,.0f}")
            return True
            
    except Exception as e:
        print(f"❌ Error fetching data: {e}")
        return False

def check_api():
    """Test API startup"""
    print("\n🌐 API Check")
    print("-" * 60)
    
    try:
        from backend_api import app
        print("✅ API can be imported")
        
        # Check if FastAPI
        if hasattr(app, 'routes'):
            print(f"✅ {len(app.routes)} routes defined")
            return True
        else:
            print("⚠️ Could not verify routes")
            return False
            
    except Exception as e:
        print(f"❌ Error importing API: {e}")
        return False

def check_model_files():
    """Check if model files are valid"""
    print("\n🧠 Model Files Check")
    print("-" * 60)
    
    model_ok = False
    scaler_ok = False
    
    # Check model
    if Path('stock_model.keras').exists():
        try:
            import tensorflow as tf
            model = tf.keras.models.load_model('stock_model.keras', compile=False)
            print(f"✅ Model loaded successfully")
            print(f"   Input shape: {model.input_shape}")
            print(f"   Output shape: {model.output_shape}")
            model_ok = True
        except Exception as e:
            print(f"❌ Error loading model: {e}")
    else:
        print("⚠️ Model file not found (need to train first)")
    
    # Check scaler
    if Path('scaler_ggrm.pkl').exists():
        try:
            import joblib
            scaler = joblib.load('scaler_ggrm.pkl')
            print(f"✅ Scaler loaded successfully")
            print(f"   Features: {scaler.n_features_in_}")
            scaler_ok = True
        except Exception as e:
            print(f"❌ Error loading scaler: {e}")
    else:
        print("⚠️ Scaler file not found (need to train first)")
    
    return model_ok, scaler_ok

def generate_report(results):
    """Generate final report"""
    print("\n" + "=" * 60)
    print("VERIFICATION REPORT")
    print("=" * 60)
    
    python_ok, deps_ok, req_ok, opt_ok, data_ok, api_ok, model_ok, scaler_ok = results
    
    total_checks = 8
    passed = sum([python_ok, deps_ok, req_ok, api_ok, data_ok])
    optional_passed = sum([opt_ok, model_ok, scaler_ok])
    
    print(f"\n✅ Passed: {passed}/{total_checks} critical checks")
    
    if opt_ok:
        print(f"✅ Optional: Model files available")
    else:
        print(f"ℹ️  Optional: Model files not yet trained")
    
    # Status determination
    if python_ok and deps_ok and req_ok and api_ok and data_ok:
        print("\n🟢 STATUS: READY TO START")
        print("\nNext steps:")
        print("1. python train_model.py          (train the model)")
        print("2. python validate_ggrm_model.py  (validate)")
        print("3. uvicorn backend_api:app --reload (run API)")
        return 0
    else:
        print("\n🔴 STATUS: SETUP INCOMPLETE")
        print("\nIssues to fix:")
        if not python_ok:
            print("• Python 3.8+ required")
        if not deps_ok:
            print("• Install dependencies: pip install -r requirements.txt")
        if not req_ok:
            print("• Some required files missing")
        if not api_ok:
            print("• API cannot be imported - check backend_api.py")
        if not data_ok:
            print("• Cannot fetch GGRM data - check internet connection")
        return 1

def main():
    print("╔════════════════════════════════════════════════════════════╗")
    print("║         GGRM STOCK PREDICTION - VERIFICATION SCRIPT        ║")
    print("╚════════════════════════════════════════════════════════════╝")
    
    # Get tuple returns properly
    req_ok, opt_ok = check_files()
    model_ok, scaler_ok = check_model_files()
    
    results = [
        check_python_version(),
        check_dependencies(),
        req_ok,
        opt_ok,
        check_ggrm_data(),
        check_api(),
        model_ok,
        scaler_ok,
    ]
    
    exit_code = generate_report(results)
    
    print("\n" + "=" * 60)
    return exit_code

if __name__ == "__main__":
    sys.exit(main())

