#!/usr/bin/python3

# eltávolítja a fájlok végén található számot,
# ha nem létezik még olyan fájl
# pl. 20220405_215713_simi-3.jpg -> 20220405_215713_simi.jpg

# a working directorynak a képeket tartalmazó mappának kell lennie

import os
import re

for img in os.listdir():
    if re.match(".+-[0-9]*.jpg$", img):
        base_filename = img.split("-")[0] + ".jpg"
        if not os.path.isfile(base_filename):
            print(f"Rename {img} -> {base_filename}")
            os.rename(img, base_filename)
