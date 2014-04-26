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

  // Spawn tile.
  public static function isSpawn(i:int):Boolean
  {
    return (i == ENEMY || i == BOMB);
  }

  // Empty tile.
  public static function isEmpty(i:int):Boolean
  { 
    return (i == NONE || i == LADDER || isSpawn(i)); 
  }

  // Ladder tile.
  public static function isLadder(i:int):Boolean
  { 
    return (i == LADDER || i == LADDER_TOP); 
  }

  // Tile that you cannot go.
  public static function isObstacle(i:int):Boolean
  { 
    return !(isEmpty(i) || isLadder(i));
  }

  // Tile that you cannot fall into.
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
