package com.fc.movthecat.screen 
{
	import com.fc.air.base.Factory;
	import com.fc.air.base.GlobalInput;
	import com.fc.air.base.ScreenMgr;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.air.res.Asset;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.MTCAsset;
	import com.fc.movthecat.config.CatCfg;
	import com.fc.movthecat.gui.CharSelectorUI;
	import com.fc.movthecat.logic.Player;
	import com.fc.movthecat.MTCUtil;
	import flash.geom.Rectangle;
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
		
		public function CharacterSelectScreen() 
		{
			charUI = new CharSelectorUI();
			charUI.addEventListener(MTCUtil.EVENT_ON_PICK_CHAR, onPlayGame);
			
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
		
		private function onHideUI():void 
		{
			charUI.removeFromParent();
		}
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
	
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
		}
		
	}

}