from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Float, Text, Enum
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from enum import Enum as PyEnum
from ..database import Base


class BudgetCategoryType(PyEnum):
    ALIMENTATION = "alimentation"
    TRANSPORT = "transport"
    LOGEMENT = "logement"
    LOISIRS = "loisirs"
    SANTE = "santé"
    VETEMENTS = "vêtements"
    EDUCATION = "éducation"
    EPARGNE = "épargne"
    AUTRE = "autre"


class TransactionType(PyEnum):
    INCOME = "income"      # Revenus
    EXPENSE = "expense"    # Dépenses
    TRANSFER = "transfer"  # Virements


class BudgetCategory(Base):
    __tablename__ = "budget_categories"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    category_type = Column(Enum(BudgetCategoryType), nullable=False)
    monthly_budget = Column(Float, nullable=False, default=0.0)
    color = Column(String(7), default="#3B82F6")  # Couleur hex
    icon = Column(String(50), nullable=True)
    description = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Clé étrangère vers User
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Relations
    owner = relationship("User", back_populates="budget_categories")
    transactions = relationship("BudgetTransaction", back_populates="category", cascade="all, delete-orphan")
    
    @property
    def spent_this_month(self):
        """Calcule le montant dépensé ce mois-ci pour cette catégorie"""
        # Cette propriété sera calculée via une requête SQL dans les services
        return 0
    
    @property
    def remaining_budget(self):
        """Budget restant pour ce mois"""
        return self.monthly_budget - self.spent_this_month
    
    @property
    def budget_percentage_used(self):
        """Pourcentage du budget utilisé"""
        if self.monthly_budget > 0:
            return (self.spent_this_month / self.monthly_budget) * 100
        return 0


class BudgetTransaction(Base):
    __tablename__ = "budget_transactions"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    amount = Column(Float, nullable=False)
    transaction_type = Column(Enum(TransactionType), nullable=False)
    transaction_date = Column(DateTime(timezone=True), server_default=func.now())
    receipt_url = Column(String(500), nullable=True)  # URL vers un justificatif
    tags = Column(String(500), nullable=True)  # Tags séparés par des virgules
    is_recurring = Column(Boolean, default=False)
    recurring_interval = Column(String(50), nullable=True)  # monthly, weekly, yearly
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Clés étrangères
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    category_id = Column(Integer, ForeignKey("budget_categories.id"), nullable=True)
    
    # Relations
    owner = relationship("User", back_populates="budget_transactions")
    category = relationship("BudgetCategory", back_populates="transactions")
    
    @property
    def tags_list(self):
        """Retourne les tags sous forme de liste"""
        if self.tags:
            return [tag.strip() for tag in self.tags.split(",")]
        return []
    
    def add_tag(self, tag: str):
        """Ajouter un tag"""
        current_tags = self.tags_list
        if tag not in current_tags:
            current_tags.append(tag)
            self.tags = ", ".join(current_tags)
    
    def remove_tag(self, tag: str):
        """Supprimer un tag"""
        current_tags = self.tags_list
        if tag in current_tags:
            current_tags.remove(tag)
            self.tags = ", ".join(current_tags) 