#!/usr/bin/env python3

import random
import subprocess
import sys
from pathlib import Path


TRANSITION_TYPES = [
    "fade", "left", "right", "top", "bottom",
    "wipe", "wave", "grow", "center", "any", "outer",
]

FILTERS = ["Nearest", "Bilinear", "CatmullRom", "Mitchell", "Lanczos3"]


def random_bezier():
    a = round(random.uniform(0.0, 1.0), 2)
    b = round(random.uniform(0.0, 1.0), 2)
    c = round(random.uniform(0.0, 1.0), 2)
    d = round(random.uniform(0.0, 1.0), 2)
    return f"{a},{b},{c},{d}"


def build_args(image_path: str) -> list[str]:
    ttype = random.choice(TRANSITION_TYPES)
    duration = random.randint(2, 6)
    step = random.randint(20, 120)
    fps = random.choice([30, 60])
    filt = random.choice(FILTERS)
    bezier = random_bezier()

    cmd = [
        "awww", "img",
        "--transition-type", ttype,
        "--transition-duration", str(duration),
        "--transition-step", str(step),
        "--transition-fps", str(fps),
        "--filter", filt,
        "--transition-bezier", bezier,
    ]

    extra = ""
    if ttype in ("wipe", "wave"):
        angle = random.randint(0, 359)
        cmd += ["--transition-angle", str(angle)]
        extra = f" / angle: {angle}°"
    elif ttype in ("grow", "any", "outer"):
        x = round(random.uniform(0.0, 1.0), 2)
        y = round(random.uniform(0.0, 1.0), 2)
        cmd += ["--transition-pos", f"{x},{y}"]
        extra = f" / pos: ({x},{y})"

    cmd.append(str(image_path))

    name = Path(image_path).name
    print(f"    {name}")
    print(f"    {ttype}{extra}")

    return cmd


def main():
    if len(sys.argv) != 2:
        print("Usage: wallpaper-change.sh <image>", file=sys.stderr)
        sys.exit(1)

    raw = sys.argv[1]
    path = Path(raw).expanduser().resolve()

    if not path.is_file():
        print(f"Error: '{raw}' is not a valid file", file=sys.stderr)
        sys.exit(1)

    cmd = build_args(str(path))
    result = subprocess.run(cmd)
    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
