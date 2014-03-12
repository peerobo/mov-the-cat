package com.fc.movthecat.logic 
{
	import com.fc.air.base.Factory;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author ndp
	 */
	public class VisibleScreen 
	{
		public var player:Player;
		public var blockMap:BlockMap;
		
		public var needRender:Boolean;
		
		public function VisibleScreen() 
		{
			player = Factory.getInstance(Player);
			blockMap = Factory.getInstance(BlockMap);			
		}
		
		public function checkPlayerOut():Boolean
		{
			var ret:Boolean = (player.y < 0);
			ret ||= player.y > blockMap.gameWindow.bottom + 2;
			return ret;
		}
		
	}

}