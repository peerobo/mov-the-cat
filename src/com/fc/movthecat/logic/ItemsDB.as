package com.fc.movthecat.logic 
{
	import com.fc.air.base.Factory;
	import com.fc.air.Util;
	import com.fc.movthecat.config.CatCfg;
	import com.fc.movthecat.MTCUtil;
	/**
	 * ...
	 * @author ndp
	 */
	public class ItemsDB 
	{
		private var obj:Object
		public function ItemsDB() 
		{
			obj = new Object();
		}
		
		public function checkUnlock(idx:int):Boolean
		{
			return obj.hasOwnProperty("cat" + idx);
		}
				
		public function unlock(idx:int):void
		{
			var cfg:CatCfg = Factory.getInstance(CatCfg);
			MTCUtil.setCatCfg(idx, cfg);
			
		}
		
		public function getItem(idx:int):int
		{
			var key:String = idx.toString();
			var c:int;
			if(obj.hasOwnProperty(key))
				c = obj[key];
			else
				c = 0;			
			return c;
		}
		
		public function addItem(idx:int, num:int):void
		{
			obj[idx.toString()] = getItem(idx) + num;
		}
		
		public function save():void
		{
			Util.setPrivateValue("items",JSON.stringify(obj));
		}
		
		public function load():void
		{
			var str:String = Util.getPrivateKey("items");
			if (str == null)
				obj = { };
			else
				obj = JSON.parse(str);
		}
		
	}

}