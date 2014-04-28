package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.media.Sound;
import flash.utils.getTimer;
import baseui.Screen;
import baseui.ScreenEvent;
import baseui.SoundLoop;

//  GameScreen
//
public class GameScreen extends Screen
{
  public static const GAMEOVER:String = "GameScreen.GAMEOVER";

  // TileMap image:
  [Embed(source="../assets/levels/tilemap1.png", mimeType="image/png")]
  private static const Level1TilemapImageCls:Class;

  // DirtMap image:
  [Embed(source="../assets/levels/dirtmap1.png", mimeType="image/png")]
  private static const Level1DirtmapImageCls:Class;

  // Musics
  [Embed(source="../assets/music/Level1.mp3", mimeType="audio/mpeg")]
  private static const Level1MusicCls:Class;

  private var _width:int;
  private var _height:int;
  private var _status:Status;

  /// Game-related functions

  private var _scene:Scene;
  private var _player:Player;
  private var _music:SoundLoop;
  private var _phase:int;
  private var _starttime:uint;

  public function GameScreen(width:int, height:int)
  {
    _status = new Status();
    _width = width;
    _height = height;
  }

  // open()
  public override function open():void
  {
    var tilemapImage:Bitmap = new Level1TilemapImageCls();
    var dirtmapImage:Bitmap = new Level1DirtmapImageCls();
    var music:Sound = new Level1MusicCls();

    _scene = new Scene(20, 15, 16,
		       tilemapImage.bitmapData, 
		       dirtmapImage.bitmapData);
    _scene.width *= 2;
    _scene.height *= 2;
    _scene.y = _height-_scene.window.height*2;
    _scene.open();

    _player = _scene.player;
    _player.health = 3;
    _player.addEventListener(Player.HURT, onPlayerHurt);
    _player.addEventListener(Player.SCORE, onPlayerScore);

    _status.goal = Math.floor(_scene.collectibles*0.75); // 75% thing
    _status.score = 0;
    _status.health = _player.health;
    _status.time = 0;
    _starttime = getTimer();

    _music = new SoundLoop(music);
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
    _status.time = (getTimer() - _starttime)/1000;
    _status.update();

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
      _player.checkDig();
      break;

    case Keyboard.RIGHT:
    case 68:			// D
    case 76:			// L
      _player.vx = +1;
      _player.checkDig();
      break;

    case Keyboard.UP:
    case 87:			// W
    case 75:			// K
      if (!_player.collect()) {
	_player.vy = -1;
	_player.checkDig();
      }
      break;

    case Keyboard.DOWN:
    case 83:			// S
    case 74:			// J
      if (!_player.collect()) {
	_player.vy = +1;
	_player.checkDig();
      }
      break;

    case Keyboard.SHIFT:
    case Keyboard.CONTROL:
      _player.digging = true;
      _player.checkDig();
      break;

    case Keyboard.SPACE:
    case Keyboard.ENTER:
    case 88:			// X
    case 90:			// Z
      _player.jump();
      break;

    case 77:
      _scene.toggleMask();
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

  private function onPlayerHurt(e:ActorEvent):void
  {
    _status.health = _player.health;
    if (_player.health == 0) {
      // DEAD
      dispatchEvent(new ScreenEvent(MenuScreen));
    }
  }

  private function onPlayerScore(e:ActorEvent):void
  {
    _status.score++;
  }
}

} // package

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import baseui.Font;

class Status extends Sprite
{
  public var score:int;
  public var goal:int;
  public var health:int;
  public var time:int;

  private var _text:Bitmap;

  // Symbols image:
  [Embed(source="../assets/hud/symbols.png", mimeType="image/png")]
  private static const SymbolsImageCls:Class;
  private static const symbolsImage:Bitmap = new SymbolsImageCls();

  public function Status()
  {
    _text = Font.createText("HEALTH: XX  GRAVE: XX/XX  TIME: XXX", 0xffffff, 0, 2);
    addChild(_text)
  }

  public function update():void
  {
    var text:String = ("HEALTH: "+Utils.format(health, 2)+
		       "  GRAVE: "+Utils.format(score, 2)+"/"+Utils.format(goal, 2)+
		       "  TIME: "+Utils.format(time, 3));
    Font.renderText(_text.bitmapData, text);
  }
}
