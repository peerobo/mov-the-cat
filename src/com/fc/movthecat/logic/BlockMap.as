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
		
		public function checkEmpty(r:int, c:int):Boolean
		{
			var idx:int = r * col + c;			
			return !blocks[idx];
		}
		
		public function pixelToBlock(r:Rectangle):Rectangle
		{
			var pW:int = Util.appWidth;
			var pH:int = Util.appHeight;
			
			var blockW:int = Util.appWidth / col;
			var blockH:int = Util.appHeight / (lvlStage.OUT_OF_VIEW * 2);
			
			var rec:Rectangle = Factory.getObjectFromPool(Rectangle);
			rec.x = r.x / blockW;
			rec.y = r.y / blockH;
			rec.width = r.width / blockW;
			rec.height = r.height / blockH;
			
			return rec;			
		}
		
		public function blockToPixel(r:Rectangle):Rectangle
		{
			var pW:int = Util.appWidth;
			var pH:int = Util.appHeight;
			
			var blockW:int = Util.appWidth / col;
			var blockH:int = Util.appHeight / (lvlStage.OUT_OF_VIEW * 2);
			
			var rec:Rectangle = Factory.getObjectFromPool(Rectangle);
			rec.x = r.x * blockW;
			rec.y = r.y * blockH;
			rec.width = r.width * blockW;
			rec.height = r.height * blockH;			
			return rec;
			
		}
		
		public function validate():void 
		{
			if (anchorPt.y >= 2)
			{
				lvlStage.deleteBricks(1);
				var count:int = 2 * col;
				for (var i:int = 0; i < count; i++) 
				{
					blocks[i] = false;
				}
			}
			else
			{
				
			}
		}
		
	}

}