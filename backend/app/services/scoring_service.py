from collections import Counter
from dataclasses import dataclass
from datetime import date, datetime, timedelta
from statistics import mean
from typing import Iterable, Sequence


NEGATIVE_EMOTIONS = {"anxious", "sad", "angry", "irritated", "tired"}
MENSTRUAL_PAIN_TYPES = {"menstrual_cramp", "abdominal_pain", "back_pain", "breast_pain"}


@dataclass(frozen=True)
class ScoreResult:
    pms_score: int
    health_score: int
    risk_level: str
    confidence: str
    main_factors: list[str]
    care_tips: list[str]
    recommended_category: str | None


def calculate_pms_score(
    cycles: Sequence[object] | None = None,
    emotions: Sequence[object] | None = None,
    sleep_logs: Sequence[object] | None = None,
    pain_logs: Sequence[object] | None = None,
    today: date | None = None,
) -> ScoreResult:
    cycles = list(cycles or [])
    emotions = list(emotions or [])
    sleep_logs = list(sleep_logs or [])
    pain_logs = list(pain_logs or [])
    today = today or date.today()

    score = 10.0
    main_factors: list[str] = []

    cycle_factor = _cycle_phase_factor(cycles, today)
    if cycle_factor:
        score += cycle_factor
        main_factors.append(
            "월경 주기상 증상이 나타나기 쉬운 시기에 가까운 기록이 있어요."
            if cycle_factor >= 15
            else "현재 월경 기간으로 기록되어 있어요."
        )

    pain_scores = [_number(log, "pain_score") for log in pain_logs]
    pain_scores = [value for value in pain_scores if value is not None]
    pain_factor = min(mean(pain_scores) * 2.0, 20.0) if pain_scores else 0.0
    if pain_factor:
        score += pain_factor
        main_factors.append("최근 통증 점수가 PMS 위험도 계산에 반영되었어요.")

    negative_emotions = [
        _number(log, "intensity")
        for log in emotions
        if _text(log, "emotion_type") in NEGATIVE_EMOTIONS
    ]
    negative_emotions = [value for value in negative_emotions if value is not None]
    emotion_factor = min(mean(negative_emotions) * 4.0, 20.0) if negative_emotions else 0.0
    if emotion_factor:
        score += emotion_factor
        main_factors.append("불안, 슬픔, 짜증, 피로 같은 감정 기록이 함께 나타났어요.")

    sleep_hours = [_number(log, "sleep_hours") for log in sleep_logs]
    sleep_hours = [value for value in sleep_hours if value is not None]
    sleep_factor = _sleep_factor(sleep_hours)
    if sleep_factor:
        score += sleep_factor
        main_factors.append("최근 수면 시간이 컨디션에 부담을 줄 수 있는 범위로 기록되었어요.")

    if _has_cycle_irregularity(cycles):
        score += 10
        main_factors.append("최근 월경 주기 길이의 변동폭이 크게 기록되었어요.")

    if _symptom_density(emotions, pain_logs, today) >= 3:
        score += 10
        main_factors.append("최근 7일 안에 통증 또는 감정 증상 기록이 반복되었어요.")

    pms_score = _clamp_int(score, 0, 100)
    health_score = _health_score(pms_score, sleep_factor, pain_factor, emotion_factor)

    if not main_factors:
        main_factors.append("아직 두드러진 위험 요인은 적게 기록되었어요.")

    return ScoreResult(
        pms_score=pms_score,
        health_score=health_score,
        risk_level=_risk_level(pms_score),
        confidence=_confidence(cycles, emotions, sleep_logs, pain_logs),
        main_factors=main_factors,
        care_tips=_care_tips(sleep_factor, pain_factor, emotion_factor),
        recommended_category=_recommended_category(cycles, emotions, pain_logs),
    )


def _cycle_phase_factor(cycles: Sequence[object], today: date) -> int:
    latest = _latest_by(cycles, "start_date")
    if latest is None:
        return 0

    start_date = _as_date(_value(latest, "start_date"))
    end_date = _as_date(_value(latest, "end_date"))
    if start_date is None:
        return 0

    if end_date is not None and start_date <= today <= end_date:
        return 10
    if end_date is None and 0 <= (today - start_date).days <= 7:
        return 10

    cycle_length = _number(latest, "cycle_length") or _average_cycle_length(cycles) or 28
    predicted_start = start_date + timedelta(days=int(cycle_length))
    days_until = (predicted_start - today).days
    if 1 <= days_until <= 7:
        return 25
    if 8 <= days_until <= 14:
        return 15
    return 0


