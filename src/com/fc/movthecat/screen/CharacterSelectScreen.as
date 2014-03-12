package com.fc.movthecat.screen 
{
	import com.fc.air.base.Factory;
	import com.fc.air.base.GlobalInput;
	import com.fc.air.base.ScreenMgr;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.MTCAsset;
	import com.fc.movthecat.gui.CharSelectorUI;
	import com.fc.movthecat.MTCUtil;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.textures.TextureSmoothing;
	/**
	 * ...
	 * @author ndp
	 */
	public class CharacterSelectScreen extends LoopableSprite
	{
		private var charUI:CharSelectorUI;
		private var character:MovieClip;
		public function CharacterSelectScreen() 
		{
			charUI = new CharSelectorUI();
			charUI.addEventListener(MTCUtil.EVENT_ON_PICK_CHAR, onPlayGame);
			
		}
		
		private function onPlayGame(e:Event):void 
		{
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);		
			globalInput.setDisableTimeout(2);
			Starling.juggler.tween(charUI, 2, { y: -Util.appHeight, onComplete: onHideUI } );
			
			character = MTCUtil.getGameMVWithScale(MTCAsset.MV_CHAR_IDLE, character);
			if (character.scaleX < 1)
				character.smoothing = TextureSmoothing.TRILINEAR;
			else
				character.smoothing = TextureSmoothing.NONE;
			
			character.fps = 4;			
			character.play();	
			
			var gameScreen:GameScreen = Factory.getInstance(GameScreen);
			//gameScreen.addChild(bg);			
			//gameScreen.addChild(cloudBg);
			gameScreen.addChild(character);
			ScreenMgr.showScreen(GameScreen);
		}
		
		private function onHideUI():void 
		{
			charUI.removeFromParent();
		}
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);		
			globalInput.setDisableTimeout(3);
			
			charUI.buildGUI();
			charUI.x = Util.appWidth - charUI.width >> 1;
			var desY:int = Util.appHeight - charUI.height >> 1;
			charUI.y = Util.appHeight;
			addChild(charUI);
			Starling.juggler.tween(
				charUI,
				3,
				{
					y: desY,
					transition: Transitions.EASE_OUT_BOUNCE
				}
			)	
		}
		
	}

}