package com.fc.movthecat.gui 
{
	import com.fc.air.base.BaseButton;
	import com.fc.air.base.BaseJsonGUI;
	import com.fc.air.base.Factory;
	import com.fc.air.base.font.BaseBitmapTextField;
	import com.fc.air.base.LangUtil;
	import com.fc.air.FPSCounter;
	import com.fc.movthecat.asset.MTCAsset;
	import com.fc.movthecat.config.CatCfg;
	import com.fc.movthecat.MTCUtil;
	import flash.geom.Rectangle;
	import starling.display.MovieClip;
	import starling.events.Event;
	
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
			
		public function CharSelectorUI() 
		{
			super("CharacterSelectorUI");
			charIdx = 0;
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
			charIdx += inc;
			charIdx = charIdx < 0 ? MTCUtil.catCfgs.length - 1 : charIdx;
			charIdx = charIdx == MTCUtil.catCfgs.length ? 0 : charIdx;
			updateChar();
		}
		
		private function updateChar():void 
		{
			var catCfg:CatCfg = Factory.getInstance(CatCfg);
			MTCUtil.setCatCfg(charIdx, catCfg);			
			char = MTCUtil.getGameMVWithScale(MTCAsset.MV_CAT + charIdx + "_", char, catCfg.scale);
			char.x = recChar.x + (recChar.width - char.width >> 1);
			char.y = recChar.y + (recChar.height - char.height >> 1);
			char.fps = catCfg.fps;
			char.play();
			addChild(char);
			charNameTxt.text = LangUtil.getText("cat" + charIdx);
		}
		
		private function onCharSelect():void 
		{
			dispatchEventWith(MTCUtil.EVENT_ON_PICK_CHAR);					
		}
		
		override public function onRemoved(e:Event):void 
		{
			char = null;
			super.onRemoved(e);					
		}
		
	}

}