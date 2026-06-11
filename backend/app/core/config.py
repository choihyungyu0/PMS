import os
from pathlib import Path
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

from dotenv import load_dotenv


BACKEND_DIR = Path(__file__).resolve().parents[2]
load_dotenv(BACKEND_DIR / ".env")
PASSWORD_PLACEHOLDERS = (
    "CHANGE_ME_DATABASE_PASSWORD",
    "[YOUR-PASSWORD]",
    "<YOUR_DB_PASSWORD>",
)


def _normalize_database_url(database_url: str) -> str:
    normalized = database_url.strip()
    if any(placeholder in normalized for placeholder in PASSWORD_PLACEHOLDERS):
        raise ValueError(
            "MORE_CYCLE_DATABASE_URL still contains a placeholder database password. "
            "Replace it with the Supabase database password in backend/.env."
        )

    if normalized.startswith("postgres://"):
        normalized = f"postgresql://{normalized.removeprefix('postgres://')}"

    if normalized.startswith("sqlite"):
        return normalized.replace("\\", "/")

    if normalized.startswith(("postgresql://", "postgresql+psycopg2://")):
        parsed = urlsplit(normalized)
        if parsed.hostname and "supabase" in parsed.hostname and "sslmode=" not in parsed.query:
            query_items = parse_qsl(parsed.query, keep_blank_values=True)
            query_items.append(("sslmode", "require"))
            normalized = urlunsplit(parsed._replace(query=urlencode(query_items)))

    return normalized


class Settings:
    backend_dir = BACKEND_DIR
    data_dir = backend_dir / "data"
    medical_csv_path = data_dir / "mc_incheon_medical.csv"

    database_url = _normalize_database_url(
        os.getenv(
            "MORE_CYCLE_DATABASE_URL",
            f"sqlite:///{backend_dir / 'more_cycle.db'}",
        )
    )
    secret_key = os.getenv("MORE_CYCLE_SECRET_KEY", "change-this-local-demo-secret")
    algorithm = "HS256"
    access_token_expire_minutes = int(
        os.getenv("MORE_CYCLE_ACCESS_TOKEN_EXPIRE_MINUTES", "1440")
    )
    cors_origins = [
        origin.strip()
        for origin in os.getenv(
            "MORE_CYCLE_CORS_ORIGINS",
            ",".join(
                [
                    "http://localhost:5173",
                    "http://127.0.0.1:5173",
                    "http://localhost:3000",
                    "http://127.0.0.1:3000",
                    "http://localhost:8080",
                    "http://127.0.0.1:8080",
                    "http://localhost:8093",
                    "http://127.0.0.1:8093",
                ]
            ),
        ).split(",")
        if origin.strip()
    ]


settings = Settings()
