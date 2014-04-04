package com.fc.movthecat.comp 
{
	import com.fc.air.base.LangUtil;
	import com.fc.air.base.LayerMgr;
	import com.fc.air.comp.BGText;
	import com.fc.air.comp.IAchievementBanner;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.BackgroundAsset;
	import com.fc.movthecat.asset.FontAsset;
	import com.fc.movthecat.MTCUtil;
	import starling.core.Starling;
	import starling.display.Sprite;
	/**
	 * ...
	 * @author ndp
	 */
	public class AchievementBanner implements IAchievementBanner 
	{
		private var _isShowing:Boolean;
		private var _queue:Array;
		
		private var spr:BGText;		
		
		public function AchievementBanner() 
		{
			_queue = [];
			spr = new BGText();
		}
		
		/* INTERFACE com.fc.air.comp.IAchievementBanner */
		
		public function get isShowing():Boolean 
		{
			return _isShowing;
		}
		
		public function setLabelAndShow(achName:String):void 
		{
			CONFIG::isIOS {
				achName = LangUtil.getText(achName); 
			}
			CONFIG::isAndroid {
				achName = LangUtil.getText(MTCUtil.gsReverseCode(achName));
			}
			if (Util.isDesktop)
				achName = LangUtil.getText(achName); 
			_isShowing = true;
			spr.setText(FontAsset.GEARHEAD, achName, BackgroundAsset.BG_BOX,0xFFFF80);
			spr.scaleX = spr.scaleY = 0.8;			
			spr.alpha = 0.9;
			LayerMgr.getLayer(LayerMgr.LAYER_EFFECT).addChild(spr);
			spr.y = -spr.height;
			spr.x = Util.appWidth - spr.width >> 1;
			Starling.juggler.tween(spr, 0.5, { y:0, onComplete: onShowed } );
		}
		
		private function onShowed():void 
		{
			Starling.juggler.tween(spr, 0.5, {y: -spr.height, delay: 2, onComplete: onHidden})
		}
		
		private function onHidden():void 
		{
			spr.removeFromParent();
			_isShowing = false;
			if (_queue.length > 0)
			{
				setLabelAndShow(_queue[0]);
				_queue.splice(0, 1);
			}
		}
		
		public function queue(achName:String):void 
		{
			_queue.push(achName);
		}
		
	}

}