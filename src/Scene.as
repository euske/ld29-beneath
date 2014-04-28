package {

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

//  Scene
// 
public class Scene extends Sprite
{
  private var _tilesize:int;
  private var _tiledata:BitmapData;
  private var _dirtdata:BitmapData;
  private var _tileset:BitmapData;
  private var _fluidimage:Bitmap;
  private var _tileimage:Bitmap;
  private var _actorlayer:Sprite;
  private var _dirtimage:Bitmap;
  private var _maskimage:Bitmap;
  private var _maprect:Rectangle;

  private var _window:Rectangle;
  private var _tilewindow:Rectangle;
  private var _tilemap:TileMap;
  private var _maskmap:MaskMap;
  private var _maskchanged:Boolean;
  private var _player:Player;
  private var _actors:Array;
  private var _collectibles:int;
  private var _phase:int;

  // Background image:
  [Embed(source="../assets/background.png", mimeType="image/png")]
  private static const BackgroundImageCls:Class;

  // TileSet image:
  [Embed(source="../assets/tileset.png", mimeType="image/png")]
  private static const TilesetImageCls:Class;
  private static const tilesetImage:Bitmap = new TilesetImageCls();

  // Scene(w, h, tilemap): set up fixated things.
  public function Scene(w:int, h:int, tilesize:int,
			tiledata:BitmapData,
			dirtdata:BitmapData)
  {
    _tilesize = tilesize;
    _tiledata = tiledata;
    _dirtdata = dirtdata;
    _tileset = tilesetImage.bitmapData;
    _window = new Rectangle(0, 0, w*tilesize, h*tilesize);

    var tw:int = (w+1)*tilesize;
    var th:int = (h+1)*tilesize;
    _fluidimage = new Bitmap(new BitmapData(tw, th, true, 0x00000000));
    _tileimage = new Bitmap(new BitmapData(tw, th, true, 0x00000000));
    _actorlayer = new Sprite();
    _dirtimage = new Bitmap(new BitmapData(tw, th, true, 0x00000000));
    _maskimage = new Bitmap(new BitmapData(tw, th, true, 0x00000000));
    _maprect = new Rectangle(0, 0,
			     _tiledata.width*tilesize,
			     _tiledata.height*tilesize);

    var bgimage:Bitmap = new BackgroundImageCls();
    bgimage.width = _window.width;
    bgimage.height = _window.height;

    var clipping:Shape = new Shape();
    clipping.graphics.beginFill(0xffffff);
    clipping.graphics.drawRect(0, 0, _window.width, _window.height);
    _fluidimage.mask = clipping;
    _tileimage.mask = clipping;
    _actorlayer.mask = clipping;
    _dirtimage.mask = clipping;
    _maskimage.mask = clipping;

    addChild(clipping);
    addChild(bgimage);
    addChild(_fluidimage);
    addChild(_tileimage);
    addChild(_actorlayer);
    addChild(_dirtimage);
    addChild(_maskimage);
  }

  // open()
  public function open():void
  {
    // initialize things for each gameplay.
    _window.x = 0;
    _window.y = 0;
    _tilemap = new TileMap(_tilesize);
    _tilemap.setBitmap(_tiledata, _dirtdata);
    _tilewindow = new Rectangle();
    _maskmap = new MaskMap(_tilemap.width, _tilemap.height, _tilesize);
    _actors = new Array();
    _player = new Player(this);
    _player.activate();
    add(_player);
    _collectibles = 0;
    placeActors();
  }

  // close()
  public function close():void
  {
    for each (var actor:Actor in _actors) {
      _actorlayer.removeChild(actor.skin);
    }
  }
  
  // tilesize
  public function get tilesize():int
  {
    return _tilesize;
  }

  // player
  public function get player():Player
  {
    return _player;
  }

  // tilemap
  public function get tilemap():TileMap
  {
    return _tilemap;
  }

  // maprect
  public function get maprect():Rectangle
  {
    return _maprect;
  }

  // window
  public function get window():Rectangle
  {
    return _window;
  }

  // add(actor)
  public function add(actor:Actor):void
  {
    _actors.push(actor);
    _actorlayer.addChild(actor.skin);
  }

  // remove(actor)
  public function remove(actor:Actor):void
  {
    var i:int = _actors.indexOf(actor);
    if (0 <= i) {
      _actors.splice(i, 1);
      _actorlayer.removeChild(actor.skin);
    }
  }

  // update()
  public function update():void
  {
    for (var i:int = 0; i < _actors.length; i++) {
      var actor:Actor = _actors[i];
      if (!actor.active) continue;
      for (var j:int = i+1; j < _actors.length; j++) {
	var a:Actor = _actors[j];
	if (a.active && actor.bounds.intersects(a.bounds)) {
	  actor.collide(a);
	  a.collide(actor);
	}
      }
      actor.update();
    }
  }

  // paint()
  public function paint(phase:int):void
  {
    // Render each actor.
    for each (var actor:Actor in _actors) {
      var p:Point = translatePoint(actor.pos);
      actor.skin.x = p.x+actor.frame.x;
      actor.skin.y = p.y+actor.frame.y;
    }

    // Refresh the map if needed.
    var x0:int = Math.floor(_window.left/_tilesize);
    var y0:int = Math.floor(_window.top/_tilesize);
    var x1:int = Math.ceil(_window.right/_tilesize);
    var y1:int = Math.ceil(_window.bottom/_tilesize);
    var r:Rectangle = new Rectangle(x0, y0, x1-x0+1, y1-y0+1);
    if (!_tilewindow.equals(r) || _phase != phase) {
      renderFluids(r, Math.floor(phase/2));
    }
    if (!_tilewindow.equals(r) || _tilemap.changed) {
      renderTiles(r);
    }
    if (_maskchanged) {
      renderMasks(r);
    }
    _tilewindow = r;
    _phase = phase;
    _tilemap.changed = false;
    _maskchanged = false;

    var bx:int = (_tilewindow.x*_tilesize)-_window.x;
    var by:int = (_tilewindow.y*_tilesize)-_window.y;
    _fluidimage.x = bx;
    _fluidimage.y = by;
    _tileimage.x = bx;
    _tileimage.y = by;
    _dirtimage.x = bx;
    _dirtimage.y = by;
    _maskimage.x = bx;
    _maskimage.y = by;
  }

  // refreshTiles()
  public function refreshTiles():void
  {
    _tilewindow = new Rectangle();
  }

  // getTileSrcRect(i)
  private function getTileSrcRect(i:int):Rectangle
  {
    return new Rectangle(i*_tilesize, 0, _tilesize, _tilesize);
  }

  // createTileSkin(i)
  private function createTileSkin(i:int):Bitmap
  {
    var src:Rectangle = new Rectangle(i*_tilesize, 0, _tilesize, _tilesize);
    var skin:BitmapData = new BitmapData(src.width, src.height);
    skin.copyPixels(_tileset, src, new Point());
    return new Bitmap(skin);
  }

  // renderTiles(r)
  private function renderTiles(r:Rectangle):void
  {
    var area:Rectangle = new Rectangle(0, 0, _tileimage.width, _tileimage.height);
    _tileimage.bitmapData.fillRect(area, 0x00000000);
    _dirtimage.bitmapData.fillRect(area, 0x00000000);
    for (var dy:int = 0; dy <= r.height; dy++) {
      var y:int = r.y+dy;
      for (var dx:int = 0; dx <= r.width; dx++) {
	var x:int = r.x+dx;
	var dst:Point = new Point(dx*_tilesize, dy*_tilesize);
	var i:int = _tilemap.getRawTile(x, y);
	if (0 <= i && Tile.getFluid(i, -1) < 0) {
	  _tileimage.bitmapData.copyPixels(_tileset, getTileSrcRect(i), dst);
	}
	i = _tilemap.getDirt(x, y);
	if (0 <= i) {
	  _dirtimage.bitmapData.copyPixels(_tileset, getTileSrcRect(i), dst);
	}
      }
    }
  }

  // renderFluids(r, phase)
  private function renderFluids(r:Rectangle, phase:int):void
  {
    var area:Rectangle = new Rectangle(0, 0, _fluidimage.width, _fluidimage.height);
    _fluidimage.bitmapData.fillRect(area, 0x00000000);
    for (var dy:int = 0; dy <= r.height; dy++) {
      var y:int = r.y+dy;
      for (var dx:int = 0; dx <= r.width; dx++) {
	var x:int = r.x+dx;
	var p:int = phase+(dx*3)+(dy*7); // randomize the phase of each cell.
	var i:int = Tile.getFluid(_tilemap.getTile(x, y), p);
	var src:Rectangle;
	var dst:Point = new Point(dx*_tilesize, dy*_tilesize);
	if (0 <= i) {
	  // whole fluid.
	  src = getTileSrcRect(i);
	  _fluidimage.bitmapData.copyPixels(_tileset, src, dst);
	  continue;
	}
	// partial fluid (left).
	i = Tile.getFluid(_tilemap.getTile(x-1, y), phase);
	if (0 <= i) {
	  src = getTileSrcRect(i);
	  src.width = _tilesize/2;
	  _fluidimage.bitmapData.copyPixels(_tileset, src, dst);
	}
	// partial fluid (right).
	i = Tile.getFluid(_tilemap.getTile(x+1, y), phase);
	if (0 <= i) {
	  src = getTileSrcRect(i);
	  src.left += _tilesize/2;
	  src.width = _tilesize/2;
	  dst.x += _tilesize/2;
	  _fluidimage.bitmapData.copyPixels(_tileset, src, dst);
	}
	// partial fluid (up).
	i = Tile.getFluid(_tilemap.getTile(x, y-1), phase);
	if (0 <= i) {
	  src = getTileSrcRect(i);
	  src.top += 3*_tilesize/4;
	  src.height = _tilesize/4;
	  _fluidimage.bitmapData.copyPixels(_tileset, src, dst);
	}
      }
    }
  }

  // renderMasks(x, y)
  private function renderMasks(r:Rectangle):void
  {
    var area:Rectangle = new Rectangle(0, 0, _maskimage.width, _maskimage.height);
    _maskimage.bitmapData.fillRect(area, 0x00000000);
    for (var dy:int = 0; dy <= r.height; dy++) {
      var y:int = r.y+dy;
      for (var dx:int = 0; dx <= r.width; dx++) {
	var x:int = r.x+dx;
	var dst:Rectangle = new Rectangle(dx*_tilesize, dy*_tilesize, _tilesize, _tilesize);
	if (_maskmap.getMask(x, y) <= 0) {
	  _maskimage.bitmapData.fillRect(dst, 0xff000000);
	}
      }
    }
  }

  // uncoverMap(r): open up a part of the map/activate things.
  public function uncoverMap(bounds:Rectangle, size:int):void
  {
    var r:Rectangle = bounds.clone();
    r.inflate(size, size);
    _maskmap.setMaskByRect(r, 1);
    _maskchanged = true;
    // Activate actors in the uncover part.
    for each (var actor:Actor in _actors) {
      if (!actor.active && _maskmap.getMaskByRect(actor.bounds)) {
	actor.activate();
      }
    }
    refreshTiles();
  }

  // setCenter(p)
  public function setCenter(p:Point, hmargin:int, vmargin:int):void
  {
    // Center the window position.
    if (_maprect.width < _window.width) {
      _window.x = -(_window.width-_maprect.width)/2;
    } else if (p.x-hmargin < _window.left) {
      _window.x = Math.max(_maprect.left, p.x-hmargin);
    } else if (_window.right < p.x+hmargin) {
      _window.x = Math.min(_maprect.right, p.x+hmargin)-_window.width;
    }
    if (_maprect.height < _window.height) {
      _window.y = -(_window.height-_maprect.height)/2;
    } else if (p.y-vmargin < _window.top) {
      _window.y = Math.max(_maprect.top, p.y-vmargin);
    } else if (_window.bottom < p.y+vmargin) {
      _window.y = Math.min(_maprect.bottom, p.y+vmargin)-_window.height;
    }
  }

  // translatePoint(p)
  public function translatePoint(p:Point):Point
  {
    return new Point(p.x-_window.x, p.y-_window.y);
  }

  // getCenteredBounds(center, margin)
  public function getCenteredBounds(center:Point, margin:int=0):Rectangle
  {
    var x0:int = Math.floor(_window.left/_tilesize);
    x0 = Math.max(x0-margin, 0);
    var y0:int = Math.floor(_window.top/_tilesize);
    y0 = Math.max(y0-margin, 0);
    var x1:int = Math.ceil(_window.right/_tilesize);
    x1 = Math.min(x1+margin, _tilemap.width-1);
    var y1:int = Math.ceil(_window.bottom/_tilesize);
    y1 = Math.min(y1+margin, _tilemap.height-1);
    return new Rectangle(x0, y0, x1-x0, y1-y0);
  }

  // placeActors()
  private function placeActors():void
  {
    for (var y:int = 0; y < _tilemap.height; y++) {
      for (var x:int = 0; x < _tilemap.width; x++) {
	var i:int = _tilemap.getRawTile(x, y);
	var p:Point = new Point(x*_tilesize, y*_tilesize);
	var actor:Actor = null;
	switch (i) {
	case Tile.SPAWN_PLAYER:
	  _player.pos = p;
	  break;

	case Tile.SPAWN_GRAVE:
	  i = Utils.rnd(Tile.GRAVE_BEGIN, Tile.GRAVE_END+1);
	  actor = new Grave(this, createTileSkin(Tile.GRAVE_TRACE));
	  actor.skin = createTileSkin(i);
	  _collectibles++;
	  break;

	case Tile.SPAWN_ENEMY1:
	  actor = new RunningEnemy(this, +1);
	  break;
	case Tile.SPAWN_ENEMY2:
	  actor = new FlyingEnemy(this, +1);
	  break;
	case Tile.SPAWN_ENEMY3:
	  actor = new StickingEnemy(this, +1, 0);
	  break;

	}
	if (actor != null) {
	  trace("spawn tile: "+i+" at ("+x+","+y+")");
	  actor.pos = p;
	  add(actor);
	}
      }
    }
  }
}

} // package
