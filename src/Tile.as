package {

public class Tile
{
  // Ladder tile.
  public static function isLadder(c:int):Boolean { return (c == 3); }

  // Tile that you cannot go.
  public static function isObstacle(c:int):Boolean { return (c != 0 && c != 3); }
}

}
