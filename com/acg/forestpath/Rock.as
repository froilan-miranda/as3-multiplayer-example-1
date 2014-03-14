package com.acg.forestpath
{
import flash.display.Sprite;
import fl.motion.easing.*;
import flash.events.Event;
import flash.geom.Point;
import com.gskinner.motion.GTween;
import com.gskinner.motion.GTweenTimeline;
import com.gskinner.motion.plugins.ColorAdjustPlugin;

public class Rock extends Sprite
{
	internal var _owner:PlayerStation;
	private var destinationX:Number;
	private var destinationY:Number;
	private var tweenRock:GTween;
	private var nuetralized:Array = [];
	private var startingPoint:Point;
	private var rockMC:BoulderAnime;

	private var pixelPerSec:Number;
	private const nuetralizedPos:Array = [new Point(-45, -45), new Point(10, -45)];

	public function Rock(station:PlayerStation, dx:Number, dy:Number, start:Point):void
	{
		var _sc:Settings = Settings.instance;
		pixelPerSec = _sc.getValueInt("pixelPerSecond");
		
		this.graphics.beginFill(0xff0000, 0.0);
		this.graphics.drawCircle(0, 0, 100);
		this.graphics.endFill();

		createRock();

		_owner = station;
		this.x = start.x;
		this.y = start.y;
		startingPoint = start;
		destinationX  = dx;
		destinationY = dy;

		if(stage)
			launchAttack(null);
		else
			this.addEventListener(Event.ADDED_TO_STAGE, launchAttack);
	}
	private function createRock():void
	{
		rockMC = new BoulderAnime();
		//rockMC.x = -(rockMC.width/2);
		//rockMC.y = -(rockMC.height/2);
		rockMC.x = 0;
		rockMC.y = 0;
		this.addChild(rockMC);
		rockMC.addFrameScript(rockMC.totalFrames - 1, function():void{rockMC.gotoAndPlay(1);});
		//rockMC.gotoAndPlay(1);
	}
	private function launchAttack(e:Event):void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, launchAttack);
		ssDebug.trace("ATTACK!!!");
		tweenRock = new GTween(this, getDuration(this.x, destinationX, this.y, destinationY), {x: destinationX, y:destinationY});
		tweenRock.onComplete = onImpact;
	}
	private function onImpact(e:GTween):void
	{
		ssDebug.trace("KABOOoommm");
		// do what ever animation for hit and tell manager to hit test
		rockMC.stop();
		this.dispatchEvent(new CustomEvent(CustomEvent.ROCK_IMPACT));
	}
	private function getDuration(x1:Number, x2:Number, y1:Number, y2:Number):Number
	{
		var dx:Number = x1 - x2;
		var dy:Number = y1 - y2;
		var distance:Number = Math.sqrt(dx * dx + dy * dy);
		var duration:Number = Math.abs(distance / pixelPerSec);
		return duration;
	}
	internal function nuetralizeTNF(tnf:GPTNF):void
	{
		if(nuetralized.length < 2){
			nuetralized.push(tnf);
			this.addChild(tnf);
			new GTween(tnf, 0.5, {x:nuetralizedPos[nuetralized.indexOf(tnf)].x, y:nuetralizedPos[nuetralized.indexOf(tnf)].y});
		}
	}
	internal function numTnf():int 
	{
		return nuetralized.length;
	}
	internal function reloadRock():void
	{
		_owner.isFiring = false;
	}
	internal function updateScore():void
	{
		_owner.updateScore(nuetralized.length);
	}
	internal function greyScaleMove():void
	{
		//ColorTransformPlugin.install();
		ColorAdjustPlugin.install();
		var timeline:GTweenTimeline = new GTweenTimeline();

		//var greyScale:GTween = new GTween(this, 2, { redOffset:-256, greenOffset:-256, blueOffset:-256 }, { ease:Circular.easeOut } );

		var greyScale:GTween;
		var tweenOffscreen:GTween;

		switch(nuetralized.length){
			case  0:
				var slope:Number
				//this will check and make sure we do not divide by 0
				slope = ( (startingPoint.x - destinationX) != 0) ?  (startingPoint.y - destinationY) / (startingPoint.x - destinationX) :  (startingPoint.y - destinationY) / 0.1; 
				var b:Number = startingPoint.y - (startingPoint.x * slope);
				var offScreenX = (((0- this.height) - b)/slope);
				var tweenMiss:GTween = new GTween(this,  getDuration(this.x, offScreenX, this.y, -this.height), {x:offScreenX, y:-this.height});
				tweenMiss.onComplete = removeSelf;
				ssDebug.trace("this is case 0: " );
				ssDebug.trace("startingPoint.y:"+startingPoint.y);
				ssDebug.trace("destinationY:"+destinationY);
				ssDebug.trace("startingPoint.x:"+startingPoint.x);
				ssDebug.trace("destinationX:"+destinationX);
				ssDebug.trace("slope: " + slope );
				ssDebug.trace("b: " + b );
				ssDebug.trace("offScreenX: " + offScreenX );
				break;
			case 1:
				greyScale = new GTween(this, 2, { saturation:-75 }, { ease:Circular.easeOut } );
				timeline.addTween(0, greyScale);
				tweenOffscreen = new GTween(this, 1, { x: - this.width, y: - this.height});
				timeline.addTween(1, tweenOffscreen);
				timeline.addCallback(2, removeSelf);
				timeline.calculateDuration();
				timeline.gotoAndPlay(0);
				break;
			case 2:
				greyScale = new GTween(this, 2, { saturation:-75 }, { ease:Circular.easeOut } );
				timeline.addTween(0, greyScale);
				tweenOffscreen = new GTween(this, 1, { x: - this.width, y: - this.height});
				timeline.addTween(1, tweenOffscreen);
				timeline.addCallback(2, removeSelf);
				timeline.calculateDuration();
				timeline.gotoAndPlay(0);
				break;
			default:
				ssDebug.trace("nuetralized tnf's out of limit: " + nuetralized.length);
				break; 
		}
	}
	private function removeSelf(e:GTween = null)
	{
		for each( var tnf:GPTNF in nuetralized){
			this.removeChild(tnf);
			tnf = null;
		}
		nuetralized = null;
		dispatchEvent(new CustomEvent(CustomEvent.ROCK_OFFSCREEN));
	}
}//class
}//package