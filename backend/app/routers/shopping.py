from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from ..database import get_db
from ..auth import get_current_active_user
from ..models.user import User
from ..models.shopping import ShoppingItem
from ..schemas.shopping import ShoppingItemCreate, ShoppingItemUpdate, ShoppingItemResponse

router = APIRouter()


@router.get("/", response_model=List[ShoppingItemResponse])
async def get_shopping_items(
    completed: Optional[bool] = None,
    category: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Obtenir tous les articles de courses de l'utilisateur"""
    query = db.query(ShoppingItem).filter(ShoppingItem.user_id == current_user.id)
    
    if completed is not None:
        query = query.filter(ShoppingItem.completed == completed)
    
    if category:
        query = query.filter(ShoppingItem.category == category)
    
    items = query.offset(skip).limit(limit).all()
    return items


@router.get("/{item_id}", response_model=ShoppingItemResponse)
async def get_shopping_item(
    item_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Obtenir un article de courses spécifique"""
    item = db.query(ShoppingItem).filter(
        ShoppingItem.id == item_id, 
        ShoppingItem.user_id == current_user.id
    ).first()
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Article non trouvé"
        )
    return item


@router.post("/", response_model=ShoppingItemResponse)
async def create_shopping_item(
    item_data: ShoppingItemCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Créer un nouvel article de courses"""
    db_item = ShoppingItem(
        **item_data.dict(),
        user_id=current_user.id
    )
    
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    
    return db_item


@router.put("/{item_id}", response_model=ShoppingItemResponse)
async def update_shopping_item(
    item_id: int,
    item_update: ShoppingItemUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Mettre à jour un article de courses"""
    item = db.query(ShoppingItem).filter(
        ShoppingItem.id == item_id, 
        ShoppingItem.user_id == current_user.id
    ).first()
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Article non trouvé"
        )
    
    update_data = item_update.dict(exclude_unset=True)
    
    # Gestion spéciale pour le changement de statut completed
    if "completed" in update_data:
        if update_data["completed"]:
            actual_price = update_data.get("actual_price")
            item.mark_purchased(actual_price)
        else:
            item.mark_unpurchased()
        # Retirer de update_data pour éviter la double mise à jour
        del update_data["completed"]
    
    # Mettre à jour les autres champs
    for field, value in update_data.items():
        setattr(item, field, value)
    
    db.commit()
    db.refresh(item)
    
    return item


@router.delete("/{item_id}")
async def delete_shopping_item(
    item_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Supprimer un article de courses"""
    item = db.query(ShoppingItem).filter(
        ShoppingItem.id == item_id, 
        ShoppingItem.user_id == current_user.id
    ).first()
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Article non trouvé"
        )
    
    db.delete(item)
    db.commit()
    
    return {"message": "Article supprimé avec succès"}


@router.patch("/{item_id}/toggle", response_model=ShoppingItemResponse)
async def toggle_item_completion(
    item_id: int,
    actual_price: Optional[float] = None,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Basculer l'état d'achat d'un article"""
    item = db.query(ShoppingItem).filter(
        ShoppingItem.id == item_id, 
        ShoppingItem.user_id == current_user.id
    ).first()
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Article non trouvé"
        )
    
    if item.completed:
        item.mark_unpurchased()
    else:
        item.mark_purchased(actual_price)
    
    db.commit()
    db.refresh(item)
    
    return item


@router.get("/stats/summary")
async def get_shopping_summary(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Obtenir un résumé des statistiques de courses"""
    total_items = db.query(ShoppingItem).filter(ShoppingItem.user_id == current_user.id).count()
    completed_items = db.query(ShoppingItem).filter(
        ShoppingItem.user_id == current_user.id,
        ShoppingItem.completed == True
    ).count()
    pending_items = total_items - completed_items
    
    return {
        "total_items": total_items,
        "completed_items": completed_items,
        "pending_items": pending_items,
        "completion_rate": (completed_items / total_items * 100) if total_items > 0 else 0
    } 