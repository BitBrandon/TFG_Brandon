from models import db

class Producto(db.Model):
    __tablename__ = 'productos'

    id_producto = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100))
    precio = db.Column(db.Numeric(10, 2))
    stock = db.Column(db.Integer)
    id_categoria = db.Column(db.Integer)
    id_proveedor = db.Column(db.Integer)

    def to_dict(self):
        return {
            'id_producto': self.id_producto,
            'id': self.id_producto,
            'nombre': self.nombre,
            'precio': float(self.precio),
            'stock': self.stock,
            'id_categoria': self.id_categoria,
            'id_proveedor': self.id_proveedor
        }