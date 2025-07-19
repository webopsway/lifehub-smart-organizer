from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from ..models.shopping import ShoppingCategory


class ShoppingItemBase(BaseModel):
    name: str
    quantity: int = 1
    unit: str = "unité"
    estimated_price: Optional[float] = None
    category: ShoppingCategory = ShoppingCategory.EPICERIE
    notes: Optional[str] = None


class ShoppingItemCreate(ShoppingItemBase):
    pass


class ShoppingItemUpdate(BaseModel):
    name: Optional[str] = None
    quantity: Optional[int] = None
    unit: Optional[str] = None
    estimated_price: Optional[float] = None
    actual_price: Optional[float] = None
    category: Optional[ShoppingCategory] = None
    notes: Optional[str] = None
    completed: Optional[bool] = None


class ShoppingItemResponse(ShoppingItemBase):
    id: int
    actual_price: Optional[float] = None
    completed: bool
    purchased_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    user_id: int
    total_estimated_cost: float
    total_actual_cost: float

    class Config:
        from_attributes = True 