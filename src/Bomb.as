package {

import flash.media.Sound;
import flash.geom.Point;
import flash.geom.Rectangle;

//  Bomb
// 
public class Bomb extends Actor
{
  public const ticking_duration:int = 48; // in frames
  public const ticking_interval:int = 16; // in frames

  private var _ticks:int;

  // Ticking sound
  [Embed(source="../assets/bombtick.mp3", mimeType="audio/mpeg")]
  private static const BombtickSoundClass:Class;
  private static const bombtickSound:Sound = new BombtickSoundClass();
  // Explosion sound
  [Embed(source="../assets/explosion.mp3", mimeType="audio/mpeg")]
  private static const ExplosionSoundClass:Class;
  private static const explosionSound:Sound = new ExplosionSoundClass();

  public function Bomb(scene:Scene)
  {
    super(scene);
    _ticks = 0;
  }

  public override function activate():void
  {
    super.activate();
    _ticks = ticking_duration;
  }

  public override function update():void
  {
    super.update();
    if (0 < _ticks) {
      var i:int = (ticking_duration - _ticks) % ticking_interval;
      if (i == 0) {
	bombtickSound.play();
      }
      _ticks--;
      if (_ticks == 0) {
	explode();
      }
    }
  }

  private function explode():void
  {
    // TODO: particle.
    // TODO: remove itself.
    explosionSound.play();
  }
}

} // package
