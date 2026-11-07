#!/usr/bin/env python3

from pathlib import Path
import subprocess

# Configuración de rutas
WALLPAPERS_DIR = Path("/home/carlosm/Pictures/Wallpapers")
THUMBS_DIR = Path("/home/carlosm/Pictures/wallpaper_thumbs")

THUMB_WIDTH = 300
THUMB_HEIGHT = 200


def list_files(directory: Path) -> list[str]:
    """
    Devuelve únicamente los nombres de archivo contenidos
    en el directorio.
    """
    return [f.name for f in directory.iterdir() if f.is_file()]


def remove_ext(filename: str) -> str:
    """
    Elimina la extensión del archivo.
    """
    return Path(filename).stem


print("Scanning wallpapers and thumbnails...")

# 1) Leer wallpapers y thumbnails
wallpapers = list_files(WALLPAPERS_DIR)
thumbs = list_files(THUMBS_DIR)

# 2) Crear conjunto de thumbnails existentes
thumbs_base = {
    remove_ext(t).removeprefix("thumb-")
    for t in thumbs
}

# 3) Crear thumbnails faltantes
for wallpaper in wallpapers:
    w_path = WALLPAPERS_DIR / wallpaper
    w_base = remove_ext(wallpaper)

    t_path = THUMBS_DIR / f"thumb-{wallpaper}"

    if w_base not in thumbs_base:
        print(f"Generating thumbnail for: {w_path}")

        cmd = [
            "/usr/bin/magick",
            str(w_path),
            "-thumbnail",
            f"{THUMB_WIDTH}x{THUMB_HEIGHT}^",
            "-gravity",
            "center",
            "-extent",
            f"{THUMB_WIDTH}x{THUMB_HEIGHT}",
            str(t_path),
        ]

        result = subprocess.run(
            cmd,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

        if result.returncode != 0:
            print(f"Error generating thumbnail for: {w_path}")

print("Thumbnail generation complete.")
