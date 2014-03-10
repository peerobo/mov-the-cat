package com.fc.movthecat.logic 
{
	import com.fc.air.base.Factory;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	/**
	 * ...
	 * @author ndp
	 */
	public class GameSession implements IAnimatable
	{
		public var visibleScreen:VisibleScreen;
		public var input:UserInput;
		public var scrollSpeed:Number;
		public var gravitySpeed:Number;
		
		private var interval:Number;
		private var timePass:Number;
		private var helperPoint:Point;
		
		public function GameSession() 
		{
			interval = 0.033;
		}
		
		public function loop():void
		{
			if(input.keyPress != UserInput.NONE_KEY)	// move player
			{
				var isLeft:Boolean = input.keyPress == UserInput.LEFT_KEY;
				var currBound:Rectangle = visibleScreen.player.tryMoving(isLeft);
				var canMove:Boolean = true;
				canMove &&= visibleScreen.blockMap.checkEmpty(currBound.left, currBound.top);
				canMove &&= visibleScreen.blockMap.checkEmpty(currBound.right, currBound.bottom);
				canMove &&= visibleScreen.blockMap.checkEmpty(currBound.left, currBound.bottom);
				canMove &&= visibleScreen.blockMap.checkEmpty(currBound.right, currBound.top);
				if(canMove)	// move left right
				{
					visibleScreen.player.move(isLeft);										
				}
				Factory.toPool(currBound);
				// check free fall
				var check:Boolean = true;				
				var b:Rectangle = visibleScreen.player.getBound();
				if(!helperPoint)
				{
					helperPoint = new Point(b.left, b.right);
				}
				else
				{
					helperPoint.x = b.left;
					helperPoint.y = b.right;
				}	
				var destY:Number = b.bottom + gravitySpeed * visibleScreen.player.weight;
				for (var i:int = helperPoint.x; i <= helperPoint.y; i++) 
				{
					check &&= visibleScreen.blockMap.checkEmpty(i, destY);
				}
				if (check)	// continue falling
					visibleScreen.player.y += gravitySpeed * visibleScreen.player.weight;
				
			}
			if (visibleScreen.blockMap.anchorPt != null)	// scroll whole stage
			{
				if (visibleScreen.blockMap.anchorPt.y >= 2)
				{
					visibleScreen.blockMap.validate();	
					visibleScreen.blockMap.anchorPt.y = 0;
				}
				visibleScreen.blockMap.anchorPt.y += scrollSpeed;
				visibleScreen.player.y -= scrollSpeed;
							
			}
			if (visibleScreen.checkPlayerOut())
			{
				gameOver();
			}
		}
		
		public function startNewGame():void
		{
			// create stage
			if(!visibleScreen)
			{
				visibleScreen = Factory.getInstance(VisibleScreen);
				visibleScreen.blockMap.calculateScreenViaLevelStage();
				var rec:Rectangle = Factory.getObjectFromPool(Rectangle);
				rec.x = 0 ;
				rec.width = visibleScreen.blockMap.col;
				rec.y = 2;
				rec.height = visibleScreen.blockMap.row - rec.y - 3;
				visibleScreen.blockMap.gameWindow = rec;
			}
			// construct level
			visibleScreen.blockMap.lvlStage.construct();
			// init player position
			visibleScreen.player.x = visibleScreen.blockMap.col >> 1;
			visibleScreen.player.y = -visibleScreen.blockMap.row >> 1;
			visibleScreen.player.speed = 0.1;
			visibleScreen.player.weight = 1;
			visibleScreen.player.h = 0.5;
			visibleScreen.player.w = 0.5;
			visibleScreen.blockMap.anchorPt.x = 0;
			visibleScreen.blockMap.anchorPt.y = visibleScreen.player.y;
			visibleScreen.blockMap.validate();
			// init world
			scrollSpeed = 0.2;
			gravitySpeed = 0.5;
			// start receive user input
			input = Factory.getInstance(UserInput);
			input.start();			
			// add to loop
			//Starling.juggler.add(this);
		}			
		
		public function gameOver():void
		{
			Starling.juggler.remove(this);
		}
		
		/* INTERFACE starling.animation.IAnimatable */
		
		public function advanceTime(time:Number):void 
		{
			timePass += time;
			if(timePass >= interval)
			{
				loop();
				timePass -= interval;
			}
		}
	}

}