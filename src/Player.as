package {

import flash.media.Sound;
import flash.geom.Point;
import flash.geom.Rectangle;

//  Player
//
public class Player extends Actor
{
  public static const SCORE:String = "Player.SCORE";
  public static const HURT:String = "Player.HURT";

  public var health:int;

  // the way the player wants to move.
  public var vx:int;
  public var vy:int;

  public const speed_walking:int = 4;
  public const speed_digging:int = 1;
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
  public override function update():void
  {
    super.update();
    //trace("v="+vx+","+vy);

    var speed:int = (_digging)? speed_digging : speed_walking;

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

    // Hurt if touching something bad.
    if (hasDeadly()) {
      hurt();
    }

    // Auto-collect thigns.
    if (scene.tilemap.isRawTileByPoint(pos, Tile.isCollectible)) {
      eat();
    }

    // Dig stuff.
    var r:Rectangle = bounds.clone();
    r.inflate(inset_dig, inset_dig);
    if (0 < scene.tilemap.digTileByRect(r)) {
      digSound.play();
    }

    // skin animation.
    _phase++;
    if (0 < _invincible) {
      skinId = Skin.playerHurting(_phase) + ((vx<0)? 1 : 0);
    } else if (_digging) {
      skinId = Skin.playerDigging(_phase) + ((vx<0)? 1 : 0);
    } else if (vx != 0) {
      skinId = Skin.playerWalking(_phase) + ((vx<0)? 1 : 0);
    } else if (vy != 0) {
      skinId = Skin.playerClimbing(_phase);
    }

    // blinking.
    if (0 < _invincible) {
      _invincible--;
      if (_invincible == 0) {
	skin.alpha = 1.0;
	skinId = 0;
      } else {
	var b:Boolean = ((_invincible % 4) < 2);
	skin.alpha = (b)? 0.0 : 1.0;
      } 
    }
  }

  // collide(actor)
  public override function collide(actor:Actor):void
  {
    //trace("collide: "+actor);
    if (actor is RunningEnemy ||
	actor is FlyingEnemy ||
	actor is StickingEnemy) {
      hurt();
    }
  }

  // collect(): try to open the chest.
  public function collect():Boolean
  {
    if (scene.tilemap.isRawTileByPoint(pos, Tile.isGrave)) {
      scene.tilemap.setRawTileByPoint(pos, Tile.GRAVE_TRACE);
      digGraveSound.play();
      dispatchEvent(new ActorEvent(SCORE));
      return true;
    }
    return false;
  }

  // eat(): just ate something
  public function eat():void
  {
    scene.tilemap.setRawTileByPoint(pos, Tile.NONE);
    collectSound.play();       // XXX
    //dispatchEvent(new ActorEvent(SCORE));
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
