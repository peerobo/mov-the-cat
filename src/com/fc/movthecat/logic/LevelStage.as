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
		
		public function LevelStage() 
		{					
		}
		
		public function calculateScreen():void
		{
			var sw:int = Util.appWidth;			
			var sh:int = Util.appHeight;
			row = sh / Constants.GAME_TILE_SIZE_4X;
			col = sw / Constants.GAME_TILE_SIZE_4X;
			currentMinBlockNo = 1;
			currentMaxBlockNo = col - 1;
			bricks = [];
			FPSCounter.log("row", row, "col", col);
		}
		
		public function construct():void
		{
			var len:int = row * col;
			var currentBlocks:int = currentMinBlockNo + Util.getRandom(currentMaxBlockNo - currentMinBlockNo);
			var currentNonBlocks:int = currentMinBlockNo + Util.getRandom(col - currentBlocks - currentMinBlockNo);
			FPSCounter.log("blocks", currentBlocks, "non blocks", currentNonBlocks);
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
					FPSCounter.log("blocks", currentBlocks, "non blocks", currentNonBlocks);
					
					bricks[i] = true;
					currentBlocks--;
				}
			}
			
			var str:String = "";
			for (var j:int = 0; j < row; j++) 
			{
				for (var k:int = 0; k < col; k++) 
				{
					str += bricks[j * col + k] ? "-" : "+";
				}
				str += "\n";
			}
			FPSCounter.log(str);
		}
	}

}