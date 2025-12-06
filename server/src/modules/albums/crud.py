from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from src.modules.albums.models import Album
from src.modules.albums.schemas import AlbumCreate, AlbumUpdate, AlbumRead


async def get_album(db: AsyncSession, album_id: int) -> Optional[AlbumRead]:
    result = await db.execute(select(Album).where(Album.id == album_id))
    return result.scalar_one_or_none()


async def list_albums(db: AsyncSession, skip: int = 0, limit: int = 100) -> List[AlbumRead]:
    result = await db.execute(select(Album).offset(skip).limit(limit))
    return result.scalars().all()


async def create_album(db: AsyncSession, payload: AlbumCreate) -> AlbumRead:
    db_obj = Album(title=payload.title, visible=payload.visible, user_id=payload.user_id)
    db.add(db_obj)
    await db.commit()
    await db.refresh(db_obj)
    return db_obj


async def update_album(db: AsyncSession, album_id: int, payload: AlbumUpdate) -> Optional[AlbumRead]:
    album = await get_album(db, album_id)
    if not album:
        return None
    data = payload.model_dump(exclude_none=True)
    for k, v in data.items():
        setattr(album, k, v)
    db.add(album)
    await db.commit()
    await db.refresh(album)
    return album


async def delete_album(db: AsyncSession, album_id: int) -> bool:
    album = await get_album(db, album_id)
    if not album:
        return False
    await db.delete(album)
    await db.commit()
    return True
