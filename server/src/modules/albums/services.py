import os
from typing import List
import uuid
from fastapi import HTTPException, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

from src.modules.albums.schemas import AlbumCreate, AlbumUpdate
import src.modules.albums.crud as repo
from src.modules.photos.models import Photo


MEDIA_DIR = "media/photos"

async def get_album(db: AsyncSession, album_id: int):
    return await repo.select_album(db, album_id)


async def get_public_albums(db: AsyncSession, skip: int = 0, limit: int = 100):
    return await repo.select_albums(db, skip, limit)


async def get_albums_by_user(db: AsyncSession, user_id: int, skip: int = 0, limit: int = 100):
    return await repo.select_albums_by_user(db, user_id, skip, limit)


async def create_album(db: AsyncSession, album: AlbumCreate):
    return await repo.add_album(db, album)


async def update_album(db: AsyncSession, album_id: int, album_data: AlbumUpdate):
    return await repo.update(db, album_id, album_data)


async def delete_album(db: AsyncSession, album_id: int):
    return await repo.delete(db, album_id)


async def upload_files_to_album(db: AsyncSession, album_id: int, files: List[UploadFile]):
    """Загрузить список файлов в альбом, сохранить на диск и записать в БД"""

    if not files:
        raise HTTPException(status_code=400, detail="Файлы не переданы")

    saved_photos = []

    # создаём папку если нет
    os.makedirs(MEDIA_DIR, exist_ok=True)

    for file in files:
        # уникальное имя файла
        filename = f"{uuid.uuid4()}_{file.filename}"
        filepath = os.path.join(MEDIA_DIR, filename)

        # сохранение файла
        try:
            # with open(filepath, "wb") as buffer:
            #     buffer.write(await file.read())
            data = await file.read()
            with open(filepath, "wb") as buffer:
                buffer.write(data)
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Ошибка сохранения файла: {e}")

        # запись в БД
        photo = Photo(
            album_id=album_id,
            path=f"/media/photos/{filename}"
        )

        db.add(photo)
        saved_photos.append(photo)

    await db.commit()

    for photo in saved_photos:
        await db.refresh(photo)

    return saved_photos
    