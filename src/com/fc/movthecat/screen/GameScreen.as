package com.fc.movthecat.screen
{
	import com.fc.air.base.Factory;
	import com.fc.air.base.GlobalInput;
	import com.fc.air.base.LangUtil;
	import com.fc.air.base.PopupMgr;
	import com.fc.air.base.ScreenMgr;
	import com.fc.air.base.SoundManager;
	import com.fc.air.comp.BGText;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.air.comp.TileImage;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.BackgroundAsset;
	import com.fc.movthecat.asset.FontAsset;
	import com.fc.movthecat.asset.SoundAsset;
	import com.fc.movthecat.Constants;
	import com.fc.movthecat.gui.GameOverUI;
	import com.fc.movthecat.gui.QuoteUI;
	import com.fc.movthecat.logic.GameSession;
	import com.fc.movthecat.logic.LevelStage;
	import com.fc.movthecat.MTCUtil;
	import com.fc.movthecat.screen.game.GameRender;
	import flash.media.SoundChannel;
	import flash.system.System;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.MovieClip;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class GameScreen extends LoopableSprite
	{
		public var charIdx:int;		
		private var sndCh:SoundChannel;
		private var cloudBG:DisplayObject;
		private var nextCloudBg:DisplayObject;
		private var character:MovieClip;
		private var gameRender:GameRender;
		
		private var gameOverUI:GameOverUI;
		
		public function GameScreen()
		{
			charIdx = -1;
		}
		
		override public function onAdded(e:Event):void
		{
			super.onAdded(e);
			
			cloudBG = getChildAt(1);
			character = getChildAt(2) as MovieClip;
					
			nextCloudBg = MTCUtil.getRandomCloudBG();
			nextCloudBg.y = Util.appHeight;
			addChildAt(nextCloudBg,2);
			Starling.juggler.tween(cloudBG, 2, {y: -Util.appHeight, onComplete:onCloudVanished, transition:Transitions.EASE_OUT});			
			Starling.juggler.tween(nextCloudBg, 2, { y: 0 } );
			Starling.juggler.tween(character, 2, { x: Util.appWidth - character.width >> 1, y: 100, transition:Transitions.EASE_OUT, onComplete: onCharacterDone } );
			
			SoundManager.instance.muteMusic = true;	
			var gSession:GameSession = Factory.getInstance(GameSession);
			if (charIdx != gSession.foodType)
			{
				SoundManager.instance.removeSound(SoundAsset.BG_MUSIC_PREFIX + charIdx + SoundAsset.FILE_TYPE);
				charIdx = gSession.foodType;
				var url:String = SoundAsset.BG_MUSIC_PREFIX + charIdx + SoundAsset.FILE_TYPE;
				SoundManager.instance.queueSound(url,url);
				SoundManager.instance.loadAll(playSpecificTheme);				
			}
			else
			{
				playCharacterTheme();
			}
		}
		
		private function playSpecificTheme(progress:Number):void 
		{
			if(progress ==1)
				sndCh = SoundManager.instance.playSound(SoundAsset.BG_MUSIC_PREFIX + charIdx + SoundAsset.FILE_TYPE, false, int.MAX_VALUE);
		}
		
		public function gameOver():void 
		{
			var quoteUI:QuoteUI = Factory.getInstance(QuoteUI);
			PopupMgr.addPopUp(quoteUI);
			if (!gameOverUI)
			{
				gameOverUI = new GameOverUI();
				gameOverUI.addEventListener(MTCUtil.EVENT_ON_PLAYGAME, onPlayGame);
				gameOverUI.addEventListener(MTCUtil.EVENT_ON_PICK_CHAR, onPickChar);
				gameOverUI.addEventListener(MTCUtil.EVENT_ON_HOME, onGoHome);
			}			
			gameOverUI.buildGUI();
			gameOverUI.x = Util.appWidth - gameOverUI.width >> 1;			
			gameOverUI.y = -gameOverUI.height;
			
			Starling.juggler.delayCall(showScore, 3);
			System.pauseForGCIfCollectionImminent(0);
		}
		
		private function showScore():void 
		{
			var quoteUI:QuoteUI = Factory.getInstance(QuoteUI);
			PopupMgr.removePopup(quoteUI);
			var desY:int = Util.appHeight - gameOverUI.height >> 1;
			addChild(gameOverUI);
			Starling.juggler.tween(
				gameOverUI,
				2,
				{
					y: desY,
					transition: Transitions.EASE_OUT_BOUNCE,
					onComplete: transitionDone					
				}
			)
		}
		
		private function flattenGOUI():void 
		{
			//gameOverUI.flatten();						
		}
		
		private function transitionDone():void 
		{
			//gameOverUI.unflatten();
			gameOverUI.showScore();			
		}
		
		private function onGoHome(e:Event):void 
		{
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);		
			globalInput.setDisableTimeout(1);
			Starling.juggler.tween(gameOverUI, 1, { y: -Util.appHeight, onComplete: onHideUI } );			
			var manScr:MainScreen = Factory.getInstance(MainScreen);
			manScr.addChild(getChildAt(0));			
			manScr.addChild(getChildAt(0));
			manScr.addChild(gameOverUI);			
			ScreenMgr.showScreen(MainScreen);
		}
		
		private function onPickChar(e:Event):void 
		{
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
			//centerUI.flatten();			
			globalInput.setDisableTimeout(1);
			Starling.juggler.tween(gameOverUI, 1, { y: -Util.appHeight, onComplete: onHideUI } );			
			var charScreen:MainScreen = Factory.getInstance(MainScreen);
			charScreen.addChild(getChildAt(0));			
			charScreen.addChild(getChildAt(0));
			charScreen.addChild(gameOverUI);			
			ScreenMgr.showScreen(MainScreen);
		}
		
		private function onPlayGame(e:Event):void 
		{					
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
			globalInput.setDisableTimeout(2);
			Starling.juggler.tween(gameOverUI, 2, { y: -Util.appHeight, onComplete: onHideUI } );
			
			nextCloudBg = MTCUtil.getRandomCloudBG();
			nextCloudBg.y = Util.appHeight;
			addChildAt(nextCloudBg,2);
			Starling.juggler.tween(cloudBG, 2, {y: -Util.appHeight, onComplete:onCloudVanished, transition:Transitions.EASE_OUT});			
			Starling.juggler.tween(nextCloudBg, 2, { y: 0 } );
			Starling.juggler.tween(character, 2, { x: Util.appWidth - character.width >> 1, y: 100, transition:Transitions.EASE_OUT, onComplete: onCharacterDone } );
			
			//SoundManager.instance.muteMusic = true;
			gameRender.reset();	
			addButtons();
		}
		
		private function addButtons():void
		{						
			var bts:Array = [];
			var bt:BGText = new BGText();
			bt.setText(FontAsset.GEARHEAD, LangUtil.getText("moveLeft"), BackgroundAsset.BG_BOX);
			bt.alpha = 0.3;	
			bt.scaleX = bt.scaleY = 0.7;
			bt.touchable = false;
			addChild(bt);
			bt.y = Util.appHeight - bt.height;
			bt.x = 0;				
			bts.push(bt);
			bt = new BGText();
			bt.setText(FontAsset.GEARHEAD, LangUtil.getText("moveRight"), BackgroundAsset.BG_BOX);
			bt.alpha = 0.3;
			bt.scaleX = bt.scaleY = 0.7;
			bt.touchable = false;
			addChild(bt);				
			Util.g_centerScreen(bt);				
			bt.x = Util.appWidth - bt.width;								
			bt.y = Util.appHeight - bt.height;
			bts.push(bt);
			Starling.juggler.delayCall(removeBts,5,bts);			
		}
		
		private function removeBts(btArr:Array):void 
		{
			for (var i:int = 0; i < btArr.length; i++) 
			{
				btArr[i].removeFromParent();
			}
		}
		
		private function onHideUI():void 
		{
			gameOverUI.removeFromParent();
		}
		
		private function onCharacterDone():void 
		{
			gameRender = Factory.getInstance(GameRender);			
			gameRender.setCharacter(character);
			var logic:GameSession = Factory.getInstance(GameSession);
			logic.startNewGame();	
			gameRender.reset();
			addChildAt(gameRender, 2);
			addButtons();
			CONFIG::isAndroid{
				Util.showBannerAd();
			}
		}
		
		override public function onRemoved(e:Event):void 
		{
			super.onRemoved(e);
			if(sndCh)
				sndCh.stop();
			sndCh = null;			
			SoundManager.instance.muteMusic = false;	
		}
		
		public function playCharacterTheme():void 
		{
			sndCh = SoundManager.instance.playSound(SoundAsset.BG_MUSIC_PREFIX + charIdx + SoundAsset.FILE_TYPE, false, int.MAX_VALUE);
		}
		
		private function onCloudVanished():void 
		{			
			cloudBG.removeFromParent();
			Factory.toPool(cloudBG);
			cloudBG = nextCloudBg;			
		}
	
	}

}