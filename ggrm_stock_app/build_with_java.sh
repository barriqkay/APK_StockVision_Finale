#!/bin/bash
# Script untuk build Flutter APK dengan JAVA_HOME yang benar

# Set JAVA_HOME ke Android Studio JBR
export JAVA_HOME=/home/berkuiii/android-studio/jbr
export PATH=$JAVA_HOME/bin:$PATH

# Set Flutter path
export FLUTTER_HOME=/home/berkuiii/flutter
export PATH=$FLUTTER_HOME/bin:$PATH

echo "JAVA_HOME: $JAVA_HOME"
echo "FLUTTER_HOME: $FLUTTER_HOME"
echo "Java version:"
java -version

# Pindah ke direktori app
cd /home/berkuiii/Documents/stock-predict-backend-main/ggrm_stock_app

echo "Running flutter clean..."
$FLUTTER_HOME/bin/flutter clean

echo "Running flutter pub get..."
$FLUTTER_HOME/bin/flutter pub get

echo "Building APK..."
$FLUTTER_HOME/bin/flutter build apk --debug

echo "Build selesai!"

