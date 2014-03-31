package com.fc.movthecat.gui 
{
	import com.fc.air.base.BaseButton;
	import com.fc.air.base.BaseJsonGUI;
	import com.fc.air.base.BFConstructor;
	import com.fc.air.base.EffectMgr;
	import com.fc.air.base.Factory;
	import com.fc.air.base.font.BaseBitmapTextField;
	import com.fc.air.base.GameService;
	import com.fc.air.base.GlobalInput;
	import com.fc.air.base.LangUtil;
	import com.fc.air.base.SoundManager;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.FontAsset;
	import com.fc.movthecat.asset.IconAsset;
	import com.fc.movthecat.asset.SoundAsset;
	import com.fc.movthecat.Constants;
	import com.fc.movthecat.logic.GameSession;
	import com.fc.movthecat.MTCUtil;
	import flash.geom.Point;
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
		private var itemTxt:BaseBitmapTextField;
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
			best = gameService.getHighscore(MTCUtil.HIGHSCORE);
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
			facebookBt.setCallbackFunc(onFB);
			twitterBt.setCallbackFunc(onTwitter);
			leaderboardBt.setCallbackFunc(onLeaderboard);
		}
		
		private function onLeaderboard():void 
		{
			SoundManager.playSound(SoundAsset.SOUND_CLICK);
		}
		
		private function onTwitter():void 
		{
			SoundManager.playSound(SoundAsset.SOUND_CLICK);
		}
		
		private function onFB():void 
		{
			SoundManager.playSound(SoundAsset.SOUND_CLICK);
		}
		
		private function onMoreGame():void 
		{
			SoundManager.playSound(SoundAsset.SOUND_CLICK);
			Util.showMoreGames();
		}
		
		private function onHome():void 
		{
			gameOverTxt.text = LangUtil.getText("score");
			Util.g_replaceAndColorUp(gameOverTxt, ["@score", "@best"], ["--", "--"], [0xFF8040, 0xFFFF80]);
			SoundManager.playSound(SoundAsset.SOUND_CLICK);
			dispatchEventWith(MTCUtil.EVENT_ON_HOME);
		}
		
		private function onChar():void 
		{
			gameOverTxt.text = LangUtil.getText("score");
			Util.g_replaceAndColorUp(gameOverTxt, ["@score", "@best"], ["--", "--"], [0xFF8040, 0xFFFF80]);
			SoundManager.playSound(SoundAsset.SOUND_CLICK);
			dispatchEventWith(MTCUtil.EVENT_ON_PICK_CHAR);
		}

		private function onPlayGame():void 
		{
			gameOverTxt.text = LangUtil.getText("score");
			Util.g_replaceAndColorUp(gameOverTxt, ["@score", "@best"], ["--", "--"], [0xFF8040, 0xFFFF80]);
			SoundManager.playSound(SoundAsset.SOUND_CLICK);
			dispatchEventWith(MTCUtil.EVENT_ON_PLAYGAME);			
		}
		
		public function get score():int 
		{
			return _score;
		}
		
		public function set score(value:int):void 
		{
			_score = value / 10;			
			itemTxt.text = "x " + value.toString();
			gameOverTxt.text = LangUtil.getText("score");			
			best = best < _score ? _score : best;
			Util.g_replaceAndColorUp(gameOverTxt, ["@score", "@best"], [_score.toString(), best.toString()], [0xFF8040, 0xFFFF80]);
		}
		
		public function showScore():void
		{
			_score = 0;
			var gameSession:GameSession = Factory.getInstance(GameSession);			
			var texName:String = IconAsset.ICO_FOOD_PREFIX + gameSession.foodType;
			itemTxt = BFConstructor.getTextField(500, 140, "", FontAsset.GEARHEAD, 0xFFFFFF);
			addChild(itemTxt);			
			var image:DisplayObject = MTCUtil.getGameImageWithScale(texName);			
			image.height = 140;
			image.scaleX = image.scaleY;
			image.x = this.width - (image.width + itemTxt.width) >> 1;
			image.y = lbl.y + lbl.height;
			itemTxt.x = image.x + image.width;
			itemTxt.y = image.y;
			addChild(image);
			itemTxt.text = " x " + gameSession.foodNum;
			Util.tweenWithTimer(this, { score: gameSession.foodNum }, null, onComplete );			
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
			globalInput.disable = true;
		}
		
		private function onComplete(obj:Object,props:Object):void 
		{
			var txtText:TextField = BFConstructor.getShortTextField(itemTxt.width, itemTxt.height, itemTxt.text, FontAsset.GEARHEAD, 0xFFFF00);
			txtText.alpha = 1;
			txtText.x = itemTxt.x;
			txtText.y = itemTxt.y;
			addChild(txtText);
			var gameSession:GameSession = Factory.getInstance(GameSession);			
			if (gameSession.foodNum > 0)
			{
				var destPt:Point = new Point(charBt.x, charBt.y);
				var interPt:Point = new Point(this.width, this.height / 2);
				EffectMgr.interpolate(txtText, destPt, interPt, 0.8);
			}
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
			globalInput.disable = false;
			var gameService:GameService = Factory.getInstance(GameService);
			gameService.setHighscore(MTCUtil.HIGHSCORE,best);
		}
		
	}

}
