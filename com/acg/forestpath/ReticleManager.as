package com.acg.forestpath
{
import flash.display.Sprite;
import flash.geom.Point;
import flash.utils.Dictionary;
import com.gskinner.motion.GTween;

public class ReticleManager extends Sprite
{
	private const reticleAtlas:Array = ["p1_target.png", "p2_target.png", "p3_target.png", "p4_target.png"]; //hold addy of images
	private const initPos:Array = [new Point(125, 800), new Point(480, 800), new Point(830, 800), new Point(1180, 800)];
	//private const _jStickAtlas:Array = ["268760", "260695", "260708", "260563"]; //keep track of joystick serial numbers
	private var _jStickAtlas:Array;
	private var _activeReticles:Dictionary;
	private var tweenLevelComplete:GTween;

	public function ReticleManager():void
	{
		var _sc:Settings = Settings.instance;
		var serialNumbers = _sc.getValueString("serials");
		_jStickAtlas = serialNumbers.split("|");

		initReticlaManager();
	}

	private function initReticlaManager():void
	{
		_activeReticles = new Dictionary();

		/*****************************************************
		** we need to add this so that the sprite can be sized
		******************************************************/
		this.graphics.beginFill(0xff0000, 0.0);
		this.graphics.drawRect(0,0,1420,  ForestPath.STAGE_HEIGHT - 250);
		this.graphics.endFill();

		this.width = 1420;
		this.height = ForestPath.STAGE_HEIGHT - 250;
		this.x = 250;
		this.y = 0;
	}

	internal function addReticle(station:PlayerStation):void
	{
		var newReticle:Reticle = new Reticle(station, reticleAtlas[station.stationNumber-1],initPos[station.stationNumber-1])
		_activeReticles[newReticle] = _jStickAtlas[station.stationNumber - 1];
		this.addChild(newReticle);
	}

	internal function onLevelComplete():void
	{
		tweenLevelComplete = new GTween(this, 0.5, {alpha:0.0});
		tweenLevelComplete.onComplete = unloadManager;
	}

	internal function unloadManager(e:GTween):void
	{
		for (var key:Object in _activeReticles) delete _activeReticles[key];
	}

	internal function get activeReticles():Dictionary
	{
		return _activeReticles
	}

	internal function get jStickAtlas():Array
	{
		return _jStickAtlas;
	}
}//class
}//package