package com.acg.forestpath
{
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.Loader;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.utils.setInterval;
import flash.utils.clearInterval;
import flash.utils.setTimeout;
import flash.utils.clearTimeout;
import flash.utils.Timer;
import flash.utils.Dictionary;
import flash.text.TextFieldAutoSize;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.AntiAliasType;
import flash.filters.GlowFilter;
import flash.filters.DropShadowFilter;

import com.acg.forestpath.SpawnManager;
import com.vanik.utils.TCPSocketNC;
import com.gskinner.motion.GTween;

public class SceneLevel01 extends Sprite
{
	private var bgLoader:Loader;
	private var bmpBG:Bitmap;
	private var playerStations:Array;
	private var spawnManager:SpawnManager;
	private var rockManager:RockManager;
	private var reticleManager:ReticleManager;
	private var _jsController:JoyStickController;
	private var levelTime:Timer;
	private var waitOnComplete:int;
	private var completeTimeoutId:int;
	private var levelComplete:TextField;
	private var highScore:TextField;
	private static var _timeLimit:int;
	private var winningTree:TimerTree;
	private var sceneTween:GTween;

	private var p1Color:Array = new Array("0x76bfff", "0x044490");
	private var p2Color:Array = new Array("0x8f06b4", "0x51056a");
	private var p3Color:Array = new Array("0xdacb0b", "0x726d0b");
	private var p4Color:Array = new Array("0xff0340", "0x810223");

	private var colorAtlas:Array = new Array(p1Color, p2Color, p3Color, p4Color);

	public function SceneLevel01():void
	{
		trace("Level 01 initiated");
		this.alpha = 0.0;
		if(stage)
			loadSettings(null);
		else
			this.addEventListener(Event.ADDED_TO_STAGE, loadSettings);
	}

	private function loadSettings(e:Event):void
	{
		var _sc:Settings = Settings.instance;
		waitOnComplete = _sc.getValueInt("waitOnComplete");

		initScene();
	}
	
	private function initScene():void
	{
		loadBG();
		queAudioBG();

		if (ssGlobals.ssStartDir != null){
			_jsController = JoyStickController.instance;
			_jsController.addEventListener(CustomEvent.JOYSTICK_DATA_READY, processJoystickData);
		}

		this.removeEventListener(Event.ADDED_TO_STAGE, initScene);
		trace("level 01 added to stage");
		playerStations = []; //initiate stations array
		createPlayerStations();
		createSpawnManager();
		initTimer();

		TCPSocketNC.messageTarget = this;  //tell tcp class to use 'this' as reciever for messages
	}

	private function queAudioBG():void
	{
		Audio.playGameSound(0);
	}
	
	private function initTimer():void
	{
		levelTime = new Timer(1000, _timeLimit);
		levelTime.addEventListener(TimerEvent.TIMER, scaleTrees);
		//levelTime.addEventListener(TimerEvent.TIMER_COMPLETE,  onLevelComplete)
		levelTime.start();
	}

	public function msgProcess(msg:String):void
	{
		ssDebug.trace(msg);
		msg = msg.slice(0, -1); //Remove end of string char
		var msgArray:Array = msg.split("|");
		switch(msgArray[0]){
			case "TIMES_UP":
				this.onLevelComplete();
				rockManager.timeExpired = true;
				break;
			case "GO_SCORES":
				EOS();
				break;
			case "RESET":
				this.onReset();
				break;
			default:
				ssDebug.trace("Unrecognized message: " + msgArray[0]);
				break;
		}
	}

	private function onLevelComplete():void
	{
		levelTime.removeEventListener(TimerEvent.TIMER, scaleTrees);
		//levelTime.removeEventListener(TimerEvent.TIMER_COMPLETE, onLevelComplete);
		ssDebug.trace("level on time up");
		_jsController.jStickStop();
		spawnManager.onLevelComplete();
		reticleManager.onLevelComplete();
		Audio.stopSoundChannel(0);
		Audio.playTimeOutSound(0);
		TCPSocketNC.sendRequest(PlayerInfoManager.allScores);

		//add text
		var format1:TextFormat = new TextFormat();
		format1.font =  new Helvetica_ExtraCompressed().fontName;
		format1.color = 0x410715;
		format1.size = 144;
		format1.align = "center";
		format1.letterSpacing = 3;

		levelComplete = new TextField();
		levelComplete.embedFonts = true;
		levelComplete.selectable=false;
		levelComplete.autoSize = TextFieldAutoSize.CENTER;
		levelComplete.antiAliasType = AntiAliasType.ADVANCED;
		levelComplete.defaultTextFormat = format1;
		levelComplete.text = "LEVEL ONE\nCOMPLETE";
		levelComplete.x = (ForestPath.STAGE_WIDTH - levelComplete.width)/2;
		levelComplete.y =  (ForestPath.STAGE_HEIGHT - levelComplete.height)/2;
		levelComplete.filters = [new GlowFilter(0x180308, 1.0, 2, 2, 4), new DropShadowFilter(0, 45, 0x180308, 0.43, 11.0, 11.0, 1.0, 1.0, false, false, false)];

		this.addChild(levelComplete);

		format1 = null;

		completeTimeoutId = setTimeout(showWinner, waitOnComplete);
	}

	private function showWinner(){
		this.removeChild(levelComplete);

		fadeStations();
		var highScoreData:Array = PlayerInfoManager.highScore;
		TCPSocketNC.sendRequest("WINNER|P" + highScoreData[0]); //send host top scoring player

		//add text
		var format1:TextFormat = new TextFormat();
		format1.font =  new Helvetica_ExtraCompressed().fontName;
		format1.color = colorAtlas[highScoreData[0] - 1][0];
		format1.size = 120;

		highScore = new TextField();
		highScore.embedFonts = true;
		highScore.selectable=false;
		highScore.autoSize = TextFieldAutoSize.LEFT;
		highScore.antiAliasType = AntiAliasType.ADVANCED;
		highScore.defaultTextFormat = format1;
		highScore.text = "CONGRATULATIONS PLAYER " + highScoreData[0] + "!";
		highScore.x = (ForestPath.STAGE_WIDTH - highScore.width)/2;
		highScore.y =  (ForestPath.STAGE_HEIGHT - highScore.height - 70);
		highScore.filters = [new GlowFilter(colorAtlas[highScoreData[0] - 1][1], 1.0, 2, 2, 4), new DropShadowFilter(0, 45, 0x180308, 0.43, 11.0, 11.0, 1.0, 1.0, false, false, false)];
		this.addChild(highScore);
		trace("level complete box added" + highScore.y + "|" + highScore.x);

		format1 = null;

		Audio.playCongratsSound(0);
		//highScoreTimeoutId = setTimeout(EOS, waitOnHighScore);
	}

	private function fadeStations():void
	{
		var highScoreData:Array = PlayerInfoManager.highScore;

		for each(var pStation:PlayerStation in playerStations){
			if(pStation.stationNumber != highScoreData[0]){
				new GTween(pStation, 1, {alpha:0});
			}else{
				var globalPos:Point = pStation.globalTreePos();
				winningTree = pStation.winningTree();
				this.addChild(winningTree);
				winningTree.x = globalPos.x;
				winningTree.y = globalPos.y;
				new GTween(winningTree, 1, { scaleX:1.0, scaleY:1.0, x: 725, y:60})
			}
		}
	}

	private function scaleTrees(e:TimerEvent):void
	{
		for each(var pStation:PlayerStation in playerStations){
			pStation.updateTree(levelTime.currentCount, levelTime.repeatCount);
		}
	}

	private function createRockManager():void
	{
		rockManager = new RockManager(spawnManager);
		this.addChild(rockManager);

		sceneTween = new GTween(this, 1, {alpha:1.0});
	}

	private function createSpawnManager():void
	{
		spawnManager = new SpawnManager(1);
		this.addChild(spawnManager);

		if(reticleManager){
			var reticleIndex = this.getChildIndex(reticleManager);
			this.setChildIndex(spawnManager, reticleIndex)
		}
		createRockManager();
	}

	private function createPlayerStations():void
	{
		//create Reticle Manager to hold all player reticles
		reticleManager = new ReticleManager();
		this.addChild(reticleManager);
		this.setChildIndex(reticleManager,this.numChildren - 1);

		_jsController.jStickStart();// start reacting to joystick data

		// loop through active players and create a station for them
		for each(var index:PlayerInfo in PlayerInfoManager.activePlayers){
			//create station and send player info ref
			var newStation:PlayerStation = new PlayerStation(index, reticleManager.jStickAtlas[index.position - 1]);
			newStation.addEventListener(CustomEvent.FIRE_READY, launchRock);
			//create reticle for player
			reticleManager.addReticle(newStation);
			//and add to stations lists
			playerStations.push(newStation);
			this.addChild(newStation);
		}
	}

	private function loadBG():void
	{
		var imageUrl:URLRequest;
		if (ssGlobals.ssStartDir == null) {
			imageUrl = new URLRequest("assets/images/bg/bg_forest.png");
		}else{
			imageUrl = new URLRequest(ssGlobals.ssStartDir + "\\" + "assets/images/bg/bg_forest.png");			
		}
		bgLoader = new Loader();
		bgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, bgLoaded);
		bgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		bgLoader.load(imageUrl);
		imageUrl = null;
	}

	private function bgLoaded(e:Event):void
	{
		e.target.removeEventListener(Event.COMPLETE, bgLoaded);
		e.target.removeEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		bmpBG = new Bitmap();
		bmpBG = e.target.content;
		bmpBG.x = 0;
		bmpBG.y = 0;
		bgLoader.unload();
		this.addChild(bmpBG);
		this.setChildIndex(bmpBG,0);
	}

	private function loaderIOErrorHandler(err:IOErrorEvent):void
	{
		trace("there is a problem loading: " + err.target)
	}

	private function processJoystickData(e:CustomEvent):void
	{
		// get data from joystick controller instance
		var jData = _jsController.joystickData;

		//set default namespace on xml 
		var nsDefault:Namespace  = new Namespace("http://schemas.datacontract.org/2004/07/viJoystickLib");
		default xml namespace = nsDefault;

		var activeReticles:Dictionary = reticleManager.activeReticles;
		for (var key:Object in activeReticles){
			var serial:String = activeReticles[key];
			var newX:String = jData.Joysticks.Joystick.(Serial == serial).X;
			var newY:String = jData.Joysticks.Joystick.(Serial == serial).Y;
			key.newPos(Number(newX), Number(newY));
			if(jData.Joysticks.Joystick.(Serial == serial).Thumb.toString() == "true"){
				var firePos:Point = key.currentPos();
				var station:PlayerStation = key.playerStation;
				station.requestFire(firePos.x, firePos.y);
			}
		}

		default xml namespace = new Namespace("");
		//ssDebug.trace(jData);
		//ssDebug.trace(jData.Joysticks.Joystick.(Serial == index.joystickSerial).X);
		//ssDebug.trace(jData.Joysticks.Joystick.(Serial == index.joystickSerial).Y);
	}

	private function launchRock(e:CustomEvent):void
	{
		ssDebug.trace("ready to launch attack!!!");
		rockManager.launchRock(e.target as PlayerStation, e.target.targetX	, e.target.targetY);
	}

	private function EOS():void
	{
		trace("here is eos");
		sceneTween = new GTween(this, 1.0, {alpha:0.0});
		sceneTween.onComplete = removeScene;
	}

	private function removeScene(e:GTween):void
	{
		clearTimeout(completeTimeoutId);
		_jsController.removeEventListener(CustomEvent.JOYSTICK_DATA_READY, processJoystickData);
		this.removeChild(highScore);
		this.removeChild(rockManager);
		this.removeChild(reticleManager);
		this.removeChild(bmpBG);
		this.removeChild(winningTree);
		for each(var station:PlayerStation in playerStations){
			this.removeChild(station);
			station = null;
		}
		//look into the bg code, may need to be removed
		_jsController = null;
		levelComplete = null;
		rockManager = null;
		reticleManager = null;
		bmpBG = null;
		winningTree = null;

		// Dispatch a 'custom' event.
		this.dispatchEvent(new CustomEvent(CustomEvent.SCENE_EXIT));
	} 

	private function onReset():void
	{
		clearTimeout(completeTimeoutId);
		_jsController.removeEventListener(CustomEvent.JOYSTICK_DATA_READY, processJoystickData);
		if(highScore)this.removeChild(highScore);
		this.removeChild(rockManager);
		this.removeChild(reticleManager);
		this.removeChild(bmpBG);
		if(winningTree) this.removeChild(winningTree);
		for each(var station:PlayerStation in playerStations){
			this.removeChild(station);
			station = null;
		}
		//look into the bg code, may need to be removed
		_jsController = null;
		levelComplete = null;
		rockManager = null;
		reticleManager = null;
		bmpBG = null;
		winningTree = null;
		Audio.stopSoundChannel(0);
		this.dispatchEvent(new CustomEvent(CustomEvent.GAME_RESET));
	}

	internal static function set timeLimit(gameTime:int):void
	{
		_timeLimit = gameTime;
	}
}
}