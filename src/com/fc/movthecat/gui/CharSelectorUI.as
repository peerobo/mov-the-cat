package com.fc.movthecat.gui 
{
	import com.fc.air.base.BaseButton;
	import com.fc.air.base.BaseJsonGUI;
	import com.fc.air.base.BFConstructor;
	import com.fc.air.base.Factory;
	import com.fc.air.base.font.BaseBitmapTextField;
	import com.fc.air.base.LangUtil;
	import com.fc.air.base.SoundManager;
	import com.fc.air.FPSCounter;
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
			backBt.setCallbackFunc(onUpdate,[-1]);			
			updateChar();
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
			const HIMG:int = 140;
			var img:DisplayObject;
			var text:TextField;
			var itemsDB:ItemsDB = Factory.getInstance(ItemsDB);			
			posY += (h - len * HIMG >> 1);
			if(!itemsDB.checkUnlock(charIdx))
			{
				for (var i:int = 0; i < len; i++) 
				{
					img = MTCUtil.getGameImageWithScale(IconAsset.ICO_FOOD_PREFIX + catCfg.reqIdxs[i]);
					img.height = HIMG;
					img.scaleX = img.scaleY;
					addChild(img);
					img.x = posX - 100;
					img.y = posY + HIMG * i;					
					reqs.push(img);
					text = BFConstructor.getShortTextField(1, HIMG, " x " + catCfg.numIdxs[i], FontAsset.GEARHEAD);
					text.autoSize = TextFieldAutoSize.HORIZONTAL;
					text.x = img.x + img.width;
					text.y = img.y;
					addChild(text);
					reqs.push(text);
				}
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
		
	}

}