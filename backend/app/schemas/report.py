from datetime import datetime

from pydantic import BaseModel


class HealthReportRead(BaseModel):
    id: int
    pms_score: int
    health_score: int
    risk_level: str
    confidence: str
    summary: str
    main_factors: list[str]
    care_tips: list[str]
    recommended_category: str | None
    disclaimer: str
    created_at: datetime
