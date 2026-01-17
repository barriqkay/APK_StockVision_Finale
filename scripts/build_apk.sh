#!/bin/bash
# Build Flutter APK - Android App

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Building Flutter Android APK"
echo "=========================================="
echo ""

# 1. Check Flutter installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found!"
    echo ""
    echo "Install Flutter from: https://flutter.dev/docs/get-started/install"
    echo ""
    echo "Quick install (Linux/Mac):"
    echo "  git clone https://github.com/flutter/flutter.git -b stable"
    echo "  export PATH=\"\$PATH:\$(pwd)/flutter/bin\""
    exit 1
fi

echo "✓ Flutter found: $(flutter --version | head -1)"

# 2. Change to project directory
cd "$PROJECT_DIR"

# 3. Check pubspec.yaml exists
if [ ! -f "$PROJECT_DIR/pubspec.yaml" ]; then
    echo "❌ pubspec.yaml not found!"
    exit 1
fi

# 4. Get dependencies
echo ""
echo "Getting Flutter dependencies..."
flutter pub get

# 5. Build APK (debug)
echo ""
echo "=========================================="
echo "Building APK (Debug)"
echo "=========================================="
echo ""

flutter build apk

APK_DEBUG="$PROJECT_DIR/build/app/outputs/apk/debug/app-debug.apk"
if [ -f "$APK_DEBUG" ]; then
    echo ""
    echo "✅ Debug APK built successfully!"
    echo "📦 Location: $APK_DEBUG"
    ls -lh "$APK_DEBUG"
else
    echo "❌ Failed to build debug APK"
    exit 1
fi

# 6. Build APK (release) - requires signing
echo ""
echo "=========================================="
echo "Building APK (Release)"
echo "=========================================="
echo ""

# Check if keystore exists
KEYSTORE_PATH="$PROJECT_DIR/android/app/keystore.jks"
if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "⚠ Keystore not found. Generating new keystore..."
    echo ""
    echo "You'll be asked to create a password and enter keystore details:"
    echo ""
    
    keytool -genkey -v -keystore "$KEYSTORE_PATH" \
      -keyalg RSA -keysize 2048 -validity 10000 \
      -alias ggrm-key -storepass ggrm2024 -keypass ggrm2024 \
      -dname "CN=GGRM Stock Prediction,O=Berkuiii,L=Indonesia,C=ID"
    
    echo ""
    echo "✓ Keystore created at: $KEYSTORE_PATH"
fi

# Build release APK
flutter build apk --release

APK_RELEASE="$PROJECT_DIR/build/app/outputs/apk/release/app-release.apk"
if [ -f "$APK_RELEASE" ]; then
    echo ""
    echo "✅ Release APK built successfully!"
    echo "📦 Location: $APK_RELEASE"
    ls -lh "$APK_RELEASE"
else
    echo "❌ Failed to build release APK"
    exit 1
fi

# 7. Summary
echo ""
echo "=========================================="
echo "✅ APK Build Complete!"
echo "=========================================="
echo ""
echo "APKs created:"
echo "  Debug:   $APK_DEBUG"
echo "  Release: $APK_RELEASE"
echo ""
echo "Next steps:"
echo "  1. Install on device:"
echo "     adb install -r $APK_DEBUG"
echo ""
echo "  2. Or distribute release APK to users"
echo ""
echo "  3. For Play Store: Upload $APK_RELEASE"
