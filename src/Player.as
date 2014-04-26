package {

import flash.media.Sound;
import flash.geom.Point;
import flash.geom.Rectangle;

//  Player
//
public class Player extends Actor
{
  public var health:int;

  // the way the player wants to move.
  public var vx:int;
  public var vy:int;
  // speed by gravity.
  public var vg:int;

  public const speed:int = 8;
  public const gravity:int = 2;
  public const jumpacc:int = -20;
  public const maxspeed:int = +20;
  public const inv_duration:int = 24; // in frames.

  private var _jumping:Boolean;
  private var _grabbing:Boolean;

  private var _invincible:int;	// >0: temp. invincibility

  // Jump sound
  [Embed(source="../assets/jump.mp3", mimeType="audio/mpeg")]
  private static const JumpSoundClass:Class;
  private static const jumpSound:Sound = new JumpSoundClass();

  // Hurt sound
  [Embed(source="../assets/hurt.mp3", mimeType="audio/mpeg")]
  private static const HurtSoundClass:Class;
  private static const hurtSound:Sound = new HurtSoundClass();

  // Player(scene)
  public function Player(scene:Scene)
  {
    super(scene);
    vx = 0;
    vy = 0;
    health = 3;
  }

  // hasLadder()
  public function hasLadder():Boolean
  {
    return scene.tilemap.hasTileByRect(bounds, Tile.isLadder);
  }

  // isLanded()
  public function isLanded():Boolean
  {
    return scene.tilemap.hasCollisionByRect(bounds, 0, 1, Tile.isStoppable);
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

  // collide(actor)
  public override function collide(actor:Actor):void
  {
    trace("collide: "+actor);
    if (actor is Enemy) {
      hurt();
    }
  }

  // update()
  public override function update():void
  {
    super.update();
    // (tdx,tdy): the amount that the character should move.
    var tdxOfDoom:int = vx*speed;
    var tdyOfDoom:int = 0;
    var fx:Function = (vx == 0)? Tile.isStoppable : Tile.isObstacle;
    var fy:Function = (vy == 0)? Tile.isStoppable : Tile.isObstacle;

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
      tdyOfDoom = Math.min(vg+gravity, maxspeed);
    }
    if (_jumping) {
      _jumping = false;
      tdyOfDoom += jumpacc;
    }

    // (dy,dy): the amount that the character actually moved.
    var dx:int = 0, dy:int = 0;
    var v:Point;

    // try moving diagonally first.
    v = scene.tilemap.getCollisionByRect(bounds, //=getMovedBounds(dx,dy), 
					 tdxOfDoom, tdyOfDoom, Tile.isStoppable);
    dx += v.x;
    dy += v.y;
    tdxOfDoom -= v.x;
    tdyOfDoom -= v.y;
    // try moving left/right.
    v = scene.tilemap.getCollisionByRect(getMovedBounds(dx,dy), 
					 tdxOfDoom, 0, fx);
    dx += v.x;
    dy += v.y;
    tdxOfDoom -= v.x;
    tdyOfDoom -= v.y;
    // try moving up/down.
    v = scene.tilemap.getCollisionByRect(getMovedBounds(dx,dy), 
					 0, tdyOfDoom, fy);
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

    // blinking.
    if (0 < _invincible) {
      _invincible--;
      if (_invincible == 0) {
	skin.alpha = 1.0;
      } else {
	var b:Boolean = ((_invincible % 4) < 2);
	skin.alpha = (b)? 0.0 : 1.0;
      }
    }
  }

  // hurt()
  private function hurt():void
  {
    if (0 < _invincible) return;
    hurtSound.play();

    if (health == 0) {
      dispatchEvent(new ActorEvent(DIE));
    } else {
      health--;
      _invincible = inv_duration;
    }
  }
}

} // package
