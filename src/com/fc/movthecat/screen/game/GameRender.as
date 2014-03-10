package com.fc.movthecat.screen.game 
{
	import com.fc.air.base.Factory;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.movthecat.logic.VisibleScreen;
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class GameRender extends LoopableSprite 
	{
		private var character:DisplayObject;
		private var visibleScreen:VisibleScreen;
		
		private var brickDispList:Array;
		private var scroll2Stage:Boolean;
		
		public function GameRender() 
		{
			super();
			brickDispList = [];
			visibleScreen = Factory.getInstance(VisibleScreen);
		}
		
		public function setCharacter(disp:DisplayObject):void
		{
			character = disp;
			addChild(character);
		}
		
		override public function update(time:Number):void 
		{
			super.update(time);
			
			if (visibleScreen.blockMap.anchorPt.y < 0 || scroll2Stage)
			{
				scroll2Stage = true;
				if (visibleScreen.blockMap.anchorPt.y >= 2)
				{
					scroll2Stage = false;
				}
			}			
			else
			{
				var rec:Rectangle = visibleScreen.blockMap.gameWindow;
			}
			
		}
		
	}

}