from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from src.modules.likes.models import Like
from src.modules.likes.schemas import LikeCreate, LikeUpdate


async def get_like(db: AsyncSession, like_id: int):
    result = await db.execute(select(Like).where(Like.id == like_id))
    return result.scalar_one_or_none()


async def get_likes(db: AsyncSession, skip: int = 0, limit: int = 100):
    result = await db.execute(select(Like).offset(skip).limit(limit))
    return result.scalars().all()


async def create_like(db: AsyncSession, like: LikeCreate):
    # Проверяем, существует ли уже лайк
    result = await db.execute(
        select(Like).where(
            (Like.user_id == like.user_id) & (Like.photo_id == like.photo_id)
        )
    )
    existing_like = result.scalar_one_or_none()
    
    if existing_like:
        # Удаляем существующий лайк (отмена лайка)
        await db.delete(existing_like)
        await db.commit()
        return {"user_id": 0, "photo_id": 0}
    else:
        # Создаем новый лайк
        db_like = Like(**like.dict())
        db.add(db_like)
        await db.commit()
        await db.refresh(db_like)
        return db_like


async def delete_like(db: AsyncSession, like_id: int):
    db_like = await get_like(db, like_id)
    if db_like:
        await db.delete(db_like)
        await db.commit()
        return True
    return False
