package com.fc.movthecat.gui 
{
	import com.fc.air.base.BaseButton;
	import com.fc.air.base.BaseJsonGUI;
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
		public var lbl:TextField;
		public var moreBt:BaseButton;
		public var playBt:BaseButton;
		public var rateBt:BaseButton;
		
		public function GameOverUI() 
		{
			super("GameOverUI");
			
			titleShadow = BlurFilter.createDropShadow();
			titleShadow.cache();
		}
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
			
			lbl.filter = titleShadow;
			
			moreBt.setCallbackFunc(onMoreGames);
			playBt.setCallbackFunc(onPlayGame);
			rateBt.setCallbackFunc(onRateMe);
		}
		
		private function onRateMe():void 
		{
			navigateToURL(new URLRequest(Constants.RATE_URL));
		}
		
		private function onPlayGame():void 
		{
			dispatchEventWith(MTCUtil.EVENT_ON_PLAYGAME);
		}
		
		private function onMoreGames():void 
		{
			Util.showMoreGames();
		}
		
	}

}