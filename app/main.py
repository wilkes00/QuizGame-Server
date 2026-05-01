import socket
import threading
import json
import requests

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

        #variables para sala de espera
        self.clientes_conectados = []
        self.host_conn = None
        #para evitar problemas entre los hilos
        self.lock = threading.Lock()
        #contador
        self.respuestas_recibidas = 0
        self.partida_actual = None

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


    def mandar_podio(self, id_partida):
        print(f"Solicitando podio para la partida {id_partida}...")
        try:
            res_podio = requests.get(f"{self.api_url}/resultados/{id_partida}")
        except requests.exceptions.RequestException as e:
            print(f"Error con la peticion a la API: {e}")

        if res_podio.status_code == 200:
            datos_podio = res_podio.json()["podio"]
            json_podio = json.dumps({
                "comando": "MOSTRAR_PODIO",
                "datos": datos_podio
            }) + "\n"
            
            for cliente in self.clientes_conectados:
                try:
                    cliente.sendall(json_podio.encode('utf-8'))
                except:
                    pass
            
            print(f"[*] Podio enviado a {len(self.clientes_conectados)} jugadores.")
        
        #reinicio de las variables para la siguiente partida
        self.respuestas_recibidas = 0
        self.partida_actual = None


    #manejador para cada cliente TCP que se conecta
    def manejador_cliente(self, conn, addr):
        print(f"[+] Jugador conectado desde: {addr}")

        #tiempo de gracia, si pasan 5 minutos en silencio, el server corta la conexion
        conn.settimeout(300.0)

        with self.lock:
            self.clientes_conectados.append(conn)

            if self.host_conn is None:
                self.host_conn = conn
                conn.sendall("ROL:HOST\n".encode('utf-8'))
                print(f"{addr[0]} ha sido asignado como el HOST de la sala.")
            else:
                conn.sendall("ROL:JUGADOR\n".encode('utf-8'))
                print(f"{addr[0]} se unio como JUGADOR")  

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
                        nombre_user = data.split(":")[1]
                        
                        try:
                            #peticion POST a la API
                            respuesta_api = requests.post(f"{self.api_url}/usuario", json={"nombre": nombre_user})
                        except requests.exceptions.RequestException as e:
                            print(f"Error con la peticion a la API: {e}")

                        if respuesta_api.status_code == 200:
                            id_usuario = respuesta_api.json()["id_usuario"]
                            res = f"USUARIO_REGISTRADO:{id_usuario}\n"
                            conn.sendall(res.encode('utf-8'))
                            print(f"Usuario '{nombre_user}' registrado via API con el ID: {id_usuario}")
                        else:
                            print(f"Error 500 de la API al registrar: {respuesta_api.text}")

                    #Protocolo se debe enviar "INICIAR_PARTIDA: id_categoria"
                    elif data.startswith("INICIAR_PARTIDA:"):
                        #verifcar si quien envia el mensaje es el host
                        if conn == self.host_conn:
                            partes = data.split(":")
                            if len(partes) == 2 and partes[1].isdigit():
                                id_cat = int(partes[1])

                                try:
                                    #peticion POST para crear la partida en la base de datos
                                    post_partida = requests.post(f"{self.api_url}/partidas", json={"id_categoria": id_cat})
                                except requests.exceptions.RequestException as e:
                                    print(f"Error con la peticion a la API: {e}")

                                if post_partida.status_code == 200:
                                    id_partida = post_partida.json()["id_partida"]

                                    #reinicio de variables para esta nueva partida
                                    with self.lock:
                                        self.partida_actual = id_partida
                                        self.respuestas_recibidas = 0

                                    try:
                                        #peticion GET para obtener las preguntas
                                        get_preguntas = requests.get(f"{self.api_url}/preguntas/{id_cat}")
                                    except requests.exceptions.RequestException as e:
                                        print(f"Error con la peticion a la API: {e}")

                                    preguntas = get_preguntas.json()

                                    #empaquetado de la query en un JSON con un comando para que el cliente lo entienda
                                    #el \n al final es importante para que StreamReader.ReadLine() funcione bien en C#
                                    respuesta_json = json.dumps({"comando": "PREGUNTAS", 
                                                                "id_partida" : id_partida, 
                                                                "datos": preguntas}) + "\n"
                                    
                                    with self.lock:
                                        for cliente in self.clientes_conectados:
                                            try:
                                                cliente.sendall(respuesta_json.encode('utf-8'))
                                            except Exception as e:
                                                print(f"No se pudo enviar a un cliente: {e}")

                                    print(f"El HOST ha iniciado la partida #{id_partida}. Preguntas enviadas a todos.")
                        else:
                              print(f"Un jugador no HOST intento iniciar la partida. Accion bloqueada.")

                    #Caso en el que se recibe un JSON con los resultados de la partida.
                    elif data.startswith("{"):
                        try:
                            msg_json = json.loads(data)
                            if msg_json.get("comando") == "FINALIZAR_PARTIDA":
                                try:
                                    #peticion POST a la api para guardar los resultados en la base de datos
                                    guardar = requests.post(f"{self.api_url}/resultados", json=msg_json)
                                except requests.exceptions.RequestException as e:
                                    print(f"Error con la peticion a la API: {e}")

                                if guardar.status_code == 200:
                                    print("[*] Resultados de un jugador guardados exitosamente")
                                    conn.sendall("PARTIDA_GUARDADA\n".encode('utf-8'))

                                    with self.lock:
                                        self.respuestas_recibidas += 1
                                        total_jugadores = len(self.clientes_conectados)
                                        
                                        #condicion: ya se recibio todos los resultados de los jugadores?
                                        if self.respuestas_recibidas == total_jugadores:
                                            self.mandar_podio(self.partida_actual)
                                else:
                                    print("Error con la API al guardar los resultados")
                        except json.JSONDecodeError:
                            print(f"ERROR: Se recibio un JSON malformado de {addr[0]}")
                except socket.timeout:
                    print(f"El jugador {addr[0]} se quedo AFK. Cerrando conexion.")
                    break #romper el bucle si el jugador no responde en 5 minutos
        except Exception as e:
            print(f"[-] Error con el jugador {addr}: {e}")
        finally:
            with self.lock:
                if conn in self.clientes_conectados:
                    #se elimina la conexion de la lista si el jugador se desconecta
                    self.clientes_conectados.remove(conn)

                

                if conn == self.host_conn:
                    self.host_conn = None
                    if len(self.clientes_conectados) > 0:
                        self.host_conn = self.clientes_conectados[0]
                        try:
                            self.host_conn.sendall("ROL:HOST\n".encode('utf-8'))
                            print("El HOST original se desconecto. Se ha asignado un nuevo HOST.")
                        except:
                            pass
                
                total_jugadores = len(self.clientes_conectados)
                #si hay una partida activa, aun quedan jugadores, y los que quedan ya terminaron:
                if self.partida_actual is not None and total_jugadores > 0:
                   if self.respuestas_recibidas >= total_jugadores:
                        print("Un jugador se desconecto, generando el podio para los jugadores restantes...")
                        self.mandar_podio(self.partida_actual)
                   
            print(f"[-] Jugador desconectado: {addr[0]}. Quedan {len(self.clientes_conectados)} en la sala.")
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
            