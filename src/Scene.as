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
  private var _window:Rectangle;
  private var _tilemap:TileMap;
  private var _dirtmap:DirtMap;
  private var _tiles:BitmapData;
  private var _fluidimage:Bitmap;
  private var _mapimage:Bitmap;
  private var _maskimage:Bitmap;
  private var _maprect:Rectangle;
  private var _actors:Array;

  private var _tilewindow:Rectangle;
  private var _dirtchanged:Boolean;
  private var _phase:int;

  // Background image:
  [Embed(source="../assets/background.png", mimeType="image/png")]
  private static const BackgroundImageCls:Class;

  // Scene(w, h, tilemap)
  public function Scene(w:int, h:int, 
			tilemap:TileMap, tiles:BitmapData)
  {
    _window = new Rectangle(0, 0, w*tilemap.tilesize, h*tilemap.tilesize);
    _tilemap = tilemap;
    _dirtmap = new DirtMap(tilemap.width, tilemap.height, tilemap.tilesize);
    _tiles = tiles;
    _tilewindow = new Rectangle();

    var tw:int = (w+1)*tilemap.tilesize;
    var th:int = (h+1)*tilemap.tilesize;
    _fluidimage = new Bitmap(new BitmapData(tw, th, true, 0x00000000));
    _mapimage = new Bitmap(new BitmapData(tw, th, true, 0x00000000));
    _maskimage = new Bitmap(new BitmapData(tw, th, true, 0x00000000));
    _maprect = new Rectangle(0, 0,
			     tilemap.width*tilemap.tilesize,
			     tilemap.height*tilemap.tilesize);
    _actors = new Array();

    var bgimage:Bitmap = new BackgroundImageCls();
    bgimage.width = _window.width;
    bgimage.height = _window.height;

    var clipping:Shape = new Shape();
    clipping.graphics.beginFill(0xffffff);
    clipping.graphics.drawRect(0, 0, _window.width, _window.height);
    _fluidimage.mask = clipping;
    _mapimage.mask = clipping;
    _maskimage.mask = clipping;

    addChild(clipping);
    addChild(bgimage);
    addChild(_fluidimage);
    addChild(_mapimage);
    addChild(_maskimage);
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
    addChild(actor.skin);
  }

  // remove(actor)
  public function remove(actor:Actor):void
  {
    var i:int = _actors.indexOf(actor);
    if (0 <= i) {
      _actors.splice(i, 1);
      removeChild(actor.skin);
    }
  }

  // clear()
  public function clear():void
  {
    for each (var actor:Actor in _actors) {
      removeChild(actor.skin);
    }
    _actors = new Array();
  }

  // update()
  public function update():void
  {
    for each (var actor:Actor in _actors) {
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
    var tilesize:int = _tilemap.tilesize;
    var x0:int = Math.floor(_window.left/tilesize);
    var y0:int = Math.floor(_window.top/tilesize);
    var x1:int = Math.ceil(_window.right/tilesize);
    var y1:int = Math.ceil(_window.bottom/tilesize);
    var r:Rectangle = new Rectangle(x0, y0, x1-x0+1, y1-y0+1);
    if (!_tilewindow.equals(r)) {
      renderTiles(r);
    }
    if (!_tilewindow.equals(r) || _phase != phase) {
      renderFluids(r, phase);
    }
    if (_dirtchanged) {
      renderMasks(r);
    }
    _tilewindow = r;
    _phase = phase;
    _dirtchanged = false;

    _mapimage.x = (_tilewindow.x*tilesize)-_window.x;
    _mapimage.y = (_tilewindow.y*tilesize)-_window.y;
    _fluidimage.x = _mapimage.x;
    _fluidimage.y = _mapimage.y;
    _maskimage.x = _mapimage.x;
    _maskimage.y = _mapimage.y;
  }

  // refreshTiles()
  public function refreshTiles():void
  {
    _tilewindow = new Rectangle();
  }

  private function getTileSrcRect(i:int):Rectangle
  {
    var tilesize:int = _tilemap.tilesize;
    return new Rectangle(i*tilesize, 0, tilesize, tilesize);
  }

  // renderTiles(r)
  private function renderTiles(r:Rectangle):void
  {
    var tilesize:int = _tilemap.tilesize;
    var area:Rectangle = new Rectangle(0, 0, _mapimage.width, _mapimage.height);
    _mapimage.bitmapData.fillRect(area, 0x00000000);
    for (var dy:int = 0; dy <= r.height; dy++) {
      var y:int = r.y+dy;
      for (var dx:int = 0; dx <= r.width; dx++) {
	var x:int = r.x+dx;
	var i:int = _tilemap.getTile(x, y);
	if (0 <= i && Tile.getFluid(i, -1) < 0) {
	  var src:Rectangle = getTileSrcRect(i);
	  var dst:Point = new Point(dx*tilesize, dy*tilesize);
	  _mapimage.bitmapData.copyPixels(_tiles, src, dst);
	}
      }
    }
  }

  // renderFluids(r, phase)
  private function renderFluids(r:Rectangle, phase:int):void
  {
    var tilesize:int = _tilemap.tilesize;
    var area:Rectangle = new Rectangle(0, 0, _fluidimage.width, _fluidimage.height);
    _fluidimage.bitmapData.fillRect(area, 0x00000000);
    for (var dy:int = 0; dy <= r.height; dy++) {
      var y:int = r.y+dy;
      for (var dx:int = 0; dx <= r.width; dx++) {
	var x:int = r.x+dx;
	var p:int = phase+(dx*3)+(dy*7); // randomize the phase of each cell.
	var i:int = Tile.getFluid(_tilemap.getTile(x, y), p);
	var src:Rectangle;
	var dst:Point = new Point(dx*tilesize, dy*tilesize);
	if (0 <= i) {
	  // whole fluid.
	  src = getTileSrcRect(i);
	  _fluidimage.bitmapData.copyPixels(_tiles, src, dst);
	  continue;
	}
	// partial fluid (left).
	i = Tile.getFluid(_tilemap.getTile(x-1, y), phase);
	if (0 <= i) {
	  src = getTileSrcRect(i);
	  src.width = tilesize/2;
	  _fluidimage.bitmapData.copyPixels(_tiles, src, dst);
	}
	// partial fluid (right).
	i = Tile.getFluid(_tilemap.getTile(x+1, y), phase);
	if (0 <= i) {
	  src = getTileSrcRect(i);
	  src.left += tilesize/2;
	  src.width = tilesize/2;
	  dst.x += tilesize/2;
	  _fluidimage.bitmapData.copyPixels(_tiles, src, dst);
	}
	// partial fluid (up).
	i = Tile.getFluid(_tilemap.getTile(x, y-1), phase);
	if (0 <= i) {
	  src = getTileSrcRect(i);
	  src.top += 3*tilesize/4;
	  src.height = tilesize/4;
	  _fluidimage.bitmapData.copyPixels(_tiles, src, dst);
	}
      }
    }
  }

  // renderMasks(x, y)
  private function renderMasks(r:Rectangle):void
  {
    var tilesize:int = _tilemap.tilesize;
    var area:Rectangle = new Rectangle(0, 0, _maskimage.width, _maskimage.height);
    _maskimage.bitmapData.fillRect(area, 0x00000000);
    for (var dy:int = 0; dy <= r.height; dy++) {
      var y:int = r.y+dy;
      for (var dx:int = 0; dx <= r.width; dx++) {
	var x:int = r.x+dx;
	var dst:Rectangle = new Rectangle(dx*tilesize, dy*tilesize, tilesize, tilesize);
	if (_dirtmap.getMask(x, y) <= 0) {
	  _maskimage.bitmapData.fillRect(dst, 0xff000000);
	}
      }
    }
  }

  // openMap(r)
  public function openMap(r:Rectangle, size:int):void
  {
    r = r.clone();
    r.inflate(size, size);
    _dirtmap.setMaskByRect(r, 1);
    _dirtchanged = true;
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
    var tilesize:int = _tilemap.tilesize;
    var x0:int = Math.floor(_window.left/tilesize);
    x0 = Math.max(x0-margin, 0);
    var y0:int = Math.floor(_window.top/tilesize);
    y0 = Math.max(y0-margin, 0);
    var x1:int = Math.ceil(_window.right/tilesize);
    x1 = Math.min(x1+margin, _tilemap.width-1);
    var y1:int = Math.ceil(_window.bottom/tilesize);
    y1 = Math.min(y1+margin, _tilemap.height-1);
    return new Rectangle(x0, y0, x1-x0, y1-y0);
  }
}

} // package
