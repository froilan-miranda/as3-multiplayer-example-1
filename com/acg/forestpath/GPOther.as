package com.acg.forestpath
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;

import com.gskinner.motion.GTween;

public class GPOther extends Bitmap
{
	//private var gameStatus:String;
	private var cloneData:BitmapData;

	private var maxSpeed:Number;
	private var minSpeed:Number;

	private var tweenDown:GTween;

	public function GPOther(cData:BitmapData, speedMax:int, speedMin:int):void
	{
		cloneData = cData;
		maxSpeed = speedMax;
		minSpeed = speedMin;

		if(stage)
			initGamePiece(null);
		else
			this.addEventListener(Event.ADDED_TO_STAGE, initGamePiece);
	}
	private function initGamePiece(e:Event):void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, initGamePiece);
		this.bitmapData = cloneData; 
		this.x = randomRange(0, (parent.width - bitmapData.width));
		this.y = -(bitmapData.height);
		this.width = bitmapData.width;
		this.height = bitmapData.height;

		tweenDown = new GTween(this, randomRange(minSpeed, maxSpeed), {y:ForestPath.STAGE_HEIGHT});
		tweenDown.onComplete = reachedBottom;
	}
	private function randomRange(minNum:int, maxNum:int):int
	{
		return(Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
	}
	private function reachedBottom(e:GTween):void
	{ 
		tweenDown = null;
		this.dispatchEvent(new CustomEvent(CustomEvent.DESTROY_OTHER));
	}
}//class
}//package