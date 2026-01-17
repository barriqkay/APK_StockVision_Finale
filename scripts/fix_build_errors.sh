#!/bin/bash

# Fix build errors script
echo "=== Fixing Flutter Build Errors ==="
echo ""

# Fix 1: Update NDK version in android/app/build.gradle
echo "1. Fixing NDK version..."
APP_BUILD_GRADLE="/home/berkuiii/Documents/stock-predict-backend-main/ggrm_stock_app/android/app/build.gradle"

# Check if file exists and update
if [ -f "$APP_BUILD_GRADLE" ]; then
    # Add ndkVersion after android { line
    sed -i '/^[[:space:]]*android {/a\        ndkVersion = "25.1.8937393"' "$APP_BUILD_GRADLE"
    echo "   ✓ NDK version added"
else
    echo "   ✗ build.gradle not found"
fi

# Fix 2: Fix app_widgets.dart - BoxShadow type error
echo "2. Fixing BoxShadow type error in app_widgets.dart..."
WIDGETS_FILE="/home/berkuiii/Documents/stock-predict-backend-main/ggrm_stock_app/lib/widgets/app_widgets.dart"

if [ -f "$WIDGETS_FILE" ]; then
    # Replace boxShadow: AppShadows.small[0] with boxShadow: AppShadows.small
    sed -i 's/boxShadow: AppShadows\.small\[0\]/boxShadow: AppShadows.small/g' "$WIDGETS_FILE"
    echo "   ✓ BoxShadow fixed"
else
    echo "   ✗ app_widgets.dart not found"
fi

# Fix 3: Fix profile_screen.dart - IconColor type error
echo "3. Fixing IconColor type error in profile_screen.dart..."
PROFILE_FILE="/home/berkuiii/Documents/stock-predict-backend-main/ggrm_stock_app/lib/screens/profile_screen.dart"

if [ -f "$PROFILE_FILE" ]; then
    # Replace leading: Icon(iconColor ?? AppColors.textSecondary with leading: Icon(icon, color: iconColor ?? AppColors.textSecondary
    sed -i 's/leading: Icon(iconColor ?? AppColors\.textSecondary, size: 24)/leading: Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 24)/g' "$PROFILE_FILE"
    echo "   ✓ IconColor fixed"
else
    echo "   ✗ profile_screen.dart not found"
fi

echo ""
echo "=== Fix Complete ==="
echo ""
echo "Now run:"
echo "cd /home/berkuiii/Documents/stock-predict-backend-main/ggrm_stock_app"
echo "flutter clean && flutter pub get && flutter build apk --release"

