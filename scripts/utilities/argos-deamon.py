#!/usr/bin/env python3
# No perder mas tiempo intentando optimizar esto, ctranslate2 por default consume mucha memoria

import json
import socket

HOST = "127.0.0.1"
PORT = 5005

DEFAULT_FROM = "en"
DEFAULT_TO = "es"

IDLE_TIMEOUT = 600 # 900 = 15 min

translator_module = None


def translate(text, from_code=DEFAULT_FROM, to_code=DEFAULT_TO):
    global translator_module

    if translator_module is None:
        print("[argos] Cargando Argos Translate...")

        import argostranslate.translate

        translator_module = argostranslate.translate

        print("[argos] Modelo cargado.")

    return translator_module.translate(
        text,
        from_code,
        to_code
    )


def parse_payload(data):
    try:
        payload = json.loads(data)
        if isinstance(payload, dict) and "text" in payload:
            return (
                payload.get("from", DEFAULT_FROM),
                payload.get("to", DEFAULT_TO),
                payload["text"]
            )
    except (json.JSONDecodeError, UnicodeDecodeError):
        pass
    return DEFAULT_FROM, DEFAULT_TO, data


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

            from_code, to_code, text = parse_payload(data)

            result = translate(text, from_code, to_code)

            conn.sendall(result.encode("utf-8"))
