from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from src.modules.albums.models import Album
from src.modules.albums.schemas import AlbumCreate, AlbumUpdate


async def get_album(db: AsyncSession, album_id: int):
    result = await db.execute(select(Album).where(Album.id == album_id))
    return result.scalar_one_or_none()


async def get_albums(db: AsyncSession, skip: int = 0, limit: int = 100):
    result = await db.execute(select(Album).offset(skip).limit(limit))
    return result.scalars().all()


async def create_album(db: AsyncSession, album: AlbumCreate):
    db_album = Album(**album.dict())
    db.add(db_album)
    await db.commit()
    await db.refresh(db_album)
    return db_album


async def update_album(db: AsyncSession, album_id: int, album_data: AlbumUpdate):
    db_album = await get_album(db, album_id)
    if not db_album:
        return None

    update_data = album_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_album, key, value)

    await db.commit()
    await db.refresh(db_album)
    return db_album


async def delete_album(db: AsyncSession, album_id: int):
    db_album = await get_album(db, album_id)
    if db_album:
        await db.delete(db_album)
        await db.commit()
        return True
    return False
