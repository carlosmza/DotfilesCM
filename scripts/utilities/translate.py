#!/usr/bin/env python3
import socket
import sys
import subprocess

HOST = "127.0.0.1"
PORT = 5005


def get_selection():
    result = subprocess.run(
        ["wl-paste", "-p"], capture_output=True, text=True
    )
    return result.stdout.strip()


def translate(text):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(5)
        try:
            s.connect((HOST, PORT))
            s.sendall(text.encode("utf-8"))
            response = s.recv(4096).decode("utf-8")
            return response
        except (ConnectionRefusedError, TimeoutError, OSError) as e:
            print(f"Error: argos daemon not available ({e})", file=sys.stderr)
            sys.exit(1)


def main():
    text = get_selection()
    if not text:
        print("No text in primary selection.", file=sys.stderr)
        sys.exit(1)

    text = text.replace("\n", " ").strip()[:500]
    if not text:
        print("Empty text.", file=sys.stderr)
        sys.exit(1)

    result = translate(text)
    print(result)


if __name__ == "__main__":
    main()
