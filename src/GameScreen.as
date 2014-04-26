package {

import flash.display.Shape;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.media.Sound;
import flash.utils.getTimer;
import baseui.Font;
import baseui.Screen;
import baseui.ScreenEvent;
import baseui.SoundLoop;

//  GameScreen
//
public class GameScreen extends Screen
{
  public static const GAMEOVER:String = "GameScreen.GAMEOVER";

  // Tile image:
  [Embed(source="../assets/tiles.png", mimeType="image/png")]
  private static const TilesImageCls:Class;
  private static const tilesImage:Bitmap = new TilesImageCls();

  // Skin image:
  [Embed(source="../assets/skins.png", mimeType="image/png")]
  private static const SkinsImageCls:Class;
  private static const skinsImage:Bitmap = new SkinsImageCls();

  // Map image:
  [Embed(source="../assets/map.png", mimeType="image/png")]
  private static const MapImageCls:Class;
  private static const mapImage:Bitmap = new MapImageCls();

  /// Game-related functions

  private var _scene:Scene;
  private var _player:Player;
  private var _status:Bitmap;
  private var _music:SoundLoop;
  private var _phase:int;

  public function GameScreen(width:int, height:int)
  {
    _status = Font.createText("TEXT", 0xffffff, 0, 2);

    var tilesize:int = 16;
    _scene = new Scene(20, 15, tilesize,
		       mapImage.bitmapData, 
		       tilesImage.bitmapData,
		       skinsImage.bitmapData);
    _scene.width *= 2;
    _scene.height *= 2;
    _scene.y = height-_scene.window.height*2;

    //_music = new SoundLoop(mainMusic);

    addChild(_scene);
    addChild(_status);
  }

  // open()
  public override function open():void
  {
    _scene.reset();
    _player = _scene.player;

    if (_music != null) {
      _music.start();
    }
  }

  // close()
  public override function close():void
  {
    if (_music != null) {
      _music.stop();
    }
    removeChild(_scene);
    _scene.clear();
  }

  // pause()
  public override function pause():void
  {
    if (_music != null) {
      _music.pause();
    }
  }

  // resume()
  public override function resume():void
  {
    if (_music != null) {
      _music.resume();
    }
  }

  // update()
  public override function update():void
  {
    var text:String = "TEXT";
    Font.renderText(_status.bitmapData, text);

    _scene.update();
    _scene.uncoverMap(_player.bounds, 32);
    _scene.setCenter(_player.pos, 50, 50);
    _scene.paint(_phase/2);
    _phase++;
  }

  // keydown(keycode)
  public override function keydown(keycode:int):void
  {
    switch (keycode) {
    case Keyboard.LEFT:
    case 65:			// A
    case 72:			// H
      _player.vx = -1;
      break;

    case Keyboard.RIGHT:
    case 68:			// D
    case 76:			// L
      _player.vx = +1;
      break;

    case Keyboard.UP:
    case 87:			// W
    case 75:			// K
      _player.vy = -1;
      break;

    case Keyboard.DOWN:
    case 83:			// S
    case 74:			// J
      _player.vy = +1;
      break;

    case Keyboard.SPACE:
    case Keyboard.ENTER:
    case 88:			// X
    case 90:			// Z
      _player.jump();
      break;

    }
  }

  // keyup(keycode)
  public override function keyup(keycode:int):void 
  {
    switch (keycode) {
    case Keyboard.LEFT:
    case Keyboard.RIGHT:
    case 65:			// A
    case 68:			// D
    case 72:			// H
    case 76:			// L
      _player.vx = 0;
      break;

    case Keyboard.UP:
    case Keyboard.DOWN:
    case 87:			// W
    case 75:			// K
    case 83:			// S
    case 74:			// J
      _player.vy = 0;
      break;
    }
  }
}

} // package
