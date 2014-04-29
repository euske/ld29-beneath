package {

import flash.display.Bitmap;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.events.Event;
import flash.ui.Keyboard;
import baseui.Font;
import baseui.Screen;
import baseui.ScreenEvent;

//  EndingScreen
// 
public class EndingScreen extends Screen
{
  [Embed(source="../assets/music/Win_Screen.mp3", mimeType="audio/mpeg")]
  private static const EndingSoundCls:Class;
  private static const endingSound:Sound = new EndingSoundCls();

  // Images
  [Embed(source="../assets/titles/win_screen.png", mimeType="image/png")]
  private static const EndingImageCls:Class;

  private const endingImage:Bitmap = new EndingImageCls();
  private var _channel:SoundChannel = null;
  private var _width:int;
  private var _height:int;

  public function EndingScreen(width:int, height:int)
  {
    endingImage.width *= 2;
    endingImage.height *= 2;
    endingImage.x = (width-endingImage.width)/2;
    endingImage.y = (height-endingImage.height)/2-50;
    addChild(endingImage);
    _width = width;
    _height = height;
  }

  // open()
  public override function open():void
  {
    super.open();

    var text:Bitmap;
    text = Font.createText("FINAL SCORE: "+Utils.format(sharedInfo.score,3)+
			   "\nTOTAL TIME:  "+Utils.format(sharedInfo.time,3), 
			   0xffffff, 8, 2);
    text.x = Math.floor(_width-text.width)/2;
    text.y = _height-text.height-80;
    addChild(text);

    _channel = endingSound.play();
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
