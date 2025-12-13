from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from pydantic import ConfigDict
from src.modules.likes.schemas import LikeRead
from src.modules.comments.schemas import CommentRead
from src.modules.tags.schemas import TagRead


class PhotoBase(BaseModel):
    title: Optional[str] = None
    name: Optional[str] = None
    path: str
    visible: bool = True


class PhotoCreate(PhotoBase):
    album_id: int


class PhotoUpdate(BaseModel):
    title: Optional[str] = None
    name: Optional[str] = None
    path: Optional[str] = None
    visible: Optional[bool] = None


class PhotoRead(PhotoBase):
    id: int
    created_at: datetime
    album_id: int
    
    comments: List[CommentRead] = []
    likes: List[LikeRead] = []
    tags: List[TagRead] = []
    

    model_config = ConfigDict(from_attributes=True)
