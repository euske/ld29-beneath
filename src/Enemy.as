package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  Enemy
// 
public class Enemy extends Actor
{
  public var vx:int;
  public var vy:int;

  public const speed:int = 8;

  public function Enemy(scene:Scene)
  {
    super(scene);
    updateDirection();
  }

  public override function isMovable(dx:int, dy:int):Boolean
  {
    return (super.isMovable(dx, dy) &&
	    !scene.tilemap.hasCollisionByRect(bounds, dx, dy, Tile.isObstacle));
  }


  public override function update():void
  {
    if (isMovable(vx, vy)) {
      move(vx, vy);
    } else {
      updateDirection();
    }
  }
  
  private function updateDirection():void
  {
    // randomoo!
    vx = vy = 0;
    while (vx == 0 && vy == 0) {
      vx = (Utils.rnd(3)-1)*speed;
    }
  }
  
}

} // package
