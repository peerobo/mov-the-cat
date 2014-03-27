package com.fc.movthecat.screen 
{	
	import com.fc.air.base.BaseJsonGUI;
	import com.fc.air.base.Factory;
	import com.fc.air.base.GameSave;
	import com.fc.air.base.LangUtil;
	import com.fc.air.base.ScreenMgr;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.air.res.ResMgr;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.MTCAsset;
	import flash.utils.ByteArray;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class LoadingScreen extends LoopableSprite 
	{						
		[Embed(source="../../../../../res/ico_logo.atf", mimeType="application/octet-stream")]
		public static const CompressedData:Class;
		
		private var t:Tween;
		private var quad:Quad;
		private var img:Image;
		private var txt:TextField;
		private var loadBaseAssetDone:Boolean;
		
		public function LoadingScreen() 
		{
			super();			
			
			quad = Factory.getObjectFromPool(Quad);			
			quad.width = Util.appWidth;
			quad.height = Util.appHeight;
			quad.color = 0x0;
			addChild(quad);
			
			var data:ByteArray = new CompressedData() as ByteArray;			
			var tex:Texture = Texture.fromAtfData(data, 1 / Starling.contentScaleFactor);
			
			img = Factory.getObjectFromPool(Image);
			img.texture = tex;
			img.readjustSize();
			addChild(img);			
			
			Util.g_centerScreen(img);
			
			t = new Tween(img, 1);
			t.repeatCount = 0;
			t.reverse = true;
			t.fadeTo(0.3);
			interval = 0.033;
			
			loadBaseAssetDone = false;
		}				
		
		override public function update(time:Number):void 
		{
			super.update(time);
			t.advanceTime(time);
			if (!loadBaseAssetDone)
			{
				var resMgr:ResMgr = Factory.getInstance(ResMgr);			
				if (resMgr.assetProgress == 1)
				{
					if (BaseJsonGUI.ready && LangUtil.ready)
					{							
						
						//Starling.juggler.delayCall(resMgr.loadTextureAtlas,2,MTCAsset.MTC_TEX_ATLAS,loadTAProgress)
						loadBaseAssetDone = true;
						// load all cats
						resMgr.loadTextureAtlas(MTCAsset.MTC_TEX_ATLAS, loadTAProgress);
					}
				}
			}
			
		}
		
		private function loadTAProgress(progress:int):void 
		{
			if (progress == 1)
			{
				validateGameState();
			}
		}
		
		private function validateGameState():void 
		{			
			var gameState:GameSave = Factory.getInstance(GameSave);
			var data:Object = gameState.data;
			switch(gameState.state)
			{
				case GameSave.STATE_APP_LAUNCH:
					
				break;
				case GameSave.STATE_APP_INGAME:
					
				break;
				case GameSave.STATE_APP_PURCHASE:
					
				break;
				case GameSave.STATE_APP_RESTORE:
					
				break;
			}						
			ScreenMgr.showScreen(MainScreen);
			Factory.killInstance(LoadingScreen);
		}
		
		override public function onRemoved(e:Event):void 
		{
			img.texture.dispose();
			img.removeFromParent();
			quad.removeFromParent();
			Factory.toPool(img);
			Factory.toPool(quad);
			super.dispose();
			t = null;
			img = null;
			quad = null;
			
			super.onRemoved(e);								
		}
	}

}