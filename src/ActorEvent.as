package {

import flash.events.Event;

//  ActorEvent
//
public class ActorEvent extends Event
{
  public var args:Array;
  
  public function ActorEvent(name:String, ... args)
  {
    super(name);
    this.args = args;
  }
  
}

} // package
