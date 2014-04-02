package com.fc.movthecat.gui 
{
	import com.fc.air.base.BaseButton;
	import com.fc.air.base.BaseJsonGUI;
	import com.fc.air.base.BFConstructor;
	import com.fc.air.base.EffectMgr;
	import com.fc.air.base.Factory;
	import com.fc.air.base.font.BaseBitmapTextField;
	import com.fc.air.base.LangUtil;
	import com.fc.air.base.SoundManager;
	import com.fc.air.FPSCounter;
	import com.fc.air.res.ResMgr;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.FontAsset;
	import com.fc.movthecat.asset.IconAsset;
	import com.fc.movthecat.asset.MTCAsset;
	import com.fc.movthecat.asset.SoundAsset;
	import com.fc.movthecat.config.CatCfg;
	import com.fc.movthecat.logic.ItemsDB;
	import com.fc.movthecat.MTCUtil;
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class CharSelectorUI extends BaseJsonGUI 
	{
		public var charNameTxt:BaseBitmapTextField;
		public var backBt:BaseButton;
		public var nextBt:BaseButton;
		public var pickCharBt:BaseButton;
		public var recChar:Rectangle;		
		public var charIdx:int;
		public var char:MovieClip;
		public var buyBt:BaseButton;
		public var tryBt:BaseButton;
		public var playSpr:Sprite;
		public var buySpr:Sprite;
		private var reqs:Array;
			
		public function CharSelectorUI() 
		{
			super("CharacterSelectorUI");
			charIdx = 0;
			reqs = [];
		}
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
			
			pickCharBt.setCallbackFunc(onCharSelect);			
			nextBt.setCallbackFunc(onUpdate,[1]);
			backBt.setCallbackFunc(onUpdate, [ -1]);			
			tryBt.setCallbackFunc(onTry);
			buyBt.setCallbackFunc(onBuy);
			updateChar();
		}
		
		private function onBuy():void 
		{
			var itemDB:ItemsDB = Factory.getInstance(ItemsDB);
			if (itemDB.unlock(charIdx))
			{
				updateChar();
			}
		}
		
		private function onTry():void 
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			if (!resMgr.isInternetAvailable)
			{
				EffectMgr.floatTextMessageEffectCenter(LangUtil.getText("needInternet"), 0xFF9866, 2);
				return;
			}
			CONFIG::isIOS{ 						
				if(!Util.isVideoAdAvailable())
				{
					EffectMgr.floatTextMessageEffectCenter(LangUtil.getText("videonot"), 0xFF9866, 2);
					return;
				}
				Util.showVideoAd();			
			}
			CONFIG::isAndroid{ 						
				if(!Util.isVideoAdAvailable())
				{
					EffectMgr.floatTextMessageEffectCenter(LangUtil.getText("videonot"), 0xFF9866, 2);
					return;
				}
				Util.showVideoAd();			
			}
		}
		
		private function onUpdate(inc:int):void 
		{
			SoundManager.playSound(SoundAsset.SOUND_CLICK);
			charIdx += inc;
			charIdx = charIdx < 0 ? MTCUtil.catCfgs.length - 1 : charIdx;
			charIdx = charIdx == MTCUtil.catCfgs.length ? 0 : charIdx;
			updateChar();
		}
		
		private function updateChar():void 
		{			
			var len:int;
			var catCfg:CatCfg = Factory.getInstance(CatCfg);
			MTCUtil.setCatCfg(charIdx, catCfg);			
			char = MTCUtil.getGameMVWithScale(MTCAsset.MV_CAT + charIdx + "_", char, catCfg.scale);
			char.x = recChar.x + (recChar.width - char.width >> 1);
			char.y = recChar.y + (recChar.height - char.height >> 1);
			char.fps = catCfg.fps;
			char.play();
			addChild(char);
			charNameTxt.text = LangUtil.getText("cat" + charIdx);
			len = reqs.length;
			for (var j:int = 0; j < len; j++) 
			{
				Factory.toPool(reqs[j]);
				reqs[j].removeFromParent();
			}
			reqs.splice(0, reqs.length);
			var posY:int = recChar.bottom;
			var posX:int = pickCharBt.x;
			var h:int = pickCharBt.y - posY;
			len = catCfg.reqIdxs.length;
			const HIMG:int = 80;
			var img:DisplayObject;
			var text:BaseBitmapTextField;
			var itemsDB:ItemsDB = Factory.getInstance(ItemsDB);			
			posY += (h - len * HIMG >> 1);
			var str:String;
			if(len > 0 && !itemsDB.checkUnlock(charIdx))
			{
				for (var i:int = 0; i < len; i++) 
				{
					img = MTCUtil.getGameImageWithScale(IconAsset.ICO_FOOD_PREFIX + catCfg.reqIdxs[i]);
					img.height = HIMG;
					img.scaleX = img.scaleY;
					addChild(img);
					img.x = posX - 80;
					img.y = posY + (HIMG + 10) * i;					
					reqs.push(img);
					var req:int = catCfg.numIdxs[i];
					str = " x " + req;
					text = BFConstructor.getShortTextField(1, 1, str, FontAsset.GEARHEAD,0xFFFF80);
					text.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
					var avail:int = itemsDB.getItem(catCfg.reqIdxs[i]);
					text.add( " ("+avail+")", avail > req ? 0x00FF80 : 0xFF0000)
					text.x = img.x + img.width;
					text.y = img.y + 12;
					text.scaleX = text.scaleY = 0.6;
					addChild(text);
					reqs.push(text);
				}
				buySpr.visible = true;
				playSpr.visible = false;
			}
			else
			{
				buySpr.visible = false;
				playSpr.visible = true;
			}
		}
		
		private function onCharSelect():void 
		{
			SoundManager.playSound(SoundAsset.SOUND_CLICK);
			dispatchEventWith(MTCUtil.EVENT_ON_PICK_CHAR);					
		}
		
		override public function onRemoved(e:Event):void 
		{
			reqs.splice(0, reqs.length);
			char = null;
			super.onRemoved(e);					
		}
		
		static public function videoAdHandler():void 
		{
			FPSCounter.log("video success");
			var self:CharSelectorUI = Factory.getInstance(CharSelectorUI);
			self.playSpr.visible = true;
			self.buySpr.visible = false;
			SoundManager.instance.muteMusic = false;
		}
		
		static public function videoAdStartHandler():void 
		{
			SoundManager.instance.muteMusic = true;
		}
		
	}

}