package {

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

public class MaskMap
{
  public var width:int;
  public var height:int;
  public var tilesize:int;

  private var _map:Array;

  // MaskMap(width, height)
  public function MaskMap(width:int, height:int, tilesize:int)
  {
    this.width = width;
    this.height = height;
    this.tilesize = tilesize;

    _map = new Array(height);
    for (var y:int = 0; y < _map.length; y++) {
      var row:Array = new Array(width);
      for (var x:int = 0; x < row.length; x++) {
	row[x] = 0;
      }
      _map[y] = row;
    }
  }

  // getMask(x, y): returns the tile of a pixel at (x,y).
  public function getMask(x:int, y:int):int
  {
    if (0 <= y && y < _map.length) {
      var row:Array = _map[y];
      if (0 <= x && x < row.length) {
	return row[x];
      }
    }
    return -1;
  }

  // setMask(x, y): set the tile value of pixel at (x,y).
  public function setMask(x:int, y:int, m:int):void
  {
    if (0 <= y && y < _map.length) {
      var row:Array = _map[y];
      if (0 <= x && x < row.length) {
	row[x] = m;
      }
    }
  }

  // getMaskByRect(r): maximum mask value
  public function getMaskByRect(r:Rectangle):int
  {
    r = getCoordsByRect(r);
    var m:int = -1;
    for (var y:int = r.top; y < r.bottom; y++) {
      for (var x:int = r.left; x < r.right; x++) {
	m = Math.max(m, getMask(x, y));
      }
    }
    return m;
  }

  // setMaskByRect(r): 
  public function setMaskByRect(r:Rectangle, m:int):void
  {
    r = getCoordsByRect(r);
    for (var y:int = r.top; y < r.bottom; y++) {
      for (var x:int = r.left; x < r.right; x++) {
	setMask(x, y, m);
      }
    }
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
}

} // package
