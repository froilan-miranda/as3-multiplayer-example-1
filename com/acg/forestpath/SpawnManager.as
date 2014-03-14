package com.acg.forestpath
{
import flash.display.Sprite;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.utils.setInterval;
import flash.utils.clearInterval;

import com.acg.forestpath.GPTNF;
import com.gskinner.motion.GTween;

public class SpawnManager extends Sprite
{
	private var maxTNFA:int;  //max count of onscreen tnf-a
	private var maxOther:int;  //max count of onscreen other elements

	private var _aTnf:Array; //list of all onscreen tnf-a
	private var aOther:Array; //list of all onscreen tnf-b, yellow, green, pacman

	private var tnfTempLoader:Loader;  //tnf-a loader
	private var greenTempLoader:Loader;  //green loader
	private var yellowTempLoader:Loader;  //yellow loader
	private var betaTempLoader:Loader;  //beta loader
	private var pacmanTempLoader:Loader;  //pacman loader

	private var bmdTnfMaster:BitmapData; // bitmap data to clone tnf-a from
	private var bmdYellowMaster:BitmapData //bitmap data to clone yellow from
	private var bmdGreenMaster:BitmapData //bitmap data to clone green from
	private var bmdBetaMaster:BitmapData //bitmap data to clone tnf-b from
	private var bmdPacmanMaster:BitmapData //bitmap data to clone Pacman from
	private var otherMasterList:Array // array to choose random other from

	private var intervalTnfId:int;  //reference to TNF interval
	private var intervalOtherId:int; //reference to Other interval
	private var intervalTnfTime:int; //time inbetween intervals
	private var intervalOtherTime:int; //time inbetween intervals

	private var currentLevel:int;//current level of game to be sent to spawn manager for settings purposes
	private var tnfMaxSpeed:int;
	private var tnfMinSpeed:int;
	private var otherMaxSpeed:int;
	private var otherMinSpeed:int;

	private var tweenLevelComplete:GTween;

	public function SpawnManager(lvl:int):void
	{
		currentLevel = lvl;
 		if(stage)
 			loadSettings(null);
 		else
 			this.addEventListener(Event.ADDED_TO_STAGE, loadSettings);
	}

	private function loadSettings(e:Event):void
	{
		var _sc:Settings = Settings.instance;
		maxTNFA = _sc.getValueInt("tnfMaxCount");
		maxOther = _sc.getValueInt("otherMaxCount");		
		intervalTnfTime = _sc.getValueInt("IntervalTnf");
		intervalOtherTime = _sc.getValueInt("IntervalOther");
		if(currentLevel == 1){
			tnfMaxSpeed = _sc.getValueInt("lvl01MaxSpeedTnf");
			tnfMinSpeed = _sc.getValueInt("lvl01MinSpeedTnf");
			otherMaxSpeed = _sc.getValueInt("lvl01MaxSpeedOther");
			otherMinSpeed = _sc.getValueInt("lvl01MinSpeedOther");
		}else if(currentLevel == 2){
			tnfMaxSpeed = _sc.getValueInt("lvl02MaxSpeedTnf");
			tnfMinSpeed = _sc.getValueInt("lvl02MinSpeedTnf");
			otherMaxSpeed = _sc.getValueInt("lvl02MaxSpeedOther");
			otherMinSpeed = _sc.getValueInt("lvl02MinSpeedOther");
		}

		initSpawnManager();
	}

	private function initSpawnManager():void
	{
		trace("spawn manager added to stage");
		this.removeEventListener(Event.ADDED_TO_STAGE, initSpawnManager);

		_aTnf = [];
		aOther = [];

		loadTnfTemp(); 
		loadOtherTemp();

		/*****************************************************
		** we need to add this so that the sprite can be sized
		******************************************************/
		this.graphics.beginFill(0xffffff, 0.0);
		this.graphics.drawRect(0,0,1420, 1080);
		this.graphics.endFill();

		this.width = 1420;
		this.height = ForestPath.STAGE_HEIGHT;
		this.x = 250;
		this.y = 0;
	}

	private function loadTnfTemp():void
	{
		var imageUrl:URLRequest;
		if (ssGlobals.ssStartDir == null) {
			imageUrl = new URLRequest("assets/images/molecules/tnfa.png");
		}else{
			imageUrl = new URLRequest(ssGlobals.ssStartDir + "\\" + "assets/images/molecules/tnfa.png");			
		}
		tnfTempLoader = new Loader();
		tnfTempLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, tnfTempLoaded);
		tnfTempLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		tnfTempLoader.load(imageUrl);
		imageUrl = null;
	}

	private function tnfTempLoaded(e:Event):void
	{
		e.target.removeEventListener(Event.COMPLETE, tnfTempLoaded);
		e.target.removeEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		bmdTnfMaster = e.target.content.bitmapData;
		initIntervalTnf();
		tnfTempLoader.unload();
	}

	private function loadOtherTemp():void
	{
		otherMasterList = [];
		loadGreenTemp();
		loadYellowTemp();
		loadBetaTemp();
		loadPacManTemp();
	}

	private function loadGreenTemp():void
	{
		var imageUrl:URLRequest;
		if (ssGlobals.ssStartDir == null) {
			imageUrl = new URLRequest("assets/images/molecules/green.png");
		}else{
			imageUrl = new URLRequest(ssGlobals.ssStartDir + "\\" + "assets/images/molecules/green.png");
		}
		greenTempLoader = new Loader();
		greenTempLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, greenTempLoaded);
		greenTempLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		greenTempLoader.load(imageUrl);
		imageUrl = null;
	}

	private function loadYellowTemp():void
	{
		var imageUrl:URLRequest;
		if (ssGlobals.ssStartDir == null) {
			imageUrl = new URLRequest("assets/images/molecules/yellow.png");
		}else{
			imageUrl = new URLRequest(ssGlobals.ssStartDir + "\\" + "assets/images/molecules/yellow.png");
		}
		yellowTempLoader = new Loader();
		yellowTempLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, yellowTempLoaded);
		yellowTempLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		yellowTempLoader.load(imageUrl);
		imageUrl = null;
	}

	private function loadBetaTemp():void
	{
		var imageUrl:URLRequest;
		if (ssGlobals.ssStartDir == null) {
			imageUrl = new URLRequest("assets/images/molecules/tnfb.png");
		}else{
			imageUrl = new URLRequest(ssGlobals.ssStartDir + "\\" + "assets/images/molecules/tnfb.png");
		}
		betaTempLoader = new Loader();
		betaTempLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, betaTempLoaded);
		betaTempLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		betaTempLoader.load(imageUrl);
		imageUrl = null;
	}

	private function loadPacManTemp():void
	{
		var imageUrl:URLRequest;
		if (ssGlobals.ssStartDir == null) {
			imageUrl = new URLRequest("assets/images/molecules/pacman.png");
		}else{
			imageUrl = new URLRequest(ssGlobals.ssStartDir + "\\" + "assets/images/molecules/pacman.png");
		}
		pacmanTempLoader = new Loader();
		pacmanTempLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, pacmanTempLoaded);
		pacmanTempLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		pacmanTempLoader.load(imageUrl);
		imageUrl = null;
	}

	private function greenTempLoaded(e:Event):void
	{
		e.target.removeEventListener(Event.COMPLETE, greenTempLoaded);
		e.target.removeEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		bmdGreenMaster = e.target.content.bitmapData;
		otherMasterList.push(bmdGreenMaster);
		completeOtherList();
		greenTempLoader.unload();
	}

	private function yellowTempLoaded(e:Event):void
	{
		e.target.removeEventListener(Event.COMPLETE, yellowTempLoaded);
		e.target.removeEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		bmdYellowMaster = e.target.content.bitmapData;
		otherMasterList.push(bmdYellowMaster);
		completeOtherList();
		yellowTempLoader.unload();
	}

	private function betaTempLoaded(e:Event):void
	{
		e.target.removeEventListener(Event.COMPLETE, betaTempLoaded);
		e.target.removeEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		bmdBetaMaster = e.target.content.bitmapData;
		otherMasterList.push(bmdBetaMaster);
		completeOtherList();
		betaTempLoader.unload();
	}

	private function pacmanTempLoaded(e:Event):void
	{
		e.target.removeEventListener(Event.COMPLETE, pacmanTempLoaded);
		e.target.removeEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		bmdPacmanMaster = e.target.content.bitmapData;
		otherMasterList.push(bmdPacmanMaster);
		completeOtherList();
		pacmanTempLoader.unload();
	}

	private function loaderIOErrorHandler(err:IOErrorEvent):void
	{
		trace("there is a problem loading: " + err.target)
	}

	private function completeOtherList():void
	{
		if(otherMasterList.length == 4) initIntervalOther();
	}

	private function spawnTnf():void
	{
		if(_aTnf.length < maxTNFA){
			var newTnf:GPTNF = new GPTNF(bmdTnfMaster.clone(), tnfMaxSpeed, tnfMinSpeed);
			newTnf.addEventListener(CustomEvent.DESTROY_TNF, onDestroyTnf);
			_aTnf.push(newTnf);
			this.addChild(newTnf);
		}
	}

	private function spawnOther():void
	{
		if(aOther.length < maxOther){
			var newOther:GPOther = new GPOther(otherMasterList[randomRange(0, 3)].clone(), otherMaxSpeed, otherMinSpeed);
			newOther.addEventListener(CustomEvent.DESTROY_OTHER, onDestroyOther);
			aOther.push(newOther);
			this.addChild(newOther);
		}
	}

	private function initIntervalTnf():void
	{
		intervalTnfId = setInterval(spawnTnf, intervalTnfTime);
	} 

	private function initIntervalOther():void
	{
		trace("ready to launch other elements!!!");
		intervalOtherId = setInterval(spawnOther, intervalOtherTime);
	}

	private function onDestroyTnf(e:CustomEvent):void
	{
		var tnf = e.target;
		_aTnf.splice(_aTnf.indexOf(tnf), 1);
		tnf.removeEventListener(CustomEvent.DESTROY_TNF, onDestroyTnf);
		this.removeChild(tnf);
		tnf = null;
	}

	private function onDestroyOther(e:CustomEvent):void
	{
		var other = e.target;
		aOther.splice(_aTnf.indexOf(other), 1);
		other.removeEventListener(CustomEvent.DESTROY_OTHER, onDestroyOther);
		this.removeChild(other);
		other = null;
	}

	internal function removeFromArray(tnf:GPTNF, dx:Number, dy:Number):GPTNF
	{
		tnf.stopMovement(dx, dy);
		_aTnf.splice(_aTnf.indexOf(tnf), 1);
		tnf.removeEventListener(CustomEvent.DESTROY_TNF, onDestroyTnf);
		this.removeChild(tnf);
		return tnf;
	}

	private function randomRange(minNum:int, maxNum:int):int
	{
		return(Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
	}

	internal function onLevelComplete():void
	{
		tweenLevelComplete = new GTween(this, 0.5, {alpha:0});
		tweenLevelComplete.onComplete = unloadManager;
	}

	internal function unloadManager(e:GTween):void
	{
		clearInterval(intervalTnfId);
		for each(var tnf:GPTNF in _aTnf){
			tnf.removeEventListener(CustomEvent.DESTROY_TNF, onDestroyTnf);
			if(this.contains(tnf)) this.removeChild(tnf);
			tnf = null;
		}
		clearInterval(intervalOtherId);
		for each(var other:GPOther in aOther){
			other.removeEventListener(CustomEvent.DESTROY_OTHER, onDestroyOther);			
			if(this.contains(other)) this.removeChild(other);
			other = null;
		}
		_aTnf = [];
		aOther = [];
	}

	internal function get aTnf():Array
	{
		return _aTnf;
	}
}
}