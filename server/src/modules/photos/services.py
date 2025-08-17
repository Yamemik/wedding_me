from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from src.modules.photos.models import Photo
from src.modules.photos.schemas import PhotoCreate, PhotoUpdate


async def get_photo(db: AsyncSession, photo_id: int):
    result = await db.execute(select(Photo).where(Photo.id == photo_id))
    return result.scalar_one_or_none()


async def get_photos(db: AsyncSession, skip: int = 0, limit: int = 100):
    result = await db.execute(select(Photo).offset(skip).limit(limit))
    return result.scalars().all()


async def create_photo(db: AsyncSession, photo: PhotoCreate):
    db_photo = Photo(**photo.dict())
    db.add(db_photo)
    await db.commit()
    await db.refresh(db_photo)
    return db_photo


async def update_photo(db: AsyncSession, photo_id: int, photo_data: PhotoUpdate):
    db_photo = await get_photo(db, photo_id)
    if not db_photo:
        return None

    update_data = photo_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_photo, key, value)

    await db.commit()
    await db.refresh(db_photo)
    return db_photo


async def delete_photo(db: AsyncSession, photo_id: int):
    db_photo = await get_photo(db, photo_id)
    if db_photo:
        await db.delete(db_photo)
        await db.commit()
