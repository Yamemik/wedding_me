from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from src.modules.likes.models import Like
from src.modules.likes.schemas import LikeCreate


async def get_like(db: AsyncSession, like_id: int) -> Optional[Like]:
    result = await db.execute(select(Like).where(Like.id == like_id))
    return result.scalar_one_or_none()


async def list_likes(db: AsyncSession, skip: int = 0, limit: int = 100) -> List[Like]:
    result = await db.execute(select(Like).offset(skip).limit(limit))
    return result.scalars().all()


async def create_like(db: AsyncSession, payload: LikeCreate) -> Like:
    db_obj = Like(user_id=payload.user_id, photo_id=payload.photo_id)
    db.add(db_obj)
    await db.commit()
    await db.refresh(db_obj)
    return db_obj


async def delete_like(db: AsyncSession, like_id: int) -> bool:
    obj = await get_like(db, like_id)
    if not obj:
        return False
    await db.delete(obj)
    await db.commit()
    return True
