package com.fc.movthecat.screen 
{
	import com.fc.air.base.BaseButton;
	import com.fc.air.base.BFConstructor;
	import com.fc.air.base.Factory;
	import com.fc.air.base.font.BaseBitmapTextField;
	import com.fc.air.base.GameService;
	import com.fc.air.base.GlobalInput;
	import com.fc.air.base.LangUtil;
	import com.fc.air.base.LayerMgr;
	import com.fc.air.base.ScreenMgr;
	import com.fc.air.base.SoundManager;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.air.comp.TileImage;
	import com.fc.air.FPSCounter;
	import com.fc.air.res.Asset;
	import com.fc.air.res.ResMgr;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.BackgroundAsset;
	import com.fc.movthecat.asset.ButtonAsset;
	import com.fc.movthecat.asset.FontAsset;
	import com.fc.movthecat.asset.MTCAsset;
	import com.fc.movthecat.asset.SoundAsset;
	import com.fc.movthecat.config.CatCfg;
	import com.fc.movthecat.Constants;
	import com.fc.movthecat.gui.CenterMainUI;
	import com.fc.movthecat.gui.CharSelectorUI;
	import com.fc.movthecat.logic.GameSession;
	import com.fc.movthecat.logic.Player;
	import com.fc.movthecat.MTCUtil;
	import flash.geom.Rectangle;
	import flash.system.System;
	import starling.animation.DelayedCall;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.filters.BlurFilter;
	import starling.filters.FragmentFilter;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class MainScreen extends LoopableSprite 
	{
		private var character:MovieClip;
		private var needPlayIntro:Boolean;
		private var tweenChar:Tween;
		
		//private var centerUI:CenterMainUI;
		//private var characterShadow:FragmentFilter;
		private var randomPlayerCall:DelayedCall;
		private var bg:TileImage;
		private var cloudBg:TileImage;	
		private var charUI:CharSelectorUI;
		
		public function MainScreen() 
		{
			super();
			needPlayIntro = true;
			//centerUI = new CenterMainUI();
			//centerUI.addEventListener(MTCUtil.EVENT_ON_PLAYGAME, onPlayGame);
			//characterShadow = BlurFilter.createDropShadow();
			SoundManager.playSound(SoundAsset.THEME_SONG, true);			
			charUI = new CharSelectorUI();
			charUI.addEventListener(MTCUtil.EVENT_ON_PICK_CHAR, onPlayGame);	
			var highscoreDB:GameService = Factory.getInstance(GameService);			
			if (Util.isIOS)
				highscoreDB.initGameCenter();
			else if (Util.isAndroid)
				highscoreDB.initGooglePlayGameService();
		}
		
		//private function onPlayGame(e:Event):void 
		//{						
			/*var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
			//centerUI.flatten();			
			globalInput.setDisableTimeout(1);
			//Starling.juggler.tween(centerUI, 1, { y: -Util.appHeight, onComplete: onHideUI } );
			//Starling.juggler.remove(randomPlayerCall);
			var charScreen:CharacterSelectScreen = Factory.getInstance(CharacterSelectScreen);
			charScreen.addChild(bg);			
			charScreen.addChild(cloudBg);
			//charScreen.addChild(centerUI);			
			ScreenMgr.showScreen(CharacterSelectScreen);*/
			
			/*Starling.juggler.remove(randomPlayerCall);
			
			character = MTCUtil.getGameMVWithScale(MTCAsset.MV_CHAR_IDLE, character);
			if (character.scaleX < 1)
				character.smoothing = TextureSmoothing.TRILINEAR;
			else
				character.smoothing = TextureSmoothing.NONE;
			
			character.fps = 4;			
			character.play();	
			
			var gameScreen:GameScreen = Factory.getInstance(GameScreen);
			gameScreen.addChild(bg);			
			gameScreen.addChild(cloudBg);
			gameScreen.addChild(centerUI);
			gameScreen.addChild(character);
			ScreenMgr.showScreen(GameScreen);*/
		//}
		
		private function onHideUI():void 
		{
			//centerUI.removeFromParent();			
			charUI.removeFromParent();
		}

		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);						
			playIntro();
			//centerUI.buildGUI();
			//centerUI.unflatten();
			//centerUI.x = Util.appWidth - centerUI.width >> 1;
			//var desY:int = Util.appHeight - centerUI.height >> 1;
			//centerUI.y = -centerUI.height;
			//addChild(centerUI);
			//Starling.juggler.tween(
				//centerUI,
				//2,
				//{
					//y: desY,
					//transition: Transitions.EASE_OUT_BOUNCE
				//}
			//)
		}
		
		private function playIntro():void 
		{
			if (needPlayIntro)
			{
				var resMgr:ResMgr = Factory.getInstance(ResMgr);
				var tex:Texture = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY);
				var tileImages:TileImage = Factory.getObjectFromPool(TileImage);
				tileImages.scale = Constants.GAME_SCALE * Starling.contentScaleFactor;
				tileImages.draw(tex, Util.appWidth, Util.appHeight);			
				bg = tileImages;
				cloudBg = MTCUtil.getRandomCloudBG();			
				addChildAt(cloudBg, 0);
				addChildAt(bg, 0);
				needPlayIntro = false;
			}			
			charUI.buildGUI();
			charUI.x = Util.appWidth - charUI.width >> 1;
			var desY:int = Util.appHeight - charUI.height >> 1;
			charUI.y = Util.appHeight;
			addChild(charUI);
			Starling.juggler.tween(
				charUI,
				2,
				{
					y: desY,
					transition: Transitions.EASE_OUT_BOUNCE
				}
			)
			
			//randomNPCs();
			
		}
		
		private function onPlayGame(e:Event):void 
		{
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);		
			globalInput.setDisableTimeout(2);
			
			var char:MovieClip = Factory.getObjectFromPool(MovieClip);
			Asset.cloneMV(charUI.char, char);
			var rec:Rectangle = Factory.getObjectFromPool(Rectangle);
			charUI.char.getBounds(Starling.current.stage, rec);
			char.play();
			char.x = rec.x;
			char.y = rec.y;
			Starling.juggler.add(char);
			Factory.toPool(rec);
			var charIdx:int = charUI.charIdx;						
			var charCfg:CatCfg = Factory.getInstance(CatCfg);
			MTCUtil.setCatCfg(charIdx, charCfg);
			var gameSession:GameSession = Factory.getInstance(GameSession);
			gameSession.foodType = charIdx;
			var character:Player = Factory.getInstance(Player);
			character.w = charCfg.width;
			character.weight = charCfg.weight;
			character.speed = charCfg.speed;			
			charUI.removeFromParent();
			var gameScreen:GameScreen = Factory.getInstance(GameScreen);
			gameScreen.addChild(getChildAt(0));			
			gameScreen.addChild(getChildAt(0));
			gameScreen.addChild(char);
			ScreenMgr.showScreen(GameScreen);
		}
		
		//private function randomNPCs():void 
		//{						
			//var changeAnimation:Boolean = true;
			//var rnd:int = Util.getRandom(100);
			//if (changeAnimation)
			//{
				//if(character)
				//{
					//Factory.toPool(character);
					//character.removeFromParent();
				//}
				//if (rnd < 30)
				//{
					//character = MTCUtil.getGameMVWithScale(MTCAsset.MV_CHAR_IDLE);
				//}
				//else if (rnd < 60)
				//{
					//character = MTCUtil.getGameMVWithScale(MTCAsset.MV_CHAR_JUMP);
				//}
				//else 
				//{
					//character = MTCUtil.getGameMVWithScale(MTCAsset.MV_CHAR_WALK);
				//}				
			//}
			//var rndX:int = Math.random() * (Util.appWidth - character.width - 20);
			//var rndY:int = Math.random() * (Util.appHeight - character.height - 20);
			//character.filter = characterShadow;			
			//character.touchable = false;
			//character.x = rndX;
			//character.y = rndY;
			//addChild(character);
			//character.fps = 2;
			//character.play();
			//randomPlayerCall = Starling.juggler.delayCall(randomNPCs, 5);
		//}		
		
	}

}