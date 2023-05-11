"""
Compiles data files from chunks.

:source: https://www.oreilly.com/library/view/programming-python-second/0596000855/ch04s02.html
"""

import os
import sys


READSIZE = 1024


def join(fromdir, tofile):
    """Dummy docstring."""

    output = open(tofile, "wb")
    parts = os.listdir(fromdir)
    parts.sort()
    for filename in parts:
        filepath = os.path.join(fromdir, filename)
        fileobj = open(filepath, "rb")
        while 1:
            filebytes = fileobj.read(READSIZE)
            if not filebytes:
                break
            output.write(filebytes)
        fileobj.close()
    output.close()


if len(sys.argv) < 3:
    print("NO PASSED PATH TO DATA DIRECTORY!")
    sys.exit(1)

DATA_DIR = sys.argv[1]
FILE_DIR = os.path.join(DATA_DIR, sys.argv[2])

if not os.path.exists(FILE_DIR):
    print("DIRECTORY %s DOESN'T EXISTS!" % (FILE_DIR))
    sys.exit(1)

FILE_CSV = os.path.join(DATA_DIR, "%s.csv" % (FILE_DIR))

print("COMPILE %s..." % (FILE_CSV))
join(FILE_DIR, FILE_CSV)
print("SUCCESS!")
