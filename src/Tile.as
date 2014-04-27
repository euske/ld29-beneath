package {

import flash.geom.Point;
import flash.geom.Rectangle;

public class Tile
{
  public static const tilesize:int = 16; // tilesize in pixels.

  public static const NONE:int = 0;

  // Dirt tiles.
  public static const DIRT_BEGIN:int = 2;
  public static const DIRT_END:int = 53;

  // Ladder tiles.
  public static const LADDER:int = 62;
  public static const LADDER_TOP:int = 63;
  public static const LADDER_SIDE:int = 64;		// Different tile, but same functionality as TOP
  public static const LADDER_BOTTOM:int = 65;	// Can you make LADDER_TOP be the range of 63 to 65? ~Zarkith

  // Spawn tiles.
  public static const PLAYER:int = 74;		// These tiles are drawn in the tilemap for reference...
  public static const ENEMY:int = 75;		// ...but should be invisible in the game.
  public static const BOMB:int = 76;		// 	Shouldn't Bombs be an item/powerup instead of an obstacle?

  // Deadly tiles.
  public static const LAVA:int = 61;		// 
  public static const DEEPLAVA:int = 54;	// Solid red tile for lava pools 2 or more tiles in height

  // Tiles where things can spawn (treated as empty).
  public static function isSpawn(i:int):Boolean
  {
    return (i == PLAYER || i == ENEMY || i == BOMB);
  }

  // Deadly tiles (e.g. lava).
  public static function isDeadly(i:int):Boolean
  {
    return (i == LAVA || i == DEEPLAVA);
  }

  // Ladder tile (you can grab / don't fall down).
  public static function isGrabbable(i:int):Boolean
  { 
    return (i == LADDER || i == LADDER_TOP);
  }

  // Tiles that are diggable.
  public static function isDiggable(i:int):Boolean
  {
    return (DIRT_BEGIN <= i && i <= DIRT_END);
  }

  // Tiles that are standable on top.
  public static function isStandable(i:int):Boolean
  {
    return (i == LADDER_TOP || i == LADDER_SIDE || i == LADDER_BOTTOM);
  }

  // Tiles that have no resistance.
  public static function isNonBlockingAlways(i:int):Boolean
  { 
    return (i == NONE || i == LADDER || isSpawn(i) || isDeadly(i));
  }
  public static function isBlockingAlways(i:int):Boolean
  {
    return !(isNonBlockingAlways(i) || isStandable(i) || isDiggable(i));
  }

  // Tiles that blocks your way no matter how.
  public static function isBlockingNormally(i:int):Boolean
  { 
    return (isBlockingAlways(i) || isDiggable(i));
  }
  public static function isBlockingOnTop(i:int):Boolean
  { 
    return (isBlockingNormally(i) || isStandable(i));
  }
  public static function isBlockingOnLadder(i:int):Boolean
  { 
    return (isBlockingAlways(i) || i == LADDER);
  }

  // getFluid: maps a tile ID to animated tile ID.
  public static function getFluid(i:int, phase:int):int 
  {
    switch (i) {
    case LAVA:
      return (55+phase % 6);
    case DEEPLAVA:
      return i;
    default:
      return -1;
    }
  }

  // getRect: returns a bounds of a give tile.
  public static function getRect(i:int):Rectangle
  {
    switch (i) {
    case LADDER_TOP:
    case LADDER_SIDE:
    case LADDER_BOTTOM:
      return new Rectangle(0, 1, tilesize, 4);
    case LAVA:
      return new Rectangle(0, 2, tilesize, tilesize-2);
    default:
      return new Rectangle(0, 0, tilesize, tilesize);
    }
  }
  
}

}
