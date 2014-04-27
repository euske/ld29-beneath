#!/usr/bin/env python
import sys
import pygame

def main(argv):
    args = argv[1:]
    outpath = args.pop(0)
    width = 0
    imgs = []
    for path in args:
        img = pygame.image.load(path)
        (w,h) = img.get_size()
        width += w
        imgs.append(img)
    dst = pygame.Surface((width*2, 16), pygame.SRCALPHA, 32)
    x1 = 0
    for src in imgs:
        (w,h) = src.get_size()
        for x0 in xrange(0, w, 16):
            tmp = src.subsurface((x0,0,16,16))
            dst.blit(tmp, (x1,0))
            x1 += 16
            tmp = pygame.transform.flip(tmp, 1, 0)
            dst.blit(tmp, (x1,0))
            x1 += 16
    pygame.image.save(dst, outpath)
    return 0

if __name__ == '__main__': sys.exit(main(sys.argv))
