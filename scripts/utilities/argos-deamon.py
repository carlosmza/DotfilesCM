# ~/.local/bin/argos_daemon.py

import socket
import argostranslate.translate

HOST = "127.0.0.1"
PORT = 5005

from_code = "en"
to_code = "es"

def translate(text):
    return argostranslate.translate.translate(text, from_code, to_code)

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()

    print("Argos daemon running...")

    while True:
        conn, addr = s.accept()
        with conn:
            data = conn.recv(4096).decode("utf-8")
            if not data:
                continue

            result = translate(data)
            conn.sendall(result.encode("utf-8"))
