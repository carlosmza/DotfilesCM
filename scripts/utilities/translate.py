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
            response = s.recv(4096).decode("utf-8")
            return response
        except (ConnectionRefusedError, TimeoutError, OSError) as e:
            print(f"Error: argos daemon not available ({e})", file=sys.stderr)
            sys.exit(1)


def parse_args(argv):
    from_code = DEFAULT_FROM
    to_code = DEFAULT_TO
    text = None
    i = 0
    while i < len(argv):
        arg = argv[i]
        if arg in ("--from", "--from-lang", "-f") and i + 1 < len(argv):
            from_code = argv[i + 1]
            i += 2
        elif arg in ("--to", "--to-lang", "-t") and i + 1 < len(argv):
            to_code = argv[i + 1]
            i += 2
        else:
            text = arg
            i += 1
    return from_code, to_code, text


def main():
    from_code, to_code, text = parse_args(sys.argv[1:])
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
