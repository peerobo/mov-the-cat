package com.fc.movthecat.comp 
{
	import com.fc.air.base.CallbackObj;
	import com.fc.air.base.LangUtil;
	import com.fc.air.base.PopupMgr;
	import com.fc.air.comp.IInfoDlg;
	import com.fc.air.comp.LoopableSprite;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class InfoDlg extends ConfirmDlg implements IInfoDlg 
	{		
		public function InfoDlg() 
		{
			super();
			
		}
		
		/* INTERFACE com.fc.air.comp.IInfoDlg */
		
		public function showInfo(text:String, callback:CallbackObj):void 
		{
			this.msg = text;
			if(!callback)
			{
				this.callback = null;
				this.params = null;
			}
			else
			{
				this.callback = callback.f;
				this.params = callback.p;
			}
			this.bts = [LangUtil.getText("close")];
			PopupMgr.addPopUp(this);
		}
		
	}

}