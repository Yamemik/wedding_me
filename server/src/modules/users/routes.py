from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi.security import OAuth2PasswordRequestForm

from src.common.dependencies import get_db
from src.modules.users import schemas, services, auth
from src.modules.users.dependencies import get_current_user
from src.modules.users.models import User


router = APIRouter()


# 📌 Создать нового пользователя
@router.post("/", response_model=schemas.UserBase, tags=["Users"])
async def create_user(user_in: schemas.UserCreate, db: AsyncSession = Depends(get_db)):
    existing = await services.get_user_by_email(db, user_in.email)
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    return await services.create_user(db, user_in)


# 📌 Получить список пользователей
@router.get("/", response_model=list[schemas.UserBase], tags=["Users"])
async def read_users(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    return await services.get_users(db, skip=skip, limit=limit)


# 📌 Получить пользователя по ID
@router.get("/{user_id}", response_model=schemas.UserBase, tags=["Users"])
async def read_user(user_id: int, db: AsyncSession = Depends(get_db)):
    db_user = await services.get_user(db, user_id)
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user


# 📌 Обновить пользователя
@router.put("/{user_id}", response_model=schemas.UserBase, tags=["Users"])
async def update_user(user_id: int, user_in: schemas.UserUpdate, db: AsyncSession = Depends(get_db)):
    db_user = await services.update_user(db, user_id, user_in)
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user


# 📌 Удалить пользователя
@router.delete("/{user_id}", tags=["Users"])
async def delete_user(user_id: int, db: AsyncSession = Depends(get_db)):
    success = await services.delete_user(db, user_id)
    if not success:
        raise HTTPException(status_code=404, detail="User not found")
    return {"ok": True}


# 📌 Логин
@router.post("/login", response_model=schemas.Token, tags=["Auth"])
async def login_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_db)
):
    return await auth.login(form_data, db)


# 📌 Текущий пользователь
@router.get("/me", response_model=schemas.UserBase, tags=["Auth"])
async def read_current_user(current_user: User = Depends(get_current_user)):
    return current_user
