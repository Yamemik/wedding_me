from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from src.modules.tags.models import Tag, PhotoTag
from src.modules.tags.schemas import TagCreate, TagUpdate, PhotoTagCreate


# Tag CRUD
async def get_tag(db: AsyncSession, tag_id: int) -> Optional[Tag]:
    result = await db.execute(select(Tag).where(Tag.id == tag_id))
    return result.scalar_one_or_none()


async def list_tags(db: AsyncSession, skip: int = 0, limit: int = 100) -> List[Tag]:
    result = await db.execute(select(Tag).offset(skip).limit(limit))
    return result.scalars().all()


async def create_tag(db: AsyncSession, payload: TagCreate) -> Tag:
    db_obj = Tag(name=payload.name, color=payload.color)
    db.add(db_obj)
    await db.commit()
    await db.refresh(db_obj)
    return db_obj


async def update_tag(db: AsyncSession, tag_id: int, payload: TagUpdate) -> Optional[Tag]:
    tag = await get_tag(db, tag_id)
    if not tag:
        return None
    data = payload.model_dump(exclude_none=True)
    for k, v in data.items():
        setattr(tag, k, v)
    db.add(tag)
    await db.commit()
    await db.refresh(tag)
    return tag


async def delete_tag(db: AsyncSession, tag_id: int) -> bool:
    tag = await get_tag(db, tag_id)
    if not tag:
        return False
    await db.delete(tag)
    await db.commit()
    return True


# PhotoTag CRUD
async def get_photo_tag(db: AsyncSession, pt_id: int) -> Optional[PhotoTag]:
    result = await db.execute(select(PhotoTag).where(PhotoTag.id == pt_id))
    return result.scalar_one_or_none()


async def list_photo_tags(db: AsyncSession, skip: int = 0, limit: int = 100) -> List[PhotoTag]:
    result = await db.execute(select(PhotoTag).offset(skip).limit(limit))
    return result.scalars().all()


async def create_photo_tag(db: AsyncSession, payload: PhotoTagCreate) -> PhotoTag:
    db_obj = PhotoTag(photo_id=payload.photo_id, tag_id=payload.tag_id)
    db.add(db_obj)
    await db.commit()
    await db.refresh(db_obj)
    return db_obj


async def delete_photo_tag(db: AsyncSession, pt_id: int) -> bool:
    pt = await get_photo_tag(db, pt_id)
    if not pt:
        return False
    await db.delete(pt)
    await db.commit()
    return True
