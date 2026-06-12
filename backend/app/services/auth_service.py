from fastapi import Depends, HTTPException, status
from jose import JWTError
from sqlalchemy.orm import Session

from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_access_token,
    get_password_hash,
    oauth2_scheme,
    verify_password,
)
from app.db.database import get_db
from app.db.models import User
from app.schemas.auth import SignupRequest


def create_user(db: Session, payload: SignupRequest) -> User:
    existing = db.query(User).filter(User.email == payload.email.lower()).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email is already registered.",
        )

    user = User(
        email=payload.email.lower(),
        password_hash=get_password_hash(payload.password),
        nickname=payload.nickname,
        birth_date=payload.birth_date,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def authenticate_user(db: Session, email: str, password: str) -> User | None:
    user = db.query(User).filter(User.email == email.lower()).first()
    if not user or not verify_password(password, user.password_hash):
        return None
    return user


def issue_token_for_user(user: User) -> dict[str, str]:
    subject = str(user.id)
    return {
        "access_token": create_access_token(subject),
        "refresh_token": create_refresh_token(subject),
        "token_type": "bearer",
    }


def issue_token_from_refresh(db: Session, refresh_token: str) -> dict[str, str]:
    credentials_error = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate refresh token.",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = decode_access_token(refresh_token)
        if payload.get("token_use") != "refresh":
            raise credentials_error
        user_id = int(payload.get("sub"))
    except (JWTError, TypeError, ValueError) as exc:
        raise credentials_error from exc

    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise credentials_error
    return issue_token_for_user(user)


def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> User:
    credentials_error = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials.",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = decode_access_token(token)
        if payload.get("token_use", "access") != "access":
            raise credentials_error
        user_id = payload.get("sub")
        user_id_int = int(user_id)
    except (JWTError, TypeError, ValueError) as exc:
        raise credentials_error from exc

    if user_id is None:
        raise credentials_error

    user = db.query(User).filter(User.id == user_id_int).first()
    if user is None:
        raise credentials_error
    return user
