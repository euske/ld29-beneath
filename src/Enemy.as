package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  Enemy
// 
public class Enemy extends Actor
{
  public const speed:int = 8;

  public var _vx:int;
  public var _vy:int;

  public function Enemy(scene:Scene)
  {
    super(scene);
    _vx = (Utils.rnd(2)*2-1) * speed;
    _vy = 0;
  }

  public override function isMovable(dx:int, dy:int):Boolean
  {
    return (super.isMovable(dx, dy) &&
	    !scene.tilemap.hasCollisionByRect(bounds, dx, dy, Tile.isBlockingNormally));
  }

  public override function update():void
  {
    super.update();
    if (isMovable(_vx, _vy)) {
      move(_vx, _vy);
    } else {
      _vx = -_vx;
    }
  }
}

} // package
