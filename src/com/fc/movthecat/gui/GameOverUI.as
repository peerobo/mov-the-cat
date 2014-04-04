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
	import com.fc.air.res.ResMgr;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.FontAsset;
	import com.fc.movthecat.asset.IconAsset;
	import com.fc.movthecat.asset.MTCAsset;
	import com.fc.movthecat.asset.SoundAsset;
	import com.fc.movthecat.comp.LoadingIcon;
	import com.fc.movthecat.config.CatCfg;
	import com.fc.movthecat.Constants;
	import com.fc.movthecat.logic.GameSession;
	import com.fc.movthecat.MTCUtil;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
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
		public var newScoreBt:BaseButton;
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
			newScoreBt.visible = false;
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
			
			var catCfg:CatCfg = Factory.getInstance(CatCfg);	
			var arr:Array = [playBt, btMoreGame, charBt];
			for (var i:int = 0; i < 6; i++) 
			{				
				var idx2:int = i / 2;
				var idx:int = Util.getRandom(MTCUtil.catCfgs.length);
				MTCUtil.setCatCfg(idx, catCfg);
				var char:MovieClip = MTCUtil.getGameMVWithScale(MTCAsset.MV_CAT + idx + "_", null, catCfg.scale);
				
				char.fps = catCfg.fps;
				char.play();
				char.touchable = false;
				if (i % 2 == 0)
				{
					char.scaleX = -char.scaleX;
					char.x = arr[idx2].x + char.width/2;					
				}
				else
				{
					char.x = arr[idx2].x + arr[idx2].width - char.width/2;					
				}
				char.y = arr[idx2].y + (arr[idx2].height - char.height >>1);
				addChild(char);
			}
		}
		
		private function onLeaderboard():void 
		{
			var gameService:GameService = Factory.getInstance(GameService);			
			CONFIG::isIOS {
				if(Util.internetAvailable)
				{					
					gameService.showGameCenterHighScore(MTCUtil.HIGHSCORE);				
				}
				else
				{
					EffectMgr.floatTextMessageEffectCenter(LangUtil.getText("needInternet"), 0xFF8080, 2);					
				}
			}
			CONFIG::isAndroid {
				if (Util.internetAvailable)
				{				
					gameService.showGooglePlayLeaderboard(MTCUtil.gsGetCode(MTCUtil.HIGHSCORE));
				}
				else
				{
					EffectMgr.floatTextMessageEffectCenter(LangUtil.getText("needInternet"), 0xFF8080, 2);
				}
			}
			
			SoundManager.playSound(SoundAsset.SOUND_CLICK);
		}
		
		private function onTwitter():void 
		{
			var bitmapData:BitmapData = Util.g_takeSnapshot();
			var loadingIcon:LoadingIcon = Factory.getInstance(LoadingIcon);
			loadingIcon.show();
			var msg:String = LangUtil.getText("quote" + (int(Util.getRandom(Constants.QUOTE_NUM) + 1))) + LangUtil.getText("share");
			CONFIG::isAndroid {
				Util.shareOnTTAndroid(msg, bitmapData, onDoneShare);
				Starling.juggler.delayCall(loadingIcon.close, 5);
			}
			CONFIG::isIOS {
				Util.shareOnIOS(true, msg, bitmapData);
				Starling.juggler.delayCall(loadingIcon.close, 5);
			}
			SoundManager.playSound(SoundAsset.SOUND_CLICK);
		}
		
		private function onDoneShare(shareOK:Boolean):void 
		{
			var loadingIcon:LoadingIcon = Factory.getInstance(LoadingIcon);
			loadingIcon.close();
		}
		
		private function onFB():void 
		{
			var bitmapData:BitmapData = Util.g_takeSnapshot();
			var loadingIcon:LoadingIcon = Factory.getInstance(LoadingIcon);
			loadingIcon.show();
			var msg:String = LangUtil.getText("quote" + (int(Util.getRandom(Constants.QUOTE_NUM) + 1))) + LangUtil.getText("share");
			CONFIG::isAndroid {
				Util.shareOnFBAndroid(msg, bitmapData, onDoneShare);
				Starling.juggler.delayCall(loadingIcon.close, 5);
			}
			CONFIG::isIOS {
				Util.shareOnIOS(true, msg, bitmapData);
				Starling.juggler.delayCall(loadingIcon.close, 5);
			}
			
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
			if (best < _score)
			{
				best = _score;
				newScoreBt.visible = true;
			}
			
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
			CONFIG::isAndroid{
				gameService.setHighscore(MTCUtil.gsGetCode(MTCUtil.HIGHSCORE), best);
			}
			CONFIG::isIOS {
				gameService.setHighscore(MTCUtil.HIGHSCORE, best);
			}
		}
		
	}

}
