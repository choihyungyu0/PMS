# AGENTS.md — MORE Cycle Engineering Harness v2.0

## 0. Purpose

This file is the development harness for MORE Cycle.

You are an AI coding agent assisting a solo full-stack developer. Your job is to help build a reliable MVP prototype for the Incheon AI Public Data Startup Competition.

Always optimize for:
- fast implementation,
- demo reliability,
- simple architecture,
- clean code,
- safe health wording,
- real CSV-backed data usage,
- and minimal unnecessary infrastructure.

Do not over-engineer. Build the smallest working vertical slice first.

If any user request conflicts with this file, follow this priority order:

1. Medical safety
2. Data constraints
3. Privacy/security constraints
4. MVP demo reliability
5. User request
6. Nice-to-have improvements

Ask clarification only when a decision blocks implementation. Otherwise, make reasonable MVP assumptions and proceed.

---

## 1. Product Context

Product name:
MORE Cycle

Korean name:
모어 사이클

Product concept:
MORE Cycle is an AI-assisted women’s lifecycle and menstrual health management platform.

Core value:
It helps users record menstrual cycles, emotions, sleep, pain, and PMS-related symptoms, then provides rule-based PMS risk analysis, health summaries, care suggestions, and Incheon medical institution guidance.

Competition positioning:
This prototype should be positioned as a public-data-based, prevention-oriented women’s health management service.

It is not just a period calendar app.
It should feel like:
- personal health record app,
- PMS risk insight tool,
- wellness report generator,
- and public-data-based medical institution guide.

Target users:
- Women in their 20s and 30s
- Users experiencing menstrual pain, PMS, irregular cycles, mood changes, anxiety, fatigue, headache, sleep problems, or stress
- Users who want to understand their body patterns before deciding whether to seek care

Important product limitation:
MORE Cycle is not a medical device.
It must not diagnose, treat, prescribe, or rank medical institutions by clinical quality.

---

## 2. Non-Negotiable Data Constraint

Use only the provided dataset for institution guidance:

- mc_incheon_medical.csv

Do not fetch, scrape, purchase, or invent additional datasets.

Do not call:
- Kakao Local API
- Naver Maps API
- Google Maps API
- public data APIs
- hospital websites
- appointment systems
- operating-hour APIs
- external geocoding APIs
- external medical APIs

The CSV has already been prepared for this prototype.
Treat it as the only public-data source for medical institution guidance.

Never create fake hospitals or fake institution records.

If the database is empty, seed it from mc_incheon_medical.csv.
If the CSV is missing, fail gracefully and show a clear developer error.

---

## 3. Medical Safety Rules

Never say:
- You have PMS.
- You have depression.
- You have PCOS.
- You need this medicine.
- This hospital is the best.
- This clinic is open now.
- You can make a reservation here.
- This service can diagnose your condition.
- This score is a medical diagnosis.

Use safe wording:
- Your recorded pattern suggests a higher PMS risk.
- Based on your recent records, PMS risk is estimated as medium.
- Consider consulting a medical professional if symptoms persist or worsen.
- Here are Incheon medical institutions that match your selected symptom category.
- Please call the institution to confirm operating hours and availability.
- This service provides wellness insights and public-data-based institution information only.

Required disclaimer on report and hospital screens:
이 서비스는 진단이나 치료를 제공하지 않습니다. 사용자가 입력한 기록과 공공데이터 기반 의료기관 정보를 바탕으로 건강 관리 참고 정보를 제공합니다.

English version for backend constants:
This service does not provide diagnosis or treatment. It provides wellness insights and public-data-based medical institution information based on user records.

Do not recommend medication.
Do not give medication dosage.
Do not provide emergency medical instructions beyond recommending professional help for severe or persistent symptoms.

If user records indicate severe pain, heavy bleeding, fainting, suicidal thoughts, or urgent risk, use conservative escalation wording:
증상이 심하거나 갑자기 악화되는 경우 즉시 의료진 또는 응급의료기관에 문의하세요.

Do not implement a crisis chatbot unless explicitly requested.

---

## 4. MVP Scope

This is a solo full-stack project.
Build for demo first.

MVP must include:
- Signup
- Login
- Menstrual cycle record
- Emotion record
- Sleep record
- Pain record
- Rule-based PMS score calculation
- Health report screen
- Institution search and recommendation from mc_incheon_medical.csv
- Korean mobile UI
- Medical disclaimer

MVP should not depend on:
- production cloud deployment
- Apple Watch integration
- real push notifications
- OAuth login
- App Store deployment
- payment
- hospital reservation integration
- real operating hours
- advanced machine learning
- external LLM APIs
- Spring Boot microservice split
- separate AI server deployment

