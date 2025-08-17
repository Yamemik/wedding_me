from fastapi import APIRouter

# импорт всех роутеров
from src.modules.users.routes import router as users_router
from src.modules.albums.routes import router as albums_router
from src.modules.photos.routes import router as photos_router
from src.modules.comments.routes import router as comments_router
from src.modules.likes.routes import router as likes_router
from src.modules.tags.routes import router as tags_router
from src.modules.payments.routes import router as payments_router

api_router = APIRouter()

# подключаем роутеры
api_router.include_router(users_router, prefix="/users", tags=["Users"])
api_router.include_router(albums_router, prefix="/albums", tags=["Albums"])
api_router.include_router(photos_router, prefix="/photos", tags=["Photos"])
api_router.include_router(comments_router, prefix="/comments", tags=["Comments"])
api_router.include_router(likes_router, prefix="/likes", tags=["Likes"])
api_router.include_router(tags_router, prefix="/tags", tags=["Tags"])
api_router.include_router(payments_router, prefix="/payments", tags=["Payments"])
