package {

public class Tile
{
  public static function isEmpty(c:int):Boolean { return (c == 0); }

  public static function isObstacle(c:int):Boolean { return (c != 0); }
}

}
