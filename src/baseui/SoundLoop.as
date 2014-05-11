package baseui {

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;

public class SoundLoop
{
  private var _sound:Sound;
  private var _channel:SoundChannel;
  private var _position:Number;

  public function SoundLoop(sound:Sound)
  {
    _sound = sound;
  }

  public function start(position:Number=0):void
  {
    _channel = _sound.play(position);
    _channel.addEventListener(Event.SOUND_COMPLETE, soundCompleted);
  }

  public function stop():void
  {
    if (_channel != null) {
      _channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleted);
      _channel.stop();
      _channel = null;
    }
  }

  public function pause():void
  {
    if (_channel != null) {
      _position = _channel.position;
      stop();
    }
  }

  public function resume():void
  {
    if (_channel == null) {
      start(_position);
    }
  }

  private function soundCompleted(e:Event):void
  {
    stop();
    start();
  }
}

} // package baseui
