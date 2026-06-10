from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


EmotionType = Literal["happy", "calm", "anxious", "sad", "angry", "irritated", "tired"]


class EmotionCreate(BaseModel):
    emotion_type: EmotionType
    intensity: int = Field(ge=0, le=5)


class EmotionRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    emotion_type: str
    intensity: int
    created_at: datetime
