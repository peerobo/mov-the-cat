package com.fc.movthecat.logic
{
	import com.fc.air.base.Factory;
	import com.fc.air.base.GlobalInput;
	import com.fc.air.base.LayerMgr;
	import com.fc.air.FPSCounter;
	import com.fc.air.Util;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class UserInput
	{
		public var keyPress:int;
		
		public static const NONE_KEY:int = -1;
		public static const LEFT_KEY:int = 0;
		public static const RIGHT_KEY:int = 1;
		
		public function UserInput()
		{
			
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
			globalInput.registerKey(Keyboard.LEFT, onKeyPress);
			globalInput.registerKey(Keyboard.RIGHT, onKeyPress);
		}
		
		private function onKeyPress():void
		{
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
			if (globalInput.currDownKey == -1)
				keyPress = NONE_KEY;
			else if (globalInput.currDownKey == Keyboard.LEFT)
				keyPress = LEFT_KEY;
			else if (globalInput.currDownKey == Keyboard.RIGHT)
				keyPress = RIGHT_KEY;
		
		}
		
		public function start():void
		{
			keyPress = NONE_KEY;
			//var layerGame:Sprite = LayerMgr.getLayer(LayerMgr.LAYER_GAME);
			Starling.current.stage.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		public function stop():void
		{
			keyPress = NONE_KEY;
			//var layerGame:Sprite = LayerMgr.getLayer(LayerMgr.LAYER_GAME);
			Starling.current.stage.removeEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private function onTouch(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(Starling.current.stage);
			if (touch)
			{
				var touchPt:Point = new Point(touch.globalX, touch.globalY);
				switch (touch.phase)
				{
					//case TouchPhase.STATIONARY:
					case TouchPhase.BEGAN: 
						//case TouchPhase.MOVED:
						keyPress = touch.globalX > (Util.appWidth >> 1) ? RIGHT_KEY : LEFT_KEY;
						//FPSCounter.log("began", keyPress);
						break;
					case TouchPhase.ENDED: 
						var releaseSide:int = touch.globalX > (Util.appWidth >> 1) ? RIGHT_KEY : LEFT_KEY;
						if (releaseSide == keyPress)
							keyPress = NONE_KEY;
						//FPSCounter.log("ended", keyPress);
						break;
				}
			}
			else
			{
				//keyPress = NONE_KEY;
			}
			e.stopImmediatePropagation();
		}
	
	}

}