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
  private var _grabbing:Boolean;

  // Tile image:
  [Embed(source="../assets/jump.mp3", mimeType="audio/mpeg")]
  private static const JumpSoundClass:Class;
  private static const jumpSound:Sound = new JumpSoundClass();

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
    var tdyOfDoom:int = 0;
    var f:Function = Tile.isStoppable;

    if (vx != 0 || vy != 0) {
      f = Tile.isObstacle;
    }

    if (vy != 0) {
      if (hasLadder()) {
	// Start grabbing the tile.
	_grabbing = true;
      } else {
	vy = 0;
      }
    }

    if (_grabbing) {
      tdyOfDoom = vy*speed;
    } else {
      tdyOfDoom = vg+gravity;
    }
    if (_jumping) {
      _jumping = false;
      tdyOfDoom += jumpacc;
    }

    // (dy,dy): the amount that the character actually moved.
    var dx:int = 0, dy:int = 0;
    var v:Point;

    // try moving diagonally first.
    v = scene.tilemap.getCollisionByRect(getMovedBounds(dx,dy), 
					 tdxOfDoom, tdyOfDoom, f);
    dx += v.x;
    dy += v.y;
    tdxOfDoom -= v.x;
    tdyOfDoom -= v.y;
    // try moving left/right.
    v = scene.tilemap.getCollisionByRect(getMovedBounds(dx,dy), 
					 tdxOfDoom, 0, f);
    dx += v.x;
    dy += v.y;
    tdxOfDoom -= v.x;
    tdyOfDoom -= v.y;
    // try moving up/down.
    v = scene.tilemap.getCollisionByRect(getMovedBounds(dx,dy), 
					 0, tdyOfDoom, f);
    dx += v.x;
    dy += v.y;
    tdxOfDoom -= v.x;
    tdyOfDoom -= v.y;

    vg = dy;
    move(dx, dy);

    if (!hasLadder()) {
      // End grabbing the tile.
      _grabbing = false;
    }
  }

  // hasLadder()
  public function hasLadder():Boolean
  {
    return scene.tilemap.hasTileByRect(bounds, Tile.isLadder);
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
      _grabbing = false;
      jumpSound.play();
    }
  }
}

} // package
