from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.schemas.institution import InstitutionRecommendationResponse, MedicalInstitutionRead
from app.services.institution_service import (
    VALID_SERVICE_CATEGORIES,
    recommend_institutions,
    search_institutions,
)


router = APIRouter(prefix="/institutions", tags=["institutions"])


@router.get("/categories")
def categories() -> dict[str, list[str]]:
    return {"items": sorted(VALID_SERVICE_CATEGORIES)}


@router.get("", response_model=list[MedicalInstitutionRead])
def list_institutions(
    service_category: str | None = None,
    sigungu: str | None = None,
    keyword: str | None = None,
    latitude: float | None = None,
    longitude: float | None = None,
    limit: int = Query(default=20, ge=1, le=50),
    db: Session = Depends(get_db),
) -> list[dict]:
    return _safe_search(db, service_category, sigungu, keyword, latitude, longitude, limit)


@router.get("/search", response_model=list[MedicalInstitutionRead])
def search(
    service_category: str | None = None,
    sigungu: str | None = None,
    keyword: str | None = None,
    latitude: float | None = None,
    longitude: float | None = None,
    limit: int = Query(default=20, ge=1, le=50),
    db: Session = Depends(get_db),
) -> list[dict]:
    return _safe_search(db, service_category, sigungu, keyword, latitude, longitude, limit)


@router.get("/recommend", response_model=InstitutionRecommendationResponse)
def recommend(
    symptom: str | None = None,
    service_category: str | None = None,
    sigungu: str | None = None,
    latitude: float | None = None,
    longitude: float | None = None,
    limit: int = Query(default=10, ge=1, le=50),
    db: Session = Depends(get_db),
) -> dict:
    try:
        return recommend_institutions(
            db=db,
            symptom=symptom,
            service_category=service_category,
            sigungu=sigungu,
            latitude=latitude,
            longitude=longitude,
            limit=limit,
        )
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


def _safe_search(
    db: Session,
    service_category: str | None,
    sigungu: str | None,
    keyword: str | None,
    latitude: float | None,
    longitude: float | None,
    limit: int,
) -> list[dict]:
    try:
        return search_institutions(
            db=db,
            service_category=service_category,
            sigungu=sigungu,
            keyword=keyword,
            latitude=latitude,
            longitude=longitude,
            limit=limit,
        )
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
