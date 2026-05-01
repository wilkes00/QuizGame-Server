import mysql.connector

class ServicioJuego:
    def get_connection(self):
        return mysql.connector.connect(
            host='localhost',
            user='root',
            password='root',
            database='quiz_game'
        )
    
    def obtenerCategorias(self):
        conn = self.get_connection()
        try:
            with conn.cursor(dictionary=True) as cursor:
                query = "SELECT * FROM categoria;"
                cursor.execute(query)
                categorias = cursor.fetchall()

                return categorias
        finally:
            if conn.is_connected():
                conn.close()
    
    def obtenerPreguntasAleatorias(self, id_categoria):
        conn = self.get_connection()
        try:
            with conn.cursor(dictionary=True) as cursor:
                #consulta principal
                query = "SELECT id_pregunta, texto_pregunta, tipo_respuesta FROM pregunta WHERE id_categoria = %s ORDER BY RAND() LIMIT 10"
                cursor.execute(query, (id_categoria,))
                preguntas = cursor.fetchall()

                #obtener respuestas para cada pregunta
                for pregunta in preguntas:
                    query_res = "SELECT id_respuesta, texto_respuesta, ruta_imagen, es_correcta FROM respuesta WHERE id_pregunta = %s"
                    cursor.execute(query_res, (pregunta['id_pregunta'],))

                    respuestas = cursor.fetchall()

                    #cambio de 'es_correcta' a true/false para JSON
                    for respuesta in respuestas:
                        respuesta['es_correcta'] = bool(respuesta['es_correcta'])
                    
                    pregunta['respuestas'] = respuestas
                
                return preguntas
        finally:
            if conn.is_connected():
                conn.close()
    
    def registrar_usuario(self, nombre_usuario):
        conn = self.get_connection()
        
        try:
            with conn.cursor(dictionary=True) as cursor:
                #verificar si el usuario ya existe
                query_verificar = "SELECT id_usuario FROM usuario WHERE nombre_usuario = %s"
                cursor.execute(query_verificar, (nombre_usuario,))
                usuario = cursor.fetchone()

                if usuario:
                    return usuario['id_usuario']
                else:
                    #si no existe, entonces insertarlo en la db
                    query_insert = "INSERT INTO usuario (nombre_usuario) VALUES (%s)"
                    cursor.execute(query_insert, (nombre_usuario,))
                    conn.commit()
                    #regresa el id generado por la db
                    return cursor.lastrowid
        finally:
            if conn.is_connected():
                conn.close()

    def crear_partida(self, id_categoria):
        conn = self.get_connection()
        try:
            with conn.cursor() as cursor:
                #insertamos la partida y obtenemos el id
                query = "INSERT INTO partida (fecha, id_categoria) VALUES (NOW(), %s)"
                cursor.execute(query, (id_categoria,))
                conn.commit()
                return cursor.lastrowid #obtiene el ultimo id insertado
        finally:
            if conn.is_connected():
                conn.close()

    def guardar_partida(self, id_partida, id_usuario, puntaje_final, detalles):
        conn = self.get_connection()
        try:
            with conn.cursor() as cursor:
                
                query_puntaje = "INSERT INTO partida_usuario (id_partida, id_usuario, puntaje_final) VALUES (%s, %s, %s)"
                cursor.execute(query_puntaje, (id_partida, id_usuario, puntaje_final))

                query_detalles = "INSERT INTO partida_detalle (id_partida, id_usuario, id_pregunta, id_respuesta, fue_correcta) VALUES (%s, %s, %s, %s, %s)"
                res_detalles = [(id_partida, id_usuario, d['id_pregunta'], d['id_respuesta'], d['fue_correcta']) for d in detalles]
                cursor.executemany(query_detalles, res_detalles)

                conn.commit()
                return cursor.rowcount
        finally:
            if conn.is_connected():
                conn.close()
        
    def obtener_podio(self, id_partida):
        conn = self.get_connection()
        try:
            with conn.cursor(dictionary=True) as cursor:
                query = """
                    SELECT u.nombre_usuario, pu.puntaje_final
                    FROM partida_usuario pu
                    JOIN usuario u ON pu.id_usuario = u.id_usuario
                    WHERE pu.id_partida = %s
                    ORDER BY pu.puntaje_final DESC
                """
                cursor.execute(query, (id_partida,))
                return cursor.fetchall()
        finally:
            if conn.is_connected():
                conn.close()

