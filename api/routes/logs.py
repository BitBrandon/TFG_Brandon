from flask import Blueprint, request, jsonify
from models.log import Log
from models import db
from datetime import datetime

logs_bp = Blueprint('logs', __name__)

@logs_bp.route('/', methods=['GET'])
def obtener_logs():
    logs = Log.query.all()
    return jsonify([l.to_dict() for l in logs]), 200

@logs_bp.route('/<int:id>', methods=['GET'])
def obtener_log(id):
    log = Log.query.get(id)
    if not log:
        return jsonify({'error': 'Log no encontrado'}), 404
    return jsonify(log.to_dict()), 200

@logs_bp.route('/', methods=['POST'])
def crear_log():
    data = request.get_json()
    nuevo_log = Log(
        usuario=data['usuario'],
        accion=data['accion'],
        fecha=datetime.strptime(data['fecha'], '%Y-%m-%d %H:%M:%S') if 'fecha' in data else datetime.utcnow()
    )
    db.session.add(nuevo_log)
    db.session.commit()
    return jsonify(nuevo_log.to_dict()), 201

@logs_bp.route('/<int:id>', methods=['PUT'])
def actualizar_log(id):
    log = Log.query.get(id)
    if not log:
        return jsonify({'error': 'Log no encontrado'}), 404
    data = request.get_json()
    log.usuario = data.get('usuario', log.usuario)
    log.accion = data.get('accion', log.accion)
    if 'fecha' in data:
        log.fecha = datetime.strptime(data['fecha'], '%Y-%m-%d %H:%M:%S')
    db.session.commit()
    return jsonify(log.to_dict()), 200

@logs_bp.route('/<int:id>', methods=['DELETE'])
def eliminar_log(id):
    log = Log.query.get(id)
    if not log:
        return jsonify({'error': 'Log no encontrado'}), 404
    db.session.delete(log)
    db.session.commit()
    return jsonify({'mensaje': 'Log eliminado'}), 200
