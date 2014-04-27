package {

public class Tile
{
  public static const NONE:int = 0;
  public static const DIRT:int = 2;

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

  // Empty tiles (as air).
  public static function isEmpty(i:int):Boolean
  { 
    return (i == NONE || i == LADDER || isSpawn(i) || isDeadly(i)); 
  }

  // Ladder tile (you can grab / don't fall down).
  public static function isLadder(i:int):Boolean
  { 
    return (i == LADDER || i == LADDER_TOP || i == LADDER_SIDE || i == LADDER_BOTTOM); 
  }

  // Tiles that you cannot step into.
  public static function isObstacle(i:int):Boolean
  { 
    return !(i == DIRT || isEmpty(i) || isLadder(i));
  }

  // Tile that you cannot fall into, but you can step into if you want.
  public static function isStoppable(i:int):Boolean 
  { 
    return !isEmpty(i);
  }

  // getFluid: maps a tile ID to animated tile ID.
  public static function getFluid(i:int, phase:int):int 
  {
    if (i == LAVA) return (55+phase % 5);
    return -1;
  }
  
}

}
