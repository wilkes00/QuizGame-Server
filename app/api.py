from fastapi import FastAPI, HTTPException
from app.servicios.servicio_juego import ServicioJuego

app = FastAPI(title="QuizGame API")
servicio_juego = ServicioJuego()

@app.get("/api/categorias")
def obtener_categorias():
    #consulta para la tabla categorias
    return {"mensaje": "Endpoint para listar categorias activo"}

@app.get("/api/preguntas/{id_categoria}")
def obtener_preguntas(id_categoria: int):
    try:
        preguntas = servicio_juego.obtenerPreguntasAleatorias(id_categoria)
        if not preguntas:
            raise HTTPException(status_code=404, detail="Categoria no encontrada")
        return preguntas
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    