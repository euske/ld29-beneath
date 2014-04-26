package {

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

public class DirtMap
{
  public var width:int;
  public var height:int;
  public var tilesize:int;

  private var _map:Array;

  // DirtMap(width, height)
  public function DirtMap(width:int, height:int, tilesize:int)
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

  // setMaskByRect(r): 
  public function setMaskByRect(r:Rectangle, m:int):void
  {
    var r:Rectangle = getCoordsByRect(r);
    for (var y:int = r.top; y < r.bottom; y++) {
      for (var x:int = r.left; x < r.right; x++) {
	setMask(x, y, m);
      }
    }
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
}

} // package
