package com.fc.movthecat 
{
	import com.fc.air.base.Factory;
	import com.fc.air.comp.TileImage;
	import com.fc.air.res.Asset;
	import com.fc.air.res.ResMgr;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.BackgroundAsset;
	import com.fc.movthecat.asset.IconAsset;
	import com.fc.movthecat.asset.MTCAsset;
	import com.hurlant.crypto.prng.ARC4;
	import com.hurlant.crypto.prng.Random;
	import feathers.display.Scale9Image;
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
		public static function getGameImageWithScale(texName:String):DisplayObject
		{
			var disp:DisplayObject = Asset.getImage(MTCAsset.MTC_TEX_ATLAS, texName);
			disp.scaleX = disp.scaleY = Constants.GAME_SCALE * Starling.contentScaleFactor;
			if(disp as Image)
				(disp as Image).smoothing = TextureSmoothing.NONE;
			if(disp as Scale9Image)
				(disp as Scale9Image).smoothing = TextureSmoothing.NONE;
			return disp;
		}
		
		public static function getGameMVWithScale(texName:String, mv:MovieClip=null):MovieClip
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			var v:Vector.<Texture> = resMgr.getTextures(MTCAsset.MTC_TEX_ATLAS, texName);
			var mv:MovieClip = Asset.getMovieClip(v, 24, mv);
			mv.scaleX = mv.scaleY = Constants.GAME_SCALE * Starling.contentScaleFactor;
			mv.smoothing = TextureSmoothing.NONE;
			return mv;
		}
		
		public static function getRandomCloudBG():TileImage
		{
			var tileImages:TileImage = Factory.getObjectFromPool(TileImage);		
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
	}

}