
How to start:

Install:
  Java JRE (32-bit): http://www.oracle.com/technetwork/java/javase/downloads/index.html
  Flex SDK 4: https://www.adobe.com/devnet/flex/flex-sdk-download.html
  FlashDevelop: http://www.flashdevelop.org/

TODO:
  http://videogamena.me/

  Need to tweak physics:
   - gravity
   - speed / maximum speed
   - jump height
   - enemy speed / enemy gravity

  For enemy/obstacle type:
   - moving/jumping (affected by grativty)
   - floating/flying (not affected by gravity)
   - triggered (bomb, trap, icicle, etc.)
   We need:
     - Tile (16x16, if the object is static.)
     - Sprite (16x16, if the object is animated.)

  For each tile/animated object:
   Need a predictable way to locate the area in the sprite/tile sheet.
   Maybe reserve some space for additons?
   (e.g. 1st row is for enemy, 2nd row is for particle, etc.)

  Need to implement:
   Rocks
   Collectibles  

  We need spawn tiles!


To Hawk (How to compile the thing):
  1. Install Java.
  2. Download Flex SDK 4.6 and unpack on your home directory. (your_home/flex_sdk_4.6)
  3. Run build.sh
  4. bin/beneath.swf should be playable.
