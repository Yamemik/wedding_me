from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.exc import NoResultFound

from .models import Album
from .schemas import AlbumCreate, AlbumUpdate


async def get_by_id(db: AsyncSession, album_id: int) -> Optional[Album]:
    result = await db.execute(select(Album).where(Album.id == album_id))
    return result.scalar_one_or_none()


async def get_all(db: AsyncSession) -> List[Album]:
    result = await db.execute(select(Album))
    return result.scalars().all()


async def create(db: AsyncSession, obj_in: AlbumCreate) -> Album:
    db_obj = Album(**obj_in.model_dump())
    db.add(db_obj)
    await db.commit()
    await db.refresh(db_obj)
    return db_obj


async def update(db: AsyncSession, db_obj: Album, obj_in: AlbumUpdate) -> Album:
    obj_data = obj_in.model_dump(exclude_unset=True)
    for field, value in obj_data.items():
        setattr(db_obj, field, value)

    db.add(db_obj)
    await db.commit()
    await db.refresh(db_obj)
    return db_obj


async def delete(db: AsyncSession, db_obj: Album) -> None:
    await db.delete(db_obj)
    await db.commit()
