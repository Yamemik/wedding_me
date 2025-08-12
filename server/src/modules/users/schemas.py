from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    email: EmailStr
    surname: str
    name: str
    patr: Optional[str] = None
    is_admin: bool = False


class UserCreate(UserBase):
    password: str


class UserUpdate(BaseModel):
    email: Optional[EmailStr]
    surname: Optional[str]
    name: Optional[str]
    patr: Optional[str]
    password: Optional[str]
    is_admin: Optional[bool]


class UserOut(UserBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

    
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TokenPayload(BaseModel):
    sub: str  # email
    exp: int | None = None
