from models import db

class Proveedor(db.Model):
    __tablename__ = 'proveedores'

    id_proveedor = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100), nullable=False)
    telefono = db.Column(db.String(20))
    email = db.Column(db.String(100))

    def to_dict(self):
        return {
            'id_proveedor': self.id_proveedor,
            'id': self.id_proveedor,
            'nombre': self.nombre,
            'telefono': self.telefono,
            'email': self.email
        }