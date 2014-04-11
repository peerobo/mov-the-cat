package com.fc.movthecat.screen 
{
	import com.fc.air.base.Factory;
	import com.fc.air.base.GameService;
	import com.fc.air.base.GlobalInput;
	import com.fc.air.base.ScreenMgr;
	import com.fc.air.base.SoundManager;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.air.comp.TileImage;
	import com.fc.air.FPSCounter;
	import com.fc.air.res.Asset;
	import com.fc.air.res.ResMgr;
	import com.fc.air.Util;	
	import com.fc.movthecat.asset.BackgroundAsset;
	import com.fc.movthecat.asset.IconAsset;
	import com.fc.movthecat.asset.MTCAsset;
	import com.fc.movthecat.asset.SoundAsset;
	import com.fc.movthecat.config.CatCfg;
	import com.fc.movthecat.Constants;
	import com.fc.movthecat.gui.CharSelectorUI;
	import com.fc.movthecat.logic.GameSession;
	import com.fc.movthecat.logic.Player;
	import com.fc.movthecat.MTCUtil;
	import flash.events.GeolocationEvent;
	import flash.events.StatusEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.sensors.Geolocation;
	import starling.animation.DelayedCall;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	import starling.utils.deg2rad;
	
	CONFIG::isAndroid{
		import com.fc.FCAndroidUtility;
	}
	
	/**
	 * ...
	 * @author ndp
	 */
	public class MainScreen extends LoopableSprite 
	{
		private var character:MovieClip;
		private var needPlayIntro:Boolean;
		private var tweenChar:Tween;
		
		//private var centerUI:CenterMainUI;
		//private var characterShadow:FragmentFilter;
		private var randomPlayerCall:DelayedCall;
		private var bg:TileImage;
		private var cloudBg:TileImage;	
		private var charUI:CharSelectorUI;
		
		public function MainScreen() 
		{
			super();
			needPlayIntro = true;
			//centerUI = new CenterMainUI();
			//centerUI.addEventListener(MTCUtil.EVENT_ON_PLAYGAME, onPlayGame);
			//characterShadow = BlurFilter.createDropShadow();
			SoundManager.playSound(SoundAsset.THEME_SONG, true);			
			charUI = Factory.getInstance(CharSelectorUI);
			charUI.addEventListener(MTCUtil.EVENT_ON_PICK_CHAR, onPlayGame);					
		}
	
		private function onHideUI():void 
		{
			charUI.removeFromParent();
		}

		override public function onAdded(e:starling.events.Event):void 
		{
			super.onAdded(e);						
			playIntro();		
		}
		
		private function playIntro():void 
		{
			var gameService:GameService = Factory.getInstance(GameService);			
			if (needPlayIntro)
			{
				var resMgr:ResMgr = Factory.getInstance(ResMgr);				
				var tex:Texture;
				var date:Date = new Date();
				var h:Number = date.getHours();
				if (h >= 0 && h < 1)
				{
					tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_0_1);
				}
				else if (h >= 11 && h < 14)
				{
					tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_11_14);
				}
				else if (h >= 14 && h < 17)
				{
					tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_14_17);
				}
				else if((h>=17 && h < 19)||(h>=6 && h < 8))
				{
					tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_17_19_6_8);
				}
				else if((h>=21 && h < 23)||(h>=2 && h < 5))
				{
					tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_21_23_2_5);
				}
				else if(h>=1 && h < 2)
				{
					tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_23_0_1_2);
				}
				else if(h>=8 && h < 11)
				{
					tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_8_11);
				}
				else
				{
					tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_19_21_5_6);
				}
				
				var tileImages:TileImage = Factory.getObjectFromPool(TileImage);	
				tileImages.touchable = false;
				tileImages.scale = 1;
				tileImages.draw(tex, Util.appWidth, Util.appHeight);				
				bg = tileImages;
				//onGeoHandler();
				drawWeather();
				cloudBg = MTCUtil.getRandomCloudBG();					
				addChildAt(cloudBg, 0);
				addChildAt(bg, 0);
				needPlayIntro = false;
			}			
			charUI.buildGUI();
			charUI.x = Util.appWidth - charUI.width >> 1;
			var desY:int = Util.appHeight - charUI.height >> 1;
			charUI.y = Util.appHeight;
			addChild(charUI);
			Starling.juggler.tween(
				charUI,
				2,
				{
					y: desY,
					transition: Transitions.EASE_OUT_BOUNCE
				}
			)									
		}
		
		private function onPlayGame(e:starling.events.Event):void 
		{
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);		
			globalInput.setDisableTimeout(2);
			
			var char:MovieClip = Factory.getObjectFromPool(MovieClip);
			Asset.cloneMV(charUI.char, char);
			var rec:Rectangle = Factory.getObjectFromPool(Rectangle);
			charUI.char.getBounds(Starling.current.stage, rec);
			char.play();
			char.x = rec.x;
			char.y = rec.y;
			Starling.juggler.add(char);
			Factory.toPool(rec);
			var charIdx:int = charUI.charIdx;						
			var charCfg:CatCfg = Factory.getInstance(CatCfg);
			MTCUtil.setCatCfg(charIdx, charCfg);
			var gameSession:GameSession = Factory.getInstance(GameSession);
			gameSession.foodType = charIdx;
			var character:Player = Factory.getInstance(Player);
			character.w = charCfg.width;
			character.weight = charCfg.weight;
			character.speed = charCfg.speed;			
			charUI.removeFromParent();
			var gameScreen:GameScreen = Factory.getInstance(GameScreen);			
			gameScreen.addChild(getChildAt(0));			
			gameScreen.addChild(getChildAt(0));
			gameScreen.addChild(char);
			ScreenMgr.showScreen(GameScreen);
		}				
		
		public function refreshBG(hour:int = -1, weather:int = -1):void		
		{	
			var resMgr:ResMgr = Factory.getInstance(ResMgr);				
			var tex:Texture;
			var date:Date = new Date();			
			var h:Number = date.getHours();
			if (hour > -1)
				h = hour;
			if (h >= 0 && h < 1)
			{
				tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_0_1);
			}
			else if (h >= 11 && h < 14)
			{
				tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_11_14);
			}
			else if (h >= 14 && h < 17)
			{
				tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_14_17);
			}
			else if((h>=17 && h < 19)||(h>=6 && h < 8))
			{
				tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_17_19_6_8);
			}
			else if((h>=21 && h < 23)||(h>=2 && h < 5))
			{
				tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_21_23_2_5);
			}
			else if(h>=1 && h < 2)
			{
				tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_23_0_1_2);
			}
			else if(h>=8 && h < 11)
			{
				tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_8_11);
			}
			else
			{
				tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, BackgroundAsset.BG_SKY_19_21_5_6);
			}
			bg.draw(tex, Util.appWidth, Util.appHeight);			
			if(weather == -1)
			{
				drawWeather();			
			}
			else
			{
				switch(weather)
				{
					case 0:
						tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, IconAsset.ICO_RAIN);
						break;
					case 1:
						tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, IconAsset.ICO_SNOW);
						break;				
					default:
						return;
				}
				
				var img:Image = Factory.getObjectFromPool(Image);
				img.texture = tex;
				img.readjustSize();
				img.scaleX = img.scaleY = Starling.contentScaleFactor;			
				for (var i:int = 0; i < 50; i++) 
				{
					img.x = Util.getRandom(Util.appWidth - img.width);
					img.y = Util.getRandom(Util.appHeight - img.height);				
					
					bg.addImage(img);
				}
				Factory.toPool(img);
			}
		}
		
		private function drawWeather():void 
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			if (!resMgr.isInternetAvailable)
				return;
			if (Geolocation.isSupported)
			{
				var geo:Geolocation = new Geolocation();
				if(geo.muted)
					geo.addEventListener(StatusEvent.STATUS, onChangeState);
				else
					geo.addEventListener(GeolocationEvent.UPDATE, onGeoHandler);
			}
		}
		
		private function onChangeState(e:StatusEvent):void 
		{
			var geo:Geolocation = e.currentTarget as Geolocation;
			if (!geo.muted)
			{
				geo.removeEventListener(StatusEvent.STATUS, onChangeState)
				geo.addEventListener(GeolocationEvent.UPDATE, onGeoHandler);
			}
		}
		
		private function onGeoHandler(e:GeolocationEvent = null):void 
		{
			var geo:Geolocation = e.currentTarget as Geolocation;
			geo.removeEventListener(GeolocationEvent.UPDATE, onGeoHandler);			
			var urlRequest:URLRequest = new URLRequest("http://api.openweathermap.org/data/2.5/weather?lat=" + e.latitude.toString() + "&lon=" + e.longitude.toString());
			//var urlRequest:URLRequest = new URLRequest("http://api.openweathermap.org/data/2.5/weather?lat=21.033333&lon=105.85");
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(flash.events.Event.COMPLETE, onCompleteWeather);
			urlLoader.load(urlRequest);
        } 
		
		private function onCompleteWeather(e:flash.events.Event):void 
		{
			var urlLoader:URLLoader = e.currentTarget as URLLoader;
			urlLoader.removeEventListener(flash.events.Event.COMPLETE, onCompleteWeather);
			var resMgr:ResMgr = Factory.getInstance(ResMgr);				
			var tex:Texture;
			var str:String = (e.currentTarget as URLLoader).data;
			var weatherObj:Object = JSON.parse(str);
			switch(weatherObj.weather[0].main)
			{
				case "Rain":
				case "Thunderstorm":
				case "Drizzle":
				case "Extreme":
					tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, IconAsset.ICO_RAIN);
				break;
				case "Snow":
					tex = resMgr.getTexture(MTCAsset.MTC_TEX_ATLAS, IconAsset.ICO_SNOW);
				break;
				default:
					return;
			}
			
			var img:Image = Factory.getObjectFromPool(Image);
			img.texture = tex;
			img.readjustSize();
			img.scaleX = img.scaleY = Starling.contentScaleFactor;			
			for (var i:int = 0; i < 50; i++) 
			{
				img.x = Util.getRandom(Util.appWidth - img.width);
				img.y = Util.getRandom(Util.appHeight - img.height);				
				
				bg.addImage(img);
			}
			Factory.toPool(img);
		}
			
		
	}

}