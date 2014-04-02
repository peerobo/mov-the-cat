package com.fc.movthecat.comp 
{
	import com.fc.air.base.BaseButton;
	import com.fc.air.base.BFConstructor;
	import com.fc.air.base.font.BaseBitmapTextField;
	import com.fc.air.base.PopupMgr;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.air.res.Asset;
	import com.fc.movthecat.asset.BackgroundAsset;
	import com.fc.movthecat.asset.ButtonAsset;
	import com.fc.movthecat.asset.FontAsset;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class ConfirmDlg extends LoopableSprite 
	{
		public var msg:String;
		public var callback:Function; // function(btIdx:int):void
		public var bts:Array;
		public function ConfirmDlg() 
		{
			super();
			
		}
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
			
			var msgTxt:BaseBitmapTextField = BFConstructor.getTextField(1, 1, msg, FontAsset.GEARHEAD, 0x0);
			msgTxt.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			msgTxt.scaleX = msgTxt.scaleY = 0.7;
			var len:int = bts.length;
			var bt:BaseButton;
			var btStr:String;
			for (var i:int = 0; i < len ; i++) 
			{
				if (i % 3 == 0)
					btStr = ButtonAsset.BLUE_BT;
				else if (i % 3 == 1)
					btStr = ButtonAsset.GREEN_BT;
				else
					btStr = ButtonAsset.YELLOW_BT;
				
				bt = Asset.getBaseBt(btStr);
				bt.setText(bts[i], true);
				bts[i] = bt;
				bt.setCallbackFunc(onClose, [i]);
			}
			
			var bg:DisplayObject = Asset.getBaseImage(BackgroundAsset.BG_BOX);
			bg.alpha = 0.8;
			bg.width = msgTxt.width + 100;
			bg.height = msgTxt.height + 60 + (bt.height + 24) * len + 100;
			addChild(bg);
			msgTxt.x = 50;
			msgTxt.y = 50;
			addChild(msgTxt);
			for (var j:int = 0; j < len; j++) 
			{
				bt = bts[j];
				bt.x = bg.width - bt.width >> 1;
				bt.y = msgTxt.y + msgTxt.height + 60 + (bt.height + 24) * j;
				addChild(bt);
			}
			
		}
		
		private function onClose(idx:int):void 
		{
			PopupMgr.removePopup(this);
			if(callback is Function)
				callback(idx);
			callback = null;
		}
		
	}

}