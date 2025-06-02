from flask import Blueprint, request, jsonify
from models.cliente import Cliente
from models import db

clientes_bp = Blueprint('clientes', __name__)

# Obtener todos los clientes
@clientes_bp.route('/', methods=['GET'])
def get_clientes():
    clientes = Cliente.query.all()
    return jsonify([cliente.to_dict() for cliente in clientes]), 200

# Obtener un cliente por ID
@clientes_bp.route('/<int:id>', methods=['GET'])
def get_cliente(id):
    cliente = Cliente.query.get(id)
    if not cliente:
        return jsonify({'error': 'Cliente no encontrado'}), 404
    return jsonify(cliente.to_dict()), 200

# Crear un nuevo cliente
@clientes_bp.route('/', methods=['POST'])
def crear_cliente():
    data = request.get_json()
    nuevo_cliente = Cliente(
        nombre=data.get('nombre'),
        email=data.get('email'),
        telefono=data.get('telefono'),
        direccion=data.get('direccion')
    )
    db.session.add(nuevo_cliente)
    db.session.commit()
    return jsonify(nuevo_cliente.to_dict()), 201

# Actualizar un cliente existente
@clientes_bp.route('/<int:id>', methods=['PUT'])
def actualizar_cliente(id):
    cliente = Cliente.query.get(id)
    if not cliente:
        return jsonify({'error': 'Cliente no encontrado'}), 404

    data = request.get_json()
    cliente.nombre = data.get('nombre', cliente.nombre)
    cliente.email = data.get('email', cliente.email)
    cliente.telefono = data.get('telefono', cliente.telefono)
    cliente.direccion = data.get('direccion', cliente.direccion)

    db.session.commit()
    return jsonify(cliente.to_dict()), 200

# Eliminar un cliente
@clientes_bp.route('/<int:id>', methods=['DELETE'])
def eliminar_cliente(id):
    cliente = Cliente.query.get(id)
    if not cliente:
        return jsonify({'error': 'Cliente no encontrado'}), 404

    db.session.delete(cliente)
    db.session.commit()
    return jsonify({'mensaje': 'Cliente eliminado'}), 200
