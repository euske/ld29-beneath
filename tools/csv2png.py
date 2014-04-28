#!/usr/bin/env python
# CSV->PNG conversion tool.
#   usage: python csv2png.py input.csv output.png
#
#   WARNING: output.png is overwritten without notice!

import sys
import csv
import pygame
import struct

colors = []
for i in xrange(256):
    (r,g,b,a) = ((i*11)%256, (i*22+33)%256, (i*33+44)%256, 255)
    c = (r,g,b,a)
    assert c not in colors
    colors.append(c)

def main(argv):
    import fileinput
    args = argv[1:]
    csvpath = args.pop(0)
    pngpath = args.pop(0)
    rows = list(csv.reader(fileinput.input([csvpath])))
    rows = [ [ int(v) for v in row ] for row in rows ]
    m = max( max(row) for row in rows )
    (w,h) = (len(rows[0]), len(rows))
    w = max(w, m)
    img = pygame.Surface((w,h),0,32)
    for (y,row) in enumerate(rows):
        for (x,v) in enumerate(row):
            c = colors[int(v)]
            img.set_at((x,y+1), c)
    pygame.image.save(img, pngpath)
    return 0

if __name__ == '__main__': sys.exit(main(sys.argv))
