package {

import flash.media.Sound;
import flash.geom.Point;
import flash.geom.Rectangle;

//  Player
//
public class Player extends Actor
{
  public static const HURT:String = "Player.HURT";
  public static const COLLECT:String = "Player.COLLECT";
  public static const LOOT:String = "Player.LOOT";
  
  public const start_health:int = 3;
  public const max_health:int = 5;
  public const speed_walking:int = 4;
  public const speed_digging:int = 1;
  public const gravity:int = 1;
  public const jumpdur_long:int = 3;
  public const jumpacc_long:int = -8;
  public const jumpacc_short:int = -6;
  public const maxspeed_normal:int = +10;
  public const maxspeed_digging:int = +2;
  public const inv_duration:int = 24; // in frames.
  public const dig_duration:int = 12; // in frames.

  private var _health:int;	// the player's health.
  private var _vx:int, _vy:int;	// the way the player wants to move.
  private var _vg:int;		// speed by gravity.
  private var _digging:Boolean;	// true when the player is digging.
  private var _jumping:Boolean;	// true when the player is jumping.
  private var _jumpdur:int;	// jumping duration.
  private var _grabbing:Boolean; // true when the player is grabbing a ladder.
  private var _cheering:Boolean; // true when the player is doing winning animation.

  private var _skin_vx:int;	// skin direction.
  private var _invincible:int;	// >0: invincibility counter.
  private var _dig_slowness:int; // >0: slowness because of digging.

  // Jump sound
  [Embed(source="../assets/sounds/jump.mp3", mimeType="audio/mpeg")]
  private static const JumpSoundClass:Class;
  private static const jumpSound:Sound = new JumpSoundClass();

  // Dig sound
  [Embed(source="../assets/sounds/dig.mp3", mimeType="audio/mpeg")]
  private static const DigSoundClass:Class;
  private static const digSound:Sound = new DigSoundClass();

  // DigGrave sound
  [Embed(source="../assets/sounds/diggrave.mp3", mimeType="audio/mpeg")]
  private static const DigGraveSoundClass:Class;
  private static const digGraveSound:Sound = new DigGraveSoundClass();

  // Unbreakable
  [Embed(source="../assets/sounds/unbreakable.mp3", mimeType="audio/mpeg")]
  private static const UnbreakableSoundClass:Class;
  private static const unbreakableSound:Sound = new UnbreakableSoundClass();

  // Collect sound
  [Embed(source="../assets/sounds/collect.mp3", mimeType="audio/mpeg")]
  private static const CollectSoundClass:Class;
  private static const collectSound:Sound = new CollectSoundClass();

  // Powerup sound
  [Embed(source="../assets/sounds/powerup.mp3", mimeType="audio/mpeg")]
  private static const PowerupSoundClass:Class;
  private static const powerupSound:Sound = new PowerupSoundClass();

  // Hurt sound
  [Embed(source="../assets/sounds/hurt.mp3", mimeType="audio/mpeg")]
  private static const HurtSoundClass:Class;
  private static const hurtSound:Sound = new HurtSoundClass();

  // Player(scene)
  public function Player(scene:Scene)
  {
    super(scene);
    setSkinId(Skin.PLAYER_FRONT);
    _vx = 0;
    _vy = 0;
    _vg = 0;
    _digging = false;
    _jumping = false;
    _grabbing = false;
    _health = start_health;
  }

  // isLanded(): true if the player is landed.
  public function isLanded():Boolean
  {
    return scene.tilemap.hasCollisionByRect(bounds, 0, 1, Tile.isBlockingOnTop);
  }

  // bounds: slightly smaller hitbox.
  public override function get bounds():Rectangle
  {
    return new Rectangle(pos.x-6, pos.y-4, 12, 12);
  }

  // player health.
  public function get health():int
  {
    return _health;
  }

  // vx, vy: the direction the player's heading.
  public function get vx():int
  {
    return _vx;
  }
  public function set vx(v:int):void
  {
    _vx = v;
  }
  public function get vy():int
  {
    return _vy;
  }
  public function set vy(v:int):void
  {
    _vy = v;
  }

  // digging: true if the player is digging.
  public function get digging():Boolean
  {
    return _digging;
  }
  public function set digging(v:Boolean):void
  {
    _digging = v;
  }

  // jumping: true if the player is jumping.
  public function get jumping():Boolean
  {
    return _jumping;
  }
  public function set jumping(v:Boolean):void
  {
    if (v) {
      // Only possible when landed or grabbing a ladder.
      if (isLanded() || _grabbing) {
	_jumping = true;
	_jumpdur = 0;
	// ungrab the ladder (if any).
	_grabbing = false;
      }
    } else {
      _jumping = false;
    }
  }

  // update()
  public override function update(phase:int):void
  {
    super.update(phase);
    //trace("v="+_vx+","+_vy);

    if (_cheering) {
      // do the cheering dance.
      skin.alpha = 1.0;
      setSkinId(Skin.playerCheering(phase));
      return;
    }

    // Turn on/off the Ladder behavoir.
    if (scene.tilemap.hasTileByRect(bounds, Tile.isGrabbable)) {
      if (_vy != 0) {
	// Start grabbing the tile.
	_grabbing = true;
      }
    } else {
      // End grabbing the tile.
      _grabbing = false;
    }

    // Moving.
    var speed:int = (_digging || 0 < _dig_slowness)? speed_digging : speed_walking;
    var maxspeed:int = (0 < _dig_slowness)? maxspeed_digging : maxspeed_normal;
    if (0 < _dig_slowness) {
      _dig_slowness--;
    }

    // (tdx,tdy): the amount that the character should move.
    var tdxOfDoom:int = _vx*speed;
    var tdyOfDoom:int = 0;
    // (dy,dy): the amount that the character actually moved.
    var dx:int = 0;
    var dy:int = 0;
    // (fx,fy): hit detection function.
    var fx:Function = Tile.isBlockingNormally;
    var fy:Function = null;

    var jumpacc:int = 0;
    if (_jumping) {
      if (_jumpdur == 0) {
	// short jump.
	jumpacc = jumpacc_short;
	jumpSound.play();
      } else if (_jumpdur == jumpdur_long) {
	// long jump.
	jumpacc = jumpacc_long;
      }
      _jumpdur++;
    }

    if (_grabbing) {
      // grabbing a ladder.
      if (_vy != 0) {
	fy = Tile.isBlockingNormally;
      } else {
      	fy = Tile.isBlockingOnLadder;
      }
      tdyOfDoom = _vy*speed;
    } else if (jumpacc != 0) {
      // jumping.
      fy = Tile.isBlockingNormally;
      tdyOfDoom = jumpacc;
    } else {
      // free fall.
      if (0 < _vy) {
	fy = Tile.isBlockingNormally;
      } else {
	fy = Tile.isBlockingOnTop;
      }
      tdyOfDoom = Math.min(_vg+gravity, maxspeed);
    }

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

    // Digging.
    if (_digging && (_vx != 0 || _vy != 0)) {
      // Dig stuff.
      if (_vy != 0) {
	tdxOfDoom = 0;
      } else {
	tdyOfDoom = 0;
      }
      v = scene.tilemap.getCollisionByRect(getMovedBounds(dx,dy), 
					   tdxOfDoom, tdyOfDoom, 
					   Tile.isBlockingAlways);
      dx += v.x;
      dy += v.y;
      tdxOfDoom -= v.x;
      tdyOfDoom -= v.y;
      var r:Rectangle = getMovedBounds(dx,dy);
      if (0 < scene.tilemap.digTileByRect(r)) {
	digSound.play();
	dx = dy = 0;
	_dig_slowness = dig_duration;
      }
    }

    // Compute vertical velocity.
    _vg = (_grabbing)? 0 : dy;
    move(dx, dy);

    // Auto-collect thigns.
    if (scene.tilemap.isRawTileByPoint(pos, Tile.isCollectible)) {
      loot();
    }

    // Hurt if touching something bad.
    if (scene.tilemap.hasTileByRect(bounds, Tile.isDeadly)) {
      hurt();
    }

    // Invincible blinking after hurting.
    if (0 < _invincible) {
      _invincible--;
      if (_invincible == 0) {
	// End blinking.
	skin.alpha = 1.0;
	setSkinId(Skin.PLAYER_FRONT);
      } else {
	var b:Boolean = ((_invincible % 4) < 2);
	skin.alpha = (b)? 0.0 : 1.0;
      } 
    }

    // Animate the skin.
    if (0 < _invincible) {
      setSkinId(Skin.playerHurting(phase, _skin_vx));
    } else if (0 < _dig_slowness) {
      if (_vx != 0) {
	_skin_vx = _vx;
      }
      setSkinId(Skin.playerDigging(phase, _skin_vx));
    } else if (_grabbing && _vy != 0) {
      setSkinId(Skin.playerClimbing(phase));
    } else if (_vx != 0) {
      _skin_vx = _vx;
      setSkinId(Skin.playerWalking(phase, _skin_vx));
    }
  }

  // collide(actor): called when the player hits something.
  public override function collide(actor:Actor):void
  {
    //trace("collide: "+actor);
    if (actor is RunningEnemy ||
	actor is FlyingEnemy) {
      hurt();
    } else if (actor is RoboCake) {
      eat(actor);
    }
  }

  // collect(): try to open the chest/tombstone.
  public function collect():Boolean
  {
    if (scene.tilemap.isRawTileByPoint(pos, Tile.isGrave)) {
      scene.tilemap.setRawTileByPoint(pos, Tile.GRAVE_TRACE);
      _dig_slowness = dig_duration;
      digGraveSound.play();
      dispatchEvent(new ActorEvent(COLLECT));
      return true;
    }
    return false;
  }

  // checkDig(): make a little beep if the direction is not diggable.
  public function checkDig():void
  {
    var dx:int = _vx * speed_digging;
    var dy:int = _vy * speed_digging;
    if (_digging &&
	scene.tilemap.hasCollisionByRect(bounds, dx, dy, Tile.isBlockingAlways)) {
      unbreakableSound.play();
    }
  }

  // cheer(): start the winning animation.
  public function cheer():void
  {
    _cheering = true;
  }

  // loot(): gotz something.
  private function loot():void
  {
    scene.tilemap.setRawTileByPoint(pos, Tile.NONE);
    collectSound.play();
    dispatchEvent(new ActorEvent(LOOT));
  }

  // eat(actor): just ate something.
  private function eat(actor:Actor):void
  {
    scene.remove(actor);
    powerupSound.play();
    _health++;
    _health = Math.min(_health, max_health);
  }

  // hurt(): the player is hurt.
  private function hurt():void
  {
    if (0 < _invincible) return;

    hurtSound.play();
    _health--;
    // Become invincible for a moment.
    _invincible = inv_duration;

    dispatchEvent(new ActorEvent(HURT));
  }
}

} // package
