from . import db

class Usuario(db.Model):
    __tablename__ = 'usuarios'
    id_usuario = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100))
    email = db.Column(db.String(100))
    rol = db.Column(db.Enum('trabajador', 'jefe', 'admin_informatica'), nullable=False)
    activo = db.Column(db.Boolean, default=True)

    def to_dict(self):
        return {
            "id_usuario": self.id_usuario,
            "nombre": self.nombre,
            "email": self.email,
            "rol": self.rol,
            "activo": self.activo
        }