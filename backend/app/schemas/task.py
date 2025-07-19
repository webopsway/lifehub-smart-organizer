from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from ..models.task import TaskPriority, TaskStatus


class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    priority: TaskPriority = TaskPriority.MEDIUM
    due_date: Optional[datetime] = None


class TaskCreate(TaskBase):
    pass


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    priority: Optional[TaskPriority] = None
    status: Optional[TaskStatus] = None
    completed: Optional[bool] = None
    due_date: Optional[datetime] = None


class TaskResponse(TaskBase):
    id: int
    status: TaskStatus
    completed: bool
    completed_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    user_id: int

    class Config:
        from_attributes = True 