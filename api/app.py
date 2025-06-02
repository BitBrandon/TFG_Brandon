from flask import Flask
from dotenv import load_dotenv
import os
from flask_cors import CORS
import time
from sqlalchemy.exc import OperationalError
from flask import jsonify

# Carga variables de entorno
load_dotenv()

# Importa la base de datos y los modelos
from models import db

# Importa los blueprints de las rutas
from routes.usuarios import usuarios_bp
from routes.clientes import clientes_bp
from routes.productos import productos_bp
from routes.ventas import ventas_bp
from routes.facturas import facturas_bp
from routes.categorias import categorias_bp
from routes.proveedores import proveedores_bp
from routes.gastos import gastos_bp
from routes.logs import logs_bp

from sqlalchemy import text  # Añade este import

def wait_for_db(app, db, retries=10, delay=3):
    for attempt in range(retries):
        try:
            with app.app_context():
                with db.engine.connect() as connection:
                    connection.execute(text("SELECT 1"))
            print("✅ Conexión a la base de datos establecida.")
            return
        except OperationalError as e:
            print(f"⏳ Esperando la base de datos... intento {attempt+1}/{retries}")
            time.sleep(delay)
    print("❌ No se pudo conectar a la base de datos.")
    raise e

def create_app():
    app = Flask(__name__)
    CORS(app)

    # Configuración de la base de datos desde .env
    app.config['SQLALCHEMY_DATABASE_URI'] = (
        f"mysql+pymysql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
    )
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    # Inicializa la base de datos
    db.init_app(app)

    # Esperar que la base de datos esté disponible antes de crear las tablas
    wait_for_db(app, db)

    # Crea las tablas si no existen
    with app.app_context():
        db.create_all()

    # Registra los blueprints
    app.register_blueprint(usuarios_bp, url_prefix='/usuarios')
    app.register_blueprint(clientes_bp, url_prefix='/clientes')
    app.register_blueprint(productos_bp, url_prefix='/productos')
    app.register_blueprint(ventas_bp, url_prefix='/ventas')
    app.register_blueprint(facturas_bp, url_prefix='/facturas')
    app.register_blueprint(categorias_bp, url_prefix='/categorias')
    app.register_blueprint(proveedores_bp, url_prefix='/proveedores')
    app.register_blueprint(gastos_bp, url_prefix='/gastos')
    app.register_blueprint(logs_bp, url_prefix='/logs')

    @app.route('/')
    def home():
        return "API de Mayorista Brandon funcionando"

    return app

# Punto de entrada
if __name__ == '__main__':
    app = create_app()
    app.run(host='0.0.0.0', port=5000)
