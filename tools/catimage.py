#!/usr/bin/env python
# Image concatenation tool.
#   usage: python catimage.py [-p] [-o output.png] a.png b.png ...
#
#   -p : add flipped image for each image.

import sys
import pygame

def main(argv):
    import getopt
    def usage():
        print 'usage: %s [-p] [-o output] [file ...]' % argv[0]
        return 100
    try:
        (opts, args) = getopt.getopt(argv[1:], 'po:')
    except getopt.GetoptError:
        return usage()
    flip = False
    outpath = 'out.png'
    for (k, v) in opts:
        if k == '-p': flip = True
        elif k == '-o': outpath = v
    #
    width = 0
    height = 0
    imgs = []
    for path in args:
        img = pygame.image.load(path)
        (w,h) = img.get_size()
        width += w
        height = max(height, h)
        imgs.append(img)
    if flip:
        width *= 2
    dst = pygame.Surface((width, height), pygame.SRCALPHA, 32)
    x1 = 0
    for src in imgs:
        (w,h) = src.get_size()
        for x0 in xrange(0, w, h):
            tmp = src.subsurface((x0,0,h,h))
            dst.blit(tmp, (x1,0))
            x1 += h
            if flip:
                tmp = pygame.transform.flip(tmp, 1, 0)
                dst.blit(tmp, (x1,0))
                x1 += h
    pygame.image.save(dst, outpath)
    return 0

if __name__ == '__main__': sys.exit(main(sys.argv))
