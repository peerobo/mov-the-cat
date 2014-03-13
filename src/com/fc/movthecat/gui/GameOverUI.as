package com.fc.movthecat.gui 
{
	import com.fc.air.base.BaseButton;
	import com.fc.air.base.BaseJsonGUI;
	import com.fc.air.base.font.BaseBitmapTextField;
	import com.fc.air.Util;
	import com.fc.movthecat.Constants;
	import com.fc.movthecat.MTCUtil;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import starling.events.Event;
	import starling.filters.BlurFilter;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class GameOverUI extends BaseJsonGUI 
	{
		private var titleShadow:BlurFilter;
		private var glow:BlurFilter;
		public var lbl:TextField;
		public var charBt:BaseButton;
		public var playBt:BaseButton;
		public var homeBt:BaseButton;
		public var gameOverTxt:BaseBitmapTextField;
		
		public function GameOverUI() 
		{
			super("GameOverUI");
			
			titleShadow = BlurFilter.createDropShadow();
			titleShadow.cache();
			glow = BlurFilter.createGlow(0x0,1,2,1);
		}
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
			
			lbl.filter = titleShadow;
			gameOverTxt.filter = glow;
			
			charBt.setCallbackFunc(onChar);
			playBt.setCallbackFunc(onPlayGame);
			homeBt.setCallbackFunc(onHome);
		}
		
		private function onHome():void 
		{
			dispatchEventWith(MTCUtil.EVENT_ON_HOME);
		}
		
		private function onChar():void 
		{
			dispatchEventWith(MTCUtil.EVENT_ON_PICK_CHAR);
		}

		private function onPlayGame():void 
		{
			dispatchEventWith(MTCUtil.EVENT_ON_PLAYGAME);
		}
	}

}