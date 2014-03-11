package com.fc.movthecat.logic
{
	import com.fc.air.base.Factory;
	import com.fc.air.FPSCounter;
	import com.fc.movthecat.screen.GameScreen;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.Image;
	
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
		private var scroll2Stage:Boolean;
		
		public function GameSession()
		{
			interval = 0.033;
			timePass = 0;
		}
		
		public function loop():void
		{
			if (input.keyPress != UserInput.NONE_KEY) // move player
			{
				var isLeft:Boolean = input.keyPress == UserInput.LEFT_KEY;
				var currBound:Rectangle = visibleScreen.player.tryMoving(isLeft);
				var canMove:Boolean = true;
				var str:String = "";
				//canMove &&= visibleScreen.blockMap.checkEmpty(currBound.top, currBound.left);
				//str += "top-left " + currBound.top + " " + currBound.left + " " + canMove;
				canMove &&= visibleScreen.blockMap.checkEmpty(currBound.bottom, currBound.right);				
				canMove &&= visibleScreen.blockMap.checkEmpty(currBound.bottom, currBound.left);				
				//canMove &&= visibleScreen.blockMap.checkEmpty(currBound.top, currBound.right);
				//str += "\ntop-right " + canMove;
				if (canMove) // move left right
				{
					visibleScreen.player.move(isLeft);					
				}
				Factory.toPool(currBound);					
			}
			// check character free fall
			var check:Boolean = true;
			var b:Rectangle = visibleScreen.player.getBound();
			if (!helperPoint)
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
				check &&= visibleScreen.blockMap.checkEmpty(destY, i);
			}
			if (check) // continue falling
				visibleScreen.player.y += gravitySpeed * visibleScreen.player.weight;
			// scroll whole stage
			if (visibleScreen.blockMap.anchorPt != null) 
			{
				if (visibleScreen.blockMap.anchorPt.y >= visibleScreen.blockMap.gameWindow.y)
				{
					visibleScreen.blockMap.validate();
					visibleScreen.blockMap.anchorPt.y -= visibleScreen.blockMap.gameWindow.y;
					visibleScreen.player.y -= visibleScreen.blockMap.gameWindow.y;
					scroll2Stage = false;					
				}
				visibleScreen.blockMap.anchorPt.y += scrollSpeed;				
			}
			Factory.toPool(b);
			if (!scroll2Stage && visibleScreen.checkPlayerOut())
			{
				//FPSCounter.log("player",visibleScreen.player.y, visibleScreen.player.x);
				gameOver();
			}
			System.pauseForGCIfCollectionImminent(1);
		}
		
		public function startNewGame():void
		{
			var rec:Rectangle;
			// create stage
			if (!visibleScreen)
			{
				visibleScreen = Factory.getInstance(VisibleScreen);
				visibleScreen.blockMap.calculateScreenViaLevelStage();
				rec = Factory.getObjectFromPool(Rectangle);
				rec.x = 0;
				rec.width = visibleScreen.blockMap.col;
				rec.y = 2;
				rec.height = visibleScreen.blockMap.row - rec.y - 3;
				visibleScreen.blockMap.gameWindow = rec;
			}
			// construct level
			visibleScreen.blockMap.lvlStage.construct();
			// init player position
			visibleScreen.player.x = visibleScreen.blockMap.col >> 1;
			visibleScreen.player.y = -visibleScreen.blockMap.row;			
			rec = Factory.getObjectFromPool(Rectangle);
			rec.setTo(0, 0, visibleScreen.player.wInPixel, visibleScreen.player.hInPixel);
			var recBlock:Rectangle = visibleScreen.blockMap.pixelToBlock(rec);
			visibleScreen.player.h = recBlock.height;
			visibleScreen.player.w = recBlock.width;			
			visibleScreen.blockMap.anchorPt.x = 0;
			visibleScreen.blockMap.anchorPt.y = visibleScreen.player.y;
			visibleScreen.blockMap.validate();
			visibleScreen.player.weight = 1;
			visibleScreen.player.speed = 0.25;
			Factory.toPool(rec);
			Factory.toPool(recBlock);
			// init world
			scrollSpeed = 0.2;
			gravitySpeed = 1;
			// start receive user input
			input = Factory.getInstance(UserInput);
			input.start();
			// add to loop
			timePass = 0;
			scroll2Stage = true;
			visibleScreen.needRender = true;
			Starling.juggler.add(this);
		}
		
		public function gameOver():void
		{
			visibleScreen.needRender = false;
			var gameScreen:GameScreen = Factory.getInstance(GameScreen);
			gameScreen.gameOver();
			Starling.juggler.remove(this);
		}
		
		/* INTERFACE starling.animation.IAnimatable */
		
		public function advanceTime(time:Number):void
		{
			timePass += time;
			if (timePass >= interval)
			{
				loop();
				timePass -= interval;
			}
		}
	}

}