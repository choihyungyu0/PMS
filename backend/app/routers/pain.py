from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.db.models import PainLog, User
from app.schemas.pain import PainCreate, PainRead
from app.services.auth_service import get_current_user


router = APIRouter(prefix="/pain", tags=["pain"])


@router.get("", response_model=list[PainRead])
def list_pain(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[PainLog]:
    return (
        db.query(PainLog)
        .filter(PainLog.user_id == current_user.id)
        .order_by(PainLog.created_at.desc())
        .all()
    )


@router.post("", response_model=PainRead)
def create_pain(
    payload: PainCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> PainLog:
    pain = PainLog(user_id=current_user.id, **payload.model_dump())
    db.add(pain)
    db.commit()
    db.refresh(pain)
    return pain
