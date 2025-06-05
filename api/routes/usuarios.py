from flask import Blueprint, request, jsonify
from models.usuario import Usuario
from models import db

usuarios_bp = Blueprint('usuarios', __name__)

@usuarios_bp.route('/', methods=['GET'])
def listar_usuarios():
    usuarios = Usuario.query.all()
    return jsonify([u.to_dict() for u in usuarios]), 200

@usuarios_bp.route('/', methods=['POST'])
def crear_usuario():
    data = request.json
    nuevo_usuario = Usuario(
        nombre=data.get('nombre'),
        email=data.get('email'),
        rol=data.get('rol', 'trabajador'),
        activo=data.get('activo', True)
    )
    db.session.add(nuevo_usuario)
    db.session.commit()
    return jsonify(nuevo_usuario.to_dict()), 201

@usuarios_bp.route('/<int:id>', methods=['GET'])
def obtener_usuario(id):
    usuario = Usuario.query.get(id)
    if usuario:
        return jsonify(usuario.to_dict()), 200
    return jsonify({"error": "No encontrado"}), 404

@usuarios_bp.route('/<int:id>', methods=['PUT'])
def actualizar_usuario(id):
    usuario = Usuario.query.get(id)
    if not usuario:
        return jsonify({"error": "No encontrado"}), 404
    data = request.json
    usuario.nombre = data.get('nombre', usuario.nombre)
    usuario.email = data.get('email', usuario.email)
    usuario.rol = data.get('rol', usuario.rol)
    usuario.activo = data.get('activo', usuario.activo)
    db.session.commit()
    return jsonify(usuario.to_dict()), 200

@usuarios_bp.route('/<int:id>', methods=['DELETE'])
def eliminar_usuario(id):
    usuario = Usuario.query.get(id)
    if not usuario:
        return jsonify({"error": "No encontrado"}), 404
    db.session.delete(usuario)
    db.session.commit()
    return jsonify({"message": "Eliminado"}), 200