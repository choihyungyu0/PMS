import pytest
import re

from app.core.config import DEFAULT_LOCAL_CORS_ORIGIN_REGEX, _normalize_database_url


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


def test_default_local_cors_regex_allows_flutter_web_ports():
    pattern = re.compile(DEFAULT_LOCAL_CORS_ORIGIN_REGEX)

    assert pattern.match("http://localhost:60057")
    assert pattern.match("http://127.0.0.1:60057")
