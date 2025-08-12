from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from src.modules.comments.models import Comment
from src.modules.comments.schemas import CommentCreate, CommentUpdate


async def get_comment(db: AsyncSession, comment_id: int) -> Optional[Comment]:
    result = await db.execute(select(Comment).where(Comment.id == comment_id))
    return result.scalar_one_or_none()


async def list_comments(db: AsyncSession, skip: int = 0, limit: int = 100) -> List[Comment]:
    result = await db.execute(select(Comment).offset(skip).limit(limit))
    return result.scalars().all()


async def create_comment(db: AsyncSession, payload: CommentCreate) -> Comment:
    db_obj = Comment(text=payload.text, is_deleted=payload.is_deleted, user_id=payload.user_id, photo_id=payload.photo_id)
    db.add(db_obj)
    await db.commit()
    await db.refresh(db_obj)
    return db_obj


async def update_comment(db: AsyncSession, comment_id: int, payload: CommentUpdate) -> Optional[Comment]:
    comment = await get_comment(db, comment_id)
    if not comment:
        return None
    data = payload.model_dump(exclude_none=True)
    for k, v in data.items():
        setattr(comment, k, v)
    db.add(comment)
    await db.commit()
    await db.refresh(comment)
    return comment


async def delete_comment(db: AsyncSession, comment_id: int) -> bool:
    comment = await get_comment(db, comment_id)
    if not comment:
        return False
    await db.delete(comment)
    await db.commit()
    return True