Represent advanced features as future roadmap only.

---

## 5. Recommended Solo-Developer Architecture

Use this simplified MVP architecture unless the human explicitly requests otherwise.

Frontend:
- Flutter
- Korean UI text
- Mobile-first design
- Purple/lavender MORE Cycle style

Backend:
- FastAPI
- SQLAlchemy
- Pydantic
- SQLite for local demo
- JWT demo auth
- CORS enabled for Flutter local development

Database:
- SQLite for MVP
- Models designed so PostgreSQL migration is easy later

AI / Analysis:
- Deterministic rule-based scoring
- No fake trained model
- No fake ML accuracy
- No fake model evaluation
- Label clearly as rule-based PMS risk score

Data:
- Store raw CSV at backend/data/mc_incheon_medical.csv
- Seed CSV into MedicalInstitution table
- Institution APIs must return real CSV-backed records only

Later architecture:
- Spring Boot, PostgreSQL, FastAPI AI server, AWS, FCM, and wearable integration may be roadmap items.
- Do not implement them before the MVP is stable.

---

## 6. Repository Structure

Use this monorepo structure if starting from scratch.

more-cycle/
  AGENTS.md
  README.md
  docs/
    product-scope.md
    data-contract.md
    scoring-rules.md
    demo-script.md
    api-contract.md
    safety-policy.md
  backend/
    README.md
    requirements.txt
    .env.example
    data/
      mc_incheon_medical.csv
    app/
      main.py
      core/
        config.py
        security.py
      db/
        database.py
        models.py
        seed_medical.py
      schemas/
        auth.py
        user.py
        cycle.py
        emotion.py
        sleep.py
        pain.py
        report.py
        institution.py
      routers/
        auth.py
        users.py
        cycles.py
        emotions.py
        sleep.py
        pain.py
        reports.py
        institutions.py
        health.py
      services/
        auth_service.py
        cycle_service.py
        scoring_service.py
        report_service.py
        institution_service.py
      tests/
        test_scoring_service.py
        test_institution_service.py
        test_api_smoke.py
  frontend/
    README.md
    pubspec.yaml
    lib/
      main.dart
      app.dart
      core/
        theme/
          app_theme.dart
        constants/
          app_colors.dart
          app_text.dart
        api/
          api_client.dart
        storage/
          token_storage.dart
        utils/
      models/
        user.dart
        cycle.dart
        emotion_log.dart
        sleep_log.dart
        pain_log.dart
        health_report.dart
        medical_institution.dart
      services/
        auth_api.dart
        record_api.dart
        report_api.dart
        institution_api.dart
      screens/
        onboarding/
        auth/
        home/
        record/
        calendar/
        analysis/
        hospital/
        mypage/
      widgets/

If the repository already exists, inspect it first.
Do not delete existing files unless explicitly asked.
Adapt the structure without destructive changes.

---

## 7. Dataset Contract

Dataset file:
backend/data/mc_incheon_medical.csv

Allowed columns:
- institution_name
- institution_type
- department
- service_category
- address
- sigungu
- phone
- latitude
- longitude
- geocode_query
- matched_address

User-facing display fields:
- institution_name
- institution_type
- department
- service_category
- address
- sigungu
- phone
- distance_km if user coordinates are provided

Developer/debug-only fields:
- geocode_query
- matched_address

Valid service_category values:
- WOMEN_HEALTH
- MENTAL_HEALTH
- PUBLIC_HEALTH
- PAIN_NEURO

Category meaning:
- WOMEN_HEALTH: obstetrics/gynecology, women’s health clinics
- MENTAL_HEALTH: psychiatry, mental health-related institutions
- PUBLIC_HEALTH: public health centers and public health branches
- PAIN_NEURO: neurology, anesthesiology/pain clinics, headache/pain-related institutions

Symptom to category mapping:
- menstrual cramp, irregular bleeding, irregular cycle, severe menstrual discomfort -> WOMEN_HEALTH
- anxiety, sadness, depression-like mood, mood swings, emotional instability, stress -> MENTAL_HEALTH
- public counseling, prevention, health program, general public support -> PUBLIC_HEALTH
- headache, severe pain, neurological pain, pain management -> PAIN_NEURO

Dataset limitations:
- No operating hours
- No holiday closure information
- No reservation availability
- No real-time availability
- No clinical quality ranking
- No doctor-level data

Required notice in hospital UI:
운영시간과 진료 가능 여부는 데이터에 포함되어 있지 않으므로 방문 전 반드시 전화로 확인해주세요.

