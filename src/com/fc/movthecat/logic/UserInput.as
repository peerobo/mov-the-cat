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
	import starling.display.Quad;
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
		private var quadInput:Quad;
		public var keyPress:int;
		
		public static const NONE_KEY:int = -1;
		public static const LEFT_KEY:int = 0;
		public static const RIGHT_KEY:int = 1;
		
		public function UserInput()
		{			
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
			globalInput.registerKey(Keyboard.LEFT, onKeyPress);
			globalInput.registerKey(Keyboard.RIGHT, onKeyPress);
			
			quadInput = new Quad(Util.appWidth, Util.appHeight, 0x0);
			quadInput.alpha = 0;
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
			LayerMgr.getLayer(LayerMgr.LAYER_EFFECT).addChild(quadInput);
			quadInput.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		public function stop():void
		{
			keyPress = NONE_KEY;
			//var layerGame:Sprite = LayerMgr.getLayer(LayerMgr.LAYER_GAME);
			quadInput.removeFromParent();
			quadInput.removeEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private function onTouch(e:TouchEvent):void
		{
			var touches:Vector.<Touch> = e.getTouches(Starling.current.stage);			
			var touch:Touch;
			for (var i:int = 0; i < touches.length; i++) 
			{
				touch = touches[i];
				if (touch)
				{
					var touchPt:Point = new Point(touch.globalX, touch.globalY);
					switch (touch.phase)
					{					
						case TouchPhase.BEGAN: 					
							keyPress = touch.globalX > (Util.appWidth >> 1) ? RIGHT_KEY : LEFT_KEY;							
							break;
						case TouchPhase.ENDED: 
							var releaseSide:int = touch.globalX > (Util.appWidth >> 1) ? RIGHT_KEY : LEFT_KEY;
							if (releaseSide == keyPress)
								keyPress = NONE_KEY;							
							break;
					}
				}
				else
				{
					//keyPress = NONE_KEY;
				}
			}
			
			e.stopImmediatePropagation();
		}
	
	}

}