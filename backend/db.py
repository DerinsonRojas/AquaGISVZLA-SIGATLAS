import logging
import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()


def get_connection():
    try:
        return psycopg2.connect(
            host=os.getenv("DB_HOST"),
            port=os.getenv("DB_PORT"),
            database=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
        )
    except psycopg2.Error as e:
        logging.error(f"Error al conectar a la base de datos: {e}")
        raise