---

## 8. Backend Models

Implement these core tables for MVP.

User:
- id
- email
- password_hash
- nickname
- birth_date
- created_at

MenstrualCycle:
- id
- user_id
- start_date
- end_date
- cycle_length
- memo
- created_at

EmotionLog:
- id
- user_id
- emotion_type
- intensity
- created_at

Allowed emotion_type:
- happy
- calm
- anxious
- sad
- angry
- irritated
- tired

SleepLog:
- id
- user_id
- sleep_start
- sleep_end
- sleep_hours
- quality_score
- created_at

PainLog:
- id
- user_id
- pain_type
- pain_score
- memo
- created_at

Allowed pain_type:
- menstrual_cramp
- headache
- abdominal_pain
- back_pain
- breast_pain
- other

HealthReport:
- id
- user_id
- pms_score
- health_score
- risk_level
- confidence
- summary
- main_factors_json
- care_tips_json
- recommended_category
- created_at

MedicalInstitution:
- id
- institution_name
- institution_type
- department
- service_category
- address
- sigungu
- phone
- latitude
- longitude
- geocode_query
- matched_address

---

## 9. API Contract

Use prefix:
/api

Health:
- GET /api/health

Auth:
- POST /api/auth/signup
- POST /api/auth/login
- GET /api/users/me

Cycles:
- GET /api/cycles
- POST /api/cycles
- GET /api/cycles/latest

Emotions:
- GET /api/emotions
- POST /api/emotions

Sleep:
- GET /api/sleep
- POST /api/sleep

Pain:
- GET /api/pain
- POST /api/pain

Reports:
- GET /api/reports/latest
- POST /api/reports/generate
- GET /api/reports/history

Institutions:
- GET /api/institutions
- GET /api/institutions/search
- GET /api/institutions/recommend
- GET /api/institutions/categories

Institution query parameters:
- service_category
- sigungu
- keyword
- latitude
- longitude
- limit

Institution behavior:
- If service_category is provided, filter by category.
- If sigungu is provided, filter by sigungu.
- If keyword is provided, search institution_name, department, address, and sigungu.
- If latitude and longitude are provided, sort by Haversine distance.
- If coordinates are not provided, sort by sigungu match and institution_name.
- Return only real CSV-backed institutions.

---

## 10. PMS Scoring Rules

Implement scoring in:
backend/app/services/scoring_service.py

Scoring must be:
- deterministic
- explainable
- unit-tested
- conservative
- not presented as diagnosis

Input:
- recent menstrual cycles
- recent emotion logs
- recent sleep logs
- recent pain logs
- today’s date

Output shape:
- pms_score: integer 0 to 100
- health_score: integer 0 to 100
- risk_level: low, medium, high
- confidence: low, medium, high
- main_factors: list of strings
- care_tips: list of strings
- recommended_category: WOMEN_HEALTH, MENTAL_HEALTH, PUBLIC_HEALTH, PAIN_NEURO, or null

Suggested PMS score formula:

Base score:
- 10

Cycle phase factor:
- If predicted period is 1 to 7 days away: add 25
- If predicted period is 8 to 14 days away: add 15
- If currently menstruating: add 10
- Otherwise: add 0

Pain factor:
- Average recent pain_score from 0 to 10 multiplied by 2.0
- Maximum pain factor: 20

Emotion factor:
- anxious, sad, angry, irritated, tired increase risk
- Average negative emotion intensity from 0 to 5 multiplied by 4.0
- Maximum emotion factor: 20

Sleep factor:
- If average sleep is under 6 hours: add 15
- If average sleep is 6 to under 7 hours: add 8
- If average sleep is over 9 hours: add 5
- Otherwise: add 0

Cycle irregularity factor:
- If recent cycle length variation is greater than 7 days: add 10
- Otherwise: add 0

Symptom density factor:
- If user logged pain or negative emotions on 3 or more days in the last 7 days: add 10
- Otherwise: add 0

Clamp final pms_score between 0 and 100.

Risk level:
- 0 to 39: low
- 40 to 69: medium
- 70 to 100: high

Health score:
- health_score = 100 - weighted_penalty
- Clamp between 0 and 100

Weighted penalty:
- pms_score multiplied by 0.45
- plus sleep_penalty multiplied by 0.25
- plus pain_penalty multiplied by 0.20
- plus emotion_penalty multiplied by 0.10

Confidence:
- low: fewer than 3 total logs
- medium: 3 to 9 total logs
- high: 10 or more total logs across at least 3 record types

