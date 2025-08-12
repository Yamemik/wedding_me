from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from src.modules.photos.models import Photo
from src.modules.photos.schemas import PhotoCreate, PhotoUpdate


async def get_photo(db: AsyncSession, photo_id: int) -> Optional[Photo]:
    result = await db.execute(select(Photo).where(Photo.id == photo_id))
    return result.scalar_one_or_none()


async def list_photos(db: AsyncSession, skip: int = 0, limit: int = 100) -> List[Photo]:
    result = await db.execute(select(Photo).offset(skip).limit(limit))
    return result.scalars().all()


async def create_photo(db: AsyncSession, payload: PhotoCreate) -> Photo:
    db_obj = Photo(
        title=payload.title,
        name=payload.name,
        path=payload.path,
        visible=payload.visible,
        album_id=payload.album_id
    )
    db.add(db_obj)
    await db.commit()
    await db.refresh(db_obj)
    return db_obj


async def update_photo(db: AsyncSession, photo_id: int, payload: PhotoUpdate) -> Optional[Photo]:
    photo = await get_photo(db, photo_id)
    if not photo:
        return None
    data = payload.model_dump(exclude_none=True)
    for k, v in data.items():
        setattr(photo, k, v)
    db.add(photo)
    await db.commit()
    await db.refresh(photo)
    return photo


async def delete_photo(db: AsyncSession, photo_id: int) -> bool:
    photo = await get_photo(db, photo_id)
    if not photo:
        return False
    await db.delete(photo)
    await db.commit()
    return True
