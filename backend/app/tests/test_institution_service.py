from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.db.database import Base
from app.db.models import MedicalInstitution
from app.services.institution_service import infer_category_from_symptom, search_institutions


def _db_session():
    engine = create_engine("sqlite:///:memory:", connect_args={"check_same_thread": False})
    Base.metadata.create_all(bind=engine)
    Session = sessionmaker(bind=engine)
    return Session()


def _add_institution(db, name: str, category: str, latitude: float | None = None, longitude: float | None = None):
    item = MedicalInstitution(
        institution_name=name,
        institution_type="test",
        department="test",
        service_category=category,
        address=f"{name} address",
        sigungu="남동구",
        phone=f"032-000-{len(name):04d}",
        latitude=latitude,
        longitude=longitude,
    )
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


def test_menstrual_symptoms_map_to_women_health():
    assert infer_category_from_symptom("menstrual cramp and irregular cycle") == "WOMEN_HEALTH"


def test_emotional_symptoms_map_to_mental_health():
    assert infer_category_from_symptom("anxiety and mood swings") == "MENTAL_HEALTH"


def test_headache_or_severe_pain_maps_to_pain_neuro():
    assert infer_category_from_symptom("headache and severe pain") == "PAIN_NEURO"


def test_search_returns_database_records_only():
    db = _db_session()
    try:
        inserted = _add_institution(db, "CSV-backed search fixture", "WOMEN_HEALTH")
        items = search_institutions(db, keyword="CSV-backed", limit=10)

        assert len(items) == 1
        assert items[0]["id"] == inserted.id
        assert items[0]["institution_name"] == inserted.institution_name
    finally:
        db.close()


def test_missing_latitude_longitude_does_not_crash():
    db = _db_session()
    try:
        _add_institution(db, "No Coordinate Fixture", "PUBLIC_HEALTH")
        items = search_institutions(db, latitude=None, longitude=None, limit=10)

        assert len(items) == 1
        assert items[0]["distance_km"] is None
    finally:
        db.close()


def test_empty_result_returns_safe_empty_list():
    db = _db_session()
    try:
        assert search_institutions(db, keyword="not-found") == []
    finally:
        db.close()
