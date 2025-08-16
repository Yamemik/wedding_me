from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from src.modules.users.models import User
from src.config.settings import settings
from src.common.security import get_password_hash


async def create_superuser_if_not_exists(db: AsyncSession):
    result = await db.execute(
        select(User).where(User.email == settings.SUPERUSER_EMAIL)
    )
    superuser = result.scalar_one_or_none()

    if superuser is None:
        superuser = User(
            email=settings.SUPERUSER_EMAIL,
            password=get_password_hash(settings.SUPERUSER_PASSWORD),
            surname="Admin",
            name="Admin",
            patr=None,
            is_admin=True
        )
        db.add(superuser)
        await db.commit()
        await db.refresh(superuser)
        print(f"✅ Superuser '{settings.SUPERUSER_EMAIL}' created")
    else:
        print(f"ℹ Superuser '{settings.SUPERUSER_EMAIL}' already exists")
