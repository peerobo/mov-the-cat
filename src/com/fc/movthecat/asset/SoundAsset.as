package com.fc.movthecat.asset 
{
	import com.fc.air.base.SoundManager;
	import com.fc.air.res.Asset;
	import flash.filesystem.File;
	
	/**
	 * sound list
	 * @author ndp
	 */
	public class SoundAsset 
	{		
		public static const THEME_SONG:String = Asset.SOUND_FOLDER + Asset.BASE_GUI + "/" + "theme.mp3";				
		public static const SOUND_END_GAME:String = Asset.SOUND_FOLDER + Asset.BASE_GUI + "/" + "endgame.mp3";		
		public static const SOUND_HIGH_SCORE:String = Asset.SOUND_FOLDER + Asset.BASE_GUI + "/" + "highscore.mp3";		
		public static const SOUND_CLICK:String = Asset.SOUND_FOLDER + Asset.BASE_GUI + "/" + "click.mp3";		
		
		public static var currProgress:int;
		private static var listSound:Object;
		private static var currCat:String;				
		
		public static function preload():void
		{		
			SoundManager.getSound(SOUND_CLICK);					
			SoundManager.getSound(SOUND_END_GAME);
			SoundManager.getSound(SOUND_HIGH_SCORE);
			if (!listSound)
				listSound = { };
		}
		
		public function SoundAsset() 
		{
			
		}
	}

}