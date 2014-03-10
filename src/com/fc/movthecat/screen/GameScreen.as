package com.fc.movthecat.screen
{
	import com.fc.air.base.Factory;
	import com.fc.air.base.SoundManager;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.air.comp.TileImage;
	import com.fc.air.Util;
	import com.fc.movthecat.logic.GameSession;
	import com.fc.movthecat.logic.LevelStage;
	import com.fc.movthecat.MTCUtil;
	import com.fc.movthecat.screen.game.GameRender;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class GameScreen extends LoopableSprite
	{
		private var cloudBG:DisplayObject;
		private var nextCloudBg:DisplayObject;
		private var character:DisplayObject;
		private var gameRender:GameRender;
		
		public function GameScreen()
		{
		
		}
		
		override public function onAdded(e:Event):void
		{
			super.onAdded(e);
			
			cloudBG = getChildAt(1);
			character = getChildAt(3);
					
			nextCloudBg = MTCUtil.getRandomCloudBG();
			nextCloudBg.y = Util.appHeight;
			addChildAt(nextCloudBg,2);
			Starling.juggler.tween(cloudBG, 2, {y: -Util.appHeight, onComplete:onCloudVanished, transition:Transitions.EASE_OUT});			
			Starling.juggler.tween(nextCloudBg, 2, { y: 0 } );
			Starling.juggler.tween(character, 2, { x: Util.appWidth - character.width >> 1, y: 100, transition:Transitions.EASE_OUT, onComplete: onCharacterDone } );
			
			SoundManager.instance.muteMusic = true;
		}
		
		private function onCharacterDone():void 
		{
			var logic:GameSession = Factory.getInstance(GameSession);
			logic.startNewGame();
			gameRender = Factory.getInstance(GameRender);			
			gameRender.setCharacter(character);
			addChild(gameRender);
		}
		
		private function onCloudVanished():void 
		{			
			cloudBG.removeFromParent();
			Factory.toPool(cloudBG);
			cloudBG = nextCloudBg;
			//nextCloudBg = MTCUtil.getRandomCloudBG();
			//nextCloudBg.y = Util.appHeight;
			//addChildAt(nextCloudBg,2);
			//Starling.juggler.tween(cloudBG, 5, {y: -Util.appHeight, onComplete:onCloudVanished});			
			//Starling.juggler.tween(nextCloudBg, 5, { y: 0 } );
		}
	
	}

}