package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  FlyingEnemy (Maybe ClimbingEnemy)
// 
public class FlyingEnemy extends Actor
{
  public const speed:int = 3;

  public var _vx:int;
  public var _vy:int;

  public function FlyingEnemy(scene:Scene, vx:int, vy:int)
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
    } else {
      _vx = -_vx;
      _vy = -_vy;
    }

    skinId = Skin.spinBatFlying(phase);
  }
}

} // package
