package com.fc.movthecat.comp 
{
	import com.fc.air.base.BFConstructor;
	import com.fc.air.base.font.BaseBitmapTextField;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.movthecat.asset.FontAsset;
	import starling.display.DisplayObject;	
	import starling.events.Event;
	import starling.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class IconWithText extends LoopableSprite 
	{
		private var _text:String;
		private var txt:BaseBitmapTextField;
		public var img:DisplayObject;
		public function IconWithText() 
		{
			super();			
		}
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
			
			txt = BFConstructor.getTextField(1, 1, text, FontAsset.DEFAULT_FONT);
			txt.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			img.x = txt.width + 24;
			img.y = txt.height - img.height >> 1;
			addChild(img);			
			addChild(txt);
		}
		
		public function get text():String 
		{
			return _text;
		}
		
		public function set text(value:String):void 
		{
			if (txt && txt.parent)
			{
				txt.text = value;
				img.x = txt.width + 24;
			}
			_text = value;
		}
		
		override public function onRemoved(e:Event):void 
		{
			super.onRemoved(e);
		}
		
	}

}