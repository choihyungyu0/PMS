from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.db.models import EmotionLog, User
from app.schemas.emotion import EmotionCreate, EmotionRead
from app.services.auth_service import get_current_user


router = APIRouter(prefix="/emotions", tags=["emotions"])


@router.get("", response_model=list[EmotionRead])
def list_emotions(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[EmotionLog]:
    return (
        db.query(EmotionLog)
        .filter(EmotionLog.user_id == current_user.id)
        .order_by(EmotionLog.created_at.desc())
        .all()
    )


@router.post("", response_model=EmotionRead)
def create_emotion(
    payload: EmotionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> EmotionLog:
    emotion = EmotionLog(user_id=current_user.id, **payload.model_dump())
    db.add(emotion)
    db.commit()
    db.refresh(emotion)
    return emotion
