package {

public class Tile
{
  // Ladder tile.
  public static function isLadder(i:int):Boolean { return (i == 9); }

  // Tile that you cannot go.
  public static function isObstacle(i:int):Boolean { return (i != 0 && i != 9); }

  // getFluid: maps a tile ID to animated tile ID.
  public static function getFluid(i:int, phase:int):int { 
    if (i == 4) return (49+(phase/2) % 5);
    return -1;
  }
  
}

}
