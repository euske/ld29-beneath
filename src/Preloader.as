package {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.StageScaleMode;
import flash.display.StageAlign;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.getDefinitionByName;

//  Preloader
//
public class Preloader extends MovieClip
{
  public static const PROGRESS_COLOR:uint = 0xeeeeee;
  public static const BYTES_TOTAL:uint = 5000000;

  private var _progress:Shape;
  
  public function Preloader():void 
  {
    stage.scaleMode = StageScaleMode.NO_SCALE;
    stage.align = StageAlign.TOP_LEFT;

    _progress = new Shape();
    _progress.graphics.beginFill(0, 0);
    _progress.graphics.drawRect(0, 0, stage.stageWidth/2, 8);
    _progress.x = (stage.stageWidth - _progress.width)/2;
    _progress.y = (stage.stageHeight - _progress.height)/2;
    addChild(_progress);

    addEventListener(Event.ENTER_FRAME, onEnterFrame);
    loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
    loaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
    loaderInfo.addEventListener(Event.COMPLETE, onComplete);
  }

  private function onError(e:IOErrorEvent):void 
  {
    trace(e.text);
  }
  
  private function onProgress(e:ProgressEvent):void 
  {
    trace("bytesLoaded: "+e.bytesLoaded+"/"+e.bytesTotal);
    var total:uint = (e.bytesTotal)? e.bytesTotal : BYTES_TOTAL;
    var p:Number = (e.bytesLoaded / total);
    _progress.graphics.beginFill(PROGRESS_COLOR);
    _progress.graphics.drawRect(0, 0, Math.floor(_progress.width*p), 8);
  }

  private function onComplete(e:Event):void 
  {
    trace("complete");
    loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
    loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
    loaderInfo.removeEventListener(Event.COMPLETE, onComplete);
  }

  private function onEnterFrame(e:Event):void
  {
    if (currentFrame == totalFrames) {
      removeEventListener(Event.ENTER_FRAME, onEnterFrame);
      stop();
      removeChild(_progress);
      var mainClass:Class = getDefinitionByName("Main") as Class;
      addChild(new mainClass() as DisplayObject);
    }
  }

}

} // package
