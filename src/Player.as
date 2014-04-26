package {

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.media.Sound;
import flash.geom.Point;
import flash.geom.Rectangle;

//  Player
//
public class Player extends Actor
{
  // the way the player wants to move.
  public var vx:int;
  public var vy:int;

  public var vg:int;

  private var _jumping:Boolean;

  public const speed:int = 8;
  public const gravity:int = 2;
  public const jumpacc:int = -20;

  // Player(scene)
  public function Player(scene:Scene)
  {
    super(scene);
    vx = 0;
    vy = 0;
  }

  // update()
  public override function update():void
  {
    // (tdx,tdy): the amount that the character should move.
    var tdxOfDoom:int = vx*speed;
    var tdyOfDoom:int = vg + gravity;
    if (_jumping) {
      _jumping = false;
      tdyOfDoom += jumpacc;
    }

    // (dy,dy): the amount that the character actually moved.
    var dx:int = 0, dy:int = 0;
    var v:Point;
    // try moving diagonally first.
    v = scene.tilemap.getCollisionByRect(getMovedBounds(dx,dy), 
					 tdxOfDoom, tdyOfDoom, Tile.isObstacle);
    dx += v.x;
    dy += v.y;
    tdxOfDoom -= v.x;
    tdyOfDoom -= v.y;
    // try moving left/right.
    v = scene.tilemap.getCollisionByRect(getMovedBounds(dx,dy), 
					 tdxOfDoom, 0, Tile.isObstacle);
    dx += v.x;
    dy += v.y;
    tdxOfDoom -= v.x;
    tdyOfDoom -= v.y;
    // try moving up/down.
    v = scene.tilemap.getCollisionByRect(getMovedBounds(dx,dy), 
					 0, tdyOfDoom, Tile.isObstacle);
    dx += v.x;
    dy += v.y;
    tdxOfDoom -= v.x;
    tdyOfDoom -= v.y;

    vg = dy;
    move(dx, dy);
  }

  // isLanded()
  public function isLanded():Boolean
  {
    return scene.tilemap.hasCollisionByRect(bounds, 0, 1, Tile.isObstacle);
  }

  // jump()
  public function jump():void
  {
    if (isLanded()) {
      _jumping = true;
    }
  }
}

} // package
