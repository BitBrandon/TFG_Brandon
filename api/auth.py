from flask import Blueprint, request, jsonify
import ldap3
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

auth_bp = Blueprint("auth", __name__)

LDAP_CONFIG = {
    "server": "ldap://ldap-server:389",
    "bind_dn": "cn=ldapbind,dc=mayorista,dc=local",
    "bind_password": "adminpassword",
    "base_dn": "dc=mayorista,dc=local",
    "user_ou": "ou=usuarios",
    "group_ou": "ou=grupos",
    "allowed_groups": [
        "cn=admin,ou=grupos,dc=mayorista,dc=local",
        "cn=jefe_sistemas,ou=grupos,dc=mayorista,dc=local"
    ]
}

def create_ldap_connection():
    try:
        server = ldap3.Server(LDAP_CONFIG["server"], get_info=ldap3.ALL)
        conn = ldap3.Connection(
            server,
            user=LDAP_CONFIG["bind_dn"],
            password=LDAP_CONFIG["bind_password"],
            auto_bind=True
        )
        return conn
    except Exception as e:
        logger.error(f"Error conexión LDAP: {str(e)}")
        return None

@auth_bp.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        username = data.get("username")
        password = data.get("password")
        
        if not username or not password:
            return jsonify({"success": False, "message": "Credenciales requeridas"}), 400

        # Conexión inicial
        conn = create_ldap_connection()
        if not conn:
            return jsonify({"success": False, "message": "Error conectando al servidor LDAP"}), 500

        # Autenticación usuario
        user_dn = f"uid={username},{LDAP_CONFIG['user_ou']},{LDAP_CONFIG['base_dn']}"
        if not conn.rebind(user=user_dn, password=password):
            return jsonify({"success": False, "message": "Credenciales inválidas"}), 401

        # Verificación de grupos
        conn.search(
            search_base=LDAP_CONFIG["group_ou"] + "," + LDAP_CONFIG["base_dn"],
            search_filter=f"(|(member={user_dn})(uniqueMember={user_dn}))",
            attributes=['cn']
        )
        
        user_groups = [entry.entry_dn for entry in conn.entries]
        authorized = any(group in user_groups for group in LDAP_CONFIG["allowed_groups"])
        
        return jsonify({
            "success": authorized,
            "message": "Autenticación exitosa" if authorized else "Acceso no autorizado",
            "user": username,
            "groups": user_groups
        }), 200 if authorized else 403

    except Exception as e:
        logger.error(f"Error en login: {str(e)}")
        return jsonify({"success": False, "message": "Error interno del servidor"}), 500
    finally:
        if 'conn' in locals():
            conn.unbind()