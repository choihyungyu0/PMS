from datetime import date, datetime

from pydantic import BaseModel, ConfigDict, Field, model_validator


class CycleCreate(BaseModel):
    start_date: date
    end_date: date | None = None
    cycle_length: int | None = Field(default=None, ge=15, le=60)
    memo: str | None = Field(default=None, max_length=1000)

    @model_validator(mode="after")
    def validate_date_order(self):
        if self.end_date is not None and self.end_date < self.start_date:
            raise ValueError("end_date must be on or after start_date")
        return self


class CycleRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    start_date: date
    end_date: date | None
    cycle_length: int | None
    memo: str | None
    created_at: datetime
