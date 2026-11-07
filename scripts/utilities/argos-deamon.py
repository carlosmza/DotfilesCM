#!/usr/bin/env python3
# Daemon Argos Translate — opción A: siempre caliente.
#
# - El socket acepta conexiones desde el segundo 0; el modelo se carga
#   en segundo plano al arrancar (eager load + warmup), NO dentro de
#   la primera petición.
# - Cachea un objeto ITranslation por par (from, to): no re-resuelve
#   los paquetes instalados en cada petición.
# - Comando {"cmd": "status"} -> {"ready": true/false} para que la UI
#   distinga "cargando modelo" de "traduciendo".
# - Sin IDLE_TIMEOUT: el proceso vive hasta que systemd lo pare
#   (ver argos-daemon.service: Restart=on-failure).
# - ctranslate2 consume mucha RAM de forma permanente: es el precio
#   de la opción A (traducción instantánea).

import json
import socket
import threading
import traceback

HOST = "127.0.0.1"
PORT = 5005

DEFAULT_FROM = "en"
DEFAULT_TO = "es"
WARMUP_PAIRS = [(DEFAULT_FROM, DEFAULT_TO), (DEFAULT_TO, DEFAULT_FROM)]

_model_ready = threading.Event()
_translations = {}
_load_error = None


def _load_models():
    """Eager load en hilo de fondo: importa, precarga pares y calienta ctranslate2."""
    global _load_error
    try:
        print("[argos] Cargando Argos Translate (eager)...", flush=True)

        import argostranslate.translate as translator_module

        for from_code, to_code in WARMUP_PAIRS:
            try:
                trans = translator_module.get_translation_from_codes(from_code, to_code)
                trans.translate("Hello")  # warmup: fuerza la init de ctranslate2
                _translations[(from_code, to_code)] = trans
                print(f"[argos] Par {from_code}->{to_code} listo.", flush=True)
            except Exception:
                print(f"[argos] Aviso: no se pudo precargar {from_code}->{to_code}:", flush=True)
                traceback.print_exc()

        print("[argos] Modelo listo.", flush=True)
    except Exception as e:
        _load_error = e
        print("[argos] ERROR cargando modelo:", flush=True)
        traceback.print_exc()
    finally:
        _model_ready.set()


def _get_or_create(from_code, to_code):
    key = (from_code, to_code)
    if key not in _translations:
        import argostranslate.translate as translator_module

        _translations[key] = translator_module.get_translation_from_codes(from_code, to_code)
    return _translations[key]


def parse_payload(data):
    """Devuelve (from, to, text, is_status). Acepta JSON nuevo y texto plano legacy (nc)."""
    try:
        payload = json.loads(data)
        if isinstance(payload, dict):
            if payload.get("cmd") == "status":
                return DEFAULT_FROM, DEFAULT_TO, "", True
            if "text" in payload:
                return (
                    payload.get("from", DEFAULT_FROM),
                    payload.get("to", DEFAULT_TO),
                    payload["text"],
                    False,
                )
    except (json.JSONDecodeError, UnicodeDecodeError):
        pass
    return DEFAULT_FROM, DEFAULT_TO, data, False


def _recv_all(conn):
    chunks = []
    while True:
        chunk = conn.recv(4096)
        if not chunk:
            break
        chunks.append(chunk)
    return b"".join(chunks).decode("utf-8")


def _handle(conn):
    data = _recv_all(conn)
    if not data:
        return

    from_code, to_code, text, is_status = parse_payload(data)

    if is_status:
        conn.sendall(
            json.dumps(
                {"ready": _model_ready.is_set() and _load_error is None}
            ).encode("utf-8")
        )
        return

    _model_ready.wait()
    if _load_error is not None:
        return  # el cliente muestra su mensaje de error al recibir vacío

    try:
        result = _get_or_create(from_code, to_code).translate(text)
    except Exception:
        traceback.print_exc()
        return

    conn.sendall(result.encode("utf-8"))


def main():
    loader = threading.Thread(target=_load_models, daemon=True)
    loader.start()

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind((HOST, PORT))
        s.listen()

        print("[argos] Daemon iniciado (socket abierto, modelo cargando en fondo).", flush=True)

        while True:
            try:
                conn, _addr = s.accept()
            except KeyboardInterrupt:
                print("[argos] Interrumpido. Terminando.", flush=True)
                break
            except OSError:
                traceback.print_exc()
                continue

            with conn:
                try:
                    conn.settimeout(10)
                    _handle(conn)
                except (socket.timeout, ConnectionError, OSError):
                    continue
                except Exception:
                    traceback.print_exc()
                    continue


if __name__ == "__main__":
    main()
