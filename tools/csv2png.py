#!/usr/bin/env python
# CSV->PNG conversion tool.
#   usage: python csv2png.py [-D|-T] [-o output.png] tilemap.csv dirtmap.csv
#
#   WARNING: output.png is overwritten without notice!

import sys
import csv
import pygame
import struct
import random

# SPAWN_GRAVE should be replaced with random graves.
SPAWN_GRAVE = 75
GRAVE_BEGIN = 66
GRAVE_END = 73
GRAVE_TRACE = 74

# SPAWN_ITEM should be replaced with random items.
SPAWN_ITEM = 81
ITEM_BEGIN = 87
ITEM_END = 90

# UNDIGGABLE should be replaced with rocks.
UNDIGGABLE = 80
DIRT_BEGIN = 2
DIRT_END = 53
ROCK_BEGIN = 85
ROCK_END = 86

def is_undiggable(i):
    return (i == UNDIGGABLE or
            (DIRT_BEGIN <= i and i <= DIRT_END))

colors = []
for i in xrange(256):
    (r,g,b,a) = ((i*11)%256, (i*22+33)%256, (i*33+44)%256, 255)
    c = (r,g,b,a)
    assert c not in colors
    colors.append(c)

def load_csv(path):
    fp = file(path)
    rows = [ [ int(v) for v in row ] for row in csv.reader(fp) ]
    fp.close()
    (w,h) = (len(rows[0]), len(rows))
    return (rows,(w,h))

def main(argv):
    import getopt
    import fileinput
    def usage():
        print 'usage: %s {-D output|-T output} tilemap.csv dirtmap.csv' % argv[0]
        return 100
    try:
        (opts, args) = getopt.getopt(argv[1:], 'D:T:')
    except getopt.GetoptError:
        return usage()
    mode = None
    for (k, v) in opts:
        if k == '-D': mode = 'D'; outpath = v
        elif k == '-T': mode = 'T'; outpath = v
    if mode is None: return usage();
    #
    (tilemap,(w0,h0)) = load_csv(args.pop(0))
    (dirtmap,(w1,h1)) = load_csv(args.pop(0))
    #
    assert w0 == w1
    assert h0 == h1
    img = pygame.Surface((w0,h0),0,32)
    for (y,(trow,drow)) in enumerate(zip(tilemap, dirtmap)):
        for (x,(tv,dv)) in enumerate(zip(trow, drow)):
            tv = int(tv)
            dv = int(dv)
            if mode == 'T':
                # convert tiles
                if is_undiggable(tv):
                    tv = random.randrange(ROCK_BEGIN, ROCK_END+1)
                elif tv == SPAWN_GRAVE:
                    tv = random.randrange(GRAVE_BEGIN, GRAVE_END+1)
                elif tv == SPAWN_ITEM:
                    tv = random.randrange(ITEM_BEGIN, ITEM_END+1)
                i = tv
            elif mode == 'D':
                # convert dirts
                i = dv
            img.set_at((x,y), colors[i])
    pygame.image.save(img, outpath)
    return 0

if __name__ == '__main__': sys.exit(main(sys.argv))
