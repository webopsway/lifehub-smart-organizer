from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from ..models.budget import BudgetCategoryType, TransactionType


class BudgetCategoryBase(BaseModel):
    name: str
    category_type: BudgetCategoryType
    monthly_budget: float
    color: str = "#3B82F6"
    icon: Optional[str] = None
    description: Optional[str] = None


class BudgetCategoryCreate(BudgetCategoryBase):
    pass


class BudgetCategoryUpdate(BaseModel):
    name: Optional[str] = None
    category_type: Optional[BudgetCategoryType] = None
    monthly_budget: Optional[float] = None
    color: Optional[str] = None
    icon: Optional[str] = None
    description: Optional[str] = None
    is_active: Optional[bool] = None


class BudgetCategoryResponse(BudgetCategoryBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime
    user_id: int
    spent_this_month: float
    remaining_budget: float
    budget_percentage_used: float

    class Config:
        from_attributes = True


class BudgetTransactionBase(BaseModel):
    title: str
    description: Optional[str] = None
    amount: float
    transaction_type: TransactionType
    transaction_date: Optional[datetime] = None
    receipt_url: Optional[str] = None
    tags: Optional[str] = None
    is_recurring: bool = False
    recurring_interval: Optional[str] = None


class BudgetTransactionCreate(BudgetTransactionBase):
    category_id: Optional[int] = None


class BudgetTransactionUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    amount: Optional[float] = None
    transaction_type: Optional[TransactionType] = None
    transaction_date: Optional[datetime] = None
    receipt_url: Optional[str] = None
    tags: Optional[str] = None
    is_recurring: Optional[bool] = None
    recurring_interval: Optional[str] = None
    category_id: Optional[int] = None


class BudgetTransactionResponse(BudgetTransactionBase):
    id: int
    created_at: datetime
    updated_at: datetime
    user_id: int
    category_id: Optional[int] = None
    tags_list: List[str]

    class Config:
        from_attributes = True


class BudgetOverview(BaseModel):
    """Aperçu global du budget"""
    total_budget: float
    total_spent: float
    remaining_budget: float
    categories: List[BudgetCategoryResponse] 