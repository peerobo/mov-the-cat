package com.fc.movthecat.screen 
{
	import com.fc.air.base.Factory;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.movthecat.logic.LevelStage;
	import starling.events.Event;
	/**
	 * ...
	 * @author ndp
	 */
	public class GameScreen extends LoopableSprite
	{
		
		public function GameScreen() 
		{
			
		}
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
			
			var stage:LevelStage = Factory.getInstance(LevelStage);
			stage.construct();
		}
		
	}

}