def _sleep_factor(sleep_hours: Sequence[float]) -> int:
    if not sleep_hours:
        return 0
    average_sleep = mean(sleep_hours)
    if average_sleep < 6:
        return 15
    if 6 <= average_sleep < 7:
        return 8
    if average_sleep > 9:
        return 5
    return 0


def _has_cycle_irregularity(cycles: Sequence[object]) -> bool:
    lengths = [_number(cycle, "cycle_length") for cycle in cycles]
    lengths = [int(value) for value in lengths if value is not None]
    return len(lengths) >= 2 and max(lengths) - min(lengths) > 7


def _symptom_density(emotions: Sequence[object], pain_logs: Sequence[object], today: date) -> int:
    start = today - timedelta(days=6)
    symptom_dates: set[date] = set()

    for pain in pain_logs:
        created = _as_date(_value(pain, "created_at"))
        if created and start <= created <= today:
            symptom_dates.add(created)

    for emotion in emotions:
        if _text(emotion, "emotion_type") not in NEGATIVE_EMOTIONS:
            continue
        created = _as_date(_value(emotion, "created_at"))
        if created and start <= created <= today:
            symptom_dates.add(created)

    return len(symptom_dates)


def _recommended_category(
    cycles: Sequence[object],
    emotions: Sequence[object],
    pain_logs: Sequence[object],
) -> str | None:
    if not cycles and not emotions and not pain_logs:
        return None

    counts: Counter[str] = Counter()
    for pain in pain_logs:
        pain_type = _text(pain, "pain_type")
        pain_score = _number(pain, "pain_score") or 0
        if pain_type == "headache" or pain_score >= 8:
            counts["PAIN_NEURO"] += 2
        elif pain_type in MENSTRUAL_PAIN_TYPES:
            counts["WOMEN_HEALTH"] += 2
        elif pain_score > 0:
            counts["PUBLIC_HEALTH"] += 1

    for emotion in emotions:
        if _text(emotion, "emotion_type") in NEGATIVE_EMOTIONS:
            counts["MENTAL_HEALTH"] += 1

    if cycles:
        counts["WOMEN_HEALTH"] += 1

    if not counts:
        return None
    category, count = counts.most_common(1)[0]
    if count == 0:
        return None
    return category


def _care_tips(sleep_factor: float, pain_factor: float, emotion_factor: float) -> list[str]:
    tips = ["충분한 휴식", "수분 섭취", "증상 기록 지속"]
    if sleep_factor:
        tips.append("규칙적인 수면 시간 유지")
    if pain_factor:
        tips.extend(["가벼운 스트레칭", "온찜질"])
    if emotion_factor:
        tips.append("무리한 활동 줄이기")
    tips.append("증상이 지속되거나 악화되면 의료진 상담을 고려하세요.")
    return list(dict.fromkeys(tips))


def _health_score(
    pms_score: int,
    sleep_penalty: float,
    pain_penalty: float,
    emotion_penalty: float,
) -> int:
    weighted_penalty = (
        pms_score * 0.45
        + sleep_penalty * 0.25
        + pain_penalty * 0.20
        + emotion_penalty * 0.10
    )
    return _clamp_int(100 - weighted_penalty, 0, 100)


def _risk_level(score: int) -> str:
    if score <= 39:
        return "low"
    if score <= 69:
        return "medium"
    return "high"


def _confidence(*groups: Sequence[object]) -> str:
    total_logs = sum(len(group) for group in groups)
    record_types = sum(1 for group in groups if group)
    if total_logs < 3:
        return "low"
    if total_logs >= 10 and record_types >= 3:
        return "high"
    return "medium"


def _average_cycle_length(cycles: Sequence[object]) -> float | None:
    lengths = [_number(cycle, "cycle_length") for cycle in cycles]
    lengths = [value for value in lengths if value is not None]
    return mean(lengths) if lengths else None


def _latest_by(items: Iterable[object], field: str) -> object | None:
    values = [item for item in items if _value(item, field) is not None]
    if not values:
        return None
    return max(values, key=lambda item: _value(item, field))


def _value(item: object, field: str):
    if isinstance(item, dict):
        return item.get(field)
    return getattr(item, field, None)


def _text(item: object, field: str) -> str:
    value = _value(item, field)
    return str(value or "").lower()


def _number(item: object, field: str) -> float | None:
    value = _value(item, field)
    if value is None or value == "":
        return None
    return float(value)


def _as_date(value) -> date | None:
    if value is None:
        return None
    if isinstance(value, datetime):
        return value.date()
    if isinstance(value, date):
        return value
    return None


def _clamp_int(value: float, low: int, high: int) -> int:
    return max(low, min(high, round(value)))
