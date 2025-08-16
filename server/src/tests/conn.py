import psycopg2
from psycopg2 import sql
import os
from dotenv import load_dotenv

# Загружаем переменные из .env
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env"))

# Берём параметры из переменных окружения
dbname = "wedding_me"
user = os.getenv("POSTGRES_USER", "postgres")
password = os.getenv("POSTGRES_PASSWORD", "postgres")
host = os.getenv("POSTGRES_HOST", "localhost")
port = os.getenv("POSTGRES_PORT", "5432")

# Строка DSN напрямую
dsn = f"dbname={dbname} user={user} password={password} host={host} port={port}"

try:
    conn = psycopg2.connect(dsn)
    print("✅ Connected to PostgreSQL!")
    conn.close()
except Exception as e:
    print("❌ Connection failed:")
    print(e)
