from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.db.models import User
from app.schemas.report import HealthReportRead
from app.services.auth_service import get_current_user
from app.services.report_service import generate_report, latest_report, report_history


router = APIRouter(prefix="/reports", tags=["reports"])


@router.get("/latest", response_model=HealthReportRead | None)
def read_latest_report(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> dict | None:
    return latest_report(db, current_user.id)


@router.post("/generate", response_model=HealthReportRead)
def create_report(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> dict:
    return generate_report(db, current_user.id)


@router.get("/history", response_model=list[HealthReportRead])
def read_report_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[dict]:
    return report_history(db, current_user.id)
