package {

import flash.display.Bitmap;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.events.Event;
import flash.ui.Keyboard;
import baseui.Font;
import baseui.Screen;
import baseui.ScreenEvent;

//  GameOverScreen
// 
public class GameOverScreen extends Screen
{
  [Embed(source="../assets/sounds/voice_game_over.mp3", mimeType="audio/mpeg")]
  private static const GameOverSoundCls:Class;
  private static const gameOverSound:Sound = new GameOverSoundCls();

  // Images
  [Embed(source="../assets/titles/death_screen.png", mimeType="image/png")]
  private static const DeathScreenImageCls:Class;

  private const deathScreenImage:Bitmap = new DeathScreenImageCls();
  private var _channel:SoundChannel = null;

  public function GameOverScreen(width:int, height:int)
  {
    deathScreenImage.width *= 2;
    deathScreenImage.height *= 2;
    deathScreenImage.x = (width-deathScreenImage.width)/2;
    deathScreenImage.y = (height-deathScreenImage.height)/2;
    addChild(deathScreenImage);
  }

  // open()
  public override function open():void
  {
    super.open();
    _channel = gameOverSound.play();
  }

  // close()
  public override function close():void
  {
    super.close();
    if (_channel != null) {
      _channel.stop();
      _channel = null;
    }
  }

  // keydown(keycode)
  public override function keydown(keycode:int):void
  {
    switch (keycode) {
    case Keyboard.SPACE:
    case Keyboard.ENTER:
    case 88:			// X
    case 90:			// Z
      dispatchEvent(new ScreenEvent(MenuScreen));
      break;

    }
  }
}

} // package
