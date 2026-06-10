from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.db.models import MenstrualCycle, User
from app.schemas.cycle import CycleCreate, CycleRead
from app.services.auth_service import get_current_user


router = APIRouter(prefix="/cycles", tags=["cycles"])


@router.get("", response_model=list[CycleRead])
def list_cycles(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[MenstrualCycle]:
    return (
        db.query(MenstrualCycle)
        .filter(MenstrualCycle.user_id == current_user.id)
        .order_by(MenstrualCycle.start_date.desc(), MenstrualCycle.created_at.desc())
        .all()
    )


@router.post("", response_model=CycleRead)
def create_cycle(
    payload: CycleCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> MenstrualCycle:
    cycle = MenstrualCycle(user_id=current_user.id, **payload.model_dump())
    db.add(cycle)
    db.commit()
    db.refresh(cycle)
    return cycle


@router.get("/latest", response_model=CycleRead | None)
def latest_cycle(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> MenstrualCycle | None:
    return (
        db.query(MenstrualCycle)
        .filter(MenstrualCycle.user_id == current_user.id)
        .order_by(MenstrualCycle.start_date.desc(), MenstrualCycle.created_at.desc())
        .first()
    )
