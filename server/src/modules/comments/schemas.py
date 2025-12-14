from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from pydantic import ConfigDict

from src.modules.users.schemas import UserOutWithoutToken


class CommentBase(BaseModel):
    text: str
    is_deleted: bool = False


class CommentCreate(CommentBase):
    user_id: int
    photo_id: int


class CommentUpdate(BaseModel):
    text: Optional[str] = None
    is_deleted: Optional[bool] = None


class CommentRead(CommentBase):
    id: int
    created_at: datetime
    user_id: int
    photo_id: int

    user: UserOutWithoutToken

    model_config = ConfigDict(from_attributes=True)
