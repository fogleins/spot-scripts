import os
from subprocess import PIPE, Popen
from multiprocessing import Pool


LOGO_PATH="/mnt/fstmp/fseaster180.png"


def convert_image(image):
    if not image.endswith(".jpg"):
        return
    print("[ CONVERT ] " + image)
    process = Popen(["convert", image, "-strip", "-quality", "95", "-thumbnail", "2048x2048",
                     LOGO_PATH, "-gravity", "southeast", "-geometry", "+30+30", "-composite", 
                     f"./watermark/{image}"], stdout=PIPE, shell=False)
    (output, err) = process.communicate()
    exit_code = process.wait()


if __name__ == "__main__":
    if not os.path.exists("./watermark"):
        os.mkdir("watermark")
    with Pool(8) as p:
        p.map(convert_image, os.listdir())
