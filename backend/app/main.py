from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from .config import settings
from .database import create_tables
from .routers import auth, users, tasks, shopping, budget

# Gestionnaire de contexte pour le cycle de vie de l'application
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Au démarrage
    create_tables()
    yield
    # À l'arrêt (si nécessaire)
    pass

# Créer l'instance FastAPI
app = FastAPI(
    title="LifeHub API",
    description="API pour l'organisateur personnel LifeHub",
    version="1.0.0",
    lifespan=lifespan,
)

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inclure les routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(users.router, prefix="/api/users", tags=["Users"])
app.include_router(tasks.router, prefix="/api/tasks", tags=["Tasks"])
app.include_router(shopping.router, prefix="/api/shopping", tags=["Shopping"])
app.include_router(budget.router, prefix="/api/budget", tags=["Budget"])


@app.get("/")
async def root():
    """Point d'entrée de l'API"""
    return {
        "message": "LifeHub API",
        "version": "1.0.0",
        "docs": "/docs",
        "redoc": "/redoc"
    }


@app.get("/health")
async def health_check():
    """Vérification de santé de l'API"""
    return {"status": "healthy", "version": "1.0.0"} 