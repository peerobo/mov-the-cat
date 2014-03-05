package com.fc.movthecat 
{
	import com.fc.air.base.Factory;
	import com.fc.air.res.Asset;
	import com.fc.air.res.ResMgr;
	import com.fc.movthecat.asset.MTCAsset;
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
		
		public static function getGameMVWithScale(texName:String):MovieClip
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			var v:Vector.<Texture> = resMgr.getTextures(MTCAsset.MTC_TEX_ATLAS, texName);
			var mv:MovieClip = Asset.getMovieClip(v);			
			mv.scaleX = mv.scaleY = Constants.GAME_SCALE * Starling.contentScaleFactor;
			mv.smoothing = TextureSmoothing.NONE;
			return mv;
		}
	}

}