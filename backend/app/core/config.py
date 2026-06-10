import os
from pathlib import Path


class Settings:
    backend_dir = Path(__file__).resolve().parents[2]
    data_dir = backend_dir / "data"
    medical_csv_path = data_dir / "mc_incheon_medical.csv"

    database_url = os.getenv(
        "MORE_CYCLE_DATABASE_URL",
        f"sqlite:///{backend_dir / 'more_cycle.db'}",
    ).replace("\\", "/")
    secret_key = os.getenv("MORE_CYCLE_SECRET_KEY", "change-this-local-demo-secret")
    algorithm = "HS256"
    access_token_expire_minutes = int(
        os.getenv("MORE_CYCLE_ACCESS_TOKEN_EXPIRE_MINUTES", "1440")
    )
    cors_origins = [
        origin.strip()
        for origin in os.getenv(
            "MORE_CYCLE_CORS_ORIGINS",
            "http://localhost:5173,http://127.0.0.1:5173,http://localhost:3000",
        ).split(",")
        if origin.strip()
    ]


settings = Settings()
