import os

from uuid import uuid4
from fastapi import UploadFile, File, HTTPException
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from anyio import open_file

from src.common.dependencies import get_db
from src.modules.photos import schemas, services


router = APIRouter()

MEDIA_ROOT = "media/photos"

@router.post("/", response_model=schemas.PhotoBase)
async def create_photo(photo_in: schemas.PhotoCreate, db: AsyncSession = Depends(get_db)):
    return await services.create_photo(db, photo_in)


@router.get("/", response_model=list[schemas.PhotoBase])
async def read_photos(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    return await services.get_photos(db, skip, limit)


@router.get("/{photo_id}", response_model=schemas.PhotoRead)
async def read_photo(photo_id: int, db: AsyncSession = Depends(get_db)):
    return await services.get_photo(db, photo_id)


@router.put("/{photo_id}", response_model=schemas.PhotoBase)
async def update_photo(photo_id: int, photo_in: schemas.PhotoUpdate, db: AsyncSession = Depends(get_db)):
    return await services.update_photo(db, photo_id, photo_in)


@router.delete("/{photo_id}")
async def delete_photo(photo_id: int, db: AsyncSession = Depends(get_db)):
    return await services.delete_photo(db, photo_id)


@router.post("/upload", response_model=schemas.PhotoBase)
async def upload_photo(
    album_id: int,                               
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
):
    ext = file.filename.split(".")[-1].lower()

    filename = f"{uuid4()}.{ext}"
    save_path = os.path.join(MEDIA_ROOT, filename)

    os.makedirs(MEDIA_ROOT, exist_ok=True)

    content = await file.read()
    async with await open_file(save_path, "wb") as f:
        await f.write(content)

    url = f"/media/photos/{filename}"

    # новая запись
    photo_in = schemas.PhotoCreate(
        filename=filename,
        path=url,
        album_id=album_id    
    )

    photo = await services.create_photo(db, photo_in)
    return photo
