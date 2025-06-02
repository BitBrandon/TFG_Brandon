from flask import Blueprint, request, jsonify
from models.gasto import Gasto
from models import db
from datetime import datetime

gastos_bp = Blueprint('gastos', __name__)

@gastos_bp.route('/', methods=['GET'])
def get_gastos():
    gastos = Gasto.query.all()
    return jsonify([g.to_dict() for g in gastos]), 200

@gastos_bp.route('/<int:id>', methods=['GET'])
def get_gasto(id):
    g = Gasto.query.get(id)
    if not g:
        return jsonify({'error': 'Gasto no encontrado'}), 404
    return jsonify(g.to_dict()), 200

@gastos_bp.route('/', methods=['POST'])
def crear_gasto():
    data = request.get_json()
    nuevo = Gasto(
        descripcion=data['descripcion'],
        monto=data['monto'],
        fecha=datetime.strptime(data['fecha'], '%Y-%m-%d').date()
    )
    db.session.add(nuevo)
    db.session.commit()
    return jsonify(nuevo.to_dict()), 201

@gastos_bp.route('/<int:id>', methods=['PUT'])
def actualizar_gasto(id):
    g = Gasto.query.get(id)
    if not g:
        return jsonify({'error': 'Gasto no encontrado'}), 404
    data = request.get_json()
    g.descripcion = data.get('descripcion', g.descripcion)
    g.monto = data.get('monto', g.monto)
    if 'fecha' in data:
        g.fecha = datetime.strptime(data['fecha'], '%Y-%m-%d').date()
    db.session.commit()
    return jsonify(g.to_dict()), 200

@gastos_bp.route('/<int:id>', methods=['DELETE'])
def eliminar_gasto(id):
    g = Gasto.query.get(id)
    if not g:
        return jsonify({'error': 'Gasto no encontrado'}), 404
    db.session.delete(g)
    db.session.commit()
    return jsonify({'mensaje': 'Gasto eliminado'}), 200
