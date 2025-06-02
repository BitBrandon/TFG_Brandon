from flask import Blueprint, request, jsonify
from models.producto import Producto
from models import db

productos_bp = Blueprint('productos', __name__)

@productos_bp.route('/', methods=['GET'])
def get_productos():
    productos = Producto.query.all()
    return jsonify([p.to_dict() for p in productos]), 200

@productos_bp.route('/<int:id>', methods=['GET'])
def get_producto(id):
    p = Producto.query.get(id)
    if not p:
        return jsonify({'error': 'Producto no encontrado'}), 404
    return jsonify(p.to_dict()), 200

@productos_bp.route('/', methods=['POST'])
def crear_producto():
    data = request.get_json()
    p = Producto(
        nombre=data['nombre'],
        precio=data['precio'],
        stock=data['stock'],
        id_categoria=data.get('id_categoria'),
        id_proveedor=data.get('id_proveedor')
    )
    db.session.add(p)
    db.session.commit()
    return jsonify(p.to_dict()), 201

@productos_bp.route('/<int:id>', methods=['PUT'])
def actualizar_producto(id):
    p = Producto.query.get(id)
    if not p:
        return jsonify({'error': 'Producto no encontrado'}), 404
    data = request.get_json()
    p.nombre = data.get('nombre', p.nombre)
    p.precio = data.get('precio', p.precio)
    p.stock = data.get('stock', p.stock)
    p.id_categoria = data.get('id_categoria', p.id_categoria)
    p.id_proveedor = data.get('id_proveedor', p.id_proveedor)
    db.session.commit()
    return jsonify(p.to_dict()), 200

@productos_bp.route('/<int:id>', methods=['DELETE'])
def eliminar_producto(id):
    p = Producto.query.get(id)
    if not p:
        return jsonify({'error': 'Producto no encontrado'}), 404
    db.session.delete(p)
    db.session.commit()
    return jsonify({'mensaje': 'Producto eliminado'}), 200
