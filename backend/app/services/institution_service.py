from math import asin, cos, radians, sin, sqrt

from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.db.models import MedicalInstitution


VALID_SERVICE_CATEGORIES = {"WOMEN_HEALTH", "MENTAL_HEALTH", "PUBLIC_HEALTH", "PAIN_NEURO"}
DISCLAIMER = "이 서비스는 진단이나 치료를 제공하지 않습니다. 사용자가 입력한 기록과 공공데이터 기반 의료기관 정보를 바탕으로 건강 관리 참고 정보를 제공합니다."
AVAILABILITY_NOTICE = "운영시간과 진료 가능 여부는 데이터에 포함되어 있지 않으므로 방문 전 반드시 전화로 확인해주세요."


def infer_category_from_symptom(symptom: str | None) -> str | None:
    if not symptom or not symptom.strip():
        return None

    text = symptom.lower()
    if any(keyword in text for keyword in ["menstrual", "period", "cycle", "cramp", "생리", "월경", "주기", "부정출혈"]):
        return "WOMEN_HEALTH"
    if any(keyword in text for keyword in ["headache", "neurological", "severe pain", "pain management", "두통", "신경", "심한 통증"]):
        return "PAIN_NEURO"
    if any(keyword in text for keyword in ["anxiety", "sad", "mood", "stress", "angry", "irritated", "불안", "슬픔", "기분", "스트레스", "짜증"]):
        return "MENTAL_HEALTH"
    if any(keyword in text for keyword in ["public", "prevention", "program", "support", "상담", "예방", "프로그램", "공공"]):
        return "PUBLIC_HEALTH"
    if any(keyword in text for keyword in ["mild", "general", "가벼운", "일반"]):
        return "PUBLIC_HEALTH"
    return None


def search_institutions(
    db: Session,
    service_category: str | None = None,
    sigungu: str | None = None,
    keyword: str | None = None,
    latitude: float | None = None,
    longitude: float | None = None,
    limit: int = 20,
) -> list[dict]:
    limit = _safe_limit(limit)
    category = _normalize_category(service_category)

    query = db.query(MedicalInstitution)
    if category:
        query = query.filter(MedicalInstitution.service_category == category)
    if sigungu:
        query = query.filter(MedicalInstitution.sigungu == sigungu)
    if keyword:
        like = f"%{keyword.strip()}%"
        query = query.filter(
            or_(
                MedicalInstitution.institution_name.ilike(like),
                MedicalInstitution.department.ilike(like),
                MedicalInstitution.address.ilike(like),
                MedicalInstitution.sigungu.ilike(like),
            )
        )

    records = query.all()
    has_coordinates = latitude is not None and longitude is not None
    if has_coordinates:
        records.sort(key=lambda item: _distance_sort_key(item, latitude, longitude))
    else:
        records.sort(key=lambda item: (item.sigungu or "", item.institution_name or ""))

    return [
        _institution_to_dict(
            record,
            _distance_km(latitude, longitude, record.latitude, record.longitude)
            if has_coordinates
            else None,
        )
        for record in records[:limit]
    ]


def recommend_institutions(
    db: Session,
    symptom: str | None = None,
    service_category: str | None = None,
    sigungu: str | None = None,
    latitude: float | None = None,
    longitude: float | None = None,
    limit: int = 10,
) -> dict:
    category = _normalize_category(service_category) or infer_category_from_symptom(symptom)
    items = search_institutions(
        db=db,
        service_category=category,
        sigungu=sigungu,
        latitude=latitude,
        longitude=longitude,
        limit=limit,
    )
    return {
        "category": category,
        "reason": _recommendation_reason(category, symptom),
        "disclaimer": DISCLAIMER,
        "availability_notice": AVAILABILITY_NOTICE,
        "items": items,
    }


def _normalize_category(category: str | None) -> str | None:
    if category is None or category == "":
        return None
    normalized = category.strip().upper()
    if normalized not in VALID_SERVICE_CATEGORIES:
        raise ValueError(f"Invalid service_category: {category}")
    return normalized


def _recommendation_reason(category: str | None, symptom: str | None) -> str:
    if category is None:
        return "증상 유형이 충분하지 않아 전체 의료기관 정보에서 확인할 수 있어요."
    if symptom:
        return "선택한 증상 유형과 매칭되는 인천 의료기관 정보를 조회했어요."
    return "선택한 진료/지원 카테고리에 맞는 인천 의료기관 정보를 조회했어요."


def _safe_limit(limit: int) -> int:
    return max(1, min(int(limit or 20), 50))


def _distance_sort_key(
    item: MedicalInstitution,
    latitude: float | None,
    longitude: float | None,
) -> tuple[int, float, str]:
    distance = _distance_km(latitude, longitude, item.latitude, item.longitude)
    if distance is None:
        return (1, float("inf"), item.institution_name or "")
    return (0, distance, item.institution_name or "")


def _distance_km(
    lat1: float | None,
    lon1: float | None,
    lat2: float | None,
    lon2: float | None,
) -> float | None:
    if None in (lat1, lon1, lat2, lon2):
        return None
    radius_km = 6371.0
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat / 2) ** 2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon / 2) ** 2
    c = 2 * asin(sqrt(a))
    return round(radius_km * c, 2)


def _institution_to_dict(record: MedicalInstitution, distance_km: float | None = None) -> dict:
    return {
        "id": record.id,
        "institution_name": record.institution_name,
        "institution_type": record.institution_type,
        "department": record.department,
        "service_category": record.service_category,
        "address": record.address,
        "sigungu": record.sigungu,
        "phone": record.phone,
        "latitude": record.latitude,
        "longitude": record.longitude,
        "distance_km": distance_km,
    }
