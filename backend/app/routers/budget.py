from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func, extract
from typing import List, Optional
from datetime import datetime, date
from ..database import get_db
from ..auth import get_current_active_user
from ..models.user import User
from ..models.budget import BudgetCategory, BudgetTransaction, TransactionType
from ..schemas.budget import (
    BudgetCategoryCreate, BudgetCategoryUpdate, BudgetCategoryResponse,
    BudgetTransactionCreate, BudgetTransactionUpdate, BudgetTransactionResponse,
    BudgetOverview
)

router = APIRouter()


# === CATEGORIES ===

@router.get("/categories", response_model=List[BudgetCategoryResponse])
async def get_budget_categories(
    is_active: Optional[bool] = None,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Obtenir toutes les catégories de budget de l'utilisateur"""
    query = db.query(BudgetCategory).filter(BudgetCategory.user_id == current_user.id)
    
    if is_active is not None:
        query = query.filter(BudgetCategory.is_active == is_active)
    
    categories = query.all()
    
    # Calculer les dépenses pour chaque catégorie
    current_month = datetime.now().month
    current_year = datetime.now().year
    
    for category in categories:
        spent = db.query(func.sum(BudgetTransaction.amount)).filter(
            BudgetTransaction.category_id == category.id,
            BudgetTransaction.transaction_type == TransactionType.EXPENSE,
            extract('month', BudgetTransaction.transaction_date) == current_month,
            extract('year', BudgetTransaction.transaction_date) == current_year
        ).scalar() or 0
        
        category.spent_this_month = spent
    
    return categories


@router.get("/categories/{category_id}", response_model=BudgetCategoryResponse)
async def get_budget_category(
    category_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Obtenir une catégorie de budget spécifique"""
    category = db.query(BudgetCategory).filter(
        BudgetCategory.id == category_id,
        BudgetCategory.user_id == current_user.id
    ).first()
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Catégorie non trouvée"
        )
    
    # Calculer les dépenses pour cette catégorie
    current_month = datetime.now().month
    current_year = datetime.now().year
    spent = db.query(func.sum(BudgetTransaction.amount)).filter(
        BudgetTransaction.category_id == category.id,
        BudgetTransaction.transaction_type == TransactionType.EXPENSE,
        extract('month', BudgetTransaction.transaction_date) == current_month,
        extract('year', BudgetTransaction.transaction_date) == current_year
    ).scalar() or 0
    
    category.spent_this_month = spent
    
    return category


@router.post("/categories", response_model=BudgetCategoryResponse)
async def create_budget_category(
    category_data: BudgetCategoryCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Créer une nouvelle catégorie de budget"""
    db_category = BudgetCategory(
        **category_data.dict(),
        user_id=current_user.id
    )
    
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    
    return db_category


@router.put("/categories/{category_id}", response_model=BudgetCategoryResponse)
async def update_budget_category(
    category_id: int,
    category_update: BudgetCategoryUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Mettre à jour une catégorie de budget"""
    category = db.query(BudgetCategory).filter(
        BudgetCategory.id == category_id,
        BudgetCategory.user_id == current_user.id
    ).first()
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Catégorie non trouvée"
        )
    
    update_data = category_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(category, field, value)
    
    db.commit()
    db.refresh(category)
    
    return category


@router.delete("/categories/{category_id}")
async def delete_budget_category(
    category_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Supprimer une catégorie de budget"""
    category = db.query(BudgetCategory).filter(
        BudgetCategory.id == category_id,
        BudgetCategory.user_id == current_user.id
    ).first()
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Catégorie non trouvée"
        )
    
    db.delete(category)
    db.commit()
    
    return {"message": "Catégorie supprimée avec succès"}


# === TRANSACTIONS ===

@router.get("/transactions", response_model=List[BudgetTransactionResponse])
async def get_budget_transactions(
    category_id: Optional[int] = None,
    transaction_type: Optional[TransactionType] = None,
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Obtenir toutes les transactions de budget de l'utilisateur"""
    query = db.query(BudgetTransaction).filter(BudgetTransaction.user_id == current_user.id)
    
    if category_id:
        query = query.filter(BudgetTransaction.category_id == category_id)
    
    if transaction_type:
        query = query.filter(BudgetTransaction.transaction_type == transaction_type)
    
    if start_date:
        query = query.filter(BudgetTransaction.transaction_date >= start_date)
    
    if end_date:
        query = query.filter(BudgetTransaction.transaction_date <= end_date)
    
    transactions = query.order_by(BudgetTransaction.transaction_date.desc()).offset(skip).limit(limit).all()
    return transactions


@router.post("/transactions", response_model=BudgetTransactionResponse)
async def create_budget_transaction(
    transaction_data: BudgetTransactionCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Créer une nouvelle transaction de budget"""
    # Vérifier que la catégorie appartient à l'utilisateur si fournie
    if transaction_data.category_id:
        category = db.query(BudgetCategory).filter(
            BudgetCategory.id == transaction_data.category_id,
            BudgetCategory.user_id == current_user.id
        ).first()
        if not category:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Catégorie non trouvée"
            )
    
    db_transaction = BudgetTransaction(
        **transaction_data.dict(),
        user_id=current_user.id
    )
    
    db.add(db_transaction)
    db.commit()
    db.refresh(db_transaction)
    
    return db_transaction


@router.put("/transactions/{transaction_id}", response_model=BudgetTransactionResponse)
async def update_budget_transaction(
    transaction_id: int,
    transaction_update: BudgetTransactionUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Mettre à jour une transaction de budget"""
    transaction = db.query(BudgetTransaction).filter(
        BudgetTransaction.id == transaction_id,
        BudgetTransaction.user_id == current_user.id
    ).first()
    if not transaction:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Transaction non trouvée"
        )
    
    update_data = transaction_update.dict(exclude_unset=True)
    
    # Vérifier la catégorie si modifiée
    if "category_id" in update_data and update_data["category_id"]:
        category = db.query(BudgetCategory).filter(
            BudgetCategory.id == update_data["category_id"],
            BudgetCategory.user_id == current_user.id
        ).first()
        if not category:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Catégorie non trouvée"
            )
    
    for field, value in update_data.items():
        setattr(transaction, field, value)
    
    db.commit()
    db.refresh(transaction)
    
    return transaction


@router.delete("/transactions/{transaction_id}")
async def delete_budget_transaction(
    transaction_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Supprimer une transaction de budget"""
    transaction = db.query(BudgetTransaction).filter(
        BudgetTransaction.id == transaction_id,
        BudgetTransaction.user_id == current_user.id
    ).first()
    if not transaction:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Transaction non trouvée"
        )
    
    db.delete(transaction)
    db.commit()
    
    return {"message": "Transaction supprimée avec succès"}


# === OVERVIEW ===

@router.get("/overview", response_model=BudgetOverview)
async def get_budget_overview(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Obtenir l'aperçu global du budget"""
    current_month = datetime.now().month
    current_year = datetime.now().year
    
    # Obtenir toutes les catégories actives
    categories = db.query(BudgetCategory).filter(
        BudgetCategory.user_id == current_user.id,
        BudgetCategory.is_active == True
    ).all()
    
    total_budget = 0
    total_spent = 0
    
    # Calculer les dépenses pour chaque catégorie
    for category in categories:
        spent = db.query(func.sum(BudgetTransaction.amount)).filter(
            BudgetTransaction.category_id == category.id,
            BudgetTransaction.transaction_type == TransactionType.EXPENSE,
            extract('month', BudgetTransaction.transaction_date) == current_month,
            extract('year', BudgetTransaction.transaction_date) == current_year
        ).scalar() or 0
        
        category.spent_this_month = spent
        total_budget += category.monthly_budget
        total_spent += spent
    
    return BudgetOverview(
        total_budget=total_budget,
        total_spent=total_spent,
        remaining_budget=total_budget - total_spent,
        categories=categories
    ) 