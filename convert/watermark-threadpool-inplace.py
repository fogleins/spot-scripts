import os
from subprocess import PIPE, Popen
from multiprocessing import Pool

LOGO_PATH = "/home/SPOT/logo-invert-watermark-size.png"

def convert_image(image):
    if not image.endswith(".jpg"):
        return
    print("[ CONVERT ] " + image)
    process = Popen(["magick", image, "-strip", "-quality", "95", "-thumbnail", "2048x2048",
                     f"{LOGO_PATH}", "-gravity", "southeast", "-geometry", "+30+30",
                     "-composite", f"./watermark/2048/{image}"], stdout=PIPE, shell=False)
    (output, err) = process.communicate()
    exit_code = process.wait()

#    process = Popen(["magick", image, "-strip", "-quality", "95", "-thumbnail", "400x400",
#                     f"./watermark/400/{image}"], stdout=PIPE, shell=False)
#    (output, err) = process.communicate()
#    exit_code = process.wait()


if __name__ == "__main__":
    if not os.path.exists("./watermark"):
        os.mkdir("watermark")
    if not os.path.exists("./watermark/2048"):
        os.mkdir("./watermark/2048")
#    if not os.path.exists("./watermark/400"):
#        os.mkdir("./watermark/400")

    with Pool(8) as p:
        p.map(convert_image, os.listdir())
