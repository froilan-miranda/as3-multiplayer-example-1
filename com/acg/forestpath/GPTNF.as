package com.acg.forestpath
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;

import com.gskinner.motion.GTween;

public class GPTNF extends Bitmap
{
	//private var gameStatus:String;
	private var _active:Boolean;
	private var cloneData:BitmapData;

	private var maxSpeed:Number;
	private var minSpeed:Number;

	private var tweenDown:GTween;

	public function GPTNF(cData:BitmapData, speedMax:int, speedMin:int):void
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
		active = true;
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
		this.dispatchEvent(new CustomEvent(CustomEvent.DESTROY_TNF));
	}
	internal function stopMovement(dx:Number, dy:Number):void
	{
		this.x = dx;
		this.y = dy;
		tweenDown.paused = true;
	}
	internal function set active(setActive:Boolean):void
	{
		_active = setActive;
	}
	internal function get active():Boolean
	{
		return _active;
	}
}//class
}//package