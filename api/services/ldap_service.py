import ldap
from config import Config

class LDAPService:
    """Servicio para manejar operaciones LDAP"""
    
    def __init__(self):
        """Inicializa conexión LDAP con credenciales de admin"""
        self.server = f"ldap://{Config.LDAP_HOST}:{Config.LDAP_PORT}"
        self.base_dn = Config.LDAP_BASE_DN
        self.bind_dn = Config.LDAP_USER
        self.bind_password = Config.LDAP_PASSWORD

        self.conn = ldap.initialize(self.server)
        self.conn.set_option(ldap.OPT_REFERRALS, 0)
        self.conn.protocol_version = 3

        try:
            self.conn.simple_bind_s(self.bind_dn, self.bind_password)
        except ldap.INVALID_CREDENTIALS:
            raise Exception("Credenciales LDAP inválidas.")
        except ldap.SERVER_DOWN:
            raise Exception("Servidor LDAP no disponible.")
        except Exception as e:
            raise Exception(f"Error de conexión LDAP: {str(e)}")

    def get_all_users(self):
        """Obtiene todos los usuarios del directorio LDAP
        
        Returns:
            list: Lista de diccionarios con información de usuarios
        """
        search_filter = "(objectClass=inetOrgPerson)"
        try:
            result = self.conn.search_s(self.base_dn, ldap.SCOPE_SUBTREE, search_filter)
            return [{
                "dn": dn,
                "uid": entry.get("uid", [b""])[0].decode("utf-8"),
                "cn": entry.get("cn", [b""])[0].decode("utf-8"),
                "sn": entry.get("sn", [b""])[0].decode("utf-8")
            } for dn, entry in result]
        except Exception as e:
            raise Exception(f"Error al buscar usuarios: {str(e)}")
