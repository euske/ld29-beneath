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

  public var health:int;

  // the way the player wants to move.
  public var vx:int;
  public var vy:int;

  public const max_health:int = 5;
  public const speed_walking:int = 4;
  public const speed_digging:int = 1;
  public const gravity:int = 1;
  public const jumpacc:int = -10;
  public const maxspeed_normal:int = +10;
  public const maxspeed_digging:int = +2;
  public const inv_duration:int = 24; // in frames.
  public const dig_duration:int = 12; // in frames.

  private var _vg:int;		// speed by gravity.
  private var _digging:Boolean;
  private var _jumping:Boolean;
  private var _grabbing:Boolean;

  private var _skin_adjust:int;	// 0: right, 1: left
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
    vx = 0;
    vy = 0;
    skinId = Skin.PLAYER_FRONT;

  }

  // isLanded()
  public function isLanded():Boolean
  {
    return scene.tilemap.hasCollisionByRect(bounds, 0, 1, Tile.isBlockingOnTop);
  }

  // bounds: the character hitbox (in the world)
  public override function get bounds():Rectangle
  {
    return new Rectangle(pos.x-6, pos.y-4, 12, 12);
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

  // update()
  public override function update(phase:int):void
  {
    super.update(phase);
    //trace("v="+vx+","+vy);

    // Turn on/off the Ladder behavoir.
    if (scene.tilemap.hasTileByRect(bounds, Tile.isGrabbable)) {
      if (vy != 0) {
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
    var tdxOfDoom:int = vx*speed;
    var tdyOfDoom:int = 0;
    // (dy,dy): the amount that the character actually moved.
    var dx:int = 0;
    var dy:int = 0;
    // (fx,fy): hit detection function.
    var fx:Function = Tile.isBlockingNormally;
    var fy:Function = null;

    if (_grabbing) {
      // grabbing a ladder.
      if (vy != 0) {
	fy = Tile.isBlockingNormally;
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
    if (_digging && (vx != 0 || vy != 0)) {
      // Dig stuff.
      if (vy != 0) {
	tdxOfDoom = 0;
      } else {
	tdyOfDoom = 0;
      }
      v = scene.tilemap.getCollisionByRect(getMovedBounds(dx,dy), 
					   tdxOfDoom, tdyOfDoom, Tile.isBlockingAlways);
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
	skinId = 0;
      } else {
	var b:Boolean = ((_invincible % 4) < 2);
	skin.alpha = (b)? 0.0 : 1.0;
      } 
    }

    // Animate the skin.
    if (0 < _invincible) {
      skinId = Skin.playerHurting(phase) + _skin_adjust;
    } else if (0 < _dig_slowness) {
      if (vx != 0) {
	_skin_adjust = ((0 < vx)? 0 : 1);
      }
      skinId = Skin.playerDigging(phase) + _skin_adjust;
    } else if (_grabbing && vy != 0) {
      skinId = Skin.playerClimbing(phase);
    } else if (vx != 0) {
      _skin_adjust = ((0 < vx)? 0 : 1);
      skinId = Skin.playerWalking(phase) + _skin_adjust;
    }
  }

  // collide(actor)
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

  // collect(): try to open the chest.
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

  // loot(): gotz something.
  public function loot():void
  {
    scene.tilemap.setRawTileByPoint(pos, Tile.NONE);
    collectSound.play();
    // XXX WHAT DO
    //dispatchEvent(new ActorEvent(SCORE));
  }

  // eat(actor): just ate something.
  public function eat(actor:Actor):void
  {
    scene.remove(actor);
    powerupSound.play();
    health++;
    health = Math.min(health, max_health);
  }

  // checkDig(): make a little beep if the direction is not diggable.
  public function checkDig():void
  {
    var dx:int = vx * speed_digging;
    var dy:int = vy * speed_digging;
    if (_digging &&
	scene.tilemap.hasCollisionByRect(bounds, dx, dy, Tile.isBlockingAlways)) {
      unbreakableSound.play();
    }
  }

  // cheer(): cheering dance.
  public function cheer(phase:int):void
  {
    skinId = Skin.playerCheering(phase);
  }

  // hurt()
  private function hurt():void
  {
    if (0 < _invincible) return;

    hurtSound.play();
    health--;
    _invincible = inv_duration;

    dispatchEvent(new ActorEvent(HURT));
  }
}

} // package
