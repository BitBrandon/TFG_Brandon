from flask import Blueprint, request, jsonify
from models.venta import Venta
from models import db
from datetime import datetime

ventas_bp = Blueprint('ventas', __name__)

@ventas_bp.route('/', methods=['GET'])
def get_ventas():
    ventas = Venta.query.all()
    return jsonify([v.to_dict() for v in ventas]), 200

@ventas_bp.route('/<int:id>', methods=['GET'])
def get_venta(id):
    v = Venta.query.get(id)
    if not v:
        return jsonify({'error': 'Venta no encontrada'}), 404
    return jsonify(v.to_dict()), 200

@ventas_bp.route('/', methods=['POST'])
def crear_venta():
    data = request.get_json()
    v = Venta(
        id_cliente=data['id_cliente'],
        id_producto=data['id_producto'],
        cantidad=data['cantidad'],
        fecha=datetime.strptime(data['fecha'], '%Y-%m-%d').date()
    )
    db.session.add(v)
    db.session.commit()
    return jsonify(v.to_dict()), 201

@ventas_bp.route('/<int:id>', methods=['PUT'])
def actualizar_venta(id):
    v = Venta.query.get(id)
    if not v:
        return jsonify({'error': 'Venta no encontrada'}), 404
    data = request.get_json()
    v.id_cliente = data.get('id_cliente', v.id_cliente)
    v.id_producto = data.get('id_producto', v.id_producto)
    v.cantidad = data.get('cantidad', v.cantidad)
    if 'fecha' in data:
        v.fecha = datetime.strptime(data['fecha'], '%Y-%m-%d').date()
    db.session.commit()
    return jsonify(v.to_dict()), 200

@ventas_bp.route('/<int:id>', methods=['DELETE'])
def eliminar_venta(id):
    v = Venta.query.get(id)
    if not v:
        return jsonify({'error': 'Venta no encontrada'}), 404
    db.session.delete(v)
    db.session.commit()
    return jsonify({'mensaje': 'Venta eliminada'}), 200
