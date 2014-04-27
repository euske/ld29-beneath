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

  // TileMap image:
  [Embed(source="../assets/levels/tilemap.png", mimeType="image/png")]
  private static const TilemapImageCls:Class;
  private static const tilemapImage:Bitmap = new TilemapImageCls();
  // DirtMap image:
  [Embed(source="../assets/levels/dirtmap.png", mimeType="image/png")]
  private static const DirtmapImageCls:Class;
  private static const dirtmapImage:Bitmap = new DirtmapImageCls();

  // Musics
  [Embed(source="../assets/music/Level1.mp3", mimeType="audio/mpeg")]
  private static const Level1MusicCls:Class;
  private static const level1Music:Sound = new Level1MusicCls();

  /// Game-related functions

  private var _scene:Scene;
  private var _player:Player;
  private var _status:Bitmap;
  private var _music:SoundLoop;
  private var _phase:int;

  public function GameScreen(width:int, height:int)
  {
    _status = Font.createText("HEALTH: 00", 0xffffff, 0, 2);

    var tilesize:int = 16;
    _scene = new Scene(20, 15, tilesize,
		       tilemapImage.bitmapData, 
		       dirtmapImage.bitmapData);
    _scene.width *= 2;
    _scene.height *= 2;
    _scene.y = height-_scene.window.height*2;

    _music = new SoundLoop(level1Music);
  }

  // open()
  public override function open():void
  {
    _scene.open();
    _player = _scene.player;
    _player.health = 3;
    _player.addEventListener(Actor.DIE, onPlayerDead);

    if (_music != null) {
      _music.start();
    }

    addChild(_scene);
    addChild(_status);
  }

  // close()
  public override function close():void
  {
    removeChild(_scene);
    removeChild(_status);

    if (_music != null) {
      _music.stop();
    }
    _scene.close();
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
    var text:String = ("HEALTH:"+Utils.format(_player.health));
    Font.renderText(_status.bitmapData, text);

    _scene.update();
    _scene.uncoverMap(_player.bounds, 32);
    _scene.setCenter(_player.pos, 50, 50);
    _scene.paint(_phase);
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
      _player.vy = 0;
      break;

    case Keyboard.RIGHT:
    case 68:			// D
    case 76:			// L
      _player.vx = +1;
      _player.vy = 0;
      break;

    case Keyboard.UP:
    case 87:			// W
    case 75:			// K
      _player.vx = 0;
      _player.vy = -1;
      break;

    case Keyboard.DOWN:
    case 83:			// S
    case 74:			// J
      _player.vx = 0;
      _player.vy = +1;
      break;

    case Keyboard.SHIFT:
    case Keyboard.CONTROL:
      _player.digging = true;
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

    case Keyboard.SHIFT:
    case Keyboard.CONTROL:
      _player.digging = false;
      break;
    }
  }

  private function onPlayerDead(e:ActorEvent):void
  {
    dispatchEvent(new ScreenEvent(MenuScreen));
  }
}

} // package
