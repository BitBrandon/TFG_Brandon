import os
from dotenv import load_dotenv

load_dotenv()  # Carga automáticamente el .env

class Config:
    # Configuración Flask
    FLASK_APP = os.getenv('FLASK_APP', 'app.py')
    FLASK_ENV = os.getenv('FLASK_ENV', 'development')

    # Config SQLAlchemy / MariaDB
    SQLALCHEMY_DATABASE_URL = (
        f"mysql+pymysql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False