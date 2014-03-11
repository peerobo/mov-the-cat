package com.fc.movthecat.screen.game
{
	import com.fc.air.base.Factory;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.air.FPSCounter;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.BackgroundAsset;
	import com.fc.movthecat.logic.VisibleScreen;
	import com.fc.movthecat.MTCUtil;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.QuadBatch;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class GameRender extends LoopableSprite
	{
		private var character:DisplayObject;
		private var visibleScreen:VisibleScreen;
		private var quadBatch:QuadBatch;		
		
		public function GameRender()
		{
			super();			
			visibleScreen = Factory.getInstance(VisibleScreen);
			quadBatch = new QuadBatch();
			addChild(quadBatch);
		}
		
		public function reset():void
		{
			quadBatch.reset();
		}
		
		public function setCharacter(disp:DisplayObject):void
		{
			character = disp;
			addChild(character);
		}
		
		override public function update(time:Number):void
		{
			super.update(time);
			if (visibleScreen.needRender)
			{
				var anchorPt:Point = visibleScreen.blockMap.anchorPt;			
				// draw brick
				var r:Rectangle = Factory.getObjectFromPool(Rectangle);
				r.setTo(0, anchorPt.y, 1, 1);
				var rec:Rectangle = visibleScreen.blockMap.blockToPixel(r);
				var offsetY:int = -rec.y;			
				Factory.toPool(r);					
				var startY:Number = offsetY;
				var len:int = visibleScreen.blockMap.blocks.length;
				var row:int;
				var col:int;			
				quadBatch.reset();			
				var image:Image = MTCUtil.getGameImageWithScale(BackgroundAsset.BG_LAND_TILE) as Image;
				image.width = rec.width;
				image.height = rec.height;
				for (var i:int = 0; i < len; i++) 
				{
					if (visibleScreen.blockMap.blocks[i])
					{					
						row = i / visibleScreen.blockMap.col;
						col = i % visibleScreen.blockMap.col;
						image.x = col * rec.width;
						image.y = startY + row * rec.height;
						if (image.y >= 0 || image.y <= Util.appHeight)
						{
							quadBatch.addImage(image);						
						}
					}				
				}
				// draw character				
				var cR:Rectangle = visibleScreen.player.getBound();
				var cRInPixel:Rectangle = visibleScreen.blockMap.blockToPixel(cR);				
				cRInPixel.y += startY;
				character.x = (cRInPixel.x - character.x) / 3 + character.x;
				character.y = (cRInPixel.y - character.y) / 3 + character.y;				
				Factory.toPool(rec);
				Factory.toPool(cR);
				Factory.toPool(cRInPixel);
			}
		}
	
	}

}