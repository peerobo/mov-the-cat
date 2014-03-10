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
		
		public function VisibleScreen() 
		{
			player = Factory.getInstance(Player);
			blockMap = Factory.getInstance(BlockMap);			
		}
		
		public function checkPlayerOut():Boolean
		{
			var ret:Boolean = (player.y < blockMap.gameWindow.y - 1);
			ret ||= player.y > blockMap.gameWindow.bottom;
			return ret;
		}
		
	}

}