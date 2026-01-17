GGRM Mobile (Expo)

This is a minimal Expo React Native app that calls the backend API `backend_api` provided in the project.

Run (after installing `expo-cli`):

```bash
cd mobile_app
npm install
expo start
```

Configuration:
- Edit `mobile_app/App.js` and set `BASE_URL` to your backend URL.
  - On your development machine for Android emulator (AVD): `http://10.0.2.2:8000`
  - On iOS simulator: `http://localhost:8000`
  - On a physical device using Expo Go: use your machine LAN IP, e.g. `http://192.168.1.10:8000`

Notes:
- Start the backend API first: `uvicorn backend_api:app --host 0.0.0.0 --port 8000`
- The app provides two features: fetch latest price and predict next close with 9 inputs.

Next steps I can help with:
- Add navigation & better UI
- Build APK / AAB (Android) or IPA (iOS)
- Integrate authentication
- Ship to Play Store / App Store
