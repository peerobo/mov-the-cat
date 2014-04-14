package com.fc.movthecat.logic
{
	import com.fc.air.base.EffectMgr;
	import com.fc.air.base.Factory;
	import com.fc.air.base.LangUtil;
	import com.fc.air.base.LayerMgr;
	import com.fc.air.base.PopupMgr;
	import com.fc.air.base.SoundManager;
	import com.fc.air.FPSCounter;
	import com.fc.air.Util;
	import com.fc.movthecat.asset.IconAsset;
	import com.fc.movthecat.asset.SoundAsset;
	import com.fc.movthecat.comp.ConfirmDlg;
	import com.fc.movthecat.comp.IconWithText;
	import com.fc.movthecat.Constants;
	import com.fc.movthecat.MTCUtil;
	import com.fc.movthecat.screen.game.GameRender;
	import com.fc.movthecat.screen.GameScreen;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.net.SharedObject;
	import flash.system.System;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class GameSession implements IAnimatable
	{
		public var visibleScreen:VisibleScreen;
		public var input:UserInput;
		public var scrollSpeed:Number;
		public var gravitySpeed:Number;
		public var foodType:int;
		public var foodNum:int;
		public var diamondNum:int;
		private var interval:Number;
		private var timePass:Number;
		private var helperPoint:Point;
		private var scroll2Stage:Boolean;				
		public var challenge:int;
		public var challengeTimeout:Number;
		private var startFood:int;
		private var foodTxt:IconWithText;		
		private var iconTxt:IconWithText;				
		
		public function GameSession()
		{
			interval = 0.033;
			timePass = 0;			
		}
		
		public function loop():void
		{
			if (input.keyPress != UserInput.NONE_KEY) // move player
			{
				var isLeft:Boolean = input.keyPress == UserInput.LEFT_KEY;
				var currBound:Rectangle = visibleScreen.player.tryMoving(isLeft);
				var canMove:Boolean = true;
				var str:String = "";
				canMove &&= visibleScreen.blockMap.checkEmpty(currBound.bottom, currBound.right, visibleScreen.player.y);				
				canMove &&= visibleScreen.blockMap.checkEmpty(currBound.bottom, currBound.left, visibleScreen.player.y);
				if (canMove) // move left right
				{
					visibleScreen.player.move(isLeft);	
				}
				Factory.toPool(currBound);						
				visibleScreen.player.isMoving = true;
			}
			else
			{
				visibleScreen.player.isMoving = false;
			}
			// check character free fall
			var check:Boolean = true;
			var b:Rectangle = visibleScreen.player.getBound();
			if (!helperPoint)
			{
				helperPoint = new Point(b.left, b.right);
			}
			else
			{
				helperPoint.x = b.left;
				helperPoint.y = b.right;
			}
			var dy:Number = gravitySpeed * visibleScreen.player.weight;
			var destY:Number = b.bottom + dy;
			for (var i:int = helperPoint.x; i <= helperPoint.y; i++)
			{
				check &&= visibleScreen.blockMap.checkEmpty(destY, i, visibleScreen.player.y);
			}
			if (check) // continue falling
			{									
				visibleScreen.player.y += gravitySpeed * visibleScreen.player.weight;
			}
			else
			{		
				visibleScreen.player.fallspeed = 0;
			}
			// scroll whole stage
			if (visibleScreen.blockMap.anchorPt != null) 
			{
				if (visibleScreen.blockMap.anchorPt.y >= visibleScreen.blockMap.gameWindow.y)
				{
					visibleScreen.blockMap.validate();
					visibleScreen.blockMap.anchorPt.y -= visibleScreen.blockMap.gameWindow.y;
					visibleScreen.player.y -= visibleScreen.blockMap.gameWindow.y;
					scroll2Stage = false;					
				}
				visibleScreen.blockMap.anchorPt.y += scrollSpeed;				
			}
			Factory.toPool(b);
			if (foodNum == 50)
			{
				foodNum++;
				visibleScreen.blockMap.noDiamond = false;				
			}
			if (challenge != MTCUtil.NO_CHALLENGE)
			{
				challengeTimeout -= interval;
				if (challenge == BlockMap.DIAMOND_NO_FOOD)
				{
					foodTxt.text = (70 - (foodNum - startFood)).toString();
					if (foodNum - startFood >= 70 && foodTxt.visible)
						foodTxt.visible = false;
				}
				if (challengeTimeout <= 0)
				{
					challengeTimeout = MTCUtil.NO_CHALLENGE;
					if (challenge == BlockMap.DIAMOND_NO_FOOD)					
					{
						foodTxt.removeFromParent();
						if (foodNum - startFood >= 70)
							rewardDiamond();
					}
					else
					{
						rewardDiamond();
					}
					
					visibleScreen.blockMap.noDiamond = false;										
					challenge = MTCUtil.NO_CHALLENGE;
					var gS:GameScreen = Factory.getInstance(GameScreen);
					gS.disableEffectSound();
				}								
			}
			if (!scroll2Stage && visibleScreen.checkPlayerOut())
			{
				gameOver();
			}
						
			System.pauseForGCIfCollectionImminent(1);
		}
		
		private function rewardDiamond():void 
		{
			var itemsDB:ItemsDB = Factory.getInstance(ItemsDB);
			itemsDB.addItem(ItemsDB.DIAMOND, 1);
			SoundManager.playSound(SoundAsset.GAIN_DIAMOND);
			iconTxt = new IconWithText();
			iconTxt.alpha = 1;
			iconTxt.text = "+1";
			iconTxt.img = MTCUtil.getGameImageWithScale(IconAsset.ICO_DIAMOND_PREFIX + 0, 7);
			iconTxt.x = Util.appWidth >> 1;
			iconTxt.y = Util.appHeight >> 1;
			EffectMgr.floatObject(iconTxt, new Point(0, (Util.appHeight >> 1) - 80), "y", 1);
			diamondNum++;
		}
		
		public function startNewGame():void
		{
			var rec:Rectangle;
			// create stage
			if (!visibleScreen)
			{
				visibleScreen = Factory.getInstance(VisibleScreen);
				visibleScreen.blockMap.calculateScreenViaLevelStage();
				rec = Factory.getObjectFromPool(Rectangle);
				rec.x = 0;
				rec.width = visibleScreen.blockMap.col;
				rec.y = 1*2;
				rec.height = visibleScreen.blockMap.row - rec.y - (LevelStage.OUT_OF_VIEW - 1 ) * 2;
				visibleScreen.blockMap.gameWindow = rec;
			}
			challengeTimeout = MTCUtil.NO_CHALLENGE;
			challenge = MTCUtil.NO_CHALLENGE;
			visibleScreen.blockMap.noDiamond = true;
			// construct level
			visibleScreen.blockMap.lvlStage.construct();
			// init player position
			visibleScreen.player.x = visibleScreen.blockMap.col >> 1;
			visibleScreen.player.y = -visibleScreen.blockMap.row;			
			rec = Factory.getObjectFromPool(Rectangle);
			rec.setTo(0, 0, visibleScreen.player.wInPixel, visibleScreen.player.hInPixel);
			var recBlock:Rectangle = visibleScreen.blockMap.pixelToBlock(rec);
			visibleScreen.player.h = recBlock.height;	
			visibleScreen.player.fallspeed = 0;
			//visibleScreen.player.w = recBlock.width;
			visibleScreen.blockMap.anchorPt.x = 0;
			visibleScreen.blockMap.anchorPt.y = visibleScreen.player.y;
			visibleScreen.blockMap.timePass = 0;
			visibleScreen.blockMap.validate();
			//visibleScreen.player.weight = 1;
			//visibleScreen.player.speed = 0.25;
			Factory.toPool(rec);
			Factory.toPool(recBlock);
			// init world
			scrollSpeed = 0.2;
			gravitySpeed = 1;
			foodNum = 0;
			diamondNum = 0;
			//gravitySpeed = 0.2;
			// start receive user input
			if(!input)
				input = Factory.getInstance(UserInput);
			input.start();
			// add to loop
			timePass = 0;
			scroll2Stage = true;
			visibleScreen.needRender = true;
			Starling.juggler.add(this);
		}
		
		public function gameOver():void
		{
			if (challenge == BlockMap.DIAMOND_NO_FOOD)					
				foodTxt.removeFromParent();
			visibleScreen.needRender = false;
			var items:ItemsDB = Factory.getInstance(ItemsDB);
			items.addItem(foodType, foodNum);
			var gameScreen:GameScreen = Factory.getInstance(GameScreen);
			gameScreen.gameOver();
			input = Factory.getInstance(UserInput);
			input.stop();
			Starling.juggler.remove(this);
			SoundManager.playSound(SoundAsset.CAT_DIE + foodType + SoundAsset.FILE_TYPE);
			var rateData:SharedObject = Util.getLocalData("rate");			
			if (rateData.data["launchtime"] >= Constants.REMIND_REVIEW)
			{
				rateData.data["launchtime"] = 0;
				var confirmWnd:ConfirmDlg = Factory.getInstance(ConfirmDlg);
				confirmWnd.msg = LangUtil.getText("rateMsg");
				confirmWnd.bts = [
					LangUtil.getText("rate"),
					LangUtil.getText("remindlater"),
					LangUtil.getText("neverask")				
				];
				confirmWnd.callback = onCallbackRate;			
				PopupMgr.addPopUp(confirmWnd);
			}
		}
		
		private function onCallbackRate(idx:int):void 
		{
			var rateData:SharedObject = Util.getLocalData("rate");
			if (idx == 0)
			{
				Util.rateMe();
				rateData.data["launchtime"] = -1;
			}
			else if (idx == 1)
			{				
				rateData.data["launchtime"] = 0;
			}
			else
			{
				rateData.data["launchtime"] = -1;
			}
		}
		
		/* INTERFACE starling.animation.IAnimatable */
		
		public function advanceTime(time:Number):void
		{
			timePass += time;
			if (timePass >= interval)
			{
				loop();
				timePass -= interval;
			}
		}
		
		public function activateDiamondEffect(diamondType:int):void 
		{
			//var so:SharedObject = Util.getLocalData("askDiamond");
			var guideShown:Boolean = false;
			//if (!so.data.hasOwnProperty(diamondType.toString()))	// show guide
			//{
				//var dlg:ConfirmDlg = Factory.getInstance(ConfirmDlg);
				//dlg.msg = LangUtil.getText("guideDiamond" + diamondType);
				//dlg.bts = [LangUtil.getText("neverhint"), LangUtil.getText("close")];
				//dlg.callback = onUserCloseHint;
				//dlg.params = [diamondType];
				//PopupMgr.addPopUp(dlg);				
				//Starling.juggler.remove(this);				
				//var userInput:UserInput = Factory.getInstance(UserInput);
				//userInput.stop();
				//guideShown = true;
			//}
			if (diamondType == BlockMap.DIAMOND_NO_EFFECT)
			{
				rewardDiamond();
			}
			else
			{
				var gameRender:GameRender = Factory.getInstance(GameRender);
				gameRender.startEffectTimeout();
				challenge = diamondType;
				visibleScreen.blockMap.noDiamond = true;
				if (challenge == BlockMap.DIAMOND_NO_CAT)
				{
					challengeTimeout = MTCUtil.CHALLENGE_TIMEOUT_NO_CAT;
				}
				else if (challenge == BlockMap.DIAMOND_NO_FOOD)
				{
					challengeTimeout = MTCUtil.CHALLENGE_TIMEOUT_NO_FOOD;					
					startFood = foodNum;
					if (!guideShown)
					{
						foodTxt = Factory.getInstance(IconWithText);
						foodTxt.visible = true;
						foodTxt.text = "70";
						var img:DisplayObject = MTCUtil.getGameImageWithScale(IconAsset.ICO_FOOD_PREFIX + foodType);
						img.height = 120;
						img.scaleX = img.scaleY;
						foodTxt.img = img;
						foodTxt.alpha = 0.8;					
						LayerMgr.getLayer(LayerMgr.LAYER_EFFECT).addChild(foodTxt);
						Util.g_centerScreen(foodTxt);
					}
				}
				else if (challenge == BlockMap.DIAMOND_NO_BRICK)
				{
					challengeTimeout = MTCUtil.CHALLENGE_TIMEOUT_NO_BRICK;
				}
				var gameScreen:GameScreen = Factory.getInstance(GameScreen);
				gameScreen.activateEffectSound();
			}			
		}
		
		private function onUserCloseHint(idx:int, diamondType:int):void 
		{
			if (idx == 0)
			{
				var so:SharedObject = Util.getLocalData("askDiamond");
				so.data[diamondType.toString()] = true;
			}	
			Starling.juggler.add(this);
			var userInput:UserInput = Factory.getInstance(UserInput);
			userInput.start();
			if (diamondType == BlockMap.DIAMOND_NO_FOOD)
			{
				foodTxt = Factory.getInstance(IconWithText);
				foodTxt.visible = true;
				foodTxt.text = "0";
				var img:DisplayObject = MTCUtil.getGameImageWithScale(IconAsset.ICO_FOOD_PREFIX + foodType);
				img.height = 120;
				img.scaleX = img.scaleY;
				foodTxt.img = img;
				foodTxt.alpha = 0.8;					
				LayerMgr.getLayer(LayerMgr.LAYER_EFFECT).addChild(foodTxt);
				Util.g_centerScreen(foodTxt);
			}
		}
	}

}