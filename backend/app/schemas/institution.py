from pydantic import BaseModel, ConfigDict


class MedicalInstitutionRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    institution_name: str
    institution_type: str | None
    department: str | None
    service_category: str
    address: str | None
    sigungu: str | None
    phone: str | None
    latitude: float | None
    longitude: float | None
    distance_km: float | None = None


class InstitutionRecommendationResponse(BaseModel):
    category: str | None
    reason: str
    disclaimer: str
    availability_notice: str
    items: list[MedicalInstitutionRead]
