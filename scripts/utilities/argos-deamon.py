#!/usr/bin/env python3
# No perder mas tiempo intentando optimizar esto, ctranslate2 por default consume mucha memoria

import socket

HOST = "127.0.0.1"
PORT = 5005

FROM_CODE = "en"
TO_CODE = "es"

IDLE_TIMEOUT = 600 # 900 = 15 min

translator_module = None


def translate(text):
    global translator_module

    if translator_module is None:
        print("[argos] Cargando Argos Translate...")

        import argostranslate.translate

        translator_module = argostranslate.translate

        print("[argos] Modelo cargado.")

    return translator_module.translate(
        text,
        FROM_CODE,
        TO_CODE
    )


with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:

    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    s.bind((HOST, PORT))
    s.listen()
    s.settimeout(IDLE_TIMEOUT)

    print("[argos] Daemon iniciado.")

    while True:

        try:
            conn, addr = s.accept()

        except socket.timeout:
            print("[argos] Timeout alcanzado. Terminando.")
            break

        with conn:

            data = conn.recv(4096).decode("utf-8")

            if not data:
                continue

            result = translate(data)

            conn.sendall(result.encode("utf-8"))
