from flask import Blueprint, request, jsonify
from models.factura import Factura
from models import db
from datetime import datetime

facturas_bp = Blueprint('facturas', __name__)

@facturas_bp.route('/', methods=['GET'])
def get_facturas():
    facturas = Factura.query.all()
    return jsonify([f.to_dict() for f in facturas]), 200

@facturas_bp.route('/<int:id>', methods=['GET'])
def get_factura(id):
    f = Factura.query.get(id)
    if not f:
        return jsonify({'error': 'Factura no encontrada'}), 404
    return jsonify(f.to_dict()), 200

@facturas_bp.route('/', methods=['POST'])
def crear_factura():
    data = request.get_json()
    # Permitir tanto 'fecha' como 'fecha_factura' desde el frontend
    fecha_str = data.get('fecha_factura') or data.get('fecha')
    fecha_obj = datetime.strptime(fecha_str, '%Y-%m-%d').date() if fecha_str else None
    f = Factura(
        id_venta=data['id_venta'],
        total=data['total'],
        fecha_factura=fecha_obj
    )
    db.session.add(f)
    db.session.commit()
    return jsonify(f.to_dict()), 201

@facturas_bp.route('/<int:id>', methods=['PUT'])
def actualizar_factura(id):
    f = Factura.query.get(id)
    if not f:
        return jsonify({'error': 'Factura no encontrada'}), 404
    data = request.get_json()
    f.id_venta = data.get('id_venta', f.id_venta)
    f.total = data.get('total', f.total)
    fecha_str = data.get('fecha_factura') or data.get('fecha')
    if fecha_str:
        f.fecha_factura = datetime.strptime(fecha_str, '%Y-%m-%d').date()
    db.session.commit()
    return jsonify(f.to_dict()), 200

@facturas_bp.route('/<int:id>', methods=['DELETE'])
def eliminar_factura(id):
    f = Factura.query.get(id)
    if not f:
        return jsonify({'error': 'Factura no encontrada'}), 404
    db.session.delete(f)
    db.session.commit()
    return jsonify({'mensaje': 'Factura eliminada'}), 200