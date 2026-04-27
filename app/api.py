from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from app.servicios.servicio_juego import ServicioJuego

app = FastAPI(title="QuizGame API")
servicio_juego = ServicioJuego()

#modelo para registrar a un usuario
class UsuarioNuevo(BaseModel):
    nombre_usuario: str

#modelo para las partidas
class PartidaNueva(BaseModel):
    id_categoria: int

#endpoint para registrar usuarios
@app.post("/api/usuarios")
def registrar_usuario(usuario: UsuarioNuevo):
    try:
        id_user = servicio_juego.registrar_usuario(usuario.nombre_usuario)
        return {"id_usuario": id_user}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

#endpoint para crear una partida    
@app.post("/api/partidas")
def crear_partida(partida: PartidaNueva):
    try:
        id_part = servicio_juego.crear_partida(partida.id_categoria)
        return {"id_partida": id_part}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

#endpoint para las categorias
@app.get("/api/categorias")
def obtener_categorias():
    categorias = servicio_juego.obtenerCategorias()
    return categorias

#endpoint para mostrar las preguntas
@app.get("/api/preguntas/{id_categoria}")
def obtener_preguntas(id_categoria: int):
    try:
        preguntas = servicio_juego.obtenerPreguntasAleatorias(id_categoria)
        if not preguntas:
            raise HTTPException(status_code=404, detail="Categoria no encontrada")
        return preguntas
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    