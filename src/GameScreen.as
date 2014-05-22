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
  [Embed(source="../assets/levels/tilemap4.png", mimeType="image/png")]
  private static const Level4TilemapImageCls:Class;
  [Embed(source="../assets/levels/tilemap5.png", mimeType="image/png")]
  private static const Level5TilemapImageCls:Class;
  [Embed(source="../assets/levels/tilemap6.png", mimeType="image/png")]
  private static const Level6TilemapImageCls:Class;

  // DirtMap image:
  [Embed(source="../assets/levels/dirtmap0.png", mimeType="image/png")]
  private static const Level0DirtmapImageCls:Class;
  [Embed(source="../assets/levels/dirtmap1.png", mimeType="image/png")]
  private static const Level1DirtmapImageCls:Class;
  [Embed(source="../assets/levels/dirtmap2.png", mimeType="image/png")]
  private static const Level2DirtmapImageCls:Class;
  [Embed(source="../assets/levels/dirtmap3.png", mimeType="image/png")]
  private static const Level3DirtmapImageCls:Class;
  [Embed(source="../assets/levels/dirtmap4.png", mimeType="image/png")]
  private static const Level4DirtmapImageCls:Class;
  [Embed(source="../assets/levels/dirtmap5.png", mimeType="image/png")]
  private static const Level5DirtmapImageCls:Class;
  [Embed(source="../assets/levels/dirtmap6.png", mimeType="image/png")]
  private static const Level6DirtmapImageCls:Class;

  // Musics
  [Embed(source="../assets/music/Level2.mp3", mimeType="audio/mpeg")]
  private static const Level1MusicCls:Class;
  [Embed(source="../assets/music/Level3.mp3", mimeType="audio/mpeg")]
  private static const Level2MusicCls:Class;
  [Embed(source="../assets/music/Level1.mp3", mimeType="audio/mpeg")]
  private static const Level3MusicCls:Class;
  
