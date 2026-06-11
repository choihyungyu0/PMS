from datetime import date, datetime

from sqlalchemy import Date, DateTime, Float, ForeignKey, Integer, String, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    nickname: Mapped[str] = mapped_column(String(80), nullable=False)
    birth_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    cycles = relationship("MenstrualCycle", back_populates="user", cascade="all, delete-orphan")
    emotions = relationship("EmotionLog", back_populates="user", cascade="all, delete-orphan")
    sleep_logs = relationship("SleepLog", back_populates="user", cascade="all, delete-orphan")
    pain_logs = relationship("PainLog", back_populates="user", cascade="all, delete-orphan")
    reports = relationship("HealthReport", back_populates="user", cascade="all, delete-orphan")


class MenstrualCycle(Base):
    __tablename__ = "menstrual_cycles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    start_date: Mapped[date] = mapped_column(Date, nullable=False)
    end_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    cycle_length: Mapped[int | None] = mapped_column(Integer, nullable=True)
    memo: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="cycles")


class EmotionLog(Base):
    __tablename__ = "emotion_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    emotion_type: Mapped[str] = mapped_column(String(40), nullable=False)
    intensity: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="emotions")


class SleepLog(Base):
    __tablename__ = "sleep_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    sleep_start: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    sleep_end: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    sleep_hours: Mapped[float] = mapped_column(Float, nullable=False)
    quality_score: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="sleep_logs")


class PainLog(Base):
    __tablename__ = "pain_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    pain_type: Mapped[str] = mapped_column(String(40), nullable=False)
    pain_score: Mapped[int] = mapped_column(Integer, nullable=False)
    memo: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="pain_logs")


class HealthReport(Base):
    __tablename__ = "health_reports"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True, nullable=False)
    pms_score: Mapped[int] = mapped_column(Integer, nullable=False)
    health_score: Mapped[int] = mapped_column(Integer, nullable=False)
    risk_level: Mapped[str] = mapped_column(String(20), nullable=False)
    confidence: Mapped[str] = mapped_column(String(20), nullable=False)
    summary: Mapped[str] = mapped_column(Text, nullable=False)
    main_factors_json: Mapped[str] = mapped_column(Text, nullable=False)
    care_tips_json: Mapped[str] = mapped_column(Text, nullable=False)
    recommended_category: Mapped[str | None] = mapped_column(String(40), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="reports")


class MedicalInstitution(Base):
    __tablename__ = "medical_institutions"
    __table_args__ = (
        UniqueConstraint(
            "institution_name",
            "address",
            "phone",
            name="uq_medical_institution_identity",
        ),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    institution_name: Mapped[str] = mapped_column(Text, index=True, nullable=False)
    institution_type: Mapped[str | None] = mapped_column(Text, nullable=True)
    department: Mapped[str | None] = mapped_column(Text, nullable=True)
    service_category: Mapped[str] = mapped_column(String(40), index=True, nullable=False)
    address: Mapped[str | None] = mapped_column(Text, nullable=True)
    sigungu: Mapped[str | None] = mapped_column(String(80), index=True, nullable=True)
    phone: Mapped[str | None] = mapped_column(String(80), nullable=True)
    latitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    longitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    location_status: Mapped[str | None] = mapped_column(String(80), nullable=True)
    geocode_query: Mapped[str | None] = mapped_column(Text, nullable=True)
    matched_address: Mapped[str | None] = mapped_column(Text, nullable=True)
