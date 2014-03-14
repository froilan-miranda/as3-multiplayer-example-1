package com.acg.forestpath
{
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.Loader;
import flash.geom.Point;
import flash.events.Event;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;

public class Reticle extends Sprite
{
	private var bmReticle:Bitmap;
	private var reticleLoader:Loader;
	private var bmSrc:String;
	private var _playerStation:PlayerStation;
	private var xBounds:Number;
	private var yBounds:Number;
	private var initX:int;
	private var initY:int;
	private var reticleMultiplier:int;
	private var deadZone:Number;

	public function Reticle(station:PlayerStation, imgSrc:String, initPos:Point):void
	{
		bmSrc = imgSrc;
		_playerStation = station;
		initX = initPos.x;
		initY = initPos.y;
		var _sc:Settings = Settings.instance;
		reticleMultiplier = _sc.getValueInt("reticleMulitiplier");
		deadZone = _sc.getValueNum("deadZone");

		if(stage)
			initReticle(null);
		else
			this.addEventListener(Event.ADDED_TO_STAGE, initReticle);
	}

	private function initReticle(e:Event):void
	{
		xBounds = parent.width;
		yBounds = parent.height;
		loadReticle();
	}

	private function loadReticle():void
	{
		var imageUrl:URLRequest;

		if (ssGlobals.ssStartDir == null) {
			imageUrl = new URLRequest("assets/images/reticle/" + bmSrc);
		}else{
			imageUrl = new URLRequest(ssGlobals.ssStartDir + "\\" + "assets/images/reticle/" + bmSrc);			
		}

		reticleLoader = new Loader();
		reticleLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, reticleLoaded);
		reticleLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		reticleLoader.load(imageUrl);
		imageUrl = null;
	}

	private function reticleLoaded(e:Event):void
	{
		e.target.removeEventListener(Event.COMPLETE, reticleLoaded);
		e.target.removeEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		bmReticle = e.target.content;
		bmReticle.x -= bmReticle.width/2;
		bmReticle.y -= bmReticle.height/2;
		this.addChild(bmReticle);
		this.x = initX;
		this.y = initY;

		trace("reticle add to stage");
		reticleLoader.unload();
	}
	
	private function loaderIOErrorHandler(err:IOErrorEvent):void
	{
		trace("there is a problem loading: " + err.target);
	}
	
	internal function newPos(newX:Number, newY:Number):void
	{
		updateX(newX);
		updateY(newY);
	}
	
	private function updateX(newX:Number):void
	{
		var dx = this.x +newX * reticleMultiplier;
		if(Math.abs(newX) > deadZone){
			if(dx >= 0 && dx <= xBounds)
				this.x = dx;
			else if(dx < 0)
				this.x = 0;
			else if(dx > xBounds)
				this.x = xBounds;
		}
	}
	
	private function updateY(newY:Number):void
	{
		//newY = ((newY - 1) * 0.5) * -yBounds;
		//this.y = newY;
		var dy = this.y + -newY * reticleMultiplier
		if(Math.abs(newY) > deadZone){
			if(dy >= 0 && dy <= yBounds)
				this.y = dy;
			else if(dy < 0)
				this.y = 0;
			else if(dy > yBounds)
				this.y = yBounds;
		}
	}

	internal function currentPos():Point
	{
		return  new Point(this.x, this.y);
	}

	internal function get playerStation():PlayerStation
	{
		return _playerStation;
	}
}//class
}//package