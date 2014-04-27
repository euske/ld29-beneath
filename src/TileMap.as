package {

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

//  TileMap class is a two dimensional array that has
//  various query functions.
//
public class TileMap
{
  // tilesize: the size of each tile.
  public var tilesize:int;

  // bitmap: actual bitmap to hold the 2D array.
  // The top row is used as a lookup table for tile types.
  // The color of pixel (0,0) is used as type 0.
  // The color of pixel (1,0) is used as type 1. etc.
  private var _bitmap:BitmapData;
  // dirtmap:
  private var _dirtmap:Array;

  // _tilevalue: lookup table from a pixel color to a type number.
  private var _tilevalue:Dictionary;

  // TileMap(tilesize)
  public function TileMap(tilesize:int)
  {
    this.tilesize = tilesize;
  }

  // bitmap:
  public function get bitmap():BitmapData
  {
    return _bitmap;
  }
  public function set bitmap(v:BitmapData):void
  {
    _bitmap = v.clone();
    _dirtmap = new Array(height);
    for (var y:int = 0; y < _dirtmap.length; y++) {
      var row:Array = new Array(width);
      for (var x:int = 0; x < row.length; x++) {
	row[x] = 1;
      }
      _dirtmap[y] = row;
    }

    // Construct a lookup table.
    // The color value at a pixel at (i,0) is used as i-th type.
    _tilevalue = new Dictionary();
    for (var i:int = 0; i < _bitmap.width; i++) {
      var c:uint = _bitmap.getPixel(i, 0);
      if (_tilevalue[c] === undefined) {
	_tilevalue[c] = i;
      }
    }
  }

  // width: returns the map width.
  public function get width():int
  {
    return _bitmap.width;
  }
  // height: returns the map height.
  public function get height():int
  {
    return _bitmap.height-1;
  }

  // getRawTile(x, y): returns the tile of a pixel at (x,y).
  public function getRawTile(x:int, y:int):int
  {
    if (x < 0 || _bitmap.width <= x || 
	y < 0 || _bitmap.height-1 <= y) {
      return -1;
    }
    var c:uint = _bitmap.getPixel(x, y+1);
    return _tilevalue[c];
  }

  public function getTile(x:int, y:int):int
  {
    var i:int = getRawTile(x, y);
    if (Tile.isCovered(i)) {
      var row:Array = _dirtmap[y];
      if (row[x]) i = Tile.DIRT;
    }
    return i;
  }

  // digTile(x, y): set the tile value of pixel at (x,y).
  public function digTile(x:int, y:int):Boolean
  {
    if (x < 0 || _bitmap.width <= x || 
	y < 0 || _bitmap.height-1 <= y) {
      return false;
    }
    var row:Array = _dirtmap[y];
    if (row[x]) {
      row[x] = 0;
      return true;
    }
    return false;
  }

  // digTileByRect(r)
  public function digTileByRect(r:Rectangle):Boolean
  {
    var dug:Boolean = false;
    r = getCoordsByRect(r);
    for (var y:int = r.top; y < r.bottom; y++) {
      for (var x:int = r.left; x < r.right; x++) {
	dug = dug || digTile(x, y);
      }
    }
    return dug;
  }

  // isTile(x, y, f): true if the tile at (x,y) has a property given by f.
  public function isTile(x:int, y:int, f:Function):Boolean
  {
    return f(getTile(x, y));
  }
  
  // scanTile(x0, y0, x1, y1, f): returns a list of tiles that has a given property.
  //  Note: This function scans the map sequentially and is O(w*h).
  //        Use this only if an exact position of each item is needed.
  //        For a "if-exists" query, use hasTile().
  public function scanTile(x0:int, y0:int, x1:int, y1:int, f:Function):Array
  {
    var a:Array = new Array();
    var t:int;
    // assert(x0 <= x1);
    if (x1 < x0) {
      t = x0; x0 = x1; x1 = t;
    }
    // assert(y0 <= y1);
    if (y1 < y0) {
      t = y0; y0 = y1; y1 = t;
    }
    for (var y:int = y0; y <= y1; y++) {
      for (var x:int = x0; x <= x1; x++) {
	if (f(getTile(x, y))) {
	  a.push(new Point(x, y));
	}
      }
    }
    return a;
  }

  // getTilePoint(x, y): converts a point in the map to screen space.
  public function getTilePoint(x:int, y:int):Point
  {
    return new Point(x*tilesize+tilesize/2, y*tilesize+tilesize/2);
  }

  // getTileRect(x, y): converts an area in the map to screen space.
  public function getTileRect(x:int, y:int, w:int=1, h:int=1):Rectangle
  {
    return new Rectangle(x*tilesize, y*tilesize, w*tilesize, h*tilesize);
  }

  // getCoordsByPoint(p): converts a screen position to map coordinates.
  public function getCoordsByPoint(p:Point):Point
  {
    var x:int = Math.floor(p.x/tilesize);
    var y:int = Math.floor(p.y/tilesize);
    return new Point(x, y);
  }

  // getCoordsByRect(r): converts a screen area to a map range.
  public function getCoordsByRect(r:Rectangle):Rectangle
  {
    var x0:int = Math.floor(r.left/tilesize);
    var y0:int = Math.floor(r.top/tilesize);
    var x1:int = Math.floor((r.right+tilesize-1)/tilesize);
    var y1:int = Math.floor((r.bottom+tilesize-1)/tilesize);
    return new Rectangle(x0, y0, x1-x0, y1-y0);
  }

  // scanTileByRect(r): returns a list of tiles that has a given property.
  public function scanTileByRect(r:Rectangle, f:Function):Array
  {
    r = getCoordsByRect(r);
    return scanTile(r.left, r.top, r.right-1, r.bottom-1, f);
  }

  // hasTileByRect(r):
  public function hasTileByRect(r:Rectangle, f:Function):Boolean
  {
    return (scanTileByRect(r, f).length != 0);
  }

  // getCollisionByRect(r, vx, vy, f): 
  //   adjusts vector (vx,vy) so that the rectangle doesn't collide with a tile specified by f.
  public function getCollisionByRect(r:Rectangle, vx:int, vy:int, f:Function):Point
  {
    var src:Rectangle = r.union(Utils.moveRect(r, vx, vy));
    var a:Array = scanTileByRect(src, f);
    var v:Point = new Point(vx, vy);
    for each (var p:Point in a) {
      var t:Rectangle = getTileRect(p.x, p.y);
      t.y += 1;
      t.height -= 1;
      v = Utils.collideRect(t, r, v);
    }
    return v;
  }

  // hasCollisionByRect
  public function hasCollisionByRect(r:Rectangle, vx:int, vy:int, f:Function):Boolean
  {
    var v:Point = getCollisionByRect(r, vx, vy, f);
    return (v.x != vx || v.y != vy);
  }

}

} // package
