package com.fc.movthecat 
{
	import com.fc.air.base.Factory;
	import com.fc.air.base.SoundManager;
	import com.fc.air.comp.TileImage;
	import com.fc.air.res.Asset;
	import com.fc.air.res.ResMgr;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.BackgroundAsset;
	import com.fc.movthecat.asset.IconAsset;
	import com.fc.movthecat.asset.MTCAsset;
	import com.fc.movthecat.asset.SoundAsset;
	import com.fc.movthecat.config.CatCfg;
	import com.fc.movthecat.logic.ItemsDB;
	import com.hurlant.crypto.prng.ARC4;
	import com.hurlant.crypto.prng.Random;
	import feathers.display.Scale9Image;
	import flash.net.URLLoaderDataFormat;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	/**
	 * ...
	 * @author ndp
	 */
	public class MTCUtil 
	{
		public static const EVENT_ON_PLAYGAME:String = "on_play_game";
		public static const EVENT_ON_PICK_CHAR:String = "on_pick_char";
		public static const EVENT_ON_HOME:String = "on_go_home";		
		CONFIG::isIOS{
			public static const HIGHSCORE:String = "catMain";
		}
		CONFIG::isAndroid {
			public static const HIGHSCORE:String = "CgkI7_y9xv4cEAIQAQ";
		}
		static public var catCfgs:Array;
		static private var constants:Object;
		
		public static function getGameImageWithScale(texName:String, scale:Number = -1):DisplayObject
		{
			var disp:DisplayObject = Asset.getImage(MTCAsset.MTC_TEX_ATLAS, texName);
			disp.touchable = false;
			disp.scaleX = disp.scaleY = (scale == -1 ? Constants.GAME_SCALE: scale) * Starling.contentScaleFactor;
			if(disp as Image)
				(disp as Image).smoothing = TextureSmoothing.NONE;
			if(disp as Scale9Image)
				(disp as Scale9Image).smoothing = TextureSmoothing.NONE;
			return disp;
		}
		
		public static function getGameMVWithScale(texName:String, mv:MovieClip=null, scale:Number = -1):MovieClip
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			var v:Vector.<Texture> = resMgr.getTextures(MTCAsset.MTC_TEX_ATLAS, texName);
			var mv:MovieClip = Asset.getMovieClip(v, 24, mv);
			mv.scaleX = mv.scaleY = (scale == -1 ? Constants.GAME_SCALE: scale) * Starling.contentScaleFactor;
			if (mv.scaleX < 1)
				mv.smoothing = TextureSmoothing.BILINEAR;
			else
				mv.smoothing = TextureSmoothing.NONE;
			mv.touchable = false;
			return mv;
		}
		
		public static function getRandomCloudBG():TileImage
		{
			var tileImages:TileImage = Factory.getObjectFromPool(TileImage);		
			tileImages.touchable = false;
			tileImages.reset();
			var scale:Number = Constants.GAME_SCALE * Starling.contentScaleFactor;
			tileImages.scale = scale;
			var resMgr:ResMgr = Factory.getInstance(ResMgr);			
						
			var v:Vector.<Texture> = resMgr.getTextures(MTCAsset.MTC_TEX_ATLAS, IconAsset.ICO_CLOUD);
			var len:int = v.length;						
			var plantNum:int = 10;
			var img:Image = Factory.getObjectFromPool(Image);
			img.smoothing = TextureSmoothing.NONE;
			var spacing:int = Util.appHeight / plantNum;			
			for (var i:int = 0; i < plantNum; i++) 
			{
				var type:int = Util.getRandom(len);
				var tex:Texture = v[type];				
				img.texture = tex;				
				img.readjustSize();
				img.scaleX = img.scaleY = scale;
				img.x = Util.getRandom(Util.appWidth);
				img.y = i * spacing + Util.getRandom(spacing);
				img.scaleX = (Util.getRandom(1) > 0.5) ? scale : -scale;
				tileImages.addImage(img);
			}			
			
			return tileImages;
		}
		
		public static function loadCfgCats():void
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			resMgr.load(Asset.TEXT_FOLDER + "cats.json", URLLoaderDataFormat.TEXT, onDownloaded);
		}
		
		static private function onDownloaded(loadedData:String):void 
		{
			catCfgs = JSON.parse(loadedData) as Array;
			
			var len:int = catCfgs.length;
			for (var i:int = 0; i < len; i++) 
			{
				SoundManager.getSound(SoundAsset.CAT_DIE + i + SoundAsset.FILE_TYPE);
			}
			
		}
		
		public static function setCatCfg(idx:int, configObj2Set:CatCfg):void
		{
			configObj2Set.scale = catCfgs[idx].scale;
			configObj2Set.speed = catCfgs[idx].speed;
			configObj2Set.weight = catCfgs[idx].weight;
			configObj2Set.width = catCfgs[idx].width;
			configObj2Set.fps = catCfgs[idx].fps;
			configObj2Set.numIdxs = catCfgs[idx].numIdxs;
			configObj2Set.reqIdxs = catCfgs[idx].reqIdxs;
			if (configObj2Set.numIdxs.length < configObj2Set.reqIdxs.length)
			{
				var len:int = configObj2Set.numIdxs.length;
				for (var i:int = len; i < configObj2Set.reqIdxs.length; i++) 
				{
					configObj2Set.numIdxs[i] = configObj2Set.numIdxs[len - 1];
				}
			}
		}
		
		public static function gsInit():void
		{
			constants = constants || { };
			constants[Constants.ACH_UNLOCK_1_CAT] = 'CgkI7_y9xv4cEAIQAg';
			constants[Constants.ACH_10PT] = 'CgkI7_y9xv4cEAIQAw';
			constants[Constants.ACH_UNLOCK_5_CAT] = 'CgkI7_y9xv4cEAIQBA';
			constants[Constants.ACH_20PT] = 'CgkI7_y9xv4cEAIQBQ';
			constants[Constants.ACH_50PT] = 'CgkI7_y9xv4cEAIQBg';
			constants[Constants.ACH_UNLOCK_22_CAT] = 'CgkI7_y9xv4cEAIQBw';
			constants[Constants.ACH_100PT] = 'CgkI7_y9xv4cEAIQCQ';
		}
		
		public static function gsGetCode(str:String):String
		{
			return constants[str];
		}
		
		public static function gsReverseCode(code:String):String
		{
			for (var name:String in constants) 
			{
				if (constants[name] == code)
				{
					return name;
				}
			}
			return "null";
		}
	}

}