Recommended category logic:
- If menstrual pain, irregular bleeding, irregular cycle, or menstrual symptoms dominate: WOMEN_HEALTH
- If anxiety, sadness, anger, irritation, stress, or emotional symptoms dominate: MENTAL_HEALTH
- If headache or severe pain dominates: PAIN_NEURO
- If symptoms are mild or user needs public support: PUBLIC_HEALTH
- If insufficient information: null

Care tips must be conservative:
- rest
- hydration
- regular sleep
- light stretching
- symptom tracking
- warm compress
- reduce overexertion
- consider consultation if symptoms persist or worsen

Never recommend medicine.

---

## 11. Report Generation Rules

Reports must be generated from structured scores and logs.
Do not hallucinate clinical explanations.

Report language:
- Korean
- warm
- professional
- mobile-friendly
- short
- non-diagnostic

Good Korean summary example:
최근 기록을 보면 수면 시간이 다소 부족하고 통증 기록이 함께 나타나 PMS 위험도가 보통 수준으로 계산되었어요. 오늘은 무리한 활동보다 휴식, 수분 섭취, 가벼운 스트레칭을 추천해요. 증상이 반복되거나 강해진다면 가까운 의료기관에 문의해보세요.

Never write:
- PMS 확진입니다.
- 우울증입니다.
- 약을 복용하세요.
- 이 병원이 가장 좋습니다.
- 지금 바로 예약할 수 있습니다.
- 병원에 가지 않아도 됩니다.

Report response should include:
- pms_score
- health_score
- risk_level
- confidence
- summary
- main_factors
- care_tips
- recommended_category
- disclaimer

---

## 12. Institution Recommendation Rules

Institution recommendation is public-data-based information retrieval.
It is not diagnosis or treatment recommendation.

Backend flow:
1. Read user’s latest report or selected symptom.
2. Determine service_category.
3. Filter MedicalInstitution by service_category.
4. Optionally filter by sigungu.
5. If latitude and longitude exist, calculate Haversine distance.
6. Sort by distance if coordinates exist.
7. Return top 5 to 10 items.
8. Include disclaimer and availability warning.

Response shape:
- category
- reason
- disclaimer
- availability_notice
- items

Each item:
- institution_name
- institution_type
- department
- service_category
- address
- sigungu
- phone
- latitude
- longitude
- distance_km if available

Frontend hospital card should show:
- institution name
- category badge
- institution type
- department
- address
- sigungu
- phone
- distance if available
- call confirmation notice

Do not show:
- ranking by quality
- open now
- reservation available
- doctor recommendation
- guaranteed treatment

---

## 13. Frontend UX Guidelines

Framework:
- Flutter

Language:
- Korean UI text

Visual style:
- Soft purple and lavender
- White cards
- Rounded corners
- Calm, friendly, non-clinical
- Avoid scary red except urgent warnings
- Use subtle icons for cycle, sleep, mood, pain, report, and hospital

Suggested colors:
- Primary purple: #6D4AFF
- Deep purple: #4C2BD9
- Lavender background: #F4EFFF
- Soft card: #FFFFFF
- Light purple card: #F7F2FF
- Text primary: #222222
- Text secondary: #6B6B7A
- Warning soft: #FFF4E5
- Danger soft: #FFECEC

Main screens:
1. Onboarding
2. Login / Signup
3. Home dashboard
4. Record input
5. Calendar / cycle view
6. Analysis / health report
7. Hospital recommendation
8. My page

Bottom navigation:
- 홈
- 기록
- 분석
- 병원
- 마이

Home dashboard cards:
- Current cycle status
- Today’s condition
- Sleep time
- PMS risk summary
- Today’s care tips
- Hospital recommendation CTA if risk is medium or high

Empty state examples:
- 아직 기록이 부족해요. 오늘의 컨디션을 기록하면 더 정확한 분석을 받을 수 있어요.
- 병원 정보가 없습니다. 다른 증상 유형이나 지역을 선택해보세요.

Error state examples:
- 서버 연결에 실패했어요. 백엔드 실행 상태를 확인해주세요.
- 의료기관 데이터를 불러오지 못했어요. CSV 시드 상태를 확인해주세요.

---

## 14. Security and Privacy Rules

Backend:
- Hash passwords.
- Do not store plaintext passwords.
- Use JWT for demo auth.
- Keep secret keys in environment variables.
- Provide .env.example.
- Do not commit real secrets.
- Validate request input.
- Use CORS only for local development origins unless configured.

Health data:
- Treat all user records as sensitive.
- Do not log raw health record payloads unnecessarily.
- Do not expose other users’ records.
- All record queries must be scoped to authenticated user.

