import csv
from pathlib import Path

from sqlalchemy import text

from app.core.config import settings
from app.db.database import Base, SessionLocal, engine
from app.db.models import MedicalInstitution
from app.services.institution_service import VALID_SERVICE_CATEGORIES


OPTIONAL_COLUMNS = {
    "institution_type",
    "department",
    "address",
    "sigungu",
    "phone",
    "latitude",
    "longitude",
    "location_status",
    "geocode_query",
    "matched_address",
}


def seed_medical_institutions(csv_path: Path | None = None) -> dict[str, int]:
    csv_path = csv_path or settings.medical_csv_path
    Base.metadata.create_all(bind=engine)
    _ensure_medical_schema_compatibility()

    if not csv_path.exists():
        message = (
            f"Developer error: medical institution CSV not found at {csv_path}. "
            "Place mc_incheon_medical.csv under backend/data/ and run this command again."
        )
        print(message)
        return {"inserted": 0, "already_existed": 0, "skipped": 0, "missing_csv": 1}

    inserted = 0
    already_existed = 0
    skipped = 0
    db = SessionLocal()
    try:
        existing_keys = {
            (name, address, phone)
            for name, address, phone in db.query(
                MedicalInstitution.institution_name,
                MedicalInstitution.address,
                MedicalInstitution.phone,
            ).all()
        }
        new_institutions = []

        with csv_path.open("r", encoding="utf-8-sig", newline="") as file:
            reader = csv.DictReader(file)
            for row in reader:
                name = _clean(row.get("institution_name"))
                category = _clean(row.get("service_category"))
                if not name or category not in VALID_SERVICE_CATEGORIES:
                    skipped += 1
                    continue

                address = _clean(row.get("address"))
                phone = _clean(row.get("phone"))
                identity_key = (name, address, phone)
                if identity_key in existing_keys:
                    already_existed += 1
                    continue

                institution = MedicalInstitution(
                    institution_name=name,
                    service_category=category,
                    institution_type=_clean(row.get("institution_type")),
                    department=_clean(row.get("department")),
                    address=address,
                    sigungu=_clean(row.get("sigungu")),
                    phone=phone,
                    latitude=_float_or_none(row.get("latitude")),
                    longitude=_float_or_none(row.get("longitude")),
                    location_status=_clean(row.get("location_status")),
                    geocode_query=_clean(row.get("geocode_query")),
                    matched_address=_clean(row.get("matched_address")),
                )
                new_institutions.append(institution)
                existing_keys.add(identity_key)
                inserted += 1
        db.add_all(new_institutions)
        db.commit()
    finally:
        db.close()

    result = {"inserted": inserted, "already_existed": already_existed, "skipped": skipped, "missing_csv": 0}
    print(
        "Medical institution seed complete: "
        f"{inserted} inserted, {already_existed} already existed, {skipped} skipped."
    )
    return result


def _ensure_medical_schema_compatibility() -> None:
    if engine.dialect.name != "postgresql":
        return

    with engine.begin() as connection:
        connection.execute(
            text(
                """
                ALTER TABLE medical_institutions
                    ALTER COLUMN institution_name TYPE TEXT,
                    ALTER COLUMN institution_type TYPE TEXT,
                    ALTER COLUMN department TYPE TEXT,
                    ALTER COLUMN address TYPE TEXT,
                    ALTER COLUMN geocode_query TYPE TEXT,
                    ALTER COLUMN matched_address TYPE TEXT
                """
            )
        )


def _clean(value: str | None) -> str | None:
    if value is None:
        return None
    cleaned = value.strip()
    return cleaned or None


def _float_or_none(value: str | None) -> float | None:
    cleaned = _clean(value)
    if cleaned is None:
        return None
    try:
        return float(cleaned)
    except ValueError:
        return None


def main() -> int:
    result = seed_medical_institutions()
    return 1 if result["missing_csv"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
