import pytest

from app.core.config import _normalize_database_url


def test_placeholder_database_password_is_rejected():
    with pytest.raises(ValueError, match="placeholder database password"):
        _normalize_database_url(
            "postgresql://postgres:CHANGE_ME_DATABASE_PASSWORD@db.xvphevruvqlnmpdmsxki.supabase.co:5432/postgres"
        )


def test_postgres_scheme_is_normalized():
    url = _normalize_database_url("postgres://user:pass@example.com:5432/postgres")

    assert url == "postgresql://user:pass@example.com:5432/postgres"


def test_supabase_postgres_url_requires_ssl():
    url = _normalize_database_url(
        "postgresql://postgres:pass@db.xvphevruvqlnmpdmsxki.supabase.co:5432/postgres"
    )

    assert url.endswith("?sslmode=require")


def test_existing_sslmode_is_preserved():
    url = _normalize_database_url(
        "postgresql://postgres:pass@db.xvphevruvqlnmpdmsxki.supabase.co:5432/postgres?sslmode=require"
    )

    assert url.count("sslmode=require") == 1
