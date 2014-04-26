package {

public class Tile
{
  public static const NONE:int = 0;
  public static const LADDER:int = 9;
  public static const LADDER_TOP:int = 10;

  public static const PLAYER:int = 11;
  public static const BOMB:int = 12;
  public static const ENEMY:int = 13;

  public static const LAVA:int = 4;

  // Tiles where things can spawn (treated as empty).
  public static function isSpawn(i:int):Boolean
  {
    return (i == ENEMY || i == BOMB);
  }

  // Deadly tiles (e.g. lava).
  public static function isDeadly(i:int):Boolean
  {
    return (i == LAVA);
  }

  // Empty tiles (as air).
  public static function isEmpty(i:int):Boolean
  { 
    return (i == NONE || i == LADDER || isSpawn(i) || isDeadly(i)); 
  }

  // Ladder tile (you can grab / don't fall down).
  public static function isLadder(i:int):Boolean
  { 
    return (i == LADDER || i == LADDER_TOP); 
  }

  // Tiles that you cannot step into.
  public static function isObstacle(i:int):Boolean
  { 
    return !(isEmpty(i) || isLadder(i));
  }

  // Tile that you cannot fall into, but you can step into if you want.
  public static function isStoppable(i:int):Boolean 
  { 
    return !isEmpty(i);
  }

  // getFluid: maps a tile ID to animated tile ID.
  public static function getFluid(i:int, phase:int):int 
  {
    if (i == LAVA) return (49+Math.floor(phase/2) % 5);
    return -1;
  }
  
}

}
