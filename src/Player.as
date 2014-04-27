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

  public const speed:int = 4;
  public const gravity:int = 1;
  public const jumpacc:int = -10;
  public const maxspeed:int = +10;
  public const inv_duration:int = 24; // in frames.
  public const inset_dig:int = -2; // inset size of bounds for digging.

  private var _vg:int;		// speed by gravity.
  private var _digging:Boolean;
  private var _jumping:Boolean;
  private var _grabbing:Boolean;

  private var _phase:int;
  private var _invincible:int;	// >0: temp. invincibility

  // Jump sound
  [Embed(source="../assets/sounds/jump.mp3", mimeType="audio/mpeg")]
  private static const JumpSoundClass:Class;
  private static const jumpSound:Sound = new JumpSoundClass();

  // Dig sound
  [Embed(source="../assets/sounds/dig.mp3", mimeType="audio/mpeg")]
  private static const DigSoundClass:Class;
  private static const digSound:Sound = new DigSoundClass();

  // Collect sound
  [Embed(source="../assets/sounds/collect.mp3", mimeType="audio/mpeg")]
  private static const CollectSoundClass:Class;
  private static const collectSound:Sound = new CollectSoundClass();

  // Hurt sound
  [Embed(source="../assets/sounds/hurt.mp3", mimeType="audio/mpeg")]
  private static const HurtSoundClass:Class;
  private static const hurtSound:Sound = new HurtSoundClass();

  // Player(scene)
  public function Player(scene:Scene)
  {
    super(scene);
    vx = 0;
    vy = 0;
    skinId = Skin.PLAYER_FRONT;
  }

  // canGrabLadder()
  public function canGrabLadder():Boolean
  {
    return scene.tilemap.hasTileByRect(bounds, Tile.isGrabbable);
  }

  // hasDeadly()
  public function hasDeadly():Boolean
  {
    return scene.tilemap.hasTileByRect(bounds, Tile.isDeadly);
  }

  // isLanded()
  public function isLanded():Boolean
  {
    return scene.tilemap.hasCollisionByRect(bounds, 0, 1, Tile.isBlockingOnTop);
  }

  // digging
  public function set digging(v:Boolean):void
  {
    _digging = v;
  }

  // jump()
  public function jump():void
  {
    if (isLanded() || _grabbing) {
      _jumping = true;
      _grabbing = false;
      jumpSound.play();
    }
  }

  // collide(actor)
  public override function collide(actor:Actor):void
  {
    //trace("collide: "+actor);
    if (actor is Enemy) {
      hurt();
    } else if (actor is Grave) {
      (actor as Grave).collect();
      collectSound.play();
    }
  }

  // update()
  public override function update():void
  {
    super.update();
    //trace("v="+vx+","+vy);

    // (tdx,tdy): the amount that the character should move.
    var tdxOfDoom:int = vx*speed;
    var tdyOfDoom:int = 0;
    var fx:Function = (_digging && vx != 0)? Tile.isBlockingAlways : Tile.isBlockingNormally;
    var fy:Function = null;

    // turn on/off the Ladder behavoir.
    if (canGrabLadder()) {
      if (vy != 0) {
	// Start grabbing the tile.
	_grabbing = true;
      }
    } else {
      // End grabbing the tile.
      _grabbing = false;
    }

    // grabbing
    if (_grabbing) {
      // grabbing.
      if (vy != 0) {
	fy = (_digging)? Tile.isBlockingAlways : Tile.isBlockingNormally;
      } else {
      	fy = Tile.isBlockingOnLadder;
      }
      tdyOfDoom = vy*speed;
    } else if (_jumping) {
      // jumping.
      _jumping = false;
      fy = Tile.isBlockingNormally;
      tdyOfDoom = jumpacc;
    } else {
      // free fall.
      if (0 < vy) {
	fy = (_digging)? Tile.isBlockingAlways : Tile.isBlockingNormally;
      } else {
	fy = Tile.isBlockingOnTop;
      }
      tdyOfDoom = Math.min(_vg+gravity, maxspeed);
    }

    //trace("t="+tdxOfDoom+","+tdyOfDoom+", grabbing="+_grabbing);

    // (dy,dy): the amount that the character actually moved.
    var dx:int = 0, dy:int = 0;
    var v:Point;

    // try moving diagonally first.
    v = scene.tilemap.getCollisionByRect(bounds, //=getMovedBounds(dx,dy), 
					 tdxOfDoom, tdyOfDoom, fy);
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

    _vg = (_grabbing)? 0 : dy;
    move(dx, dy);

    if (hasDeadly()) {
      // Touching something bad.
      hurt();
    }

    var r:Rectangle = bounds.clone();
    r.inflate(inset_dig, inset_dig);
    if (0 < scene.tilemap.digTileByRect(r)) {
      digSound.play();
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

    // skin animation.
    _phase++;
    if (0 < _invincible) {
      skinId = Skin.playerHurting(_phase) + ((vx<0)? 1 : 0);
    } else if (vx != 0) {
      skinId = Skin.playerWalking(_phase) + ((vx<0)? 1 : 0);
    } else if (vy != 0) {
      skinId = Skin.playerClimbing(_phase);
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
