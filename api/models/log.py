from models import db
from datetime import datetime

class Log(db.Model):
    __tablename__ = 'logs'

    id_log = db.Column(db.Integer, primary_key=True)
    usuario = db.Column(db.String(100), nullable=False)
    accion = db.Column(db.Text, nullable=False)
    fecha = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id_log': self.id_log,
            'usuario': self.usuario,
            'accion': self.accion,
            'fecha': self.fecha.isoformat()
        }
