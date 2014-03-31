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
		private var foods:Array;
		public var row:int;
		public var col:int;
		public var gameWindow:Rectangle;
		public var blocks:Array;
		public var lvlStage:LevelStage;
		public var anchorPt:Point;
		
		public static var B_EMPTY:int = 0;
		public static var B_BRICK:int = 1;
		public static var B_FOOD:int = 2;
		
		public function BlockMap()
		{
			anchorPt = new Point();
			lvlStage = Factory.getInstance(LevelStage);
			blocks = [];
			foods = [];
		}
		
		public function calculateScreenViaLevelStage():void
		{
			lvlStage.calculateScreen();
			row = lvlStage.row * 2;
			col = lvlStage.col * 2;
			var total:int = row * col;
			for (var i:int = 0; i < total; i++)
			{
				blocks[i] = B_EMPTY;
			}
		}
		
		public function checkEmpty(r:int, c:int,oldY:Number = NaN):Boolean
		{			
			if (c < 0 || c >= col)
				return false;
			var idx:int = r * col + c;
			if (idx < 0 || idx > blocks.length)
				return true;			
			return !(blocks[idx] == B_BRICK);
			
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
				var ret:Boolean = (idx < 0)|| (idx > blocks.length) || !(blocks[idx]==B_EMPTY);
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
		
		public function validate(withoutDel:Boolean = false):void
		{			
			if(!withoutDel)
			{
				lvlStage.deleteBricks(1);	
				if(foods.length >=1)
					foods.splice(0, 1);
				
				var currLen:int = foods.length;
				for (var k:int = currLen; k < lvlStage.row; k++) 
				{
					foods.push(Util.getRandom(col));
				}
			}
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
					blocks[i] = lvlStage.bricks[stageR * lvlStage.col + stageC] ? B_BRICK : B_EMPTY;
				}
				else
				{
					blocks[i] = B_EMPTY;
					
					if (c == int(foods[r/2]))
					{	
						blocks[i] = B_FOOD;														
					}
				}
				c++;
				if (c == col)
				{
					r++;
					c = 0;					
				}
			}
		}
		
		public function ateFood(blockIdx:int):Boolean 
		{
			var retBool:Boolean = false;
			var r:int = blockIdx / col;
			foods[r / 2] = -1;
			//var recFood:Rectangle = Factory.getObjectFromPool(Rectangle);
			//recFood.setTo(0, 0, 1, 1);
			//var len:int = foods.length;
			//for (var i:int = 0; i < len; i++) 
			//{			
				//recFood.x = foods[i];
				//recFood.y = i;
				//retBool = recFood.intersects(rec);
				//if (retBool)
				//{
					//foods[i] = -1;
					//validate(true);
					//break;
				//}
			//}
			//Factory.toPool(rec);
			//Factory.toPool(recFood);
			return retBool;
		}
	
	}

}