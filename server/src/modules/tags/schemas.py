from pydantic import BaseModel
from typing import Optional
from pydantic import ConfigDict


class TagBase(BaseModel):
    name: str
    color: str


class TagCreate(TagBase):
    pass


class TagUpdate(BaseModel):
    name: Optional[str] = None
    color: Optional[str] = None


class TagRead(TagBase):
    id: int

    model_config = ConfigDict(from_attributes=True)


class PhotoTagBase(BaseModel):
    photo_id: int
    tag_id: int


class PhotoTagCreate(PhotoTagBase):
    pass


class PhotoTagRead(PhotoTagBase):
    id: int

    model_config = ConfigDict(from_attributes=True)
