#!/bin/bash
# Build APK Script

export PATH="$PATH:/opt/flutter/bin:$HOME/flutter/bin"
cd /home/berkuiii/Documents/stock-predict-backend-main/ggrm_stock_app

echo "Building APK..."
flutter build apk > build_output.txt 2>&1

if [ $? -eq 0 ]; then
    echo "Build SUCCESS!"
    cat build_output.txt
else
    echo "Build FAILED!"
    cat build_output.txt
fi

