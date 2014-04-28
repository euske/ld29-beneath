package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.media.Sound;
import flash.utils.getTimer;
import flash.events.Event;
import baseui.Screen;
import baseui.ScreenEvent;
import baseui.SoundLoop;

//  GameScreen
//
public class GameScreen extends Screen
{
  public static const GAMEOVER:String = "GameScreen.GAMEOVER";

  // TileMap image:
  [Embed(source="../assets/levels/tilemap0.png", mimeType="image/png")]
  private static const Level0TilemapImageCls:Class;
  [Embed(source="../assets/levels/tilemap1.png", mimeType="image/png")]
  private static const Level1TilemapImageCls:Class;
  [Embed(source="../assets/levels/tilemap2.png", mimeType="image/png")]
  private static const Level2TilemapImageCls:Class;
  [Embed(source="../assets/levels/tilemap3.png", mimeType="image/png")]
  private static const Level3TilemapImageCls:Class;

  // DirtMap image:
  [Embed(source="../assets/levels/dirtmap0.png", mimeType="image/png")]
  private static const Level0DirtmapImageCls:Class;
  [Embed(source="../assets/levels/dirtmap1.png", mimeType="image/png")]
  private static const Level1DirtmapImageCls:Class;
  [Embed(source="../assets/levels/dirtmap2.png", mimeType="image/png")]
  private static const Level2DirtmapImageCls:Class;
  [Embed(source="../assets/levels/dirtmap3.png", mimeType="image/png")]
  private static const Level3DirtmapImageCls:Class;

  // Musics
  [Embed(source="../assets/music/Level1.mp3", mimeType="audio/mpeg")]
  private static const Level1MusicCls:Class;
  [Embed(source="../assets/music/Level2.mp3", mimeType="audio/mpeg")]
  private static const Level2MusicCls:Class;
  [Embed(source="../assets/music/Level3.mp3", mimeType="audio/mpeg")]
  private static const Level3MusicCls:Class;

  // Winning music
  [Embed(source="../assets/sounds/treasure_pickup.mp3", mimeType="audio/mpeg")]
  private static const WinningMusicCls:Class;
  private static const winningMusic:Sound = new WinningMusicCls();

  private const win_duration:int = 60;

  private var _width:int;
  private var _height:int;
  private var _status:Status;
  private var _splash:Splash;

  private var LEVELS:Array;

  /// Game-related functions

  private var _scene:Scene;
  private var _player:Player;
  private var _musicloop:SoundLoop;
  private var _starttime:uint;
  private var _winning:int;
  private var _clock:int;

  public function GameScreen(width:int, height:int)
  {
    LEVELS = 
      [ new LevelInfo("TEST\nTEST",
		      Level0TilemapImageCls,
		      Level0DirtmapImageCls,
		      null),
	new LevelInfo("LEVEL 1\nINTRODUCTION",
		      Level1TilemapImageCls,
		      Level1DirtmapImageCls,
		      Level1MusicCls),
	new LevelInfo("LEVEL 2\nDERP",
		      Level2TilemapImageCls,
		      Level2DirtmapImageCls,
		      Level2MusicCls),
	new LevelInfo("LEVEL 3\nGOGGY!",
		      Level3TilemapImageCls,
		      Level3DirtmapImageCls,
		      Level3MusicCls),
	];

    _status = new Status();
    _status.level = 1;		// initial level (should be 1).
    _width = width;
    _height = height;
  }

  // open()
  public override function open():void
  {
    var info:LevelInfo = LEVELS[_status.level];
    var tilemapImage:Bitmap = new info.tilemap;
    var dirtmapImage:Bitmap = new info.dirtmap;
    var music:Sound = (info.music == null)? null : new info.music;

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
    _player.addEventListener(Player.COLLECT, onPlayerCollect);

    _status.goal = Math.floor(_scene.collectibles*0.75); // 75% thing
    _status.collected = 0;
    _status.time = 0;
    _clock = 0;

    if (music != null) {
      _musicloop = new SoundLoop(music);
    }

    // Create a splash screen.
    _splash = new Splash(_width, _height);
    _splash.title = info.name;
    _splash.addEventListener(Splash.END, onSplashEnd);

    addChild(_scene);
    addChild(_status);
    addChild(_splash);
  }

