from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, model_validator


class SleepCreate(BaseModel):
    sleep_start: datetime
    sleep_end: datetime
    sleep_hours: float = Field(ge=0, le=24)
    quality_score: int = Field(ge=0, le=10)

    @model_validator(mode="after")
    def validate_sleep_window(self):
        if self.sleep_end <= self.sleep_start:
            raise ValueError("sleep_end must be after sleep_start")
        return self


class SleepRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    sleep_start: datetime
    sleep_end: datetime
    sleep_hours: float
    quality_score: int
    created_at: datetime
