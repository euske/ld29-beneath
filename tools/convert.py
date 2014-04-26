#!/usr/bin/env python
import sys
import pygame

def doit(src):
    (w,h) = src.get_size()
    dst = pygame.Surface((w,h), 0, 32)
    ids = [ src.get_at((x,0)) for x in xrange(w) ]
    for y in xrange(h):
        for x in xrange(w):
            c = src.get_at((x,y))
            if y != 0:
                i = ids.index(c)
                if i == 3: i = 9
                c = ids[i]
            dst.set_at((x,y), c)
    return dst

def main(argv):
    args = argv[1:]
    srcpath = args.pop(0)
    dstpath = args.pop(0)
    img = pygame.image.load(srcpath)
    img = doit(img)
    pygame.image.save(img, dstpath)
    return 0

if __name__ == '__main__': sys.exit(main(sys.argv))
