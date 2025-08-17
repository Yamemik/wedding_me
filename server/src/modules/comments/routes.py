from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from src.common.dependencies import get_db
from src.modules.comments import schemas, services


router = APIRouter(prefix="/comments", tags=["Comments"])

@router.post("/", response_model=schemas.CommentBase)
async def create_comment(comment_in: schemas.CommentCreate, db: AsyncSession = Depends(get_db)):
    return await services.create_comment(db, comment_in)


@router.get("/", response_model=list[schemas.CommentBase])
async def read_comments(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    return await services.get_comments(db, skip, limit)


@router.get("/{comment_id}", response_model=schemas.CommentBase)
async def read_comment(comment_id: int, db: AsyncSession = Depends(get_db)):
    return await services.get_comment(db, comment_id)


@router.put("/{comment_id}", response_model=schemas.CommentBase)
async def update_comment(comment_id: int, comment_in: schemas.CommentUpdate, db: AsyncSession = Depends(get_db)):
    return await services.update_comment(db, comment_id, comment_in)


@router.delete("/{comment_id}")
async def delete_comment(comment_id: int, db: AsyncSession = Depends(get_db)):
    return await services.delete_comment(db, comment_id)
