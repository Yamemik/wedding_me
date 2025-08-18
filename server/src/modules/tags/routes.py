from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from src.common.dependencies import get_db
from src.modules.tags import schemas, services


router = APIRouter()

@router.post("/", response_model=schemas.TagBase)
async def create_tag(tag_in: schemas.TagCreate, db: AsyncSession = Depends(get_db)):
    return await services.create_tag(db, tag_in)


@router.get("/", response_model=list[schemas.TagBase])
async def read_tags(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    return await services.get_tags(db, skip, limit)


@router.get("/{tag_id}", response_model=schemas.TagBase)
async def read_tag(tag_id: int, db: AsyncSession = Depends(get_db)):
    return await services.get_tag(db, tag_id)


@router.put("/{tag_id}", response_model=schemas.TagBase)
async def update_tag(tag_id: int, tag_in: schemas.TagUpdate, db: AsyncSession = Depends(get_db)):
    return await services.update_tag(db, tag_id, tag_in)


@router.delete("/{tag_id}")
async def delete_tag(tag_id: int, db: AsyncSession = Depends(get_db)):
    return await services.delete_tag(db, tag_id)
