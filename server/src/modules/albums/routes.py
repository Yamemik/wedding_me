from typing import List
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

from src.common.dependencies import get_db
from src.modules.albums import schemas, services


router = APIRouter()

@router.post("/", response_model=schemas.AlbumRead)
async def create_album(album_in: schemas.AlbumCreate, db: AsyncSession = Depends(get_db)):
    return await services.create_album(db, album_in)


@router.get("/", response_model=list[schemas.AlbumRead])
async def read_albums(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    return await services.get_public_albums(db, skip, limit)


@router.get("/{album_id}", response_model=schemas.AlbumRead)
async def read_album(album_id: int, db: AsyncSession = Depends(get_db)):
    return await services.get_album(db, album_id)


@router.get("/user/{user_id}/albums", response_model=list[schemas.AlbumRead])
async def read_albums_by_user(user_id: int, db: AsyncSession = Depends(get_db)):
    return await services.get_albums_by_user(db, user_id)


@router.put("/{album_id}", response_model=schemas.AlbumRead)
async def update_album(album_id: int, album_in: schemas.AlbumUpdate, db: AsyncSession = Depends(get_db)):
    return await services.update_album(db, album_id, album_in)


@router.delete("/{album_id}")
async def delete_album(album_id: int, db: AsyncSession = Depends(get_db)):
    return await services.delete_album(db, album_id)


@router.post("/{album_id}/files/")
async def upload_album_files(album_id: int, files: List[UploadFile] = File(...), db: AsyncSession = Depends(get_db)):
    """Загрузить файлы в альбом"""
    try:
        return await services.upload_files_to_album(db, album_id, files)
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(500, f"Внутренняя ошибка сервера: {str(e)}")