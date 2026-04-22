import socket
import threading
import json
from app.servicios.servicio_juego import ServicioJuego

class TCPServer:
    def __init__(self, host='0.0.0.0', port=5000):
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        #permite reutilizar el puerto inmediatamente si se detiene y arranca el script
        self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server.bind((host, port))
        self.server.listen(5)
        self.servicio_juego = ServicioJuego()
        print(f"[*] Servidor TCP Sockets iniciado en el puerto {port}")

    def manejador_cliente(self, conn, addr):
        print(f"[+] Jugador conectado desde: {addr}")
        try:
            #bucle para escuchar indefinidamente al cliente
            while True:
                data = conn.recv(1024).decode('utf-8').strip()
                if not data:
                    break #el cliente cerro la conexion
                print(f"Mensaje recibido de {addr}: {data}")

                #Protocolo se debe enviar "INICIAR_PARtIDA:1"
                if data.startswith("INICIAR_PARTIDA:"):
                    partes = data.split(":")
                    if len(partes) == 2 and partes[1].isdigit():
                        id_cat = int(partes[1])

                        #obtener datos usando el servicio del juego
                        preguntas = self.servicio_juego.obtenerPreguntasAleatorias(id_cat)

                        #empaquetado de la query en un JSON con un comando para que el cliente lo entienda
                        #el \n al final es importante para que StreamReader.ReadLine() funcione bien en C#
                        respuesta_json = json.dumps({"comando": "PREGUNTAS", "datos": preguntas}) + "\n"
                        conn.sendall(respuesta_json.encode('utf-8'))

        except Exception as e:
            print(f"[-] Error con el jugador {addr}: {e}")
        finally:
            print(f"[-] Jugador desconectado: {addr}")
            conn.close()

    def start(self):
        while True:
            #espera hasta que un cliente se conecte
            conn, addr = self.server.accept()
            #se lanza un thread por cada jugador para que el servidor no se congele
            thread_jugador = threading.Thread(target=self.manejador_cliente, args=(conn, addr))
            thread_jugador.start()

if __name__ == "__main__":
    servidor = TCPServer()
    servidor.start()
            