import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()


def get_connection():
  # 1. Si estamos en Render (o hay un DATABASE_URL definido), usar directamente
  database_url = os.getenv("DATABASE_URL")
  if database_url:
    return psycopg2.connect(database_url)

  # 2. Si no, usamos variables locales del archivo .env (para tu PC)
  return psycopg2.connect(
      host=os.getenv("DB_HOST"),
      port=os.getenv("DB_PORT"),
      database=os.getenv("DB_NAME"),
      user=os.getenv("DB_USER"),
      password=os.getenv("DB_PASSWORD"),
  )