#!/bin/bash
# Docker setup - Build & Run Backend

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Building Docker Image"
echo "=========================================="
echo ""

# 1. Check Dockerfile exists
if [ ! -f "$PROJECT_DIR/Dockerfile" ]; then
    echo "❌ Dockerfile not found!"
    exit 1
fi

# 2. Build image
echo "Building Docker image: ggrm-predictor..."
docker build -t ggrm-predictor:latest \
  --build-arg FIREBASE_CREDENTIALS_PATH=/run/secrets/firebase-creds.json \
  "$PROJECT_DIR"

echo ""
echo "✅ Image built successfully!"
echo ""
echo "=========================================="
echo "Running Container"
echo "=========================================="
echo ""

# 3. Create secrets directory (optional)
SECRETS_DIR="/tmp/ggrm-secrets"
mkdir -p "$SECRETS_DIR"

# 4. Check Firebase credentials
FIREBASE_CRED="$PROJECT_DIR/Secret/stock-prediction-realtime-firebase-adminsdk-fbsvc-6d0f85bf5b.json"
if [ -f "$FIREBASE_CRED" ]; then
    cp "$FIREBASE_CRED" "$SECRETS_DIR/firebase-creds.json"
    echo "✓ Firebase credentials copied"
else
    echo "⚠ Firebase credentials not found - running without Firebase"
fi

# 5. Run container
echo ""
echo "Starting container..."
docker run \
  --name ggrm-predictor \
  -p 8000:8000 \
  -e FIREBASE_CREDENTIALS=/run/secrets/firebase-creds.json \
  -v "$SECRETS_DIR:/run/secrets:ro" \
  -it \
  ggrm-predictor:latest

echo ""
echo "✅ Container running on http://localhost:8000"
echo "📚 API Docs: http://localhost:8000/docs"
