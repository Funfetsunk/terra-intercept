"""Check that sprite PNGs use only the game palette.

Usage (from the project root):
    python tools/check_palette.py                 # every PNG under art/sprites/
    python tools/check_palette.py path/to/a.png   # specific files

A PNG fails if any visible pixel is not one of the 64 colours in
art/palette/resurrect-64.hex, or if any pixel is semi-transparent.
Exits with status 1 when anything fails. Needs Pillow.
"""
import glob
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HEX_PATH = os.path.join(ROOT, "art", "palette", "resurrect-64.hex")


def load_palette() -> set:
    with open(HEX_PATH) as f:
        return {tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) for h in (line.strip() for line in f) if h}


def check(path: str, palette: set) -> tuple:
    im = Image.open(path).convert("RGBA")
    off = semi = 0
    for r, g, b, a in im.getdata():
        if a == 0:
            continue
        if a < 255:
            semi += 1
        if (r, g, b) not in palette:
            off += 1
    return off, semi


def main() -> int:
    palette = load_palette()
    files = sys.argv[1:] or sorted(glob.glob(os.path.join(ROOT, "art", "sprites", "**", "*.png"), recursive=True))
    failed = 0
    for path in files:
        off, semi = check(path, palette)
        if off or semi:
            failed += 1
            print(f"FAIL {os.path.relpath(path, ROOT)}: {off} off-palette, {semi} semi-transparent pixels")
    print(f"{len(files)} checked, {failed} failed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
