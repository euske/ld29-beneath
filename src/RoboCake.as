package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  RoboCake
// 
public class RoboCake extends Actor
{
  public const speed:int = 0;

  public var _vx:int;

  public function RoboCake(scene:Scene, vx:int)
  {
    super(scene);
    _vx = vx;
  }

  public override function isMovable(dx:int, dy:int):Boolean
  {
    return (super.isMovable(dx, dy) &&
	    !scene.tilemap.hasCollisionByRect(bounds, dx, dy, Tile.isBlockingNormally) &&
	    scene.tilemap.hasCollisionByRect(getMovedBounds(dx, dy),
					     0, 1, Tile.isBlockingOnTop));
  }

  public override function update(phase:int):void
  {
    super.update(phase);

    var dx:int = _vx*speed;
    if (isMovable(dx, 0)) {
      move(dx, 0);
    } else {
      _vx = -_vx;
    }
    setSkinId(Skin.roboCake(phase)+((0 < _vx)? 0 : 1));
  }
}

} // package
