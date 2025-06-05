from models import db

class Gasto(db.Model):
    __tablename__ = 'gastos'

    id_gasto = db.Column(db.Integer, primary_key=True)
    descripcion = db.Column(db.Text, nullable=False)
    monto = db.Column(db.Numeric(10, 2), nullable=False)
    fecha = db.Column(db.Date, nullable=False)

    def to_dict(self):
        return {
            'id_gasto': self.id_gasto,
            'id': self.id_gasto,
            'descripcion': self.descripcion,
            'monto': float(self.monto),
            'fecha': self.fecha.isoformat()
        }