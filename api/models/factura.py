from models import db

class Factura(db.Model):
    __tablename__ = 'facturas'

    id_factura = db.Column(db.Integer, primary_key=True)
    id_venta = db.Column(db.Integer, db.ForeignKey('ventas.id_venta'))
    total = db.Column(db.Numeric(10, 2))
    fecha_factura = db.Column(db.Date)

    def to_dict(self):
        return {
            'id_factura': self.id_factura,
            'id_venta': self.id_venta,
            'total': float(self.total),
            'fecha_factura': self.fecha_factura.isoformat()
        }
