from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.db.database import Base, engine
from app.routers import auth, cycles, emotions, health, institutions, pain, reports, sleep, users


app = FastAPI(
    title="MORE Cycle API",
    description="Rule-based women's lifecycle wellness API for the MORE Cycle MVP.",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_origin_regex=settings.cors_origin_regex,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup() -> None:
    Base.metadata.create_all(bind=engine)


app.include_router(health.router, prefix="/api")
app.include_router(auth.router, prefix="/api")
app.include_router(users.router, prefix="/api")
app.include_router(cycles.router, prefix="/api")
app.include_router(emotions.router, prefix="/api")
app.include_router(sleep.router, prefix="/api")
app.include_router(pain.router, prefix="/api")
app.include_router(reports.router, prefix="/api")
app.include_router(institutions.router, prefix="/api")
