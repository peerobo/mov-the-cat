package com.fc.movthecat.screen
{
	import com.fc.air.base.Factory;
	import com.fc.air.base.GlobalInput;
	import com.fc.air.base.ScreenMgr;
	import com.fc.air.base.SoundManager;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.air.comp.TileImage;
	import com.fc.air.Util;
	import com.fc.movthecat.gui.GameOverUI;
	import com.fc.movthecat.logic.GameSession;
	import com.fc.movthecat.logic.LevelStage;
	import com.fc.movthecat.MTCUtil;
	import com.fc.movthecat.screen.game.GameRender;
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
		private var cloudBG:DisplayObject;
		private var nextCloudBg:DisplayObject;
		private var character:MovieClip;
		private var gameRender:GameRender;
		
		private var gameOverUI:GameOverUI;
		
		public function GameScreen()
		{
			
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
		}
		
		public function gameOver():void 
		{
			if (!gameOverUI)
			{
				gameOverUI = new GameOverUI();
				gameOverUI.addEventListener(MTCUtil.EVENT_ON_PLAYGAME, onPlayGame);
				gameOverUI.addEventListener(MTCUtil.EVENT_ON_PICK_CHAR, onPickChar);
				gameOverUI.addEventListener(MTCUtil.EVENT_ON_HOME, onGoHome);
			}
			gameOverUI.buildGUI();
			gameOverUI.x = Util.appWidth - gameOverUI.width >> 1;
			var desY:int = Util.appHeight - gameOverUI.height >> 1;
			gameOverUI.y = -gameOverUI.height;
			addChild(gameOverUI);
			Starling.juggler.tween(
				gameOverUI,
				2,
				{
					y: desY,
					transition: Transitions.EASE_OUT_BOUNCE
				}
			)
			SoundManager.instance.muteMusic = false;
			System.pauseForGCIfCollectionImminent(0);
		}
		
		private function onGoHome(e:Event):void 
		{
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
			//centerUI.flatten();			
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
			var charScreen:CharacterSelectScreen = Factory.getInstance(CharacterSelectScreen);
			charScreen.addChild(getChildAt(0));			
			charScreen.addChild(getChildAt(0));
			charScreen.addChild(gameOverUI);			
			ScreenMgr.showScreen(CharacterSelectScreen);
		}
		
		private function onPlayGame(e:Event):void 
		{
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
			//gameOverUI.flatten();			
			globalInput.setDisableTimeout(2);
			Starling.juggler.tween(gameOverUI, 2, { y: -Util.appHeight, onComplete: onHideUI } );
			
			nextCloudBg = MTCUtil.getRandomCloudBG();
			nextCloudBg.y = Util.appHeight;
			addChildAt(nextCloudBg,2);
			Starling.juggler.tween(cloudBG, 2, {y: -Util.appHeight, onComplete:onCloudVanished, transition:Transitions.EASE_OUT});			
			Starling.juggler.tween(nextCloudBg, 2, { y: 0 } );
			Starling.juggler.tween(character, 2, { x: Util.appWidth - character.width >> 1, y: 100, transition:Transitions.EASE_OUT, onComplete: onCharacterDone } );
			
			SoundManager.instance.muteMusic = true;
			gameRender.reset();
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
			addChild(gameRender);
		}
		
		private function onCloudVanished():void 
		{			
			cloudBG.removeFromParent();
			Factory.toPool(cloudBG);
			cloudBG = nextCloudBg;			
		}
	
	}

}