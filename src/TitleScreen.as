package {

import flash.display.Bitmap;
import flash.events.Event;
import flash.ui.Keyboard;
import flash.media.Sound;
import flash.media.SoundChannel;
import baseui.Font;
import baseui.Screen;
import baseui.ScreenEvent;
import baseui.SoundLoop;

//  TitleScreen
// 
public class TitleScreen extends Screen
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
  private static const LogoImageCls:Class;
  private static const logoImage:Bitmap = new LogoImageCls();
  [Embed(source="../assets/titles/skelebot_drawn.png", mimeType="image/png")]
  private static const SkelebotImageCls:Class;
  private static const skelebotImage:Bitmap = new SkelebotImageCls();
  [Embed(source="../assets/titles/credits_logo.png", mimeType="image/png")]
  private static const CreditsImageCls:Class;
  private static const creditsImage:Bitmap = new CreditsImageCls();

  // Background image:
  [Embed(source="../assets/titles/title_background.png", mimeType="image/png")]
  private static const BackgroundImageCls:Class;
  private static const backgroundImage:Bitmap = new BackgroundImageCls();

  private var _musicloop:SoundLoop;
  private var _menu:Menu;
  private var _level:int;
  private var _clock:int;

  private static const TWEEN_START:int = 40;
  private static const LEVELS:Array = [ "LEVEL 1", "LEVEL 2", "LEVEL 3" ];

  public function TitleScreen(width:int, height:int)
  {
    scale(backgroundImage, 2);
    addChild(backgroundImage);

    scale(creditsImage, 2);
    creditsImage.x = width-creditsImage.width-8;
    creditsImage.y = height-creditsImage.height-8;
    addChild(creditsImage);

    scale(skelebotImage, 0.7);
    skelebotImage.x = width;
    skelebotImage.y = height-skelebotImage.height-20;
    addChild(skelebotImage);

    scale(logoImage, 2);
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

    _musicloop = new SoundLoop(titleScreenMusic);
  }

  // scale a bitmap.
  private function scale(bitmap:Bitmap, n:Number):void
  {
    bitmap.width = bitmap.bitmapData.width * n;
    bitmap.height = bitmap.bitmapData.height * n;
  }

  // open()
  public override function open():void
  {
    super.open();

    sharedInfo = new SharedInfo();

    _musicloop.start();
    _menu.paint(_level);
  }

  // close()
  public override function close():void
  {
    super.close();
    _musicloop.stop();
  }

  // pause()
  public override function pause():void
  {
    _musicloop.pause();
  }

  // resume()
  public override function resume():void
  {
    _musicloop.resume();
  }

  // update()
  public override function update():void
  {
    var d:Number = (_clock % 32);
    backgroundImage.x = -d;
    backgroundImage.y = -d;

    if (TWEEN_START < _clock) {
      var x:Number = (_clock-TWEEN_START)/8.0;
      x = Math.abs(Math.exp(-x*3)*Math.cos(x*x*4));
      skelebotImage.x = 10+x*320;
    }

    _clock++;
  }

  // keydown(keycode)
  public override function keydown(keycode:int):void
  {
    switch (keycode) {
    case Keyboard.UP:
    case 87:			// W
    case 75:			// K
      if (0 < _level) {
	_level--;
	beepSound.play();
	_menu.paint(_level);
      }
      break;

    case Keyboard.DOWN:
    case 83:			// S
    case 74:			// J
      if (_level < (LEVELS.length-1)) {
	_level++;
	beepSound.play();
	_menu.paint(_level);
      }
      break;

    case Keyboard.SPACE:
    case Keyboard.ENTER:
    case 88:			// X
    case 90:			// Z
      beepSound.play();
      sharedInfo.level = _level+1;
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
