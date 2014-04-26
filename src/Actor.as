package {

import flash.events.EventDispatcher;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

//  Actor
//
public class Actor extends EventDispatcher
{
  public static const DIE:String = "ActorEvent.DIE";

  public var pos:Point;
  public var frame:Rectangle;

  private var _skin:DisplayObject;
  private var _active:Boolean;
  private var _scene:Scene;

  // Actor(scene)
  public function Actor(scene:Scene)
  {
    _scene = scene;
    _active = false;
    pos = new Point(0, 0);
  }

  // active
  public function get active():Boolean
  {
    return _active;
  }

  // skin
  public function get skin():DisplayObject
  {
    return _skin;
  }
  public function set skin(v:DisplayObject):void
  {
    _skin = v;
    _skin.visible = _active;
  }

  // scene
  public function get scene():Scene
  {
    return _scene;
  }

  // bounds
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

  // activate
  public virtual function activate():void
  {
    _active = true;
    _skin.visible = true;
  }

  // collide(actor)
  public virtual function collide(actor:Actor):void
  {
  }

  // update()
  public virtual function update():void
  {
  }

}

} // package
