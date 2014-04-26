#!/usr/bin/env python
import sys
import csv
import pygame
import struct

def main(argv):
    import fileinput
    rows = list(csv.reader(fileinput.input()))
    rows = [ [ int(v) for v in row ] for row in rows ]
    m = max( max(row) for row in rows )
    (w,h) = (len(rows[0]), len(rows))
    w = max(w, m)
    img = pygame.Surface((w,h+1),0,32)
    colors = [0]
    for i in xrange(m):
        c = ((i*11)%256, (i*22+33)%256, (i*33+44)%256, 255)
        assert c not in colors
        colors.append(c)
        img.set_at((i,0), c)
    for (y,row) in enumerate(rows):
        for (x,v) in enumerate(row):
            c = colors[int(v)]
            img.set_at((x,y+1), c)
    pygame.image.save(img, 'out.png')
    return 0

if __name__ == '__main__': sys.exit(main(sys.argv))
