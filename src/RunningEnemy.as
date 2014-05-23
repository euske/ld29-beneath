package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  RunningEnemy 
// 
public class RunningEnemy extends Actor
{
  public const speed:int = 4;

  public var _vx:int;

  public function RunningEnemy(scene:Scene, vx:int)
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
    setSkinId(Skin.moleRunning(phase, _vx));
  }
}

} // package
