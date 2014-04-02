package com.fc.movthecat
{
	import com.fc.air.base.BaseButton;
	import com.fc.air.base.BaseJsonGUI;
	import com.fc.air.base.BFConstructor;
	import com.fc.air.base.EffectMgr;
	import com.fc.air.base.Factory;
	import com.fc.air.base.GameSave;
	import com.fc.air.base.GameService;
	import com.fc.air.base.GlobalInput;
	import com.fc.air.base.IAP;
	import com.fc.air.base.LangUtil;
	import com.fc.air.base.LayerMgr;
	import com.fc.air.base.ScreenMgr;
	import com.fc.air.base.SoundManager;
	import com.fc.air.comp.IAchievementBanner;
	import com.fc.air.FPSCounter;
	import com.fc.air.res.Asset;
	import com.fc.air.res.ResMgr;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.BackgroundAsset;
	import com.fc.movthecat.asset.ButtonAsset;
	import com.fc.movthecat.asset.FontAsset;
	import com.fc.movthecat.asset.ParticleAsset;
	import com.fc.movthecat.asset.SoundAsset;
	import com.fc.movthecat.comp.AchievementBanner;
	import com.fc.movthecat.logic.ItemsDB;
	import com.fc.movthecat.logic.LevelStage;
	import com.fc.movthecat.screen.LoadingScreen;
	import com.fc.movthecat.screen.MainScreen;
	import flash.desktop.NativeApplication;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	CONFIG::isAndroid
	{
		import com.fc.air.base.SocialForAndroid;
	}
	
	/**
	 * ...
	 * @author ndp
	 */
	public class App extends Sprite
	{
		public static const APP_NAME:String = "movthecat";
		public static const URL_REMOTE:String = "http://";
		public static var ins:App;
		
		public function App()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onInit);
			this.alpha = 0.9999;
			ins = this;									
			
			// init app default
			var obj:Object = {};
			obj["iapIOS"] = Constants.IOS_PRODUCT_IDS[0];
			obj["iapAndroid"] = Constants.ANDROID_PRODUCT_IDS[0];
			obj["iapIDsAndroid"] = Constants.ANDROID_PRODUCT_IDS;
			obj["iapIDsIOS"] = Constants.IOS_PRODUCT_IDS;
			obj["iapLicensingAnroid"] = Constants.ANDROID_LICENSING;
			obj["applink"] = Constants.SHORT_LINK;
			obj["appname"] = APP_NAME;
			obj["banner"] = Constants.LEAD_BOLT_BANNER_ID;
			obj["fullscreen"] = Constants.LEAD_BOLT_FULLSCREEN_ID;
			obj["moregames"] = Constants.LEAD_BOLT_MOREGAMES_ID;
			CONFIG::isIOS{
				obj["moregames"] = Constants.LEAD_BOLT_MOREGAMES_ID_IOS;
				Util.initVideoAd(Constants.VIDEO_AD_IOS, false, CharSelectorUI.videoAdHandler);
			}
			obj["fbkey"] = Constants.FB_KEY;
			obj["fbapp"] = Constants.FACEBOOK_APP_ID;
			obj["twitterkey"] = Constants.TWITTER_KEY;
			obj["twittercallback"] = Constants.TWITTER_URL_CALLBACK;
			obj["fbcallback"] = Constants.FB_URL_CALLBACK;
			obj["twitterpublic"] = Constants.TWITTER_PUBLIC_CONSUMER;
			obj["twitterprivate"] = Constants.TWITTER_SECRET_CONSUMER;
			Util.initApp(obj);
			var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
			globalInput.root = this;
			Util.registerPool();
			Asset.isResourceByScaleContent = false;
			Asset.init(FontAsset.LIST_FONTS, URL_REMOTE, BackgroundAsset.WALL_LIST, ButtonAsset.DEFAULT_BT);
			BaseButton.DefaultFont = FontAsset.GEARHEAD;
			LangUtil.loadXMLData();
			BaseJsonGUI.loadCfg();
			EffectMgr.DEFAULT_FONT = FontAsset.GEARHEAD;		
			MTCUtil.loadCfgCats();
			var items:ItemsDB = Factory.getInstance(ItemsDB);
			items.load();
			var gameService:GameService = Factory.getInstance(GameService);
			gameService.registerType(MTCUtil.HIGHSCORE);
			gameService.load();
			var achievementBanner:IAchievementBanner = Factory.getInstance(AchievementBanner);
			gameService.achievementBanner = achievementBanner;
			//Util.iLoading = 
			//Util.iInfoDlg = 
		}
		
		public function onAppDeactivate():void
		{
			if(!Util.isDesktop)
			{	
				if(Starling.current.isStarted)
					Starling.current.stop(true);
				SoundManager.instance.muteMusic = true;   
				SoundManager.instance.mute = true;   
				var gameService:GameService = Factory.getInstance(GameService);
				gameService.save();
				var items:ItemsDB = Factory.getInstance(ItemsDB);
				items.save();
				CONFIG::isIOS {
					NativeApplication.nativeApplication.exit();
				}
			}
		}
		
		public function onAppActivate():void
		{			
			if(!Util.isDesktop)
			{	
				if(!Starling.current.isStarted)
					Starling.current.start();
				if(ScreenMgr.currScr is MainScreen)
					SoundManager.instance.muteMusic = false;
				SoundManager.instance.mute = false;   
			}
		}
		
		public function onAppExit():void
		{
			
		}
		
		public function reinitializeTextures():void
		{
		/*ScreenMgr.showScreen(LoadingScreen);
		   var resMgr:ResMgr = Factory.getInstance(ResMgr);
		 resMgr.start();	*/
		}
		
		private function onInit(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			
			var gameState:GameSave = Factory.getInstance(GameSave);
			gameState.loadState();			
			var iap:IAP = Factory.getInstance(IAP);
			iap.initInAppPurchase();
			CONFIG::isAndroid
			{
				var shareAndroid:SocialForAndroid = Factory.getInstance(SocialForAndroid);
				shareAndroid.init();
			}						
			LayerMgr.init(this);
			var input:GlobalInput = Factory.getInstance(GlobalInput);
			input.init();
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			resMgr.start();
			BFConstructor.init();
			Asset.loadParticleCfg([ParticleAsset.PARTICLE_STAR_COMPLETE]);
			SoundAsset.preload();
			ScreenMgr.showScreen(LoadingScreen);
			Util.initAd();	
		}
	}

}