from models import db

class Venta(db.Model):
    __tablename__ = 'ventas'

    id_venta = db.Column(db.Integer, primary_key=True)
    id_cliente = db.Column(db.Integer, db.ForeignKey('clientes.id_cliente'))
    id_producto = db.Column(db.Integer, db.ForeignKey('productos.id_producto'))
    cantidad = db.Column(db.Integer)
    fecha = db.Column(db.Date)

    def to_dict(self):
        return {
            'id_venta': self.id_venta,
            'id_cliente': self.id_cliente,
            'id_producto': self.id_producto,
            'cantidad': self.cantidad,
            'fecha': self.fecha.isoformat()
        }
