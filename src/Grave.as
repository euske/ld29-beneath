package {

import flash.display.Bitmap;
import flash.geom.Point;
import flash.geom.Rectangle;

//  Grave
// 
public class Grave extends Actor
{
  private var _skin2:Bitmap

  public function Grave(scene:Scene, skin2:Bitmap)
  {
    super(scene);
    _skin2 = skin2;
  }

  public function collect():void
  {
    skin = _skin2;
    scene.remove(this);
  }
  
}

} // package
