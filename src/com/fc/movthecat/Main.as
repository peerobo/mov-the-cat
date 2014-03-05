package com.fc.movthecat
{
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DProfile;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import starling.core.Starling;
	/**
	 * ...
	 * @author ndp
	 */
	[SWF(frameRate="60",backgroundColor="0x0")]
	
	public class Main extends Sprite
	{
		private var starling:Starling;
		
		public function Main():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			//stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			startStarlingFramework();
			if (Capabilities.cpuArchitecture == "ARM")
			{
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			}
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onAppExit);
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onAppActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onAppDeactivate);
		}
		
		private function onAppDeactivate(e:Event):void
		{
			starling.stop(true);
			App.ins.onAppDeactivate();
		}
		
		private function onAppActivate(e:Event):void
		{
			if (App.ins)
			{
				starling.start();
				App.ins.onAppActivate();
			}
		}
		
		private function onAppExit(e:Event):void
		{
			if (App.ins)
			{
				App.ins.onAppExit();
			}
		}
		
		private function startStarlingFramework():void
		{
			var sw:int = stage.fullScreenWidth;
			var sh:int = stage.fullScreenHeight;
			
			var maxSize:int = sw < sh ? sh : sw;
			var minSize:int = sw < sh ? sw : sh;
			var w:int;
			var h:int;
			var needExtended:Boolean = false;
			if (minSize <= 320)
			{
				w = sw / 0.25;
				h = sh / 0.25;
			}
			else if (minSize <= 480)
			{
				w = sw / 0.375;
				h = sh / 0.375;
			}
			else if (minSize <= 800)
			{
				w = sw / 0.5;
				h = sh / 0.5;
			}
			else if (minSize <= 1080)
			{
				w = sw / 0.75;
				h = sh / 0.75;
			}
			else
			{
				w = sw;
				h = sh;
				needExtended = true;
			}
			
			if (needExtended)
				starling = new Starling(App, stage, new Rectangle(0, 0, sw, sh), null, "auto", Context3DProfile.BASELINE_EXTENDED);
			else
				starling = new Starling(App, stage, new Rectangle(0, 0, sw, sh));
			starling.stage.stageWidth = w;
			starling.stage.stageHeight = h;
			starling.start();			
		}
	
	}

}