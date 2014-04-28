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

  public var changed:Boolean;

  // bitmap: actual bitmap to hold the 2D array.
  private var _bitmap:BitmapData;
  // dirtmap:
  private var _dirtmap:BitmapData;

  // _mapvalue: lookup table from a pixel color to a type number.
  private var _mapvalue:Dictionary;
  private function convertValues(bitmap:BitmapData):BitmapData
  {
    bitmap = bitmap.clone();
    for (var y:int = 0; y < bitmap.height; y++) {
      for (var x:int = 0; x < bitmap.width; x++) {
	var c:uint = bitmap.getPixel(x, y);
	bitmap.setPixel(x, y, _mapvalue[c]);
      }
    }
    return bitmap;
  }

  // TileMap(tilesize)
  public function TileMap(tilesize:int)
  {
    this.tilesize = tilesize;

    // Construct a lookup table.
    // The color value at a pixel at (i,0) is used as i-th type.
    _mapvalue = new Dictionary();
    for (var i:uint = 0; i < 256; i++) {
      var c:uint = (((i*11)%256) << 16) | (((i*22+33)%256) << 8) | ((i*33+44)%256);
      _mapvalue[c] = i;
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
    return _bitmap.height;
  }

  // setBitmap(bitmap, dirtmap)
  public function setBitmap(bitmap:BitmapData, dirtmap:BitmapData):void
  {
    _bitmap = convertValues(bitmap);
    _dirtmap = convertValues(dirtmap);
    changed = true;
  }

  // getRawTile(x, y): returns the tile of a pixel at (x,y).
  public function getRawTile(x:int, y:int):int
  {
    if (x < 0 || _bitmap.width <= x || 
	y < 0 || _bitmap.height <= y) {
      return -1;
    }
    return _bitmap.getPixel(x, y);
  }

  // getDirtTile(x, y)
  public function getDirtTile(x:int, y:int):int
  {
    if (x < 0 || _dirtmap.width <= x || 
	y < 0 || _dirtmap.height <= y) {
      return -1;
    }
    return _dirtmap.getPixel(x, y);
  }

  // digTile(x, y): set the tile value of pixel at (x,y).
  public function digTile(x:int, y:int):Boolean
  {
    var i:int = getDirtTile(x, y);
    if (!Tile.isDiggable(i)) return false;
    _dirtmap.setPixel(x, y, 0);
    changed = true;
    return true;
  }

  // digTileByRect(r)
  public function digTileByRect(r:Rectangle):int
  {
    var dug:int = 0;
    r = getCoordsByRect(r);
    for (var y:int = r.top; y < r.bottom; y++) {
      for (var x:int = r.left; x < r.right; x++) {
	if (digTile(x, y)) {
	  dug++;
	}
      }
    }
    return dug;
  }

  // getTile(x, y)
  public function getTile(x:int, y:int):int
  {
    var i:int = getRawTile(x, y);
    if (Tile.isUndiggable(i)) return Tile.UNDIGGABLE;
    var j:int = getDirtTile(x, y);
    return (j != 0)? j : i;
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
      var i:int = getTile(p.x, p.y);
      var t:Rectangle = Tile.getRect(i).clone();
      t.x = p.x*tilesize;
      t.y = p.y*tilesize;
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
