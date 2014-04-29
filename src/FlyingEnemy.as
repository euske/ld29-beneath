package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  FlyingEnemy (Maybe ClimbingEnemy)
// 
public class FlyingEnemy extends Actor
{
  public const speed:int = 3;

  public var _vy:int;

  public function FlyingEnemy(scene:Scene, vy:int)
  {
    super(scene);
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

    var dy:int = _vy*speed;
    if (isMovable(0, dy)) {
      move(0, dy);
    } else {
      _vy = -_vy;
    }

    skinId = Skin.spinBatFlying(phase);
  }
}

} // package
