from flask import Blueprint, jsonify
from services.ldap_service import LDAPService

usuarios_bp = Blueprint('usuarios', __name__)

@usuarios_bp.route('/usuarios', methods=['GET'])
def listar_usuarios():
    try:
        ldap_service = LDAPService()
        users = ldap_service.get_all_users()
        return jsonify(users), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
