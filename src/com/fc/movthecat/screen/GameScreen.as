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
	import com.fc.air.res.Asset;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.BackgroundAsset;
	import com.fc.movthecat.asset.FontAsset;
	import com.fc.movthecat.asset.MTCAsset;
	import com.fc.movthecat.asset.SoundAsset;
	import com.fc.movthecat.Constants;
	import com.fc.movthecat.gui.GameOverUI;
	import com.fc.movthecat.gui.QuoteUI;
	import com.fc.movthecat.logic.GameSession;
	import com.fc.movthecat.logic.LevelStage;
	import com.fc.movthecat.MTCUtil;
	import com.fc.movthecat.screen.game.GameRender;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.system.System;
	import flash.utils.ByteArray;
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
		private const PLAYBACK_SPEED:Number = 1.5;
		private const BUFFER:int = 4096;
		private var sndCh:SoundChannel;
		private var cloudBG:DisplayObject;
		private var nextCloudBg:DisplayObject;
		private var character:MovieClip;
		private var gameRender:GameRender;
		private var soundDiamond:Sound;
		private var prevSoundEff:int;
		private var currentByteSoundEff:ByteArray;
		private var soundPos:Number;
		private var catIsOnHigh:Boolean;
		private var numSoundSamples:int;
		private var gameOverUI:GameOverUI;
		private var mvLeft:MovieClip;
		private var mvRight:MovieClip;
		private var currSource:Sound;
		private var sequentialReadSound:Boolean;
		private var totalSoundLength:Number;
		private const BYTE_PER_FRAME:int = 5000;
		private var currentWriteByte:Number;
		
		public function GameScreen()
		{
			charIdx = -1;
			prevSoundEff = -1;
		}
		
		override public function onAdded(e:Event):void
		{
			super.onAdded(e);
			
			cloudBG = getChildAt(1);
			character = getChildAt(2) as MovieClip;
			
			nextCloudBg = MTCUtil.getRandomCloudBG();
			nextCloudBg.y = Util.appHeight;
			addChildAt(nextCloudBg, 2);
			Starling.juggler.tween(cloudBG, 3, {y: -Util.appHeight, onComplete: onCloudVanished, transition: Transitions.EASE_OUT});
			Starling.juggler.tween(nextCloudBg, 3, {y: 0});
			Starling.juggler.tween(character, 3, {y: 100, transition: Transitions.EASE_OUT, onComplete: onCharacterDone});
			
			mvRight = MTCUtil.getGameMVWithScale(MTCAsset.MV_HAND, null, 1.5);
			mvRight.alpha = 0.8;
			mvRight.fps = 0.75;
			mvRight.play();
			mvRight.currentFrame = 0;
			addChild(mvRight);
			mvRight.x = (Util.appWidth + (Util.appWidth >> 1) >> 1);
			mvRight.y = Util.appHeight >> 1;
			Starling.juggler.tween(character, 1.3, {x: Util.appWidth - character.width >> 1, delay: 1.5, onStart: onSwitchCharacterSize, onComplete: onTutDone});
			
			mvLeft = MTCUtil.getGameMVWithScale(MTCAsset.MV_HAND, null, 1.5);
			mvLeft.alpha = 0.8;
			mvLeft.currentFrame = 1;
			mvLeft.fps = 0.75;
			mvLeft.play();
			mvLeft.scaleX = -mvLeft.scaleX;
			addChild(mvLeft);
			mvLeft.x = (Util.appWidth - (Util.appWidth >> 1) >> 1);
			mvLeft.y = Util.appHeight >> 1;
			onSwitchCharacterSize();
			Starling.juggler.tween(character, 1.5, {x: character.width});
			
			SoundManager.instance.muteMusic = true;
			var gSession:GameSession = Factory.getInstance(GameSession);
			if (charIdx != gSession.foodType)
			{
				SoundManager.instance.removeSound(SoundAsset.BG_MUSIC_PREFIX + charIdx + SoundAsset.FILE_TYPE);
				charIdx = gSession.foodType;
				var url:String = SoundAsset.BG_MUSIC_PREFIX + charIdx + SoundAsset.FILE_TYPE;
				SoundManager.instance.queueSound(url, url);
				SoundManager.instance.loadAll(playSpecificTheme);
			}
			else
			{
				playCharacterTheme();
			}
		}
		
		override public function update(time:Number):void 
		{
			super.update(time);
			if(sequentialReadSound)
			{								
				var lenNumber:Number = BYTE_PER_FRAME > totalSoundLength - currentWriteByte ? totalSoundLength-currentWriteByte : BYTE_PER_FRAME;
				currSource.extract(currentByteSoundEff, lenNumber,currentWriteByte);
				currentWriteByte += lenNumber;
				if(currentWriteByte >= totalSoundLength)
				{					
					numSoundSamples = currentByteSoundEff.length / 8;					
					//sndCh = soundDiamond.play();					
					sequentialReadSound = false;
				}				
			}
		}
		
		private function onSwitchCharacterSize():void
		{
			character.scaleX = -character.scaleX;
			if (character.scaleX < 0)
				character.x += character.width;
			else
				character.x -= character.width;
		}
		
		private function onTutDone():void
		{
			if (mvLeft)
			{
				Factory.toPool(mvLeft);
				Factory.toPool(mvRight);
				mvLeft.removeFromParent();
				mvRight.removeFromParent();
				mvLeft = null;
				mvRight = null;
			}
		}
		
		private function playSpecificTheme(progress:Number):void
		{
			if (progress == 1)
				sndCh = SoundManager.instance.playSound(SoundAsset.BG_MUSIC_PREFIX + charIdx + SoundAsset.FILE_TYPE, false, int.MAX_VALUE);
					
			if (!soundDiamond)
			{
				soundDiamond = new Sound();
				soundDiamond.addEventListener(SampleDataEvent.SAMPLE_DATA, onSoundDiamondProcess);
			}
			if (prevSoundEff != charIdx)
			{
				sequentialReadSound = true;
				currSource = SoundManager.getSound(SoundAsset.BG_MUSIC_PREFIX + charIdx + SoundAsset.FILE_TYPE);
				totalSoundLength = currSource.length * 44.1;
				currentByteSoundEff = new ByteArray();
				currentWriteByte = 0;				
				prevSoundEff = charIdx;
			}
		}
		
		public function gameOver():void
		{		
			if (catIsOnHigh)
				disableEffectSound();
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
			Starling.juggler.tween(gameOverUI, 2, {y: desY, transition: Transitions.EASE_OUT_BOUNCE, onComplete: transitionDone})
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
			Starling.juggler.tween(gameOverUI, 1, {y: -Util.appHeight, onComplete: onHideUI});
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
			Starling.juggler.tween(gameOverUI, 1, {y: -Util.appHeight, onComplete: onHideUI});
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
			Starling.juggler.tween(gameOverUI, 2, {y: -Util.appHeight, onComplete: onHideUI});
			
			nextCloudBg = MTCUtil.getRandomCloudBG();
			nextCloudBg.y = Util.appHeight;
			addChildAt(nextCloudBg, 2);
			Starling.juggler.tween(cloudBG, 2, {y: -Util.appHeight, onComplete: onCloudVanished, transition: Transitions.EASE_OUT});
			Starling.juggler.tween(nextCloudBg, 2, {y: 0});
			Starling.juggler.tween(character, 2, {x: Util.appWidth - character.width >> 1, y: 100, transition: Transitions.EASE_OUT, onComplete: onCharacterDone});
			
			//SoundManager.instance.muteMusic = true;
			gameRender.reset();
			//addButtons();
		}
		
		private function addButtons():void
		{
			var bts:Array = [];
			var bt:BGText = new BGText();
			bt.setText(FontAsset.GEARHEAD, LangUtil.getText("moveLeft"), BackgroundAsset.BG_BOX);
			bt.alpha = 0.8;
			bt.scaleX = bt.scaleY = 0.7;
			bt.touchable = false;
			addChild(bt);
			bt.y = Util.appHeight - bt.height;
			bt.x = 0;
			bts.push(bt);
			bt = new BGText();
			bt.setText(FontAsset.GEARHEAD, LangUtil.getText("moveRight"), BackgroundAsset.BG_BOX);
			bt.alpha = 0.8;
			bt.scaleX = bt.scaleY = 0.7;
			bt.touchable = false;
			addChild(bt);
			Util.g_centerScreen(bt);
			bt.x = Util.appWidth - bt.width;
			bt.y = Util.appHeight - bt.height;
			bts.push(bt);
			Starling.juggler.delayCall(removeBts, 5, bts);
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
			CONFIG::isAndroid
			{
				Util.showBannerAd();
			}
		}
		
		override public function onRemoved(e:Event):void
		{
			super.onRemoved(e);
			if (sndCh)
				sndCh.stop();
			sndCh = null;
			SoundManager.instance.muteMusic = false;
		}
		
		public function playCharacterTheme():void
		{
			sndCh = SoundManager.instance.playSound(SoundAsset.BG_MUSIC_PREFIX + charIdx + SoundAsset.FILE_TYPE, false, int.MAX_VALUE);
		}
		
		public function activateEffectSound():void
		{			
			catIsOnHigh = true;
			currentByteSoundEff.position = 0;
			soundPos = 0;
			sndCh.stop();
			sndCh = soundDiamond.play();
		}
		
		public function disableEffectSound():void 
		{
			sndCh.stop();
			catIsOnHigh = false;
			playCharacterTheme();			
		}
		
		private function onSoundDiamondProcess(e:SampleDataEvent):void
		{
			var l:Number;
			var r:Number;
			
			var outputLength:int = 0;
			while (outputLength < BUFFER)
			{
				// until we have filled up enough output buffer
				
				// move to the correct location in our loaded samples ByteArray
				currentByteSoundEff.position = int(soundPos) * 8; // 4 bytes per float and two channels so the actual position in the ByteArray is a factor of 8 bigger than the phase
				
				// read out the left and right channels at this position
				l = currentByteSoundEff.readFloat();
				r = currentByteSoundEff.readFloat();
				
				// write the samples to our output buffer
				e.data.writeFloat(l);
				e.data.writeFloat(r);
				
				outputLength++;
				
				// advance the phase by the speed...
				soundPos += PLAYBACK_SPEED;
				
				// and deal with looping (including looping back past the beginning when playing in reverse)
				if (soundPos < 0)
				{
					soundPos += numSoundSamples;
				}
				else if (soundPos >= numSoundSamples)
				{
					soundPos -= numSoundSamples;
				}
			}
		}
		
		private function onCloudVanished():void
		{
			cloudBG.removeFromParent();
			Factory.toPool(cloudBG);
			cloudBG = nextCloudBg;
		}
	
	}

}