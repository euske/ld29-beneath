 package {

import flash.events.EventDispatcher;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

//  Actor
//
public class Actor extends EventDispatcher
{
  // Center position.
  public var pos:Point;

  private var _skin:Bitmap;
  private var _active:Boolean;
  private var _scene:Scene;

  // SkinSet image:
  [Embed(source="../assets/skinset.png", mimeType="image/png")]
  private static const SkinsetImageCls:Class;
  private static const skinsetImage:Bitmap = new SkinsetImageCls();

  // Actor(scene)
  public function Actor(scene:Scene)
  {
    _scene = scene;
    _active = false;
    _skin = new Bitmap(new BitmapData(scene.tilesize, scene.tilesize));
    _skin.visible = false;
    pos = new Point(0, 0);
  }

  // scene: the container object.
  public function get scene():Scene
  {
    return _scene;
  }

  // active: true if the actor is already uncovered on a map.
  public function get active():Boolean // 
  {
    return _active;
  }

  // bounds: the character hitbox (in the world)
  public virtual function get bounds():Rectangle
  {
    return new Rectangle(pos.x-_scene.tilesize/2, 
			 pos.y-_scene.tilesize/2,
			 _scene.tilesize, 
			 _scene.tilesize);
  }

  // skin: actual Flash object to display.
  public function get skin():Bitmap
  {
    return _skin;
  }

  // skinBounds: Character boundary (relative to pos).
  public function get skinBounds():Rectangle
  {
    return new Rectangle(-_scene.tilesize/2, -_scene.tilesize/2, 
			 scene.tilesize, scene.tilesize);
  }

  // move(dx, dy)
  public function move(dx:int, dy:int):void
  {
    pos = Utils.movePoint(pos, dx, dy);
  }

  // getMovedBounds(dx, dy)
  public function getMovedBounds(dx:int, dy:int):Rectangle
  {
    return Utils.moveRect(bounds, dx, dy);
  }

  // getMovableDistance(v0, hitx, hity)
  //   Moves the actor by v0 until it hits something (determined by hitx and hity).
  //   Return: the amount the character moved.
  //   NOTICE: v0 is altered! (it will have the remaining amount.)
  public function getMovableDistance(v0:Point, hitx:Function, hity:Function):Point
  {
    // v1: the amount that the character actually moved.
    var v1:Point = new Point();
    var t:Point;

    // try moving diagonally first.
    t = scene.tilemap.getCollisionByRect(bounds, //=getMovedBounds(v1.x,v1.y), 
					 v0.x, v0.y, hity);
    v1.x += t.x;
    v1.y += t.y;
    v0.x -= t.x;
    v0.y -= t.y;

    // try moving left/right.
    t = scene.tilemap.getCollisionByRect(getMovedBounds(v1.x,v1.y), 
					 v0.x, 0, hitx);
    v1.x += t.x;
    v1.y += t.y;
    v0.x -= t.x;
    v0.y -= t.y;

    // try moving up/down.
    t = scene.tilemap.getCollisionByRect(getMovedBounds(v1.x,v1.y), 
					 0, v0.y, hity);
    v1.x += t.x;
    v1.y += t.y;
    v0.x -= t.x;
    v0.y -= t.y;

    return v1;
  }

  // setSkinId: changes the character apparence.
  public function setSkinId(i:int):void
  {
    var src:Rectangle = new Rectangle(i*scene.tilesize, 0, scene.tilesize, scene.tilesize);
    _skin.bitmapData.copyPixels(skinsetImage.bitmapData, src, new Point());
  }

  // isMovable(dx, dy)
  public virtual function isMovable(dx:int, dy:int):Boolean
  {
    return scene.maprect.containsRect(getMovedBounds(dx, dy));
  }

  // activate(): called when the actor is uncovered.
  public virtual function activate():void
  {
    _active = true;
    _skin.visible = true;
  }

  // collide(actor): called when the actor is colliding with another actor.
  public virtual function collide(actor:Actor):void
  {
  }

  // update(): called at every frame.
  public virtual function update(phase:int):void
  {
  }

}

} // package
