from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from app.servicios.servicio_juego import ServicioJuego

app = FastAPI(title="QuizGame API")
servicio_juego = ServicioJuego()

#modelo para registrar a un usuario
class UsuarioNuevo(BaseModel):
    nombre: str

#modelo para las partidas
class PartidaNueva(BaseModel):
    id_categoria: int

#modelo para los detalles de la respuesta, que pregunta fue, que respuesta escogio y si es correcta o no
class DetalleRespuesta(BaseModel):
    id_pregunta: int
    fue_correcta: bool

#modelo para guardar en la db el historial de la partida
class ResultadoPartida(BaseModel):
    id_partida: int
    id_usuario: int
    puntaje_final : int
    detalles : list[DetalleRespuesta]

#endpoint para registrar usuarios
@app.post("/api/usuario")
def registrar_usuario(usuario: UsuarioNuevo):
    try:
        id_user = servicio_juego.registrar_usuario(usuario.nombre)
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
    
#endpoint para guardar los resultados de la partida
@app.post("/api/resultados")
def guardar_partida(resultados : ResultadoPartida):
    try:
        detalles_dict = [d.model_dump() for d in resultados.detalles]

        filas_insertdas = servicio_juego.guardar_partida(
            resultados.id_partida,
            resultados.id_usuario,
            resultados.puntaje_final,
            detalles_dict
        )
        return{"mensaje" : "Historial guardado con exito"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

#endpoint para obtener los puntajes finales de una partida
@app.get("/api/resultados/{id_partida}")
def obtener_podio(id_partida: int):
    try:
        podio = servicio_juego.obtener_podio(id_partida)
        return {"podio": podio}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))