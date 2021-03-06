package com.fc.movthecat.gui 
{
	import com.adobe.ane.gameCenter.GameCenterAchievement;
	import com.fc.air.base.BaseJsonGUI;
	import com.fc.air.base.Factory;
	import com.fc.air.base.LangUtil;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.MTCAsset;
	import com.fc.movthecat.config.CatCfg;
	import com.fc.movthecat.Constants;
	import com.fc.movthecat.logic.GameSession;
	import com.fc.movthecat.MTCUtil;
	import com.fc.movthecat.screen.GameScreen;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.VAlign;
	
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
			var gs:GameScreen = Factory.getInstance(GameScreen);
			var catCfg:CatCfg = Factory.getInstance(CatCfg);
			MTCUtil.setCatCfg(gs.charIdx, catCfg);
			this.scaleX = this.scaleY = 0.6;
			quoteTxt.text = LangUtil.getText("quote" + (1 + int(Util.getRandom(Constants.QUOTE_NUM)))); 						
			var character:MovieClip = MTCUtil.getGameMVWithScale(MTCAsset.MV_CAT + catCfg.idx + "_");
			character.play();					
			character.fps = catCfg.fps;
			character.height = Util.appHeight - this.height >> 1;
			character.scaleX = character.scaleY;
			character.x = quoteTxt.width - character.width >> 1;
			character.y = this.height / this.scaleY - (character.height >> 1);
			addChild(character);						
		}
	}

}