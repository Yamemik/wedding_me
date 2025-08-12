from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from pydantic import ConfigDict


class LikeBase(BaseModel):
    user_id: int
    photo_id: int


class LikeCreate(LikeBase):
    pass


class LikeUpdate(BaseModel):
    pass  # likes usually don't update fields


class LikeRead(LikeBase):
    id: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
