package com.fc.movthecat
{
	import com.fc.air.base.Factory;
	import com.fc.air.base.GameService;
	import com.fc.air.FPSCounter;
	import com.fc.air.Util;
	import com.fc.movthecat.gui.CharSelectorUI;
	import com.fc.movthecat.screen.MainScreen;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DProfile;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.setTimeout;
	import starling.core.Starling;
	/**
	 * ...
	 * @author ndp
	 */
	[SWF(frameRate = "40", backgroundColor = "0x0")]
	public class Main extends Sprite
	{
		private var starling:Starling;
		private var isLaunching:Boolean;
		private var timeOut:uint;
		
		public function Main():void
		{
			stage.quality = StageQuality.LOW;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			isLaunching = true;
			
			timeOut = 0;
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;			
			
			var fps:FPSCounter = new FPSCounter(0, 0, 0xFFFFFF, false, 0x0, stage.fullScreenWidth, stage.fullScreenHeight);
			//addChild(fps);
			var highscoreDB:GameService = Factory.getInstance(GameService);			
			if (Util.isIOS)
			{
				highscoreDB.initGameCenter();	
			}
			CONFIG::isAndroid{
				Util.initAndroidUtility(true, onAndroidInit);
				Util.setAndroidFullscreen(true);
			}
			if (Capabilities.cpuArchitecture == "ARM")
			{
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			}			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onAppActivate);			
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onAppDeactivate);
			CONFIG::isIOS
			{								
				startStarlingFramework();				
			}
			if (Util.isDesktop)
			{
				startStarlingFramework();				
			}			
		}
		
		private function onAppDeactivate(e:Event):void
		{			
			App.ins.onAppDeactivate();
		}
		
		private function onAppActivate(e:Event):void
		{
			CONFIG::isIOS{
				if (App.ins)
				{				
					App.ins.onAppActivate();
				}
			}
			CONFIG::isAndroid {							
				if (App.ins)
				{				
					App.ins.onAppActivate();
				}
				Util.setAndroidFullscreen(true);
			}
		}
		
		CONFIG::isAndroid{		
			private function onAndroidInit():void 
			{
				if (isLaunching)
				{
					if (Util.androidVersionInt >= Util.KITKAT)
					{	
						Starling.handleLostContext = true;						
					}
					else 
					{
						Starling.handleLostContext = false;						
					}	
					startStarlingFramework();
					var gS:GameService = Factory.getInstance(GameService);			
					gS.initGooglePlayGameService();
				}
			}
		}
		
		private function startStarlingFramework():void
		{
			if (!starling)
			{				
				FPSCounter.log("start starling");
				var sw:int = stage.stageWidth;
				var sh:int = stage.stageHeight;
				if (Util.isDesktop)
				{
					sw = stage.fullScreenWidth;
					sh = stage.fullScreenHeight;
				}
				
				CONFIG::isIOS {
					sw = stage.fullScreenWidth;
					sh = stage.fullScreenHeight;
				}
				
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

}