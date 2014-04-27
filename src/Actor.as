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
  // Event types.
  public static const DIE:String = "Actor.DIE";

  // Topleft position.
  public var pos:Point;
  // Character boundary (relative to pos).
  public var frame:Rectangle;

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
    frame = new Rectangle(0, 0, scene.tilesize, scene.tilesize);
  }

  // active: true if the actor is already uncovered on a map.
  public function get active():Boolean // 
  {
    return _active;
  }

  // skin: actual Flash object to display.
  public function get skin():Bitmap
  {
    return _skin;
  }
  public function set skin(v:Bitmap):void
  {
    var src:Rectangle = new Rectangle(0, 0, v.width, v.height);
    _skin.bitmapData.copyPixels(v.bitmapData, src, new Point());
  }

  // scene: the container object.
  public function get scene():Scene
  {
    return _scene;
  }

  // bounds: the character boundary (in the world)
  public function get bounds():Rectangle
  {
    return new Rectangle(pos.x+frame.x, pos.y+frame.y, 
			 frame.width, frame.height);
  }
  public function set bounds(value:Rectangle):void
  {
    frame = new Rectangle(value.x-pos.x, value.y-pos.y,
			  value.width, value.height);
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
  public virtual function update():void
  {
  }

}

} // package
