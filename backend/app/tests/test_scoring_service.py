from datetime import date, datetime, timedelta
from types import SimpleNamespace

from app.services.scoring_service import calculate_pms_score


def _cycle(start: date, end: date | None = None, length: int = 28):
    return SimpleNamespace(start_date=start, end_date=end, cycle_length=length, created_at=datetime.combine(start, datetime.min.time()))


def _pain(score: int, pain_type: str = "menstrual_cramp", days_ago: int = 0):
    return SimpleNamespace(
        pain_type=pain_type,
        pain_score=score,
        created_at=datetime(2026, 6, 11) - timedelta(days=days_ago),
    )


def _emotion(emotion_type: str, intensity: int, days_ago: int = 0):
    return SimpleNamespace(
        emotion_type=emotion_type,
        intensity=intensity,
        created_at=datetime(2026, 6, 11) - timedelta(days=days_ago),
    )


def _sleep(hours: float):
    return SimpleNamespace(sleep_hours=hours, created_at=datetime(2026, 6, 11))


def test_pms_score_is_clamped_between_0_and_100():
    result = calculate_pms_score(
        cycles=[_cycle(date(2026, 6, 8), end=date(2026, 6, 15), length=40), _cycle(date(2026, 5, 1), length=20)],
        emotions=[_emotion("anxious", 5, days_ago=i % 7) for i in range(20)],
        sleep_logs=[_sleep(4) for _ in range(10)],
        pain_logs=[_pain(10, days_ago=i % 7) for i in range(20)],
        today=date(2026, 6, 11),
    )

    assert 0 <= result.pms_score <= 100
    assert 0 <= result.health_score <= 100


def test_high_pain_increases_pms_score():
    baseline = calculate_pms_score(today=date(2026, 6, 11))
    with_pain = calculate_pms_score(pain_logs=[_pain(9)], today=date(2026, 6, 11))

    assert with_pain.pms_score > baseline.pms_score


def test_poor_sleep_increases_pms_score():
    normal_sleep = calculate_pms_score(sleep_logs=[_sleep(7.5)], today=date(2026, 6, 11))
    poor_sleep = calculate_pms_score(sleep_logs=[_sleep(5.0)], today=date(2026, 6, 11))

    assert poor_sleep.pms_score > normal_sleep.pms_score


def test_negative_emotions_increase_pms_score():
    positive = calculate_pms_score(emotions=[_emotion("happy", 5)], today=date(2026, 6, 11))
    negative = calculate_pms_score(emotions=[_emotion("anxious", 5)], today=date(2026, 6, 11))

    assert negative.pms_score > positive.pms_score


def test_current_or_near_period_phase_affects_pms_score():
    baseline = calculate_pms_score(cycles=[_cycle(date(2026, 1, 1), length=28)], today=date(2026, 6, 11))
    near_period = calculate_pms_score(cycles=[_cycle(date(2026, 5, 20), length=28)], today=date(2026, 6, 10))
    current_period = calculate_pms_score(cycles=[_cycle(date(2026, 6, 9), end=date(2026, 6, 13), length=28)], today=date(2026, 6, 11))

    assert near_period.pms_score > baseline.pms_score
    assert current_period.pms_score > baseline.pms_score


def test_low_data_returns_low_confidence():
    result = calculate_pms_score(emotions=[_emotion("sad", 2)], today=date(2026, 6, 11))

    assert result.confidence == "low"


def test_enough_logs_across_three_record_types_returns_high_confidence():
    result = calculate_pms_score(
        cycles=[_cycle(date(2026, 5, 1)), _cycle(date(2026, 5, 29))],
        emotions=[_emotion("sad", 3) for _ in range(4)],
        sleep_logs=[_sleep(6.5) for _ in range(4)],
        today=date(2026, 6, 11),
    )

    assert result.confidence == "high"
