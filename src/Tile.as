package {

import flash.geom.Point;
import flash.geom.Rectangle;

/*
Notable Numbers:
	Random gravestone sprites: 66 to 73
	Lava animation: 55 to 60
	Rain animation: 107 to 110 (works very similar to lava, but decorative only)
	Spikes: 83 & 84 (floor & ceiling)
	Undiggable rocks: 85 & 86
	Collectable bones: 87 to 93
	Decorations: 94 to 105
*/
/*
Spawn Tiles:
	Gravestone: 75
	Player: 76
	Enemies: 77 to 79
	Undiggable: 80
	Collectable: 81
	Food: 82
*/

public class Tile
{
  public static const tilesize:int = 16; // tilesize in pixels.

  public static const NONE:int = 0;

  // Dirt tiles (diggable).
  public static const DIRT_BKGND:int = 2; // a dirt tile drawn behind unbreakable things.
  public static const DIRT_BEGIN:int = 2;
  public static const DIRT_END:int = 53;

  // Deadly tiles.
  public static const LAVA_STILL:int = 54; // Solid red tile for lava pools 2 or more tiles in height
  public static const LAVA_ANIM_BEGIN:int = 55;
  public static const LAVA_ANIM_END:int = 60;
  public static const LAVA_SURFACE:int = 61; // Replaced with LAVA_ANIM_* tiles.

  // Ladder tiles.
  public static const LADDER:int = 62;
  public static const LADDER_TOP:int = 63;
  public static const LADDER_SIDE:int = 64; // Different tile, but same functionality as TOP
  public static const LADDER_BOTTOM:int = 65; // Can you make LADDER_TOP be the range of 63 to 65? ~Zarkith

  // Grave tiles (trasure).
  public static const GRAVE_BEGIN:int = 66;
  public static const GRAVE_END:int = 73;
  public static const GRAVE_TRACE:int = 74;

  // Spawn tiles.
  public static const SPAWN_GRAVE:int = 75; // unused.

  public static const SPAWN_PLAYER:int = 76; // These tiles are drawn in the tilemap for reference...
  public static const SPAWN_ENEMY1:int = 77; // ...but should be invisible in the game.
  public static const SPAWN_ENEMY2:int = 78; // ...but should be invisible in the game.
  public static const SPAWN_ENEMY3:int = 79; // enemy 3 no longer exists, do not use.

  // Unused.
  public static const UNDIGGABLE:int = 80; // unused. (stop sign)
  public static const SPAWN_ITEM:int = 81; // unused. (money bag)
  public static const SPAWN_FOOD:int = 82; // unused. (the word food)

  // Deadly tiles again.
  public static const SPIKE_BEGIN:int = 83;
  public static const SPIKE_END:int = 84;

  // Rock tiles (undiggable).
  public static const ROCK_BEGIN:int = 85;
  public static const ROCK_END:int = 86;

  // Colletibles.
  public static const ITEM_BEGIN:int = 87;
  public static const ITEM_END:int = 93;
  
  // Decorations.
  public static const DECO_BEGIN:int = 94;
  public static const DECO_END:int = 105;
  
  // Easter Egg sound cue
  public static const EASTER_EGG:int = 106;

  // Tiles where things can spawn (treated as empty).
  public static function isSpawn(i:int):Boolean
  {
    return (i == SPAWN_PLAYER || 
	    (SPAWN_ENEMY1 <= i && i <= SPAWN_ENEMY3) ||
	    i == SPAWN_GRAVE ||
	    i == SPAWN_ITEM ||
	    i == SPAWN_FOOD);
  }

  public static function isGrave(i:int):Boolean
  {
    return (GRAVE_BEGIN <= i && i <= GRAVE_END);
  }

  public static function isCollectible(i:int):Boolean
  {
    return (ITEM_BEGIN <= i && i <= ITEM_END);
  }

  // Deadly tiles (e.g. lava).
  public static function isDeadly(i:int):Boolean
  {
    return (i == LAVA_SURFACE || 
	    i == LAVA_STILL ||
	    (SPIKE_BEGIN <= i && i <= SPIKE_END));
  }

  // Ladder tile (you can grab / don't fall down).
  public static function isGrabbable(i:int):Boolean
  { 
    return (i == LADDER || 
	    i == LADDER_TOP);
  }

  // Tiles that are diggable.
  public static function isDiggable(i:int):Boolean
  {
    return (DIRT_BEGIN <= i && i <= DIRT_END);
  }
  // Tiles that are NOT diggable IF it's in tilemap.
  public static function isUndiggable(i:int):Boolean
  {
    return (i == UNDIGGABLE ||
	    (ROCK_BEGIN <= i && i <= ROCK_END));
  }

  // Tiles that are standable on top.
  public static function isStandable(i:int):Boolean
  {
    return (i == LADDER_TOP ||
	    i == LADDER_SIDE || 
	    i == LADDER_BOTTOM);
  }

  // Tiles that have no resistance.
  public static function isNonBlockingAlways(i:int):Boolean
  { 
    return (i == NONE || 
	    i == LADDER || 
	    i == GRAVE_TRACE ||
	    isGrave(i) ||
	    isSpawn(i) || 
	    isCollectible(i) ||
	    isDeadly(i) ||
	    (DECO_BEGIN <= i && i <= DECO_END) ||
		i == EASTER_EGG);
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
    return (isBlockingNormally(i) || i == LADDER);
  }

  // getFluid: maps a tile ID to animated tile ID.
  public static function getFluid(i:int, phase:int):int 
  {
    switch (i) {
    case LAVA_SURFACE:
      return LAVA_ANIM_BEGIN + (phase % (LAVA_ANIM_END-LAVA_ANIM_BEGIN+1));
    case LAVA_STILL:
      return LAVA_STILL;
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
    case LAVA_SURFACE:
      return new Rectangle(0, 2, tilesize, tilesize-2);
    default:
      return new Rectangle(0, 0, tilesize, tilesize);
    }
  }
  
}

}
