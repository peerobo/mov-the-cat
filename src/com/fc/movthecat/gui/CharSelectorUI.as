package com.fc.movthecat.gui 
{
	import com.fc.air.base.BaseButton;
	import com.fc.air.base.BaseJsonGUI;
	import com.fc.air.base.BFConstructor;
	import com.fc.air.base.EffectMgr;
	import com.fc.air.base.Factory;
	import com.fc.air.base.font.BaseBitmapTextField;
	import com.fc.air.base.IAP;
	import com.fc.air.base.LangUtil;
	import com.fc.air.base.PopupMgr;
	import com.fc.air.base.SoundManager;
	import com.fc.air.FPSCounter;
	import com.fc.air.res.ResMgr;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.FontAsset;
	import com.fc.movthecat.asset.IconAsset;
	import com.fc.movthecat.asset.MTCAsset;
	import com.fc.movthecat.asset.SoundAsset;
	import com.fc.movthecat.comp.ConfirmDlg;
	import com.fc.movthecat.comp.LoadingIcon;
	import com.fc.movthecat.config.CatCfg;
	import com.fc.movthecat.Constants;
	import com.fc.movthecat.logic.ItemsDB;
	import com.fc.movthecat.MTCUtil;
	import com.fc.movthecat.screen.MainScreen;
	import feathers.core.DisplayListWatcher;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.VAlign;
	
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
		public var lbl:BaseBitmapTextField;
		public var buyWithDiamondBt:BaseButton;			
		
		public function CharSelectorUI() 
		{
			super("CharacterSelectorUI");
			charIdx = 0;
			reqs = [];
		}
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
			
			var saveCharObj:SharedObject = Util.getLocalData("saveChar");
			if(saveCharObj.data.hasOwnProperty("charIdx"))
				charIdx = saveCharObj.data["charIdx"];
			else
				charIdx = 0;
			
			pickCharBt.setCallbackFunc(onCharSelect);			
			nextBt.setCallbackFunc(onUpdate,[1]);
			backBt.setCallbackFunc(onUpdate, [ -1]);			
			tryBt.setCallbackFunc(onTry);
			buyBt.setCallbackFunc(onBuy);
			buyWithDiamondBt.setCallbackFunc(onBuyWithDiamond);
			lbl.touchable = true;
			lbl.vAlign = VAlign.TOP;
			Factory.addMouseClickCallback(lbl, onCheat);
			updateChar();									
		}
		
		private function onBuyWithDiamond():void 
		{
			var itemDB:ItemsDB = Factory.getInstance(ItemsDB);
			if (itemDB.unlock(charIdx, true))
			{
				updateChar();
			}
			else
			{
				var confirmDlg:ConfirmDlg = Factory.getInstance(ConfirmDlg);
				confirmDlg.msg = LangUtil.getText("hintcoin");
				confirmDlg.callback = onChooseDiamond;
				confirmDlg.params = null;
				confirmDlg.bts = [LangUtil.getText("inapp099"),LangUtil.getText("inapp299"),LangUtil.getText("inapp599"), LangUtil.getText("close")];
				PopupMgr.addPopUp(confirmDlg);
			}
		}
		
		private function onChooseDiamond(clickedBt:int):void 
		{
			var iap:IAP;
			var internet:Boolean = Util.internetAvailable;
			
			if (clickedBt == 3)
			{
				return;				
			}
			if (!internet)
			{
				EffectMgr.floatTextMessageEffectCenter(LangUtil.getText("needInternet"), 0xFF9866, 2);
				return;
			}
			else
			{				
				iap = Factory.getInstance(IAP);
				if (iap.canPurchase)
				{
					iap.makePurchase(Constants.ANDROID_PRODUCT_IDS[clickedBt], onPurchaseComplete);
				}				
			}			
			var loading:LoadingIcon = Factory.getInstance(LoadingIcon);
			PopupMgr.addPopUp(loading);	
		}
		
		private function onPurchaseComplete():void 
		{
			PopupMgr.removePopup(Factory.getInstance(LoadingIcon));
			var iap:IAP = Factory.getInstance(IAP);
			var arr:Array;
			CONFIG::isAndroid {
				arr = Constants.ANDROID_PRODUCT_IDS;
			}
			CONFIG::isIOS {
				arr = Constants.IOS_PRODUCT_IDS;
			}
			var prod:String = "";
			for (var i:int = 0; i < arr.length; i++) 
			{
				if (iap.checkBought(arr[i]))
				{
					prod = arr[i];
					break;
				}
			}
			if (prod != "")
			{
				FPSCounter.log("consume", prod);
				currProcessID = prod;
				PopupMgr.addPopUp(Factory.getInstance(LoadingIcon));
				iap.restorePurchases(onRestoreDone);				
			}
			
		}
		
		private function onRestoreDone():void 
		{
			var iap:IAP = Factory.getInstance(IAP);
			iap.consumeProductID(currProcessID, onConsumeDone);
			currProcessID = "";
		}
		
		private function onConsumeDone(prodID:String,result:Boolean):void 
		{
			PopupMgr.removePopup(Factory.getInstance(LoadingIcon));			
			FPSCounter.log("consume done", prodID, result);
			if (result)
			{				
				var arr:Array;
				CONFIG::isAndroid {
					arr = Constants.ANDROID_PRODUCT_IDS;
				}
				CONFIG::isIOS {
					arr = Constants.IOS_PRODUCT_IDS;
				}
				var itemDB:ItemsDB = Factory.getInstance(ItemsDB);
				switch (arr.indexOf(prodID)) 
				{
					case 0:
						itemDB.addItem(ItemsDB.DIAMOND, 400);
					break;
					case 1:
						itemDB.addItem(ItemsDB.DIAMOND, 1000);
					break;
					case 2:
						itemDB.addItem(ItemsDB.DIAMOND, 4000);
					break;
					default:
				}
				
				updateChar();
			}			
		}
		
		private var h:int = 0;
		private var weather:int = 0;
		private var currProcessID:String;
		private function onCheat():void 
		{
			var mainScreen:MainScreen = Factory.getInstance(MainScreen);
			mainScreen.refreshBG(h++,weather++);
			h = h % 24;
			weather = weather % 3;
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
			if (Util.isDesktop)
			{
				onCharSelect();
				return;
			}
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
			var req:int;
			var avail:int;
			var len:int;
			var catCfg:CatCfg = Factory.getInstance(CatCfg);
			MTCUtil.setCatCfg(charIdx, catCfg);			
			char = MTCUtil.getGameMVWithScale(MTCAsset.MV_CAT + catCfg.idx + "_", char, catCfg.scale);
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
					req = catCfg.numIdxs[i];
					str = " x " + req;
					text = BFConstructor.getShortTextField(1, 1, str, FontAsset.GEARHEAD,0xFFFF80);
					text.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
					avail = itemsDB.getItem(catCfg.reqIdxs[i]);
					text.add( " ("+avail+")", avail > req ? 0x00FF80 : 0xFF0000)
					text.x = img.x + img.width;
					text.y = img.y + 12;
					text.scaleX = text.scaleY = 0.6;
					addChild(text);
					reqs.push(text);
				}
				
				img = MTCUtil.getGameImageWithScale(IconAsset.ICO_DIAMOND_PREFIX + "0");
				img.height = HIMG + 60;
				img.scaleX = img.scaleY;
				addChild(img);
				img.x = buyWithDiamondBt.x + buyWithDiamondBt.width + 60;
				img.y = buyWithDiamondBt.y + (buyWithDiamondBt.height - img.height >> 1);
				reqs.push(img);
				req = catCfg.diamonds;
				str = " x " + req;
				text = BFConstructor.getShortTextField(1, 1, str, FontAsset.GEARHEAD,0xFFFF80);
				text.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				text.scaleX = text.scaleY = 0.6;
				avail = itemsDB.getItem(ItemsDB.DIAMOND);
				text.add( "\n  ("+avail+")", avail > req ? 0x00FF80 : 0xFF0000)
				text.x = img.x + img.width;
				text.y = img.y + (img.height - text.height >> 1);				
				addChild(text);
				reqs.push(text);
				
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
			var saveCharObj:SharedObject = Util.getLocalData("saveChar");
			saveCharObj.data["charIdx"] = charIdx;
			SoundManager.playSound(SoundAsset.SOUND_CLICK);
			dispatchEventWith(MTCUtil.EVENT_ON_PICK_CHAR);					
		}
		
		override public function onRemoved(e:Event):void 
		{
			Factory.removeMouseClickCallback(lbl);
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
			var len:int = self.reqs.length;
			for (var j:int = 0; j < len; j++) 
			{
				Factory.toPool(self.reqs[j]);
				self.reqs[j].removeFromParent();
			}
			var itemDB:ItemsDB = Factory.getInstance(ItemsDB);
			itemDB.addItem(ItemsDB.DIAMOND, 1);
		}
		
		static public function videoAdStartHandler():void 
		{
			SoundManager.instance.muteMusic = true;
		}
		
	}

}