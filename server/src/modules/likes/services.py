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
    db_like = Like(**like.dict())
    db.add(db_like)
    await db.commit()
    await db.refresh(db_like)
    return db_like


async def update_like(db: AsyncSession, like_id: int, like_data: LikeUpdate):
    db_like = await get_like(db, like_id)
    if not db_like:
        return None

    update_data = like_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_like, key, value)

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
