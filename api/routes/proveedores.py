from flask import Blueprint, request, jsonify
from models.proveedor import Proveedor
from models import db

proveedores_bp = Blueprint('proveedores', __name__)

@proveedores_bp.route('/', methods=['GET'])
def get_proveedores():
    proveedores = Proveedor.query.all()
    return jsonify([p.to_dict() for p in proveedores]), 200

@proveedores_bp.route('/<int:id>', methods=['GET'])
def get_proveedor(id):
    p = Proveedor.query.get(id)
    if not p:
        return jsonify({'error': 'Proveedor no encontrado'}), 404
    return jsonify(p.to_dict()), 200

@proveedores_bp.route('/', methods=['POST'])
def crear_proveedor():
    data = request.get_json()
    nuevo = Proveedor(
        nombre=data['nombre'],
        telefono=data.get('telefono'),
        email=data.get('email')
    )
    db.session.add(nuevo)
    db.session.commit()
    return jsonify(nuevo.to_dict()), 201

@proveedores_bp.route('/<int:id>', methods=['PUT'])
def actualizar_proveedor(id):
    p = Proveedor.query.get(id)
    if not p:
        return jsonify({'error': 'Proveedor no encontrado'}), 404
    data = request.get_json()
    p.nombre = data.get('nombre', p.nombre)
    p.telefono = data.get('telefono', p.telefono)
    p.email = data.get('email', p.email)
    db.session.commit()
    return jsonify(p.to_dict()), 200

@proveedores_bp.route('/<int:id>', methods=['DELETE'])
def eliminar_proveedor(id):
    p = Proveedor.query.get(id)
    if not p:
        return jsonify({'error': 'Proveedor no encontrado'}), 404
    db.session.delete(p)
    db.session.commit()
    return jsonify({'mensaje': 'Proveedor eliminado'}), 200
