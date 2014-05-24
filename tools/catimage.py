#!/usr/bin/env python
# Image concatenation tool.
#   usage: python catimage.py [-p] [-s size] [-o output.png] a.png b.png ...
#
#   -p : add flipped image for each image.

import sys
import pygame

def main(argv):
    import getopt
    def usage():
        print 'usage: %s [-p] [-s size] [-o output] [file ...]' % argv[0]
        return 100
    try:
        (opts, args) = getopt.getopt(argv[1:], 'po:s:')
    except getopt.GetoptError:
        return usage()
    flip = False
    size = 0
    outpath = 'out.png'
    for (k, v) in opts:
        if k == '-p': flip = True
        elif k == '-s': size = int(v)
        elif k == '-o': outpath = v
    #
    width = 0
    height = 0
    imgs = []
    for path in args:
        img = pygame.image.load(path)
        (w,h) = img.get_size()
        if size == 0:
            size = h
        width += w*(h/size)
        height = max(height, size)
        imgs.append(img)
    if flip:
        width *= 2
    dst = pygame.Surface((width, height), pygame.SRCALPHA, 32)
    x1 = 0
    for src in imgs:
        (w,h) = src.get_size()
        for y0 in xrange(0, h, size):
            for x0 in xrange(0, w, size):
                tmp = src.subsurface((x0,y0,size,size))
                dst.blit(tmp, (x1,0))
                x1 += size
                if flip:
                    tmp = pygame.transform.flip(tmp, 1, 0)
                    dst.blit(tmp, (x1,0))
                    x1 += size
    pygame.image.save(dst, outpath)
    return 0

if __name__ == '__main__': sys.exit(main(sys.argv))