//[Embed(source="../assets/music/Title_Screen.mp3", mimeType="audio/mpeg")]  
//private static const TitleScreenMusicCls:Class;
//[Embed(source="../assets/music/#####.mp3", mimeType="audio/mpeg")]  
//private static const LoseScreenMusicCls:Class;
//[Embed(source="../assets/music/#####.mp3", mimeType="audio/mpeg")]  
//private static const WinScreenMusicCls:Class;

  // Winning music
  [Embed(source="../assets/sounds/treasure_pickup.mp3", mimeType="audio/mpeg")]
  private static const WinningMusicCls:Class;
  private static const winningMusic:Sound = new WinningMusicCls();

  private const win_duration:int = 60; // pause after win (in frames)

  private var _width:int;	// Screen width.
  private var _height:int;	// Screen height.
  private var _status:Status;	// Status text.
  private var _splash:Splash;	// Splash screen.

  private var LEVELS:Array;	// Levels (wanted to make this static but couldn't)

  /// Game-related functions

  private var _scene:Scene;	// Scrolling display.
  private var _player:Player;
  private var _musicloop:SoundLoop;
  private var _starttime:uint;	// the time the scene started.
  private var _winning:int;	// >0 if the winning animation is being played.
  private var _clock:int;	// current time.

  public function GameScreen(width:int, height:int)
  {
    LEVELS = 
      [ new LevelInfo("TEST\nTEST",
		      Level0TilemapImageCls,
		      Level0DirtmapImageCls,
		      null),
	new LevelInfo("LEVEL 1\nEASY PEASY",
		      Level1TilemapImageCls,
		      Level1DirtmapImageCls,
		      Level1MusicCls),
	new LevelInfo("LEVEL 2\nTHE QUEST BEGINS",
		      Level2TilemapImageCls,
		      Level2DirtmapImageCls,
		      Level1MusicCls),
	new LevelInfo("LEVEL 3\nGRAVEYARD?\n MORE LIKE CAVEYARD!",
		      Level3TilemapImageCls,
		      Level3DirtmapImageCls,
		      Level2MusicCls),
	new LevelInfo("LEVEL 4\n<LEVEL NAME>",
		      Level4TilemapImageCls,
		      Level4DirtmapImageCls,
		      Level2MusicCls), 
	new LevelInfo("LEVEL 5\nWELCOME TO MELTING",
		      Level5TilemapImageCls,
		      Level5DirtmapImageCls,
		      Level3MusicCls),
	new LevelInfo("LEVEL 6\nHOT N' BOTHERED",
		      Level6TilemapImageCls,
		      Level6DirtmapImageCls,
		      Level3MusicCls), 
	];

    _width = width;
    _height = height;
    _status = new Status(_width, _height);
  }

  // open()
  //   is called at initialization of each level.
  public override function open():void
  {
    var level:int = sharedInfo.level; // current level.
    var info:LevelInfo = LEVELS[level]; // get the title & music, etc.
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
    _player.addEventListener(Player.HURT, onPlayerHurt);
    _player.addEventListener(Player.COLLECT, onPlayerCollect);
    _player.addEventListener(Player.LOOT, onPlayerLoot);

    _status.level = level;
    // a level is considered cleared when the player collects 75% of the objects.
    _status.goal = Math.floor(_scene.collectibles*0.75);
    _status.collected = 0;
    _status.bones = sharedInfo.score;
    _status.time = 0;

    _clock = 0;

    if (music != null) {
      _musicloop = new SoundLoop(music);
    }

    // Create a splash screen.
    _splash = new Splash(_width, _height, info.name);
    _splash.addEventListener(Splash.END, onSplashEnd);

    addChild(_scene);
    addChild(_status);
    addChild(_splash);
  }

  // close()
  public override function close():void
  {
    if (_splash != null) {
      removeChild(_splash);
    }
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

  // update(): called at every frame.
  public override function update():void
  {
    if (_splash != null) {
      // Nothing moves when the splash screen is displayed.
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
      // The actual game is running.

      // Update the status display.
      _status.time = (getTimer() - _starttime)/1000;
      _status.health = _player.health;
      _status.update();
      
      // Scroll the scene, move the characters.
      _scene.uncoverMap(_player.bounds, 32);
      _scene.setCenter(_player.pos, 50, 50);
      _scene.paint(_clock);
      _scene.update(_clock);
    }

    _clock++;
  }

  // keydown(keycode): called when a key is pressed.
  public override function keydown(keycode:int):void
  {
    if (_splash != null) {
      _splash.finish();
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
      _player.jumping = true;
      break;

    case 77:			// M (for debugging)
      _scene.toggleMask();
      break;
    case 78:			// N (for debugging)
      onNextLevel();
      break;
    }
  }

  // keyup(keycode): called when a key is released.
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

    case Keyboard.SPACE:
    case Keyboard.ENTER:
    case 88:			// X
    case 90:			// Z
      _player.jumping = false;
      break;

    case Keyboard.SHIFT:
    case Keyboard.CONTROL:
      _player.digging = false;
      break;
    }
  }

  // onSplashEnd: called when the splash screen closes.
  private function onSplashEnd(e:Event):void
  {
    // remove the splash screen.
    if (_splash != null) {
      removeChild(_splash);
      _splash = null;
    }
    // Start the game music.
    _starttime = getTimer();
    if (_musicloop != null) {
      _musicloop.start();
    }
  }

  // onPlayerCollect: called when the player collects a thing.
  private function onPlayerCollect(e:ActorEvent):void
  {
    _status.collected++;
    if (_status.goal <= _status.collected) {
      // Goal achieved! Do the winning animation.
      _winning = win_duration;
      if (_musicloop != null) {
	_musicloop.stop();
      }
      winningMusic.play();
    }
  }

  // onPlayerLoot: called when the player loots a thing.
  private function onPlayerLoot(e:ActorEvent):void
  {
    _status.bones++;
  }

  // onPlayerHurt: called when the player is hurt.
  private function onPlayerHurt(e:ActorEvent):void
  {
    if (_player.health == 0) {
      // Player health reached 0 - DEAD!
      sharedInfo.level = _status.level;
      sharedInfo.score = _status.bones;
      sharedInfo.time += _status.time;
      //dispatchEvent(new ScreenEvent(EndingScreen));
      dispatchEvent(new ScreenEvent(GameOverScreen));
    }
  }

  // onNextLevel: called when the winning animation is finished.
  private function onNextLevel():void
  {
    // Advance the level.
    _status.level++;
    // Update the shared info.
    sharedInfo.level = _status.level;
    sharedInfo.score = _status.bones;
    sharedInfo.time += _status.time;

    if (LEVELS.length <= _status.level) {
      // All the level are cleared!
      dispatchEvent(new ScreenEvent(EndingScreen));
    } else {
      // Go to the next level.
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

//  LevelInfo:
//  a structure that holds metadata about a level.
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

//  Splash screen
//
class Splash extends Sprite
{
  public static const END:String = "Splash.END";

  public const splash_duration:int = 48; // splash pause

  public function Splash(width:int, height:int, title:String)
  {
    graphics.beginFill(0);
    graphics.drawRect(0, 0, width, height);

    var text:Bitmap = Font.createText(title, 0xffffff, 16, 3);
    text.x = (width-text.width)/2;
    text.y = (height-text.height)/2;
    addChild(text);
  }

  // Finish the splash screen.
  public function finish():void
  {
    dispatchEvent(new Event(END));
  }

  public function update(clock:int):void
  {
    if (splash_duration <= clock) {
      finish();
    }
  }
}

//  Status display
//  
class Status extends Sprite
{
  public var level:int;
  public var collected:int;
  public var goal:int;
  public var bones:int;
  public var health:int;
  public var time:int;

  private var _text:Bitmap;

  // Symbols image:
  [Embed(source="../assets/hud/symbols.png", mimeType="image/png")]
  private static const SymbolsImageCls:Class;
  private static const symbolsImage:Bitmap = new SymbolsImageCls();

  public function Status(width:int, height:int)
  {
    graphics.beginFill(0, 0.5);
    graphics.drawRect(0, 0, width, 32);
    //                       012345678901234567890123456789
    _text = Font.createText("HHHHH  XNN/NN  XNN  XNNN", 0xffffff, 0, 2);
    _text.x = (width-_text.width)/2;
    _text.y = 8;
    addChild(_text)
  }

  public function update():void
  {
    var text:String = ("XXXXX  X"+Utils.format(collected, 2)+
		       "/"+Utils.format(goal, 2)+
		       "  X"+Utils.format(bones, 2)+
		       "  X"+Utils.format(time, 3));
    Font.renderText(_text.bitmapData, text);
    
    for (var x:int = 0; x < 5; x++) {
      if (x < health) {
	slapSymbol(x, 1);	// filled heart.
      } else {
	slapSymbol(x, 2);	// empty heart.
      }
    }
    slapSymbol(7, 6);		// grave.
    slapSymbol(15, 4);		// bone.
    slapSymbol(20, 5);		// time.
  }

  private function slapSymbol(x:int, i:int):void
  {
    var src:Rectangle = new Rectangle(i*8, 0, 8, 8);
    var dst:Point = new Point(x*8, 0);
    _text.bitmapData.copyPixels(symbolsImage.bitmapData, src, dst);
  }
}
