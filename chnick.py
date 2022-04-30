#!/usr/bin/python3

"""
    Használat:
        python3 chnick.py --directory <képeket tartalmazó mappa elérési útja> --nick <nick>

    A szóközt tartalmazó mappákkal óvatosan, a space-t escape-elni kell
"""

import os
from argparse import ArgumentParser


parser = ArgumentParser()
parser.add_argument("-d", "--directory", help="Set the working directory", required=True)
parser.add_argument("-n", "--nick", help="Set your nickname", required=True)
args = parser.parse_args()


for f in os.listdir(args.directory):
    f_path = os.path.join(args.directory, f)
    if f.endswith(".jpg"):
        new_file = os.path.join(args.directory, f.replace("spot", args.nick))
        os.rename(f_path, new_file)
    elif f.endswith(".JPG"):
        new_file = os.path.join(args.directory, f.replace("spot.JPG", args.nick + ".jpg"))
        os.rename(f_path, new_file)
