import os
from datetime import datetime, timedelta
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-d", "--directory", help="Set the working directory", required=True)
parser.add_argument("-t", "--test", "--dry-run", action="store_true", help="See a list of the current filenames and what they would be renamed to without making modifying them.")
parser.add_argument("-s", "--seconds", help="Set the time delta in seconds. Note that if you specify other time delta arguments, all of them will be applied (e.g. setting -s 60 and -m 1 will add two minutes.")
parser.add_argument("-m", "--minutes", help="Set the time delta in minutes. Note that if you specify other time delta arguments, all of them will be applied (e.g. setting -s 60 and -m 1 will add two minutes.")
parser.add_argument("-H", "--hours", help="Set the time delta in hours. Note that if you specify other time delta arguments, all of them will be applied (e.g. setting -s 60 and -m 1 will add two minutes.")
args = parser.parse_args()

directory = args.directory
tdelta_hours = int(args.hours) if args.hours else 0
tdelta_minutes = int(args.minutes) if args.minutes else 0
tdelta_seconds = int(args.seconds) if args.seconds else 0
tdelta = timedelta(hours=tdelta_hours, minutes=tdelta_minutes, seconds=tdelta_seconds)
renamed_count = 0

for filename in os.listdir(directory):
    file = os.path.join(directory, filename)
    if os.path.isfile(file) and file.lower().endswith(".jpg"):
        # create a datetime object based on the filename
        # assuming that format is yyyymmdd_HHMMSS_string.jpg
        exif_datetime = datetime(int(filename[:4]), int(filename[4:6]), int(filename[6:8]), int(filename[9:11]), int(filename[11:13]), int(filename[13:15]))
        new_datetime = exif_datetime + tdelta
        new_filename = f"{new_datetime.year}{new_datetime.month:02d}{new_datetime.day:02d}_{new_datetime.hour:02d}{new_datetime.minute:02d}{new_datetime.second:02d}_{filename[16:]}"
        new_file = os.path.join(directory, new_filename)
        if not args.test:
            os.rename(file, new_file)
        else:
            # execute the line below if you are unsure if you would get the expected result
            print(f"If this wasn't a dry run, I would rename {filename} to {new_filename}.")
        renamed_count += 1

print(f"Renamed {renamed_count} files")
