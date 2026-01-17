#!/bin/bash
# Script untuk menjalankan backend stock prediction

cd /home/berkuiii/Documents/stock-predict-backend-main

echo "Starting backend server..."

# Jalankan uvicorn
.venv/bin/uvicorn backend_api:app --host 0.0.0.0 --port 8000 &

BACKEND_PID=$!

echo "Backend started with PID: $BACKEND_PID"
echo "Waiting for server to start..."
sleep 5

# Test endpoint
echo "Testing /status endpoint..."
curl -s http://localhost:8000/status

echo ""
echo "Testing /latest/GGRM.JK endpoint..."
curl -s http://localhost:8000/latest/GGRM.JK

echo ""
echo "Backend is running at http://localhost:8000"
echo "Press Ctrl+C to stop"

# Keep running
wait $BACKEND_PID

