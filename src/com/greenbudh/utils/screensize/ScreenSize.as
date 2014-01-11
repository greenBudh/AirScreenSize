/**
 * Created by bojamunje on 30.12.13..
 * credits to users on adobe forums
 * http://forums.adobe.com/message/3713696
 */
package com.greenbudh.utils.screensize {
import flash.display.Screen;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Rectangle;

public class ScreenSize {
    private var _stage:Stage;
    private var _onAddedToStageHandler:Function;
    private var _onResizeHandler:Function;
    private var _initHandler:Function;
    private var _root:Sprite;

    public function ScreenSize(root:Sprite,initHandler:Function,onAddedToStageHandler:Function = null,onResizeHandler:Function = null) {
        _stage = root.stage;
        _root = root;
        _initHandler = initHandler;
        _onAddedToStageHandler = onAddedToStageHandler;
        _onResizeHandler = onResizeHandler;
        root.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

    }
    private var _resizeEventFiredOnceAlready:Boolean;
    private var _stageWidth:Number; // Don't get confused: for our use, we mean the SHORTEST visible screen length for the app, irrespective of device orientation.  Think of the app being in portrait mode (unlike in Sierakowski's blog)
    private var _stageHeight:Number; // LONGEST visible screen length for the app.

    private function onAddedToStage(evt:Event):void
    {
        _root.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage); // remove this handler
        _onAddedToStageHandler && _onAddedToStageHandler(evt);
        // Below: we only do this once, when the app starts, since another one of this may be instanced later, possibly.
        if (!_resizeEventFiredOnceAlready)
        {
            // Below: we don't want to add (and build) our graphic assets to (based on)
            // a stretched stage.
            // Rather, we want to build them at the right size, which means we will need
            // to know the device screen size in a moment...

            _stage.align = StageAlign.TOP_LEFT;
            // Above: if there is a top status bar, top_left is nevertheless right below it, so we're good...

            _stage.scaleMode = StageScaleMode.NO_SCALE;
            // Above: needs to be set to no_scale, otherwise the resive event, below, won't fire when the app window changes its
            // its width or height.  That's a how the RESIZE event is supposed to work.
            // The default, otherwise, is "SHOW_ALL", which stretches the stage to fit within the window, but does not theorically
            // fire the resize event, though it does on iOS ( but not on Android, which is the correct behavior ) *
            // * I wished Adobe would fix these inconsistencies...

            _stage.addEventListener(Event.RESIZE, onResize);
        }
        else
            _initHandler();
    }


    private function onResize(evt:Event):void
    {
        _stage.removeEventListener(Event.RESIZE, onResize); // remove this handler
        _onResizeHandler && _onResizeHandler(evt);
        _resizeEventFiredOnceAlready = true;

        // Determine screen size so that we can properly construct our UI...
        //
        // The problem with fullScreenWidth/Height is that it gives the entire
        // screen dimension, including the area occupied by optional status bars
        // (in cases where user set <fullScreen>false</fullScreen>, in the app manifest)
        // as well as the non-optional (so I read in this thread from sigman.pl) virtual Android buttons bar,
        // on some devices (ex: Xoom w/ Android 3.0).
        //
        // These status and buttons bars have the potential of causing important UI widgets
        // to be partially hidden, so we need to size our app so that it fits nicely within
        // the visible area of the screen: hence the use of Screen.mainScreen.visibleBounds.
        //
        // However, when debugging the app on a computer (CTRL+Enter in Flash CS5),
        // Screen.visibleBounds returns the area of the desktop, not the area within the flash window,
        // so that's annoying (note: Screen.screens doesn't work as of this writing *).  Also, there is no guarantee that in the
        // future,mobile OSes might not be able to start apps in a 'minimized' mode (like a computer),
        // so we will use Math.min to address both issues, below.
        // * Another important unfinished loose end from Adobe
        //
        // Note: stage.stageWidth/Height would have returned the stage dimensions as was set in CS5,
        // regardless of what scaleMode is set at ( scaleMode only affects what the stage looks like,
        // stretched or not, on the device, but does not affect the values returned by stageWidth/Height ).


         var _screenBounds:Rectangle = Screen.mainScreen.visibleBounds;

        _stageWidth = Math.min( _stage.fullScreenWidth, _screenBounds.width );
        _stageHeight = Math.min( _stage.fullScreenHeight, _screenBounds.height );



        _stageWidth =_stage.fullScreenWidth;
        _stageHeight =_stage.fullScreenHeight; //uncoment on emulator


        // Above: fullScreenWidth and _screenBounds.width always refer to the same side of the screen,
        // on any OS and device AFIK, so we're comparing apples to apples.


        // Apparently, according to Sierakowski's blog (see link above), stage.fullScreenWidth isn't consistent in always giving the
        // same (shortest screen length), when the device is started in landscape mode between iOS and Android *.
        // Anyway, let's make sure we always get the shortest screen length:
        // * Another Adobe loose end, though I believe this has been fixed in 3.1 (maybe even earlier).

        var temp:Number = _stageWidth;
        _stageWidth = Math.min( _stageWidth, _stageHeight );
        _stageHeight = Math.max( temp, _stageHeight );
        // Above: now _stageWidth is always the shortest screen length / and _stageHeight the longest one, irrespective
        // of if we started the app in landscape mode or not.  We could now swap the 2 at this point, based on device orientation,
        // but at least we know what is what.


        // Rest of your code
        _initHandler();
    }

    public function get stageWidth():Number {
        return _stageWidth;
    }

    public function get stageHeight():Number {
        return _stageHeight;
    }
}
}
