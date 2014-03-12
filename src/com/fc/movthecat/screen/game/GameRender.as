package com.fc.movthecat.screen.game
{
	import com.fc.air.base.Factory;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.air.FPSCounter;
	import com.fc.air.res.Asset;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.BackgroundAsset;
	import com.fc.movthecat.asset.MTCAsset;
	import com.fc.movthecat.logic.VisibleScreen;
	import com.fc.movthecat.MTCUtil;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
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
		private var leftCharacter:MovieClip;
		
		public function GameRender()
		{
			super();
			visibleScreen = Factory.getInstance(VisibleScreen);
			quadBatch = new QuadBatch();
			addChild(quadBatch);
			leftCharacter = Factory.getObjectFromPool(MovieClip);
			leftCharacter.visible = false;
			addChild(leftCharacter);
			touchable = false;
		}
		
		public function reset():void
		{
			quadBatch.reset();
		}
		
		public function setCharacter(disp:MovieClip):void
		{
			character = disp;
			addChild(character);
			
			Asset.cloneMV(disp, leftCharacter);
			leftCharacter.play();
			leftCharacter.scaleX = -leftCharacter.scaleX;
			
			visibleScreen.player.wInPixel = character.width - character.width/4;
			visibleScreen.player.hInPixel = character.height;
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
				
				var imageL:Image = MTCUtil.getGameImageWithScale(BackgroundAsset.BG_LAND_LEFT) as Image;
				imageL.width = rec.width;
				imageL.height = rec.height;
				
				var imageR:Image = MTCUtil.getGameImageWithScale(BackgroundAsset.BG_LAND_RIGHT) as Image;
				imageR.width = rec.width;
				imageR.height = rec.height;
				
				var startBlock:Boolean = true;
				for (var i:int = 0; i < len; i++)
				{
					if (visibleScreen.blockMap.blocks[i])
					{
						row = i / visibleScreen.blockMap.col;
						col = i % visibleScreen.blockMap.col;
						imageL.x = imageR.x = image.x = col * rec.width;
						imageL.y = imageR.y = image.y = startY + row * rec.height;
						if (image.y >= 0 || image.y <= Util.appHeight)
						{
							if (startBlock)
								quadBatch.addImage(imageL);
							else if (!visibleScreen.blockMap.blocks[i + 1])
								quadBatch.addImage(imageR);
							else
								quadBatch.addImage(image);
						}
						startBlock = false;
					}
					else
					{
						startBlock = true;
					}
				}
				// draw character				
				var cR:Rectangle = visibleScreen.player.getBound();
				var cRInPixel:Rectangle = visibleScreen.blockMap.blockToPixel(cR);
				cRInPixel.y += startY + rec.height;
				
				var centerChar:Rectangle = Factory.getObjectFromPool(Rectangle);
				centerChar.width = character.width;				
				centerChar.x = cRInPixel.x + (cRInPixel.width - centerChar.width >> 1) ;				
				
				character.x = (centerChar.x - character.x) / 3 + character.x;
				character.y = (cRInPixel.y - character.y) / 3 + character.y;
				leftCharacter.x = character.x + leftCharacter.width;
				leftCharacter.y = character.y;
				if (visibleScreen.player.isLeft)
				{
					character.visible = false;
					leftCharacter.visible = true;
				}
				else
				{
					character.visible = true;
					leftCharacter.visible = false;
				}
				Factory.toPool(rec);
				Factory.toPool(cR);
				Factory.toPool(cRInPixel);
				Factory.toPool(image);
				Factory.toPool(imageR);
				Factory.toPool(imageL);
				Factory.toPool(centerChar);
			}
		}
	
	}

}