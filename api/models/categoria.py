from models import db

class Categoria(db.Model):
    __tablename__ = 'categorias'

    id_categoria = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100), nullable=False)

    def to_dict(self):
        return {
            'id_categoria': self.id_categoria,
            'id': self.id_categoria,
            'nombre': self.nombre
        }