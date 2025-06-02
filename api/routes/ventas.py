from flask import Blueprint, request, jsonify
from models.venta import Venta
from models import db
from datetime import datetime

ventas_bp = Blueprint('ventas', __name__)

@ventas_bp.route('/', methods=['GET'])
def listar_ventas():
    ventas = Venta.query.all()
    ventas_list = [v.to_dict() for v in ventas]
    return jsonify(ventas_list), 200

@ventas_bp.route('/', methods=['POST'])
def crear_venta():
    data = request.json
    try:
        nueva_venta = Venta(
            id_cliente=data.get('id_cliente'),
            id_producto=data.get('id_producto'),
            cantidad=data.get('cantidad'),
            fecha=datetime.strptime(data.get('fecha'), '%Y-%m-%d').date()
        )
        db.session.add(nueva_venta)
        db.session.commit()
        return jsonify(nueva_venta.to_dict()), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 400

@ventas_bp.route('/<int:id_venta>', methods=['GET'])
def obtener_venta(id_venta):
    venta = Venta.query.get(id_venta)
    if venta:
        return jsonify(venta.to_dict()), 200
    return jsonify({"error": "Venta no encontrada"}), 404

@ventas_bp.route('/<int:id_venta>', methods=['PUT'])
def actualizar_venta(id_venta):
    data = request.json
    venta = Venta.query.get(id_venta)
    if not venta:
        return jsonify({"error": "Venta no encontrada"}), 404
    try:
        venta.id_cliente = data.get('id_cliente', venta.id_cliente)
        venta.id_producto = data.get('id_producto', venta.id_producto)
        venta.cantidad = data.get('cantidad', venta.cantidad)
        if 'fecha' in data:
            venta.fecha = datetime.strptime(data['fecha'], '%Y-%m-%d').date()
        db.session.commit()
        return jsonify(venta.to_dict()), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 400

@ventas_bp.route('/<int:id_venta>', methods=['DELETE'])
def eliminar_venta(id_venta):
    venta = Venta.query.get(id_venta)
    if not venta:
        return jsonify({"error": "Venta no encontrada"}), 404
    try:
        db.session.delete(venta)
        db.session.commit()
        return jsonify({"message": "Venta eliminada"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 400