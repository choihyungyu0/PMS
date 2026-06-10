# MORE Cycle Backend

FastAPI backend for the MORE Cycle MVP. It provides demo JWT auth, user-scoped health records, rule-based PMS risk scoring, Korean health reports, and CSV-backed Incheon medical institution search.

## Setup

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Windows PowerShell:

```powershell
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

## Dataset

Place the provided public-data CSV at:

```text
backend/data/mc_incheon_medical.csv
```

Only this CSV should be used for institution guidance. The backend does not call external map, hospital, reservation, operating-hour, geocoding, or medical APIs.

Expected CSV columns:

```text
institution_name,institution_type,department,service_category,address,sigungu,phone,latitude,longitude,location_status,geocode_query,matched_address
```

`location_status`, `geocode_query`, and `matched_address` are treated as internal/debug data and are not exposed in public institution responses.

## Seed CSV

```bash
python -m app.db.seed_medical
```

If `backend/data/mc_incheon_medical.csv` is missing, the seed command exits with a clear developer error and inserts no fake records.

## Run

```bash
uvicorn app.main:app --reload
```

API docs:

```text
http://127.0.0.1:8000/docs
```

## Test

```bash
pytest
```

## Main APIs

- `GET /api/health`
- `POST /api/auth/signup`
- `POST /api/auth/login`
- `GET /api/users/me`
- `GET /api/cycles`
- `POST /api/cycles`
- `GET /api/cycles/latest`
- `GET /api/emotions`
- `POST /api/emotions`
- `GET /api/sleep`
- `POST /api/sleep`
- `GET /api/pain`
- `POST /api/pain`
- `GET /api/reports/latest`
- `POST /api/reports/generate`
- `GET /api/reports/history`
- `GET /api/institutions`
- `GET /api/institutions/search`
- `GET /api/institutions/recommend`
- `GET /api/institutions/categories`

## Medical Safety

이 서비스는 진단이나 치료를 제공하지 않습니다. 사용자가 입력한 기록과 공공데이터 기반 의료기관 정보를 바탕으로 건강 관리 참고 정보를 제공합니다.

The PMS score is deterministic and rule-based. It is not a diagnosis, treatment, medication recommendation, or clinical quality ranking.

## Dataset Limitations

The CSV does not include real-time operating hours, holiday closure, reservation availability, clinical quality rankings, or doctor-level data. Institution responses include this notice:

```text
운영시간과 진료 가능 여부는 데이터에 포함되어 있지 않으므로 방문 전 반드시 전화로 확인해주세요.
```
