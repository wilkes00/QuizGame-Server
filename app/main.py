import socket
import threading
import json
import requests
import random

class TCPServer:
    def __init__(self, host='0.0.0.0', port=5000):
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        #permite reutilizar el puerto inmediatamente si se detiene y arranca el script
        self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server.bind((host, port))
        self.server.listen(5)

        # Configuración UDP
        self.server_udp = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.server_udp.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server_udp.bind((host, port))
        #definicion de la API
        self.api_url = "http://localhost:8000/api"

        print(f"[*] Servidor TCP Sockets iniciado en el puerto {port}")
        print("[*] Escuchando UDP y conexiones TCP...")

    
    def escuchar_udp(self):
        #este hilo solo se encarga de escuchar solicitudes UDP para el auto-descubrimiento del servidor
        while True:
            try:
                data, addr = self.server_udp.recvfrom(1024)
                mensaje = data.decode('utf-8')
                
                #este es el mensaje que el cliente envia para descubrir el servidor en la red local
                if mensaje == "QUIZ_GAME_SERVIDOR":
                    print(f"[UDP] Solicitud de descubrimiento desde {addr[0]}")
                    #respuesta al cliente para que sepa la IP del servidor
                    self.server_udp.sendto("AQUI_ESTOY".encode('utf-8'), addr)
            except Exception as e:
                print(f"[UDP Error] {e}")

    #manejador para cada cliente TCP que se conecta
    def manejador_cliente(self, conn, addr):
        print(f"[+] Jugador conectado desde: {addr}")

        #tiempo de gracia, si pasan 60 segundos en silencio, el server corta la conexion
        conn.settimeout(60.0)

        try:
            #bucle para escuchar indefinidamente al cliente
            while True:
                try:
                    data = conn.recv(4096).decode('utf-8').strip()
                    if not data:
                        break #el cliente cerro la conexion
                    print(f"Mensaje recibido de {addr}: {data}")
                    

                    #este es el mensaje deberia enviar el cliente para que el servidor registre al usuario en la db
                    #es REGISTRAR_USUARIO: seguido del nombre del usuario
                    if data.startswith("REGISTRAR_USUARIO:"):
                        nombre = data.split(":")[1]
                        #peticion POST a la API
                        respuesta_api = requests.post(f"{self.api_url}/usuarios", json={"nombre_usuario": nombre})

                        if respuesta_api.status_code == 200:
                            id_usuario = respuesta_api.json()["id_usuario"]
                            res = f"USUARIO_REGISTRADO:{id_usuario}\n"
                            conn.sendall(res.encode('utf-8'))
                            print(f"Usuario '{nombre}' registrado via API con el ID: {id_usuario}")

                    #Protocolo se debe enviar "INICIAR_PARTIDA: id_categoria"
                    elif data.startswith("INICIAR_PARTIDA:"):
                        partes = data.split(":")
                        if len(partes) == 2 and partes[1].isdigit():
                            id_cat = int(partes[1])

                            #peticion POST para crear la partida en la base de datos
                            post_partida = requests.post(f"{self.api_url}/partidas", json={"id_categoria": id_cat})
                            id_partida = post_partida.json()["id_partida"]

                            #peticion GET para obtener las preguntas
                            get_preguntas = requests.get(f"{self.api_url}/preguntas/{id_cat}")
                            preguntas = get_preguntas.json()

                            #empaquetado de la query en un JSON con un comando para que el cliente lo entienda
                            #el \n al final es importante para que StreamReader.ReadLine() funcione bien en C#
                            respuesta_json = json.dumps({"comando": "PREGUNTAS", 
                                                         "id_partida" : id_partida, 
                                                         "datos": preguntas}) + "\n"
                            
                            conn.sendall(respuesta_json.encode('utf-8'))
                            print(f"PARTIDA #{id_partida} creada.")
                    
                    #Caso en el que se recibe un JSON con los resultados de la partida.
                    elif data.startswith("{"):
                        try:
                            msg_json = json.loads(data)
                            if msg_json.get("comando") == "FINALIZAR_PARTIDA":
                                guardar = requests.post(f"{self.api_url}/resultados", json=msg_json)

                                if guardar.status_code == 200:
                                    filas = guardar.json().get("filas_insertadas", 0)
                                    print("Salio bien")
                                    conn.sendall("PARTIDA_GUARDADA\n".encode('utf-8'))
                                else:
                                    print("Error con la API al guardar los resultados")
                        except json.JSONDecodeError:
                            print("ERROR: Se recibio un JSON malformado de {addr[0]}")
                except socket.timeout:
                    print(f"El jugador {addr[0]} se quedo AFK. Cerrando conexion.")
                    break #romper el bucle si el jugador no responde en 60 segundos
        except Exception as e:
            print(f"[-] Error con el jugador {addr}: {e}")
        finally:
            print(f"[-] Jugador desconectado: {addr}")
            conn.close()

    def start(self):
        # hilo para escuchar solicitudes UDP de auto-descubrimiento
        thread_udp = threading.Thread(target=self.escuchar_udp, daemon=True)
        thread_udp.start()

        while True:
            #espera hasta que un cliente se conecte
            conn, addr = self.server.accept()
            #se lanza un thread por cada jugador para que el servidor no se congele
            thread_jugador = threading.Thread(target=self.manejador_cliente, args=(conn, addr))
            thread_jugador.start()

if __name__ == "__main__":
    servidor = TCPServer()
    servidor.start()
            