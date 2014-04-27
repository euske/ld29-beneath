package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  RunningEnemy 
// 
public class RunningEnemy extends Actor
{
  public const speed:int = 8;

  public var _vx:int;

  public function RunningEnemy(scene:Scene, vx:int)
  {
    super(scene);
    _vx = vx;
  }

  public override function isMovable(dx:int, dy:int):Boolean
  {
    var r:Rectangle = getMovedBounds(dx, dy);
    return (super.isMovable(dx, dy) &&
	    !scene.tilemap.hasCollisionByRect(bounds, dx, dy, Tile.isBlockingNormally) &&
	    scene.tilemap.hasCollisionByRect(r, 0, 1, Tile.isBlockingOnTop));
  }

  public override function update():void
  {
    super.update();
    var dx:int = _vx*speed;
    if (isMovable(dx, 0)) {
      move(dx, 0);
    } else {
      _vx = -_vx;
    }
  }
}

} // package
