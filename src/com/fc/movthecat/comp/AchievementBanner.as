package com.fc.movthecat.comp 
{
	import com.fc.air.comp.IAchievementBanner;
	/**
	 * ...
	 * @author ndp
	 */
	public class AchievementBanner implements IAchievementBanner 
	{
		private var _isShowing:Boolean;
		private var _queue:Array;
		
		public function AchievementBanner() 
		{
			_queue = [];
		}
		
		/* INTERFACE com.fc.air.comp.IAchievementBanner */
		
		public function get isShowing():Boolean 
		{
			return _isShowing;
		}
		
		public function setLabelAndShow(achName:String):void 
		{
			_isShowing = true;
		}
		
		public function queue(achName:String):void 
		{
			_queue.push(achName);
		}
		
	}

}