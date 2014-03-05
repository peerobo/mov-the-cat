package com.fc.movthecat.comp 
{
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import flash.display.Graphics;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.textures.Texture;
	import starling.utils.deg2rad;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class LoadingIcon extends LoopableSprite
	{	
		//private var mc:MovieClip;
		
		private var stars:Array;
		private var pageFooter:PageFooter;
		private var currentProgress:int;
		static private const NUM_LOADING:Number = 4;
		
		public function LoadingIcon() 
		{
			super();
			interval = 0.4;		
			pageFooter = new PageFooter();
			var img:Image = Asset.getBaseImage(BackgroundAsset.BG_SQUARE) as Image;
			var c:ColorMatrixFilter = new ColorMatrixFilter();
			c.adjustBrightness(0.3);
			c.adjustHue(0.5);	
			pageFooter.initTexture(img, Asset.getBaseImage(BackgroundAsset.BG_SQUARE_ALPHA) as Image,72);
			pageFooter.filter = c;
			currentProgress = 0;
		}
		
		override public function onRemoved(e:Event):void 
		{
			pageFooter.removeFromParent();
			super.onRemoved(e);
		}
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
			
			pageFooter.setState(currentProgress, NUM_LOADING);
			addChild(pageFooter);
		}				
		
		override public function update(time:Number):void 
		{
			super.update(time);
			
			pageFooter.setState(currentProgress, NUM_LOADING);
			currentProgress++;
			currentProgress = currentProgress >= NUM_LOADING?0:currentProgress;
		}
	}

}