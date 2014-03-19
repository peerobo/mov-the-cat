package com.fc.movthecat.logic
{
	import com.fc.air.base.Factory;
	import com.fc.air.Util;
	import flash.display3D.textures.RectangleTexture;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class BlockMap
	{
		public var row:int;
		public var col:int;
		public var gameWindow:Rectangle;
		public var blocks:Array;
		public var lvlStage:LevelStage;
		public var anchorPt:Point;
		
		public function BlockMap()
		{
			anchorPt = new Point();
			lvlStage = Factory.getInstance(LevelStage);
			blocks = [];
		}
		
		public function calculateScreenViaLevelStage():void
		{
			lvlStage.calculateScreen();
			row = lvlStage.row * 2;
			col = lvlStage.col * 2;
			var total:int = row * col;
			for (var i:int = 0; i < total; i++)
			{
				blocks[i] = false;
			}
		}
		
		public function checkEmpty(r:int, c:int,oldY:Number = NaN):Boolean
		{			
			if (c < 0 || c >= col)
				return false;
			var idx:int = r * col + c;
			if (idx < 0 || idx > blocks.length)
				return true;			
			return !blocks[idx];
			
			//var ret:Boolean = true;
			//var startR:int = int(oldY);
			//for (var i:int = startR; i <= r; i++) 
			//{
				//var idx:int = i * col + c;
				//ret &&= (idx < 0)|| (idx > blocks.length) || !blocks[idx];
			//}
			//return ret;
		}
		
		public function fall(deltaY:Number, oldY:Number, oldX:Number):Number
		{
			var startR:int = int(oldY);
			var endR:int = int(deltaY + oldY);
			var prevY:Number = -1;
			for (var i:int = startR; i <= endR; i++) 
			{
				var idx:int = i * col + int(oldX);
				var ret:Boolean = (idx < 0)|| (idx > blocks.length) || !blocks[idx];
				if (!ret)
				{
					oldY = i-0.2;
					return oldY;
				}
				
			}		
			oldY += deltaY;
			return oldY;
		}
		
		public function pixelToBlock(r:Rectangle):Rectangle
		{
			var blockW:int = Util.appWidth / col;
			var blockH:int = Util.appHeight / (row - LevelStage.OUT_OF_VIEW * 2);
			
			var rec:Rectangle = Factory.getObjectFromPool(Rectangle);
			rec.x = r.x / blockW;
			rec.y = r.y / blockH;
			rec.width = r.width / blockW;
			rec.height = r.height / blockH;			
			return rec;
		}
		
		public function blockToPixel(r:Rectangle):Rectangle
		{			
			var blockW:int = Util.appWidth / col;
			var blockH:int = Util.appHeight / (row - LevelStage.OUT_OF_VIEW * 2);
			
			var rec:Rectangle = Factory.getObjectFromPool(Rectangle);
			rec.x = r.x * blockW;
			rec.y = r.y * blockH;
			rec.width = r.width * blockW;
			rec.height = r.height * blockH;
			return rec;
		
		}
		
		public function validate():void
		{			
			lvlStage.deleteBricks(1);		
			var total:int = row * col;
			var r:int = 0;
			var c:int = 0;
			var stageR:int;
			var stageC:int;
			for (var i:int = 0; i < total; i++)
			{				
				if (r % 2 == 1)
				{
					stageR = r - 1 >> 1;
					stageC = c >> 1;
					blocks[i] = lvlStage.bricks[stageR * lvlStage.col + stageC];
				}
				else
				{
					blocks[i] = false;
				}
				c++;
				if (c == col)
				{
					r++;
					c = 0;
				}
			}
		}
	
	}

}