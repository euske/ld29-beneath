package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  StickingEnemy
// 
public class StickingEnemy extends Actor
{
  public const speed:int = 4;

  private var _vx:int;
  private var _vy:int;
  private var _next:Point;

  public function StickingEnemy(scene:Scene, vx:int, vy:int)
  {
    super(scene);
    _vx = vx;
    _vy = vy;
  }

  public override function isMovable(dx:int, dy:int):Boolean
  {
    return (super.isMovable(dx, dy) &&
	    !scene.tilemap.hasCollisionByRect(bounds, dx, dy, Tile.isBlockingNormally));
  }

  public override function update(phase:int):void
  {
    super.update(phase);

    var dx:int = _vx*speed;
    var dy:int = _vy*speed;
    if (isMovable(dx, dy)) {
      move(dx, dy);
    }
    // check if there's a block on either side.
    if (scene.tilemap.hasCollisionByRect(bounds, -dy, dx, Tile.isBlockingNormally)) {
      // turn right: (vx,vy) = (-vy,+vx)
      _next = new Point(-_vy, +_vx);
    } else if (scene.tilemap.hasCollisionByRect(bounds, dy, -dx, Tile.isBlockingNormally)) {
      // turn left: (vx,vy) = (vy,-vx)
      _next = new Point(+_vy, -_vx);
    } else if (_next != null) {
      _vx = _next.x;
      _vy = _next.y;
    }
  }
}

} // package
