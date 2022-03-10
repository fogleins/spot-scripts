#!/usr/bin/python3

import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-d", "--directory", help="Set the working directory", required=True)
args = parser.parse_args()

directory = args.directory

ratings = { -1: 0, 0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 }

EXPOSURE_DELTA = 0.25  # 0.4
TEMPERATURE_DELTA = 470  # 362
TINT_DELTA = 4
CLARITY_DELTA = 10

# create dirs
img_lists_dir = os.path.join(directory, "img-lists")
if not os.path.isdir(img_lists_dir):
    os.mkdir(img_lists_dir)

for filename in os.listdir(directory):
    file = os.path.join(directory, filename)
    if file.lower().endswith(".xmp"):
        with open(file, "r") as f:
            file_content = f.readlines()

            for i in range(0, len(file_content)):
                if "crs:Exposure2012" in file_content[i]:
                    exposure = float(file_content[i].split('"')[1])
                    prefix = "+" if (exposure + EXPOSURE_DELTA) > 0 else ""  # a - jelet kiteszi magatol
                    file_content[i] = f'   crs:Exposure2012="{prefix}{exposure + EXPOSURE_DELTA}"\n'
                elif "crs:Temperature" in file_content[i]:
                    temperature = int(file_content[i].split('"')[1])
                    file_content[i] = f'   crs:Temperature="{temperature + TEMPERATURE_DELTA}"\n'
                elif "crs:Tint" in file_content[i]:
                    tint = int(file_content[i].split('"')[1])
                    prefix = "+" if (tint + TINT_DELTA) > 0 else ""
                    file_content[i] = f'   crs:Tint="{prefix}{tint + TINT_DELTA}"\n'
                elif "crs:Clarity2012" in file_content[i]:
                    clarity = int(file_content[i].split('"')[1])
                    prefix = "+" if (clarity + CLARITY_DELTA) > 0 else ""
                    file_content[i] = f'   crs:Clarity2012="{prefix}{clarity + CLARITY_DELTA}"\n'

        with open(file, "w") as f:
            f.writelines(file_content)

            #rated = False
            #for line in f:
                #if "xmp:Rating" in line:
                    #rated = True
                    #rating = int(line.split('"')[1])
                    #ratings[rating] += 1

                #if "crs:Exposure2012" in line:
                    #exposure = float(line.split('"')[1])
                    #line = f'crs:Exposure2012="{exposure + 0.2}"'

                    # with open(os.path.join(img_lists_dir, f"imglist-rating-{rating}.txt"), "a") as outfile:
                        # outfile.write(filename.replace("xmp", "NEF") + "\n")

            #if not rated:
                #ratings[-1] += 1

#for i in range(-1, 6):
    #print(i, ": ", ratings[i])


