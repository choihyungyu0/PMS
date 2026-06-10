import json

from sqlalchemy.orm import Session

from app.db.models import EmotionLog, HealthReport, MenstrualCycle, PainLog, SleepLog
from app.services.institution_service import DISCLAIMER
from app.services.scoring_service import ScoreResult, calculate_pms_score


def generate_report(db: Session, user_id: int) -> dict:
    cycles = _recent(db, MenstrualCycle, user_id, limit=12)
    emotions = _recent(db, EmotionLog, user_id, limit=60)
    sleep_logs = _recent(db, SleepLog, user_id, limit=60)
    pain_logs = _recent(db, PainLog, user_id, limit=60)

    score = calculate_pms_score(cycles, emotions, sleep_logs, pain_logs)
    report = HealthReport(
        user_id=user_id,
        pms_score=score.pms_score,
        health_score=score.health_score,
        risk_level=score.risk_level,
        confidence=score.confidence,
        summary=_summary(score),
        main_factors_json=json.dumps(score.main_factors, ensure_ascii=False),
        care_tips_json=json.dumps(score.care_tips, ensure_ascii=False),
        recommended_category=score.recommended_category,
    )
    db.add(report)
    db.commit()
    db.refresh(report)
    return report_to_response(report)


def latest_report(db: Session, user_id: int) -> dict | None:
    report = (
        db.query(HealthReport)
        .filter(HealthReport.user_id == user_id)
        .order_by(HealthReport.created_at.desc())
        .first()
    )
    return report_to_response(report) if report else None


def report_history(db: Session, user_id: int, limit: int = 20) -> list[dict]:
    reports = (
        db.query(HealthReport)
        .filter(HealthReport.user_id == user_id)
        .order_by(HealthReport.created_at.desc())
        .limit(limit)
        .all()
    )
    return [report_to_response(report) for report in reports]


def report_to_response(report: HealthReport) -> dict:
    return {
        "id": report.id,
        "pms_score": report.pms_score,
        "health_score": report.health_score,
        "risk_level": report.risk_level,
        "confidence": report.confidence,
        "summary": report.summary,
        "main_factors": _loads(report.main_factors_json),
        "care_tips": _loads(report.care_tips_json),
        "recommended_category": report.recommended_category,
        "disclaimer": DISCLAIMER,
        "created_at": report.created_at,
    }


def _recent(db: Session, model, user_id: int, limit: int):
    return (
        db.query(model)
        .filter(model.user_id == user_id)
        .order_by(model.created_at.desc())
        .limit(limit)
        .all()
    )


def _summary(score: ScoreResult) -> str:
    risk_label = {"low": "낮음", "medium": "보통", "high": "높음"}[score.risk_level]
    confidence_label = {"low": "낮은", "medium": "보통", "high": "높은"}[score.confidence]
    lead = (
        f"최근 기록을 바탕으로 PMS 위험도는 {risk_label} 수준으로 계산되었어요. "
        f"현재 분석 신뢰도는 {confidence_label} 편이에요. "
    )
    if score.risk_level == "high":
        return (
            lead
            + "오늘은 무리한 활동보다 휴식과 수분 섭취를 우선해보세요. "
            + "증상이 심하거나 갑자기 악화되는 경우 즉시 의료진 또는 응급의료기관에 문의하세요."
        )
    if score.risk_level == "medium":
        return (
            lead
            + "수면과 통증, 감정 변화를 함께 살펴보며 가벼운 스트레칭과 휴식을 추천해요. "
            + "증상이 반복되거나 강해진다면 가까운 의료기관에 문의해보세요."
        )
    return (
        lead
        + "아직 큰 위험 신호는 적게 기록되었지만, 꾸준히 컨디션을 기록하면 더 안정적인 참고 정보를 받을 수 있어요."
    )


def _loads(value: str) -> list[str]:
    try:
        loaded = json.loads(value)
    except json.JSONDecodeError:
        return []
    return loaded if isinstance(loaded, list) else []
