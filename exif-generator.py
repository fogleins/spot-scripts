#!/usr/bin/python3

# újabb Python-verziókból már kimaradt a PIL (PythonImagingLibrary), helyette a Pillow használandó: https://pypi.org/project/pillow/
# (a PIL import továbbra is működik, a Pillow kompatibilis a PIL-lel)

import os
import csv
import math

from PIL import Image
from PIL.ExifTags import TAGS

def exposure_program_lookup(value: int):
    match value:
        case 0: return "Not defined"
        case 1: return "Manual"
        case 2: return "Normal program"
        case 3: return "Aperture priority"
        case 4: return "Shutter priority"
        case 5: return "Creative program"
        case 6: return "Action program"
        case 7: return "Portrait mode"
        case 8: return "Landscape mode"


vizsgaalbum_exif = dict()
vizsgaalbum_exif_tags = [ "DateTimeOriginal", "Model", "LensModel", "FocalLength" ]
field_names = [
        "File name",
        "DateTimeOriginal",
        "Dimensions",
        "File size",
        "Model",
        "LensModel",
        "FocalLength",
        "ShutterSpeed",
        "Aperture",
        "ISO",
        "Exposure program",
        "Flash"
    ]


with open("exif-data.csv", "w", newline="") as csv_file:
    writer = csv.DictWriter(csv_file, fieldnames=field_names)
    writer.writeheader()

    for f in sorted(os.listdir()):
        if f.lower().endswith(".jpg"):
            try:
                image = Image.open(f)
                exif_data = image._getexif()

                vizsgaalbum_exif["File name"] = f
                vizsgaalbum_exif["Dimensions"] = f"{image.width}×{image.height}"
                vizsgaalbum_exif["File size"] = f"{round(os.path.getsize(f) / (1000 * 1000), 2)} MB"
                vizsgaalbum_exif["ISO"] = exif_data.get(34855)  # ISO
                shutterspeed = exif_data.get(37377)
                # Shutter Speed számolás ez alapján: https://photo.stackexchange.com/a/108823
                if shutterspeed > 0:
                    vizsgaalbum_exif["ShutterSpeed"] = f"1/{round(pow(2, shutterspeed))}"
                else:
                    vizsgaalbum_exif["ShutterSpeed"] = f"{round(pow(0.5, shutterspeed))}"
                vizsgaalbum_exif["Aperture"] = round(math.sqrt(pow(2, exif_data.get(37378))), 1)
                vizsgaalbum_exif["Flash"] = exif_data.get(37385) != 16  # 16 azt jelenti, hogy nem vakuztunk
                vizsgaalbum_exif["Exposure program"] = exposure_program_lookup(exif_data.get(34850))

                if exif_data is not None:
                    for tag, value in exif_data.items():
                        tag_name = TAGS.get(tag, tag)
                        if tag_name in vizsgaalbum_exif_tags:
                            vizsgaalbum_exif[tag_name] = value
                    writer.writerow(vizsgaalbum_exif)
                else:
                    print(f"A(z) {f} állomány nem rendelkezik EXIF-adatokkal.")
            except Exception as e:
                print(f"Hiba a fájl megnyitása során: {e}")

