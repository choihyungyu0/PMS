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

        login = client.post(
            "/api/auth/login",
            json={"email": "demo@example.com", "password": "password123"},
        )
        assert login.status_code == 200
        token = login.json()["access_token"]

        me = client.get("/api/users/me", headers={"Authorization": f"Bearer {token}"})
        assert me.status_code == 200
        assert me.json()["email"] == "demo@example.com"
    finally:
        app.dependency_overrides.clear()
