package com.fc.movthecat.screen 
{
	import com.fc.air.base.BFConstructor;
	import com.fc.air.base.Factory;
	import com.fc.air.base.font.BaseBitmapTextField;
	import com.fc.air.base.LangUtil;
	import com.fc.air.base.SoundManager;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.air.FPSCounter;
	import com.fc.air.res.Asset;
	import com.fc.air.res.ResMgr;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.FontAsset;
	import com.fc.movthecat.asset.MTCAsset;
	import com.fc.movthecat.asset.SoundAsset;
	import com.fc.movthecat.Constants;
	import com.fc.movthecat.MTCUtil;
	import flash.geom.Rectangle;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class MainScreen extends LoopableSprite 
	{
		private var character:MovieClip;
		private var tweenChar:Tween;
		
		public function MainScreen() 
		{
			super();
			
			loadTextureAtlas();
			SoundManager.playSound(SoundAsset.THEME_SONG, true);				
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
				character = MTCUtil.getGameMVWithScale(MTCAsset.MV_CHAR_IDLE);
			}
		}
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
		}
		
		override public function update(time:Number):void 
		{
			super.update(time);
			if (character && !character.parent)
			{							
				playIntro();
			}
		}
		
		private function playIntro():void 
		{
			var mainGameTitle:String = LangUtil.getText("gamename");
			var txtField:BaseBitmapTextField = BFConstructor.getShortTextField(1, 1, mainGameTitle, FontAsset.BANHMI);
			txtField.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			txtField.y = -txtField.height;
			txtField.x = Util.appWidth - txtField.width >> 1;
			addChild(txtField);
			var desY:int = (Util.appHeight - txtField.height >> 1);
			Starling.juggler.tween(
				txtField,
				2,
				{
					y: desY,
					transition: Transitions.EASE_OUT_BOUNCE
				}
			)
			var rec:Rectangle = new Rectangle(txtField.x, desY, txtField.width, txtField.height);
			
			randomNPCs();
		}
		
		private function randomNPCs():void 
		{
			var rndX:int = Math.random() * (Util.appWidth - character.width - 20);
			var rndY:int = Math.random() * (Util.appHeight - character.height - 20);			
			
			character.x = rndX;
			character.y = rndY;
			
			var changeAnimation:Boolean = true;
			var rnd:int = Math.random() * 100;
			if (changeAnimation)
			{
				
				Factory.toPool(character);
				character.removeFromParent();
				if (rnd < 30)
				{
					character = MTCUtil.getGameMVWithScale(MTCAsset.MV_CHAR_IDLE);
					FPSCounter.log("idle");
				}
				else if (rnd < 60)
				{
					character = MTCUtil.getGameMVWithScale(MTCAsset.MV_CHAR_JUMP);					
					FPSCounter.log("jump");
				}
				else 
				{
					character = MTCUtil.getGameMVWithScale(MTCAsset.MV_CHAR_WALK);					
					FPSCounter.log("walk");
				}				
			}
			addChild(character);
			character.fps = 2;
			character.play();
			Starling.juggler.delayCall(randomNPCs, 5);
		}
		
	}

}