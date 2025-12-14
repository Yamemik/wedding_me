from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from src.common.dependencies import get_db
from src.modules.likes import schemas, services


router = APIRouter()

@router.post("/", response_model=schemas.LikeBase)
async def create_like(like_in: schemas.LikeCreate, db: AsyncSession = Depends(get_db)):
    return await services.create_like(db, like_in)


@router.get("/", response_model=list[schemas.LikeBase])
async def read_likes(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    return await services.get_likes(db, skip, limit)


@router.get("/{like_id}", response_model=schemas.LikeBase)
async def read_like(like_id: int, db: AsyncSession = Depends(get_db)):
    return await services.get_like(db, like_id)
