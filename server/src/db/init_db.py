from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from src.db.session import engine, AsyncSessionLocal
from src.db.base import Base
from src.db.init_superuser import create_superuser_if_not_exists
from src.db.run_migrations import run_migrations_if_needed


async def init_db():
    async with engine.begin() as conn:
        # проверяем, есть ли таблица alembic_version
        result = await conn.execute(
            text("SELECT to_regclass('public.alembic_version')")
        )
        has_alembic = result.scalar()

        if not has_alembic:
            # alembic еще не инициализирован → создаем все таблицы руками
            await conn.run_sync(Base.metadata.create_all)
            print("✅ Таблицы созданы через create_all (первый запуск).")
        else:
            # alembic уже инициализирован → проверяем миграции
            await run_migrations_if_needed()

    # создаем суперюзера
    async with AsyncSessionLocal() as session:
        await create_superuser_if_not_exists(session)
