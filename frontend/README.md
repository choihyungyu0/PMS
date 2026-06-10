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

Edit:

```text
lib/core/api/api_config.dart
```

The app selects a local backend URL automatically:

- Android emulator: `http://10.0.2.2:8000`
- iOS simulator, desktop, and web: `http://127.0.0.1:8000`

For iOS simulator, desktop, and web local development:

```dart
return localhostBaseUrl; // http://127.0.0.1:8000
```

For Android emulator:

```dart
return androidEmulatorBaseUrl; // http://10.0.2.2:8000
```

Android debug builds allow local cleartext HTTP for MVP development. Do not use this setting as-is for production.

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
