#!/usr/bin/env python3
import json
import socket
import sys
import subprocess

HOST = "127.0.0.1"
PORT = 5005

DEFAULT_FROM = "en"
DEFAULT_TO = "es"


def get_selection():
    result = subprocess.run(
        ["wl-paste", "-p"], capture_output=True, text=True
    )
    return result.stdout.strip()


def get_cliphist_last():
    result = subprocess.run(
        ["bash", "-c", "cliphist list | head -1 | cliphist decode"],
        capture_output=True, text=True
    )
    return result.stdout.strip()


def _recv_all(s):
    chunks = []
    while True:
        chunk = s.recv(4096)
        if not chunk:
            break
        chunks.append(chunk)
    return b"".join(chunks).decode("utf-8")


def query_status():
    """Pregunta al daemon si el modelo ya está cargado. True = listo."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(5)
        try:
            s.connect((HOST, PORT))
            s.sendall(json.dumps({"cmd": "status"}).encode("utf-8"))
            s.shutdown(socket.SHUT_WR)
            return json.loads(_recv_all(s)).get("ready", False)
        except (ConnectionRefusedError, TimeoutError, OSError, ValueError):
            return False


def translate(text, from_code=DEFAULT_FROM, to_code=DEFAULT_TO):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(5)
        try:
            s.connect((HOST, PORT))
            payload = json.dumps({
                "from": from_code,
                "to": to_code,
                "text": text
            })
            s.sendall(payload.encode("utf-8"))
            s.shutdown(socket.SHUT_WR)
            return _recv_all(s)
        except (ConnectionRefusedError, TimeoutError, OSError) as e:
            print(f"Error: argos daemon not available ({e})", file=sys.stderr)
            sys.exit(1)


def parse_args(argv):
    from_code = DEFAULT_FROM
    to_code = DEFAULT_TO
    text = None
    status_only = False
    i = 0
    while i < len(argv):
        arg = argv[i]
        if arg == "--status":
            status_only = True
            i += 1
        elif arg in ("--from", "--from-lang", "-f") and i + 1 < len(argv):
            from_code = argv[i + 1]
            i += 2
        elif arg in ("--to", "--to-lang", "-t") and i + 1 < len(argv):
            to_code = argv[i + 1]
            i += 2
        else:
            text = arg
            i += 1
    return from_code, to_code, text, status_only


def main():
    from_code, to_code, text, status_only = parse_args(sys.argv[1:])
    if status_only:
        print("ready" if query_status() else "loading")
        return
    if not text:
        if (sel := get_selection()):
            text = sel
        elif (clip := get_cliphist_last()):
            text = clip
        else:
            print("No text in primary selection or clipboard history.", file=sys.stderr)
            sys.exit(1)
    if not text:
        print("Empty text.", file=sys.stderr)
        sys.exit(1)

    text = text.replace("\n", "").strip()[:500]
    if not text:
        print("Empty text.", file=sys.stderr)
        sys.exit(1)

    result = translate(text, from_code, to_code)
    print(result)


if __name__ == "__main__":
    main()
