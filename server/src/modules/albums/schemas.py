from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from pydantic import ConfigDict
from src.modules.photos.schemas import PhotoRead


class AlbumBase(BaseModel):
    title: str
    visible: bool = True


class AlbumCreate(AlbumBase):
    user_id: int


class AlbumUpdate(BaseModel):
    title: Optional[str] = None
    visible: Optional[bool] = None


class AlbumRead(AlbumBase):
    id: int
    user_id: int
    created_at: datetime
    photos: List[PhotoRead] = []

    model_config = ConfigDict(from_attributes=True)
