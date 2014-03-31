package com.fc.movthecat.gui 
{
	import com.fc.air.base.BaseJsonGUI;
	import com.fc.air.base.LangUtil;
	import com.fc.air.Util;
	import com.fc.movthecat.Constants;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class QuoteUI extends BaseJsonGUI 
	{
		public var quoteTxt:TextField;
		public function QuoteUI() 
		{
			super("QuoteUI");
			
		}
		
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
			
			quoteTxt.text = LangUtil.getText("quote" + int(Util.getRandom(Constants.QUOTE_NUM))); 			
			this.scaleX = this.scaleY = 0.7;
		}
	}

}