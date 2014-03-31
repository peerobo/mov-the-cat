package com.fc.movthecat.gui 
{
	import com.fc.air.base.BaseButton;
	import com.fc.air.base.BaseJsonGUI;
	import com.fc.air.base.Factory;
	import com.fc.air.base.font.BaseBitmapTextField;
	import com.fc.air.base.GameService;
	import com.fc.air.base.LangUtil;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.IconAsset;
	import com.fc.movthecat.Constants;
	import com.fc.movthecat.logic.GameSession;
	import com.fc.movthecat.MTCUtil;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import starling.display.DisplayObject;
	import starling.display.Image;
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
		public var btMoreGame:BaseButton;
		public var gameOverTxt:BaseBitmapTextField;
		private var _score:int;
		public var twitterBt:BaseButton;
		public var facebookBt:BaseButton;
		public var leaderboardBt:BaseButton;
		public var best:int;
		
		public function GameOverUI() 
		{
			super("GameOverUI");
			
			titleShadow = BlurFilter.createDropShadow();
			titleShadow.cache();
			glow = BlurFilter.createGlow(0x0, 1, 2, 1);
			var gameService:GameService = Factory.getInstance(GameService);
			//gameService.getHighscore
		}
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
			
			lbl.filter = titleShadow;
			gameOverTxt.filter = glow;			
			gameOverTxt.text = LangUtil.getText("score");
			Util.g_replaceAndColorUp(gameOverTxt, ["@score", "@best"], ["0", "0"], [0xFF8040, 0xFFFF80]);
			charBt.setCallbackFunc(onChar);
			playBt.setCallbackFunc(onPlayGame);
			btMoreGame.setCallbackFunc(onMoreGame);			
		}
		
		private function onMoreGame():void 
		{
			Util.showMoreGames();
		}
		
		private function onHome():void 
		{
			gameOverTxt.text = LangUtil.getText("gameover");
			Util.g_replaceAndColorUp(gameOverTxt, ["@score", "@best"], ["--", "--"], [0xFF8040, 0xFFFF80]);
			dispatchEventWith(MTCUtil.EVENT_ON_HOME);
		}
		
		private function onChar():void 
		{
			gameOverTxt.text = LangUtil.getText("gameover");
			Util.g_replaceAndColorUp(gameOverTxt, ["@score", "@best"], ["--", "--"], [0xFF8040, 0xFFFF80]);
			dispatchEventWith(MTCUtil.EVENT_ON_PICK_CHAR);
		}

		private function onPlayGame():void 
		{
			gameOverTxt.text = LangUtil.getText("gameover");
			Util.g_replaceAndColorUp(gameOverTxt, ["@score", "@best"], ["--", "--"], [0xFF8040, 0xFFFF80]);
			dispatchEventWith(MTCUtil.EVENT_ON_PLAYGAME);
		}
		
		public function get score():int 
		{
			return _score;
		}
		
		public function set score(value:int):void 
		{
			_score = value;
			trace(value);
			gameOverTxt.text = LangUtil.getText("score");
			Util.g_replaceAndColorUp(gameOverTxt, ["@score", "@best"], [value.toString(), "0"], [0xFF8040, 0xFFFF80]);
		}
		
		public function showScore():void
		{
			score = 0;
			var gameSession:GameSession = Factory.getInstance(GameSession);			
			//var texName:String = IconAsset.ICO_FOOD_PREFIX + gameSession.foodType;
			//var image:DisplayObject = MTCUtil.getGameImageWithScale(texName);			
			//image.height = 120;
			//image.scaleX = image.scaleY;
			//image.x = (this.width - image.width >> 1) + 200;
			//image.y = lbl.y + 360;
			//addChild(image);
			Util.tweenWithTimer(this, { score: gameSession.foodNum }, null, null );			
		}
	}

}