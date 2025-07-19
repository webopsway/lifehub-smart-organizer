from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Enum, Float
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from enum import Enum as PyEnum
from ..database import Base


class ShoppingCategory(PyEnum):
    FRAIS = "frais"
    LEGUMES = "légumes"
    BOULANGERIE = "boulangerie"
    EPICERIE = "épicerie"
    VIANDE = "viande"
    POISSON = "poisson"
    PRODUITS_MENAGERS = "produits_ménagers"
    HYGIENE = "hygiène"
    AUTRE = "autre"


class ShoppingItem(Base):
    __tablename__ = "shopping_items"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    quantity = Column(Integer, default=1)
    unit = Column(String(50), default="unité")  # kg, L, unité, etc.
    estimated_price = Column(Float, nullable=True)
    actual_price = Column(Float, nullable=True)
    category = Column(Enum(ShoppingCategory), default=ShoppingCategory.EPICERIE)
    notes = Column(String(500), nullable=True)
    completed = Column(Boolean, default=False)
    purchased_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Clé étrangère vers User
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Relations
    owner = relationship("User", back_populates="shopping_items")
    
    def mark_purchased(self, actual_price: float = None):
        """Marquer l'article comme acheté"""
        self.completed = True
        self.purchased_at = func.now()
        if actual_price is not None:
            self.actual_price = actual_price
    
    def mark_unpurchased(self):
        """Marquer l'article comme non acheté"""
        self.completed = False
        self.purchased_at = None
        self.actual_price = None
    
    @property
    def total_estimated_cost(self):
        """Coût total estimé (quantité × prix estimé)"""
        if self.estimated_price:
            return self.quantity * self.estimated_price
        return 0
    
    @property
    def total_actual_cost(self):
        """Coût total réel (quantité × prix réel)"""
        if self.actual_price:
            return self.quantity * self.actual_price
        return 0 