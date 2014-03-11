package com.fc.movthecat.screen 
{
	import com.fc.air.base.BaseButton;
	import com.fc.air.base.BFConstructor;
	import com.fc.air.base.Factory;
	import com.fc.air.base.font.BaseBitmapTextField;
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
	import com.fc.movthecat.Constants;
	import com.fc.movthecat.gui.CenterMainUI;
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
		
		private var centerUI:CenterMainUI;
		private var characterShadow:FragmentFilter;
		private var randomPlayerCall:DelayedCall;
		private var bg:TileImage;
		private var cloudBg:TileImage;
		
		public function MainScreen() 
		{
			super();
			needPlayIntro = false;
			centerUI = new CenterMainUI();
			centerUI.addEventListener(MTCUtil.EVENT_ON_PLAYGAME, onPlayGame);
			loadTextureAtlas();
			characterShadow = BlurFilter.createDropShadow();
			SoundManager.playSound(SoundAsset.THEME_SONG, true);			
			
		}
		
		private function onPlayGame(e:Event):void 
		{			
			//removeChild(centerUI);
			//LayerMgr.getLayer(LayerMgr.LAYER_TOOLTIP).addChild(centerUI);
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
			centerUI.flatten();			
			globalInput.setDisableTimeout(2);
			Starling.juggler.tween(centerUI, 2, { y: -Util.appHeight, onComplete: onHideUI } );
			
			Starling.juggler.remove(randomPlayerCall);
			
			character = MTCUtil.getGameMVWithScale(MTCAsset.MV_CHAR_IDLE, character);
			character.fps = 2;
			character.play();	
			
			var gameScreen:GameScreen = Factory.getInstance(GameScreen);
			gameScreen.addChild(bg);			
			gameScreen.addChild(cloudBg);
			gameScreen.addChild(centerUI);
			gameScreen.addChild(character);
			ScreenMgr.showScreen(GameScreen);
		}
		
		private function onHideUI():void 
		{
			centerUI.removeFromParent();			
		}
		
		private function loadTextureAtlas():void 
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			resMgr.loadTextureAtlas(MTCAsset.MTC_TEX_ATLAS, loadTAProgress);
		}
		
		private function loadTAProgress(progress:Number):void 
		{
			if (progress == 1)
			{				
				needPlayIntro = true;
			}
		}
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);						
		}
		
		override public function update(time:Number):void 
		{
			super.update(time);
			if (needPlayIntro)
			{						
				playIntro();
				needPlayIntro = false;
			}			
		}
		
		private function playIntro():void 
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			var tex:Texture = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY);
			var tileImages:TileImage = Factory.getObjectFromPool(TileImage);
			tileImages.scale = Constants.GAME_SCALE * Starling.contentScaleFactor;
			tileImages.draw(tex, Util.appWidth, Util.appHeight);			
			bg = tileImages;
			cloudBg = MTCUtil.getRandomCloudBG();			
			addChild(bg);
			addChild(cloudBg);
			
			centerUI.buildGUI();
			centerUI.x = Util.appWidth - centerUI.width >> 1;
			var desY:int = Util.appHeight - centerUI.height >> 1;
			centerUI.y = -centerUI.height;
			addChild(centerUI);
			Starling.juggler.tween(
				centerUI,
				2,
				{
					y: desY,
					transition: Transitions.EASE_OUT_BOUNCE
				}
			)			
			
			randomNPCs();
		}
		
		private function randomNPCs():void 
		{						
			var changeAnimation:Boolean = true;
			var rnd:int = Util.getRandom(100);
			if (changeAnimation)
			{
				if(character)
				{
					Factory.toPool(character);
					character.removeFromParent();
				}
				if (rnd < 30)
				{
					character = MTCUtil.getGameMVWithScale(MTCAsset.MV_CHAR_IDLE);
				}
				else if (rnd < 60)
				{
					character = MTCUtil.getGameMVWithScale(MTCAsset.MV_CHAR_JUMP);
				}
				else 
				{
					character = MTCUtil.getGameMVWithScale(MTCAsset.MV_CHAR_WALK);
				}				
			}
			var rndX:int = Math.random() * (Util.appWidth - character.width - 20);
			var rndY:int = Math.random() * (Util.appHeight - character.height - 20);
			character.filter = characterShadow;			
			character.touchable = false;
			character.x = rndX;
			character.y = rndY;
			addChild(character);
			character.fps = 2;
			character.play();
			randomPlayerCall = Starling.juggler.delayCall(randomNPCs, 5);
		}		
		
	}

}