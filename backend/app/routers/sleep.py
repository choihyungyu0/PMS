from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.db.models import SleepLog, User
from app.schemas.sleep import SleepCreate, SleepRead
from app.services.auth_service import get_current_user


router = APIRouter(prefix="/sleep", tags=["sleep"])


@router.get("", response_model=list[SleepRead])
def list_sleep(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[SleepLog]:
    return (
        db.query(SleepLog)
        .filter(SleepLog.user_id == current_user.id)
        .order_by(SleepLog.created_at.desc())
        .all()
    )


@router.post("", response_model=SleepRead)
def create_sleep(
    payload: SleepCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> SleepLog:
    sleep = SleepLog(user_id=current_user.id, **payload.model_dump())
    db.add(sleep)
    db.commit()
    db.refresh(sleep)
    return sleep
