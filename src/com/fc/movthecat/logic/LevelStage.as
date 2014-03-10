package com.fc.movthecat.logic 
{
	import com.fc.air.FPSCounter;
	import com.fc.air.Util;
	import com.fc.movthecat.Constants;
	import starling.core.Starling;
	/**
	 * ...
	 * @author ndp
	 */
	public class LevelStage 
	{
		public var row:int;
		public var col:int;		
		public var bricks:Array;		
		public var currentMaxBlockNo:int;
		public var currentMinBlockNo:int;
		public const OUT_OF_VIEW:int = 3;
		
		public function LevelStage() 
		{					
		}
		
		public function calculateScreen():void
		{
			var sw:int = Util.appWidth;			
			var sh:int = Util.appHeight;
			row = sh / Constants.GAME_TILE_SIZE_4X + OUT_OF_VIEW; 
			col = sw / Constants.GAME_TILE_SIZE_4X;
			currentMinBlockNo = 1;
			currentMaxBlockNo = col - 1;
			bricks = [];
		}			
		
		public function deleteBricks(rowNum:int):void
		{
			var totalDeletedElem:int = rowNum * col;
			bricks.splice(0, totalDeletedElem);
			
			var currentBlocks:int = currentMinBlockNo + Util.getRandom(currentMaxBlockNo - currentMinBlockNo);
			var currentNonBlocks:int = currentMinBlockNo + Util.getRandom(col - currentBlocks - currentMinBlockNo);			
			for (var i:int = 0; i < totalDeletedElem; i++) 
			{
				if(currentBlocks > 0)
				{
					bricks[i] = true;
					currentBlocks--;				
				}
				else if ( currentNonBlocks > 0)
				{
					bricks[i] = false;
					currentNonBlocks--;
				}
				else
				{
					currentBlocks = currentMinBlockNo + Util.getRandom(currentMaxBlockNo - currentMinBlockNo);
					currentNonBlocks = currentMinBlockNo + Util.getRandom(col - currentBlocks - currentMinBlockNo);					
					
					bricks[i] = true;
					currentBlocks--;
				}
			}
		}
		
		public function construct():void
		{
			var len:int = row * col;
			var currentBlocks:int = currentMinBlockNo + Util.getRandom(currentMaxBlockNo - currentMinBlockNo);
			var currentNonBlocks:int = currentMinBlockNo + Util.getRandom(col - currentBlocks - currentMinBlockNo);			
			for (var i:int = 0; i < len; i++) 
			{
				if(currentBlocks > 0)
				{
					bricks[i] = true;
					currentBlocks--;				
				}
				else if ( currentNonBlocks > 0)
				{
					bricks[i] = false;
					currentNonBlocks--;
				}
				else
				{
					currentBlocks = currentMinBlockNo + Util.getRandom(currentMaxBlockNo - currentMinBlockNo);
					currentNonBlocks = currentMinBlockNo + Util.getRandom(col - currentBlocks - currentMinBlockNo);					
					
					bricks[i] = true;
					currentBlocks--;
				}
			}		
		}
	}

}