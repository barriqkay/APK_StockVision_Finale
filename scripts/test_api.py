#!/usr/bin/env python3
"""
Test script untuk cek API stock prediction
Jalankan: python test_api.py
"""

import sys
sys.path.insert(0, '/home/berkuiii/Documents/stock-predict-backend-main')

from backend_api import app
import requests
import time

def test_api():
    print("=" * 50)
    print("TESTING STOCK PREDICTION API")
    print("=" * 50)
    
    base_url = "http://127.0.0.1:8000"
    
    # Test 1: Status endpoint
    print("\n[1] Testing /status endpoint...")
    try:
        response = requests.get(f"{base_url}/status", timeout=5)
        print(f"    Status Code: {response.status_code}")
        print(f"    Response: {response.json()}")
    except Exception as e:
        print(f"    ERROR: {e}")
    
    # Test 2: Latest data endpoint
    print("\n[2] Testing /latest/GGRM.JK endpoint...")
    try:
        response = requests.get(f"{base_url}/latest/GGRM.JK", timeout=10)
        print(f"    Status Code: {response.status_code}")
        data = response.json()
        print(f"    Date: {data.get('date')}")
        print(f"    OHLCV: {data.get('ohlcv')}")
        print(f"    Technical Features: {data.get('technical_features')}")
    except Exception as e:
        print(f"    ERROR: {e}")
    
    # Test 3: History endpoint
    print("\n[3] Testing /history/GGRM.JK endpoint...")
    try:
        response = requests.get(f"{base_url}/history/GGRM.JK?period=1mo", timeout=15)
        print(f"    Status Code: {response.status_code}")
        data = response.json()
        print(f"    Data Points: {data.get('data_points')}")
        if 'history' in data and len(data['history']) > 0:
            print(f"    Latest: {data['history'][-1]}")
    except Exception as e:
        print(f"    ERROR: {e}")
    
    print("\n" + "=" * 50)
    print("TEST COMPLETED")
    print("=" * 50)

if __name__ == "__main__":
    test_api()

