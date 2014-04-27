=======================================================================================
How to start:

Install:
  Java JRE (32-bit): http://www.oracle.com/technetwork/java/javase/downloads/index.html
  Flex SDK 4: https://www.adobe.com/devnet/flex/flex-sdk-download.html
  FlashDevelop: http://www.flashdevelop.org/
=======================================================================================

TODO:
---------------------------------------------------------------------------------------
! Switch from mapdata.png to mapdata.csv !!IMPORTANT!!

  Need to tweak digging:
   - Change surrounding tiles to what they need to be after digging (after higher priority stuff)
   - Digging should slow movement

  Need to tweak physics: (While Euske is at work)
   - gravity
   - speed / maximum speed
   - jump height
   - enemy speed / enemy gravity

  For enemy/obstacle type:
   - moving/jumping (affected by grativty) 	[TOO COMPLEX]
   - floating/flying (not affected by gravity)
   - triggered (bomb, trap, icicle, etc.) 	[NO TIME TO IMPLEMENT]
   - collectible (coins, items, FOODS, etc.)
   We need:
     - Tile (16x16, if the object is static.)		// Does this mean lava should be
     - Sprite (16x16, if the object is animated.)	// moved to its own spritesheet?

  For each tile/animated object:
   Need a predictable way to locate the area in the sprite/tile sheet.
   Maybe reserve some space for additons?
   (e.g. 1st row is for enemy, 2nd row is for particle, etc.)

  What kind of powerups?	[!DEFINITELY NO TIME TO IMPLEMENT POWERUPS!]
	- See further into solid tiles
	- See all hazard tiles that are behind fog of war
	- Faster run, higher jump, faster dig.

  Cooler way of uncovering a map?

  Need to implement:	[NO TIME]
    Falling Rocks

=======================================================================================
To Hawk (How to compile the thing):
  1. Install Java.
  2. Download Flex SDK 4.6 and unpack on your home directory. (your_home/flex_sdk_4.6)
  3. Run build.sh
  4. bin/beneath.swf should be playable.
