# Stock Vision - Installation Guide

## ✅ APK Status: FIXED & READY TO INSTALL

The APK has been fixed to properly launch on Android devices.

### What Was Fixed

**Problem:** APK would not launch after installation
**Root Cause:** 
- Incorrect package name configuration
- Missing Firebase configuration updates
- App name mismatch

**Solutions Applied:**
- ✅ Changed app name from "ggrm_stock_app" to "Stock Vision"
- ✅ Updated package name to "com.stockvision.app"
- ✅ Updated google-services.json with correct package name
- ✅ Corrected MainActivity package structure
- ✅ Updated AndroidManifest.xml

---

## 📱 Installation Instructions

### Method 1: Via Android Phone (Recommended)

1. **Download the APK**
   - Transfer `Stock_Vision_Final.apk` to your Android device
   - Or: Use `adb` to transfer the file

2. **Enable Unknown Sources**
   - Settings → Security → Unknown Sources → Enable
   - (Or: Settings → Apps & notifications → Special app access → Install unknown apps)

3. **Install APK**
   - Open file manager on phone
   - Find and tap `Stock_Vision_Final.apk`
   - Tap "Install"
   - Wait for installation to complete

4. **Launch App**
   - Find "Stock Vision" in App Drawer
   - Tap to launch
   - App should open without errors

### Method 2: Via ADB (Android Debug Bridge)

```bash
# Prerequisites: Android device connected via USB with ADB enabled

adb install Stock_Vision_Final.apk

# Or for force installation over existing:
adb install -r Stock_Vision_Final.apk
```

### Method 3: Via USB Transfer + Phone Installation

```bash
# On computer:
adb push Stock_Vision_Final.apk /sdcard/Download/

# On phone:
# Open Files → Download → Stock_Vision_Final.apk → Install
```

---

## 🔍 Verification Steps

After installation, verify everything works:

1. **App Launches**
   - Tap "Stock Vision" icon
   - App opens without crashing
   - Loading screen appears

2. **Login Screen**
   - Email/Password fields visible
   - "Sign Up" and "Login" buttons functional
   - Google Sign-In button present

3. **Firebase Authentication**
   - Can sign up with email
   - Can login with credentials
   - Proper error messages display

4. **Main App Features**
   - Stock predictions display
   - Dark/Light mode toggle works
   - Settings accessible
   - Refresh functionality working

---

## 🐛 Troubleshooting

### APK Installation Fails

**Error: "App not installed"**
- Solution: Enable "Unknown Sources" in settings
- Solution: Try `adb install -r` to force reinstall

**Error: "Parse error"**
- Solution: APK file may be corrupted
- Solution: Download APK again from GitHub

### App Crashes on Launch

**Error: "Stock Vision has stopped"**
- Solution: Clear app data: Settings → Apps → Stock Vision → Clear Data
- Solution: Reinstall app

**Error: "Firebase Error"**
- Solution: Check internet connection
- Solution: Clear app cache

### Firebase Authentication Issues

**Error: "Firebase initialization failed"**
- Verify google-services.json is correctly configured
- Check Firebase project settings
- Verify package name matches: `com.stockvision.app`

### Performance Issues

**App runs slowly**
- Clear app cache: Settings → Apps → Stock Vision → Storage → Clear Cache
- Close other apps
- Restart device

---

## 📋 System Requirements

- **Android Version:** 5.0 (API 21) and above
- **RAM:** Minimum 2 GB (recommended 4 GB+)
- **Storage:** 100 MB free space
- **Internet:** Required for stock data and authentication

---

## 📊 APK Details

| Property | Value |
|----------|-------|
| File Name | Stock_Vision_Final.apk |
| File Size | 23 MB |
| Package Name | com.stockvision.app |
| App Name | Stock Vision |
| Min SDK | 21 (Android 5.0) |
| Target SDK | 34 (Android 14) |
| Architectures | ARMv7, ARM64, x86_64 |

---

## 🔗 Download Links

- **GitHub Repository:** https://github.com/barriqkay/APK_StockVision_Finale
- **Latest APK:** Stock_Vision_Final.apk (in project root)

---

## ✨ Features Included

✅ AI-powered stock price predictions (7-day forecast)
✅ Dark/Light theme support with toggle
✅ Firebase authentication (sign up/login)
✅ Real-time stock data from Yahoo Finance
✅ LSTM neural network predictions
✅ User profile and settings
✅ History tracking
✅ Material Design UI

---

## 🆘 Getting Help

If you encounter issues:

1. Check the troubleshooting section above
2. Clear app data and cache
3. Reinstall the APK
4. Check GitHub issues: https://github.com/barriqkay/APK_StockVision_Finale/issues
5. Verify Android version is 5.0 or higher

---

## ℹ️ Important Notes

- This is a Release APK (optimized for production)
- The app requires internet connection for stock data
- Firebase credentials are embedded in the APK
- Do not share APK with custom Firebase project credentials

---

**Installation Status:** ✅ Ready for All Devices
**Last Updated:** January 17, 2026
**APK Version:** 2.0.0
