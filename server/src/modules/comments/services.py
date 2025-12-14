from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from src.modules.comments.models import Comment
from src.modules.comments.schemas import CommentCreate, CommentUpdate


async def get_comment(db: AsyncSession, comment_id: int):
    result = await db.execute(select(Comment).where(Comment.id == comment_id).options(selectinload(Photo.likes)))
    return result.scalar_one_or_none()


async def get_comments(db: AsyncSession, skip: int = 0, limit: int = 100):
    result = await db.execute(select(Comment).offset(skip).limit(limit).options(selectinload(Photo.likes)))
    return result.scalars().all()


async def create_comment(db: AsyncSession, comment: CommentCreate):
    db_comment = Comment(**comment.dict())
    db.add(db_comment)
    await db.commit()
    await db.refresh(db_comment)
    return db_comment


async def update_comment(db: AsyncSession, comment_id: int, comment_data: CommentUpdate):
    db_comment = await get_comment(db, comment_id)
    if not db_comment:
        return None

    update_data = comment_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_comment, key, value)

    await db.commit()
    await db.refresh(db_comment)
    return db_comment


async def delete_comment(db: AsyncSession, comment_id: int):
    db_comment = await get_comment(db, comment_id)
    if db_comment:
        await db.delete(db_comment)
        await db.commit()
        return True
    return False
