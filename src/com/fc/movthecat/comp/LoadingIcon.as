package com.fc.movthecat.comp 
{
	import com.fc.air.base.Factory;
	import com.fc.air.base.PopupMgr;
	import com.fc.air.comp.ILoading;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.MTCAsset;
	import com.fc.movthecat.config.CatCfg;
	import com.fc.movthecat.MTCUtil;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class LoadingIcon extends LoopableSprite implements ILoading
	{	
		public function LoadingIcon() 
		{
			super();
		}
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
			
			var catCfg:CatCfg = Factory.getInstance(CatCfg);			
			for (var i:int = 0; i < 3; i++) 
			{				
				MTCUtil.setCatCfg(i, catCfg);
				var char:MovieClip = MTCUtil.getGameMVWithScale(MTCAsset.MV_CAT + i + "_", null, catCfg.scale);
				char.x = 200 * i;
				char.fps = catCfg.fps;
				char.play();
				addChild(char);
			}
			
		}
		
		/* INTERFACE com.fc.air.comp.ILoading */
		
		public function show():void 
		{
			PopupMgr.addPopUp(this);
		}
		
		public function close():void 
		{
			PopupMgr.removePopup(this);
		}
		
	}

}