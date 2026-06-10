from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


PainType = Literal[
    "menstrual_cramp",
    "headache",
    "abdominal_pain",
    "back_pain",
    "breast_pain",
    "other",
]


class PainCreate(BaseModel):
    pain_type: PainType
    pain_score: int = Field(ge=0, le=10)
    memo: str | None = Field(default=None, max_length=1000)


class PainRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    pain_type: str
    pain_score: int
    memo: str | None
    created_at: datetime