Frontend:
- Store token safely for MVP.
- Handle expired token gracefully.
- Do not show stack traces to users.

---

## 15. Coding Standards

General:
- Keep code simple.
- Prefer explicit names over clever abstractions.
- Do not add unnecessary dependencies.
- Do not silently change architecture.
- Do not delete existing files unless explicitly asked.
- Keep identifiers in English.
- Keep user-facing UI strings in Korean.
- Add comments only for domain logic or non-obvious decisions.

Backend:
- Routers should be thin.
- Business logic belongs in services.
- Pydantic schemas define request and response.
- SQLAlchemy models define persistence.
- Use dependency injection for DB sessions and current user.
- Add tests for scoring and institution recommendation.
- Return stable JSON shapes.

Frontend:
- Separate screens, widgets, models, and API services.
- Use centralized theme.
- Handle loading, empty, and error states.
- Never crash on missing backend fields.
- Use mock/demo mode only when explicitly implemented and clearly labeled in code.
- Do not hard-code hospital list in Flutter. Fetch from backend.

---

## 16. Testing and Validation

Before considering a backend feature complete, run:
- pytest

Minimum backend tests:
- PMS score is clamped between 0 and 100.
- High pain increases PMS score.
- Poor sleep increases PMS score.
- Negative emotions increase PMS score.
- Cycle phase changes PMS score.
- Institution recommendation maps menstrual symptoms to WOMEN_HEALTH.
- Institution recommendation maps emotional symptoms to MENTAL_HEALTH.
- Institution recommendation maps headache/severe pain to PAIN_NEURO.
- Institution search returns only database records seeded from CSV.
- Missing latitude/longitude does not crash distance sorting.
- Empty institution result returns a safe empty list.

Before considering a Flutter feature complete, run:
- flutter analyze
- flutter test if tests exist

Manual demo checklist:
- User can sign up.
- User can log in.
- User can enter menstrual cycle record.
- User can enter emotion record.
- User can enter sleep record.
- User can enter pain record.
- User can generate health report.
- User can see PMS score.
- User can see health score.
- User can see care tips.
- User can see matching Incheon medical institutions.
- Medical disclaimer is visible.
- Hospital screen says to call before visiting.
- UI does not claim diagnosis.
- UI does not claim real-time availability.

If tests cannot be run, explain why and provide the exact commands the human should run.

---

## 17. Agent Workflow

For every task:

1. Inspect the existing repository before editing.
2. Identify the smallest vertical slice.
3. Summarize the files you will create or change.
4. Implement the feature.
5. Add or update tests.
6. Run relevant validation commands if possible.
7. Report:
   - what changed,
   - how to run it,
   - what was tested,
   - known limitations,
   - next recommended step.

Do not implement huge unrelated batches.
Do not invent hidden APIs.
Do not create placeholder fake data when CSV data should be used.
Do not ignore failing tests.
Do not claim completion if validation failed.

---

## 18. Definition of Done

A feature is done only when:
- It is implemented end-to-end or clearly marked as backend-only/frontend-only.
- It uses real CSV-backed data when institution data is needed.
- It does not rely on unavailable external APIs.
- It follows medical safety wording.
- It handles loading, empty, and error states.
- It has tests or a clear manual validation path.
- It is documented enough for a solo developer to continue.

---

## 19. First MVP Build Order

Build in this order:

1. Backend project skeleton
2. Database models
3. CSV seed script
4. Auth
5. Record APIs
6. PMS scoring service
7. Report generation API
8. Institution search/recommendation API
9. Flutter project skeleton
10. Theme and navigation
11. Auth screens
12. Record screens
13. Home dashboard
14. Analysis/report screen
15. Hospital recommendation screen
16. README and demo script

Do not start advanced UI polishing before the backend vertical slice works.

---

## 20. Local Run Expectations

Backend should support:
- install dependencies
- create database
- seed medical CSV
- run FastAPI
- open API docs

Expected backend commands may look like:
- cd backend
- python -m venv .venv
- source .venv/bin/activate
- pip install -r requirements.txt
- python -m app.db.seed_medical
- uvicorn app.main:app --reload

Frontend should support:
- cd frontend
- flutter pub get
- flutter run

README must include exact commands for the actual implementation.

---

## 21. Final Agent Response Format

After each implementation task, respond with:

Summary:
- concise description of changes

Files changed:
- list files

How to run:
- exact commands

Tests:
- commands run and results

Notes:
- limitations or next steps

Keep responses practical.
Do not write long essays after every code change.
