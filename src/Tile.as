package {

public class Tile
{
  public static const NONE:int = 0;
  public static const LADDER:int = 9;
  public static const LADDER_TOP:int = 10;

  public static const LAVA:int = 4;

  // Ladder tile.
  public static function isLadder(i:int):Boolean
  { 
    return (i == LADDER || i == LADDER_TOP); 
  }

  // Tile that you cannot go.
  public static function isObstacle(i:int):Boolean
  { 
    // TODO: this should be explicit.
    return !(i == NONE || i == LADDER || i == LADDER_TOP);
  }

  // Tile that you cannot fall into.
  public static function isStoppable(i:int):Boolean 
  { 
    return !(i == NONE || i == LADDER);
  }

  // getFluid: maps a tile ID to animated tile ID.
  public static function getFluid(i:int, phase:int):int 
  {
    if (i == LAVA) return (49+(phase/2) % 5);
    return -1;
  }
  
}

}
