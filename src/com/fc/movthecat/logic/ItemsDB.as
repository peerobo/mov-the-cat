package com.fc.movthecat.logic 
{
	import com.fc.air.base.Factory;
	import com.fc.air.base.GameService;
	import com.fc.air.Util;
	import com.fc.movthecat.config.CatCfg;
	import com.fc.movthecat.Constants;
	import com.fc.movthecat.MTCUtil;
	/**
	 * ...
	 * @author ndp
	 */
	public class ItemsDB 
	{
		public static const DIAMOND:int = 1000;				
		private var obj:Object
		public function ItemsDB() 
		{
			obj = new Object();
		}
		
		public function checkUnlock(idx:int):Boolean
		{
			return obj.hasOwnProperty("cat" + idx);
		}
				
		public function unlock(idx:int, withDiamond:Boolean = false):Boolean
		{
			var cfg:CatCfg = Factory.getInstance(CatCfg);
			MTCUtil.setCatCfg(idx, cfg);
			var canBuy:Boolean = true; 
			if (!withDiamond)
			{
				for (var i:int = 0; i < cfg.reqIdxs.length; i++) 
				{				
					canBuy &&= getItem(cfg.reqIdxs[i]) >= cfg.numIdxs[i];
				}
			}
			else
			{				
				canBuy &&= getItem(DIAMOND) >= cfg.diamonds;
			}
			if (canBuy)
			{
				if (!withDiamond)
				{
					for (i = 0; i < cfg.reqIdxs.length; i++) 
					{
						addItem(cfg.reqIdxs[i], -cfg.numIdxs[i]);
					}
				}
				else
				{
					addItem(DIAMOND, -cfg.diamonds);
				}
				obj["cat" + idx] = true;
				if (!obj.hasOwnProperty("catunlock"))
					obj["catunlock"] = 0;
				obj["catunlock"]++;
				var gameService:GameService = Factory.getInstance(GameService);
				CONFIG::isIOS{
					if (obj["catunlock"] == 1)
						gameService.unlockAchievement(Constants.ACH_UNLOCK_1_CAT);
					else if (obj["catunlock"] == 5)
						gameService.unlockAchievement(Constants.ACH_UNLOCK_5_CAT);
					else if (obj["catunlock"] == 22)
						gameService.unlockAchievement(Constants.ACH_UNLOCK_22_CAT);
				}
				CONFIG::isAndroid {
					if (obj["catunlock"] >= 1)
						gameService.unlockAchievement(MTCUtil.gsGetCode(Constants.ACH_UNLOCK_1_CAT));
					else if (obj["catunlock"] >= 5)
						gameService.unlockAchievement(MTCUtil.gsGetCode(Constants.ACH_UNLOCK_5_CAT));
					else if (obj["catunlock"] >= 22)
						gameService.unlockAchievement(MTCUtil.gsGetCode(Constants.ACH_UNLOCK_22_CAT));
				}
				return true;			
			}
			else
			{
				return false;
			}
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