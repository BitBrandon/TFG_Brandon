from flask import Blueprint, request, jsonify
from models.categoria import Categoria
from models import db

categorias_bp = Blueprint('categorias', __name__)

@categorias_bp.route('/', methods=['GET'])
def get_categorias():
    categorias = Categoria.query.all()
    return jsonify([c.to_dict() for c in categorias]), 200

@categorias_bp.route('/<int:id>', methods=['GET'])
def get_categoria(id):
    c = Categoria.query.get(id)
    if not c:
        return jsonify({'error': 'Categoría no encontrada'}), 404
    return jsonify(c.to_dict()), 200

@categorias_bp.route('/', methods=['POST'])
def crear_categoria():
    data = request.get_json()
    c = Categoria(nombre=data['nombre'])
    db.session.add(c)
    db.session.commit()
    return jsonify(c.to_dict()), 201

@categorias_bp.route('/<int:id>', methods=['PUT'])
def actualizar_categoria(id):
    c = Categoria.query.get(id)
    if not c:
        return jsonify({'error': 'Categoría no encontrada'}), 404
    data = request.get_json()
    c.nombre = data.get('nombre', c.nombre)
    db.session.commit()
    return jsonify(c.to_dict()), 200

@categorias_bp.route('/<int:id>', methods=['DELETE'])
def eliminar_categoria(id):
    c = Categoria.query.get(id)
    if not c:
        return jsonify({'error': 'Categoría no encontrada'}), 404
    db.session.delete(c)
    db.session.commit()
    return jsonify({'mensaje': 'Categoría eliminada'}), 200