  // close()
  public override function close():void
  {
    removeChild(_splash);
    removeChild(_scene);
    removeChild(_status);

    if (_musicloop != null) {
      _musicloop.stop();
    }
    _scene.close();
  }

  // pause()
  public override function pause():void
  {
    if (_musicloop != null) {
      _musicloop.pause();
    }
  }

  // resume()
  public override function resume():void
  {
    if (_musicloop != null) {
      _musicloop.resume();
    }
  }

  // update()
  public override function update():void
  {
    if (_splash.alive) {
      _splash.update(_clock);

    } else if (0 < _winning) {
      // In winning situation, only move the player animation.
      _player.cheer(_clock);
      _scene.paint(_clock);
      _winning--;
      if (_winning == 0) {
	onNextLevel();
      }
    } else {
      _status.time = (getTimer() - _starttime)/1000;
      _status.health = _player.health;
      _status.update();
      
      _scene.uncoverMap(_player.bounds, 32);
      _scene.setCenter(_player.pos, 50, 50);
      _scene.paint(_clock);
      _scene.update(_clock);
    }

    _clock++;
  }

  // keydown(keycode)
  public override function keydown(keycode:int):void
  {
    if (_splash.alive) {
      _splash.alive = false;
      return;
    }

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

    case 77:			// M
      _scene.toggleMask();
      break;
    case 78:			// N
      onNextLevel();
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

  private function onSplashEnd(e:Event):void
  {
    _splash.visible = false;	
    _starttime = getTimer();
    if (_musicloop != null) {
      _musicloop.start();
    }
  }

  private function onPlayerHurt(e:ActorEvent):void
  {
    if (_player.health == 0) {
      // DEAD
      dispatchEvent(new ScreenEvent(MenuScreen));
    }
  }

  private function onPlayerCollect(e:ActorEvent):void
  {
    _status.collected++;
    if (_status.goal <= _status.collected) {
      // WIN
      _winning = win_duration;
      if (_musicloop != null) {
	_musicloop.stop();
      }
      winningMusic.play();
    }
  }

  private function onNextLevel():void
  {
    _status.level++;
    if (LEVELS.length <= _status.level) {
      // XXX ENDING
      dispatchEvent(new ScreenEvent(MenuScreen));
    } else {
      close();
      open();
    }
  }
}

} // package

import flash.events.Event;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import baseui.Font;

class LevelInfo extends Object
{
  public var name:String;
  public var tilemap:Class;
  public var dirtmap:Class;
  public var music:Class;

  public function LevelInfo(name:String, tilemap:Class, dirtmap:Class, music:Class)
  {
    this.name = name;
    this.tilemap = tilemap;
    this.dirtmap = dirtmap;
    this.music = music;
  }
}

class Splash extends Sprite
{
  public static const END:String = "Splash.END";

  private var _alive:Boolean;

  public function Splash(width:int, height:int)
  {
    graphics.beginFill(0);
    graphics.drawRect(0, 0, width, height);
    _alive = true;
  }

  public function set title(v:String):void
  {
    var text:Bitmap = Font.createText(v, 0xffffff, 16, 3);
    text.x = (width-text.width)/2;
    text.y = (height-text.height)/2;
    addChild(text);
  }

  public function get alive():Boolean
  {
    return _alive;
  }

  public function set alive(v:Boolean):void
  {
    if (_alive && !v) {
      dispatchEvent(new Event(END));
    }
    _alive = v;
  }

  public function update(clock:int):void
  {
    alive = (clock < 48);
  }

}

class Status extends Sprite
{
  public var level:int;
  public var collected:int;
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
		       "  GRAVE: "+Utils.format(collected, 2)+"/"+Utils.format(goal, 2)+
		       "  TIME: "+Utils.format(time, 3));
    Font.renderText(_text.bitmapData, text);
  }
}

