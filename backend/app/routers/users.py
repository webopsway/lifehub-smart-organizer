from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..auth import get_current_active_user, get_password_hash
from ..models.user import User
from ..schemas.user import UserUpdate, UserResponse

router = APIRouter()


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: User = Depends(get_current_active_user)):
    """Obtenir les informations de l'utilisateur actuel"""
    return current_user


@router.put("/me", response_model=UserResponse)
async def update_current_user(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Mettre à jour les informations de l'utilisateur actuel"""
    update_data = user_update.dict(exclude_unset=True)
    
    # Si un nouveau mot de passe est fourni, le hasher
    if "password" in update_data:
        update_data["hashed_password"] = get_password_hash(update_data.pop("password"))
    
    # Vérifier l'unicité de l'email et du username si modifiés
    if "email" in update_data and update_data["email"] != current_user.email:
        existing_email = db.query(User).filter(User.email == update_data["email"]).first()
        if existing_email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Un utilisateur avec cet email existe déjà"
            )
    
    if "username" in update_data and update_data["username"] != current_user.username:
        existing_username = db.query(User).filter(User.username == update_data["username"]).first()
        if existing_username:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Ce nom d'utilisateur est déjà pris"
            )
    
    # Mettre à jour l'utilisateur
    for field, value in update_data.items():
        setattr(current_user, field, value)
    
    db.commit()
    db.refresh(current_user)
    
    return current_user


@router.delete("/me")
async def delete_current_user(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Supprimer le compte de l'utilisateur actuel"""
    db.delete(current_user)
    db.commit()
    return {"message": "Compte supprimé avec succès"} 