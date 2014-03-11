package com.fc.movthecat.logic 
{
	import com.fc.air.base.Factory;
	import flash.geom.Rectangle;
	/**
	 * origin of player:
	 *      |
	 * 	  --|--
	 *      |
	 *     / \
	 *    / . \
	 * 
	 * @author ndp
	 */
	public class Player 
	{
		public var w:Number;
		public var h:Number;
		public var speed:Number;
		public var weight:Number;
		public var x:Number;
		public var y:Number;
		//public var isFreeFall:Boolean;
		
		public function Player() 
		{
			
		}
		
		public function move(isLeft:Boolean):void
		{
			var step:Number = speed;
			x += isLeft? -step:step;			
		}
		
		public function tryMoving(isLeft:Boolean):Rectangle
		{			
			var oldX:Number = x;
			move(isLeft);
			var bound:Rectangle = getBound();
			x = oldX;
			return bound;
		}
		
		public function getBound():Rectangle
		{
			var rec:Rectangle = Factory.getObjectFromPool(Rectangle);
			rec.x = x - w / 2;
			rec.y = y - h;
			rec.width = w;
			rec.height = h;
			return rec;
		}
		
	}

}