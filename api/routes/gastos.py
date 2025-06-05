from flask import Blueprint, request, jsonify
from models.gasto import Gasto
from models import db
from datetime import datetime

gastos_bp = Blueprint('gastos', __name__)

@gastos_bp.route('/', methods=['GET'])
def listar_gastos():
    gastos = Gasto.query.all()
    return jsonify([g.to_dict() for g in gastos]), 200

@gastos_bp.route('/', methods=['POST'])
def crear_gasto():
    data = request.json
    fecha = data.get('fecha')
    fecha_obj = datetime.strptime(fecha, '%Y-%m-%d').date() if fecha else None
    nuevo_gasto = Gasto(
        descripcion=data.get('descripcion'),
        monto=data.get('monto'),
        fecha=fecha_obj
    )
    db.session.add(nuevo_gasto)
    db.session.commit()
    return jsonify(nuevo_gasto.to_dict()), 201

@gastos_bp.route('/<int:id>', methods=['GET'])
def obtener_gasto(id):
    gasto = Gasto.query.get(id)
    if gasto:
        return jsonify(gasto.to_dict()), 200
    return jsonify({"error": "No encontrado"}), 404

@gastos_bp.route('/<int:id>', methods=['PUT'])
def actualizar_gasto(id):
    gasto = Gasto.query.get(id)
    if not gasto:
        return jsonify({"error": "No encontrado"}), 404
    data = request.json
    gasto.descripcion = data.get('descripcion', gasto.descripcion)
    gasto.monto = data.get('monto', gasto.monto)
    fecha = data.get('fecha')
    if fecha:
        gasto.fecha = datetime.strptime(fecha, '%Y-%m-%d').date()
    db.session.commit()
    return jsonify(gasto.to_dict()), 200

@gastos_bp.route('/<int:id>', methods=['DELETE'])
def eliminar_gasto(id):
    gasto = Gasto.query.get(id)
    if not gasto:
        return jsonify({"error": "No encontrado"}), 404
    db.session.delete(gasto)
    db.session.commit()
    return jsonify({"message": "Eliminado"}), 200