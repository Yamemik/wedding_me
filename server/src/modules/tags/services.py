from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from src.modules.tags.models import Tag
from src.modules.tags.schemas import TagCreate, TagUpdate


async def get_tag(db: AsyncSession, tag_id: int):
    result = await db.execute(select(Tag).where(Tag.id == tag_id))
    return result.scalar_one_or_none()


async def get_tags(db: AsyncSession, skip: int = 0, limit: int = 100):
    result = await db.execute(select(Tag).offset(skip).limit(limit))
    return result.scalars().all()


async def create_tag(db: AsyncSession, tag: TagCreate):
    db_tag = Tag(**tag.dict())
    db.add(db_tag)
    await db.commit()
    await db.refresh(db_tag)
    return db_tag


async def update_tag(db: AsyncSession, tag_id: int, tag_data: TagUpdate):
    db_tag = await get_tag(db, tag_id)
    if not db_tag:
        return None

    update_data = tag_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_tag, key, value)

    await db.commit()
    await db.refresh(db_tag)
    return db_tag


async def delete_tag(db: AsyncSession, tag_id: int):
    db_tag = await get_tag(db, tag_id)
    if db_tag:
        await db.delete(db_tag)
        await db.commit()
        return True
    return False
