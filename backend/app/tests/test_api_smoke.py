from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from fastapi.testclient import TestClient

from app.db.database import Base, get_db
from app.main import app


def test_health_auth_and_protected_route(tmp_path):
    database_url = f"sqlite:///{tmp_path / 'api_smoke.db'}"
    engine = create_engine(database_url, connect_args={"check_same_thread": False})
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    Base.metadata.create_all(bind=engine)

    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    try:
        client = TestClient(app)

        health = client.get("/api/health")
        assert health.status_code == 200
        assert health.json()["status"] == "ok"

        rejected = client.get("/api/users/me")
        assert rejected.status_code == 401

        signup = client.post(
            "/api/auth/signup",
            json={
                "email": "demo@example.com",
                "password": "password123",
                "nickname": "모어",
                "birth_date": "1995-01-01",
            },
        )
        assert signup.status_code == 200
        assert signup.json()["access_token"]
        assert signup.json()["refresh_token"]

        login = client.post(
            "/api/auth/login",
            json={"email": "demo@example.com", "password": "password123"},
        )
        assert login.status_code == 200
        token_payload = login.json()
        token = token_payload["access_token"]
        refresh_token = token_payload["refresh_token"]

        me = client.get("/api/users/me", headers={"Authorization": f"Bearer {token}"})
        assert me.status_code == 200
        assert me.json()["email"] == "demo@example.com"

        refresh_as_access = client.get(
            "/api/users/me",
            headers={"Authorization": f"Bearer {refresh_token}"},
        )
        assert refresh_as_access.status_code == 401

        refreshed = client.post(
            "/api/auth/refresh",
            json={"refresh_token": refresh_token},
        )
        assert refreshed.status_code == 200
        assert refreshed.json()["access_token"]
        assert refreshed.json()["refresh_token"]

        me_with_refreshed_token = client.get(
            "/api/users/me",
            headers={"Authorization": f"Bearer {refreshed.json()['access_token']}"},
        )
        assert me_with_refreshed_token.status_code == 200
        assert me_with_refreshed_token.json()["email"] == "demo@example.com"
    finally:
        app.dependency_overrides.clear()
