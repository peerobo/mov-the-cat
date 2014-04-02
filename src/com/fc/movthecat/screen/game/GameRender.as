package com.fc.movthecat.screen.game
{
	import com.fc.air.base.Factory;
	import com.fc.air.base.GameService;
	import com.fc.air.base.SoundManager;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.air.FPSCounter;
	import com.fc.air.res.Asset;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.BackgroundAsset;
	import com.fc.movthecat.asset.IconAsset;
	import com.fc.movthecat.asset.MTCAsset;
	import com.fc.movthecat.asset.SoundAsset;
	import com.fc.movthecat.Constants;
	import com.fc.movthecat.logic.BlockMap;
	import com.fc.movthecat.logic.GameSession;
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
	import starling.events.Event;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class GameRender extends LoopableSprite
	{
		private var character:MovieClip;
		private var visibleScreen:VisibleScreen;
		private var quadBatch:QuadBatch;
		private var leftCharacter:MovieClip;
		private var previousState:Boolean;
		private var foodTex:String;
		
		public function GameRender()
		{
			super();
			visibleScreen = Factory.getInstance(VisibleScreen);
			quadBatch = new QuadBatch();			
			
			touchable = false;			
		}
		
		public function reset():void
		{
			quadBatch.reset();
		}
		
		override public function onRemoved(e:Event):void 
		{
			character = null;
			leftCharacter = null;
			quadBatch.removeFromParent();
			super.onRemoved(e);
			
		}
		
		override public function onAdded(e:Event):void 
		{
			addChildAt(quadBatch,0);
			super.onAdded(e);
		}
		
		public function setCharacter(disp:MovieClip):void
		{
			leftCharacter = Factory.getObjectFromPool(MovieClip);
			leftCharacter.visible = false;
			addChild(leftCharacter);
			character = disp;
			addChild(character);
			
			Asset.cloneMV(disp, leftCharacter);
			leftCharacter.play();			
			leftCharacter.scaleX = -leftCharacter.scaleX;
			
			visibleScreen.player.wInPixel = character.width;
			visibleScreen.player.hInPixel = character.height;
			
			var gameSession:GameSession = Factory.getInstance(GameSession);
			foodTex = IconAsset.ICO_FOOD_PREFIX + gameSession.foodType;
		}
		
		override public function update(time:Number):void
		{
			super.update(time);
			if (previousState != visibleScreen.needRender)
			{
				previousState = visibleScreen.needRender;
				if (visibleScreen.needRender)
				{
					leftCharacter.visible = false;
					Starling.juggler.add(leftCharacter);
				}
				else
				{
					leftCharacter.removeFromParent();
					Factory.toPool(leftCharacter);
					leftCharacter = null;
					character.visible = false;
					//character.removeFromParent();
					//Factory.toPool(character);
					//character = null;
					Starling.juggler.remove(leftCharacter);					
					leftCharacter = null;	
					character = null;
				}
			}			
			if (visibleScreen.needRender)
			{				
				var gameSession:GameSession = Factory.getInstance(GameSession);
				var hitRec1:Rectangle = Factory.getObjectFromPool(Rectangle);
				var hitRec2:Rectangle = Factory.getObjectFromPool(Rectangle);
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
				
				var foodImg:Image = MTCUtil.getGameImageWithScale(foodTex) as Image;
				if(foodImg.width > rec.width)
				{
					foodImg.width = rec.width;
					foodImg.scaleY = foodImg.scaleX;
				}
				if(foodImg.height > rec.height)
				{
					foodImg.height = rec.height;
					foodImg.scaleX = foodImg.scaleY;
				}
				hitRec1.width = foodImg.width;
				hitRec1.height = foodImg.height;
				// draw character				
				var cR:Rectangle = visibleScreen.player.getBound();
				var cRInPixel:Rectangle = visibleScreen.blockMap.blockToPixel(cR);
				cRInPixel.y += startY + rec.height - 30;
				
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
				if (visibleScreen.player.isMoving)
				{
					if (!leftCharacter.isPlaying)
					{
						leftCharacter.play();
						character.play();
					}					
				}
				else
				{
					if (leftCharacter.isPlaying)
					{
						leftCharacter.stop();
						character.stop();
						leftCharacter.currentFrame = 0;
						character.currentFrame = 0;
					}
				}
				
				
				var startBlock:Boolean = true;
				for (var i:int = 0; i < len; i++)
				{
					if (visibleScreen.blockMap.blocks[i] == BlockMap.B_BRICK)
					{
						row = i / visibleScreen.blockMap.col;
						col = i % visibleScreen.blockMap.col;
						imageL.x = imageR.x = image.x = col * rec.width;
						imageL.y = imageR.y = image.y = startY + row * rec.height;
						if (image.y >= 0 || image.y <= Util.appHeight)
						{
							if (startBlock)
								quadBatch.addImage(imageL);
							else if (!visibleScreen.blockMap.blocks[i + 1] == BlockMap.B_BRICK)
								quadBatch.addImage(imageR);
							else
								quadBatch.addImage(image);
						}
						startBlock = false;
					}
					else if(visibleScreen.blockMap.blocks[i] == BlockMap.B_FOOD)
					{
						row = i / visibleScreen.blockMap.col;
						col = i % visibleScreen.blockMap.col;
						foodImg.x = col * rec.width;
						foodImg.y = startY + row * rec.height;
						hitRec1.x = foodImg.x;
						hitRec1.y = foodImg.y;												
						character.getBounds(Starling.current.stage, hitRec2);
						if (hitRec1.intersects(hitRec2))
						{
							visibleScreen.blockMap.blocks[i] = -1;
							visibleScreen.blockMap.ateFood(i);
							gameSession.foodNum++;
							
							if (gameSession.foodNum >= 100)
							{
								var gameService:GameService = Factory.getInstance(GameService);
								if(gameSession.foodNum >= 1000)
									gameService.unlockAchievement(Constants.ACH_100PT);
								else if(gameSession.foodNum >= 500)
									gameService.unlockAchievement(Constants.ACH_50PT);
								else if(gameSession.foodNum >= 200)
									gameService.unlockAchievement(Constants.ACH_20PT);
								else
									gameService.unlockAchievement(Constants.ACH_10PT);								
							}
								
							SoundManager.playSound(SoundAsset.CAT_ATE);
						}
						else
						{
							quadBatch.addImage(foodImg);
						}
						startBlock = true;
					}
					else
					{
						startBlock = true;
					}
				}
				
				Factory.toPool(rec);
				Factory.toPool(hitRec1);
				Factory.toPool(hitRec2);
				Factory.toPool(cR);
				Factory.toPool(cRInPixel);				
				Factory.toPool(centerChar);
				Factory.toPool(foodImg);
				Factory.toPool(imageR);
				Factory.toPool(imageL);
				Factory.toPool(image);
			}
		}
	
	}

}