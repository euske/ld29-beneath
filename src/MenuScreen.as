package {

import flash.display.Bitmap;
import flash.events.Event;
import flash.ui.Keyboard;
import flash.media.Sound;
import flash.media.SoundChannel;
import baseui.Font;
import baseui.Screen;
import baseui.ScreenEvent;

//  MenuScreen
// 
public class MenuScreen extends Screen
{
  // Musics
  [Embed(source="../assets/music/Title_Screen.mp3", mimeType="audio/mpeg")]
  private static const TitleScreenMusicCls:Class;
  private static const titleScreenMusic:Sound = new TitleScreenMusicCls();

  [Embed(source="../assets/sounds/beep.mp3", mimeType="audio/mpeg")]
  private static const BeepSoundCls:Class;
  private static const beepSound:Sound = new BeepSoundCls();

  // Images
  [Embed(source="../assets/titles/NecRobot_logo.png", mimeType="image/png")]
  private static const logoImageCls:Class;
  [Embed(source="../assets/titles/skelebot_drawn.png", mimeType="image/png")]
  private static const skelebotImageCls:Class;
  // Background image:
  [Embed(source="../assets/background.png", mimeType="image/png")]
  private static const BackgroundImageCls:Class;

  private const bgimage:Bitmap = new BackgroundImageCls();
  private const skelebotImage:Bitmap = new skelebotImageCls();
  private const logoImage:Bitmap = new logoImageCls();
  private var _channel:SoundChannel = null;
  private var _menu:Menu;

  private const LEVELS:Array = [ "LEVEL 1", "LEVEL 2", "LEVEL 3" ];

  public function MenuScreen(width:int, height:int)
  {
    bgimage.width *= 2;
    bgimage.height *= 2;
    addChild(bgimage);

    skelebotImage.width *= 0.7;
    skelebotImage.height *= 0.7;
    skelebotImage.x = 10;
    skelebotImage.y = height-skelebotImage.height-20;
    addChild(skelebotImage);

    logoImage.width *= 2;
    logoImage.height *= 2;
    logoImage.x = (width-logoImage.width)/2;
    logoImage.y = 20;
    addChild(logoImage);
    
    _menu = new Menu(LEVELS);
    _menu.x = (width-_menu.width)/2;
    _menu.y = height-_menu.height-100;
    addChild(_menu);

    var text:Bitmap;
    text = Font.createText("PRESS ENTER TO START", 0xffffff, 2, 2);
    text.x = Math.floor(width-text.width)/2;
    text.y = height-50;
    addChild(text);
  }

  // open()
  public override function open():void
  {
    super.open();

    sharedInfo = new SharedInfo();

    _channel = titleScreenMusic.play();
    _menu.paint(sharedInfo.level);
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
    case Keyboard.UP:
    case 87:			// W
    case 75:			// K
      if (0 < sharedInfo.level) {
	sharedInfo.level--;
	beepSound.play();
	_menu.paint(sharedInfo.level);
      }
      break;

    case Keyboard.DOWN:
    case 83:			// S
    case 74:			// J
      if (sharedInfo.level < (LEVELS.length-1)) {
	sharedInfo.level++;
	beepSound.play();
	_menu.paint(sharedInfo.level);
      }
      break;

    case Keyboard.SPACE:
    case Keyboard.ENTER:
    case 88:			// X
    case 90:			// Z
      beepSound.play();
      dispatchEvent(new ScreenEvent(GameScreen));
      break;

    }
  }
}

} // package

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.geom.ColorTransform;
import baseui.Font;

class Menu extends Sprite
{
  private var _choices:Array;
  private var _levels:Array;

  public function Menu(levels:Array)
  {
    _levels = levels;
    _choices = new Array();
    for (var i:int = 0; i < _levels.length; i++) {
      var text:Bitmap = Font.createText(_levels[i], 0xffffff, 2, 2);
      text.y = i*32;
      addChild(text);
      _choices.push(text);
    }
  }

  public function paint(level:int):void
  {
    for (var i:int = 0; i < _levels.length; i++) {
      var color:uint = (level == i)? 0xff0000 : 0xffffff;
      var text:Bitmap = _choices[i];
      var ct:ColorTransform = new ColorTransform();
      ct.color = color;
      text.bitmapData.colorTransform(text.bitmapData.rect, ct);
    }
  }

}
