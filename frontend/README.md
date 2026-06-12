# MORE Cycle Flutter Frontend

Flutter MVP frontend for MORE Cycle. The app connects to the local FastAPI backend and provides Korean mobile screens for signup, login, health records, PMS report viewing, and CSV-backed Incheon medical institution guidance.

## Backend First

Run the backend before starting Flutter:

```powershell
cd backend
python -m app.db.seed_medical
python -m uvicorn app.main:app --reload
```

API docs:

```text
http://127.0.0.1:8000/docs
```

## Flutter Setup

```powershell
cd frontend
flutter pub get
flutter run
```

## Base URL Configuration

APK builds can inject a backend URL without editing source code:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=http://YOUR_PC_IP:8000
```

The helper script detects a local IPv4 address and builds the APK:

```powershell
.\scripts\build-release-apk.ps1
```

If the detected IP is not the one your phone can reach, pass it manually:

```powershell
.\scripts\build-release-apk.ps1 -BackendHost 192.168.0.12
```

Output APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

For normal development, edit:

```text
lib/core/api/api_config.dart
```

The app selects a local backend URL automatically:

- Android emulator: `http://10.0.2.2:8000`
- iOS simulator, desktop, and web: `http://127.0.0.1:8000`

Physical Android phones must use the PC's LAN IP address, not `127.0.0.1` or `10.0.2.2`.

For iOS simulator, desktop, and web local development:

```dart
return localhostBaseUrl; // http://127.0.0.1:8000
```

For Android emulator:

```dart
return androidEmulatorBaseUrl; // http://10.0.2.2:8000
```

Android debug builds allow local cleartext HTTP for MVP development. Do not use this setting as-is for production.

## Direct APK Distribution

This project is configured for direct APK sharing, not Play Store release:

- Android package ID: `kr.morecycle.app`
- Launcher label: `MORE Cycle`
- Local HTTP is allowed for the FastAPI demo backend.
- Release APKs are signed with a local keystore stored under `android/app/more-cycle-release.jks`.
- Signing files are ignored by Git through `android/.gitignore`.

Keep `android/key.properties` and `android/app/more-cycle-release.jks` backed up locally. Android treats a differently signed APK as a different update path, so losing the keystore means users may need to uninstall before installing a future APK.

## Public Tester APK

For testers outside your current Wi-Fi network, build an APK with a temporary Cloudflare Tunnel URL:

```powershell
cd frontend
.\scripts\build-public-release-apk.ps1
```

The script:

- starts the local FastAPI backend on `127.0.0.1:8000` if needed,
- downloads `cloudflared.exe` into the repo-local `.tools` folder if needed,
- opens a temporary `https://*.trycloudflare.com` tunnel,
- builds `build/app/outputs/flutter-apk/app-release.apk` with that public URL.

Keep the PC, backend process, and tunnel process running while external testers use the APK. To stop the public backend/tunnel:

```powershell
cd frontend
.\scripts\stop-public-backend.ps1
```

The temporary tunnel URL can change after stopping or restarting the tunnel. If it changes, rebuild and resend the APK.

## Analyze And Test

```powershell
cd frontend
flutter analyze
flutter test
```

## Demo Flow

1. Start backend.
2. Seed CSV if needed.
3. Run Flutter app.
4. Sign up.
5. Log in.
6. Add menstrual cycle record.
7. Add emotion record.
8. Add sleep record.
9. Add pain record.
10. Generate health report.
11. Confirm PMS score and health score appear.
12. Confirm medical disclaimer appears.
13. Open hospital tab.
14. Confirm institutions load from backend API.
15. Confirm availability notice appears.
16. Log out.

## Known Limitations

- No map, geolocation, reservation, push notification, OAuth, payment, Apple Watch, or external AI integration.
- Institution cards only show CSV-backed backend responses.
- Phone numbers are displayed only; no phone call plugin is used.
- This service provides wellness insights and public-data-based institution information only. It does not provide diagnosis or treatment.
