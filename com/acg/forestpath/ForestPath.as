package com.acg.forestpath
{
import flash.display.Sprite;
import flash.ui.Mouse;
import com.acg.forestpath.Settings;
import com.acg.forestpath.SceneStandby;
import com.acg.forestpath.JoyStickController;
import com.vanik.utils.TCPSocketNC;

public class ForestPath extends Sprite
{
	
	private var sceneArray:Array;
	private var currentScene:int;
	private var settings:Settings;
	private var joystick:JoyStickController;
	private var standby:SceneStandby;
	private var intro1:SceneIntro01;
	private var lvl1:SceneLevel01;
	private var score1:SceneScore01;
	private var intro2:SceneIntro02;
	private var lvl2:SceneLevel02;
	private var score2:SceneScore02;
	private var highScore:SceneHighscore;

	internal static const STAGE_WIDTH = 1920;
	internal static const STAGE_HEIGHT = 1080;

	public function  ForestPath():void
	{
		trace("get ready to defend your garden!");
		ssCore.init();
		ssDefaults.synchronousCommands = true;

		initSettings();	// begin importing settings from xml

		// setup array to manage scenes
		sceneArray = new Array("setup", "standby", "intro1", "level1", "score1", "intro2", "level2", "score2", "highscore");
		
		if(ssGlobals.ssStartDir != null) initJoystick();	// start up joystick plugin
		Mouse.hide();
	}
	
	public function initSettings():void
	{
		currentScene = 0; //set current scene, this relates to sceneArray

		//var _sc:Settings = Settings.instance;// this will ref our setting obj through a static function
		settings = new Settings();  // kick off some constructor code
		settings.addEventListener(CustomEvent.XML_LOADED, onSettingsLoaded);  // custom event for when all data is loaded
	}

	private function onSettingsLoaded(e:CustomEvent):void
	{
		TCPSocketNC.test();
		TCPSocketNC.init(settings.getValueString("hostIP"), settings.getValueInt("port"));
		//TCPSocketNC.init("10.0.0.70", 4443);
		TCPSocketNC.createSocket();
		loadNextScene(); // move to next scene
	}

	private function initJoystick():void
	{
		ssDebug.trace("loading next scene");
		joystick = new JoyStickController();
	}

	private function initStandby():void
	{
		currentScene = 1;
		standby = new SceneStandby();
		this.addChild(standby);
		standby.addEventListener(CustomEvent.SCENE_EXIT, onSceneExit);
		standby.addEventListener(CustomEvent.GAME_RESET, onReset);
	}

	private function initIntro01():void
	{
		currentScene = 2;
		intro1 = new SceneIntro01();
		this.addChild(intro1);
		intro1.addEventListener(CustomEvent.SCENE_EXIT, onSceneExit);
		intro1.addEventListener(CustomEvent.GAME_RESET, onReset);
	}

	private function initLvl01():void
	{
		currentScene = 3;
		lvl1 = new SceneLevel01();
		this.addChild(lvl1);
		lvl1.addEventListener(CustomEvent.SCENE_EXIT, onSceneExit);
		lvl1.addEventListener(CustomEvent.GAME_RESET, onReset);
	}

	private function initScore01():void
	{
		currentScene = 4;
		score1 = new SceneScore01();
		this.addChild(score1);
		score1.addEventListener(CustomEvent.SCENE_EXIT, onSceneExit);
		score1.addEventListener(CustomEvent.GAME_RESET, onReset);
	}

	private function initIntro02():void
	{
		currentScene = 5;
		intro2 = new SceneIntro02();
		this.addChild(intro2);
		intro2.addEventListener(CustomEvent.SCENE_EXIT, onSceneExit);
		intro2.addEventListener(CustomEvent.GAME_RESET, onReset);
	}

	private function initLvl02():void
	{
		currentScene = 6;
		lvl2 = new SceneLevel02();
		this.addChild(lvl2);
		lvl2.addEventListener(CustomEvent.SCENE_EXIT, onSceneExit);
		lvl2.addEventListener(CustomEvent.GAME_RESET, onReset);
	}

	private function initScore02():void
	{
		currentScene = 7;
		score2 = new SceneScore02();
		this.addChild(score2);
		score2.addEventListener(CustomEvent.SCENE_EXIT, onSceneExit);
		score2.addEventListener(CustomEvent.GAME_RESET, onReset);
	}

	private function initHighScore():void
	{
		currentScene = 8;
		highScore = new SceneHighscore();
		this.addChild(highScore);
		highScore.addEventListener(CustomEvent.SCENE_EXIT, onSceneExit);
		highScore.addEventListener(CustomEvent.GAME_RESET, onReset);
	}

	private function loadNextScene():void
	{
		var nextScene:int;

		if (currentScene == sceneArray.length - 1) {
			nextScene = 1;
		} else {
			nextScene = currentScene + 1;
		}

		trace("Unloaded: " + sceneArray[currentScene] + "|Loading: " + sceneArray[nextScene]);

		switch (nextScene) {
			case 0 :// settup
				//this should never be true. setup happens only once on initiation
				trace("trying to load setup code, not good :(");
				break;
			case 1 ://splash scene
				trace("LOADING STANDBY");
				initStandby();
				break;
			case 2 ://intro 1 scene
				initIntro01();
				break;
			case 3 : //level 1 scene
				initLvl01();
				break;
			case 4 : //score 1 scene
				initScore01();
				break;
			case 5 : //intro 2 scene
				initIntro02();
				break;
			case 6 : //level 2 scene
				initLvl02();
				break;
			case 7 : //score 2 scene
				initScore02();
				break;
			case 8 : //score daily high score scene
				initHighScore();
				break;
			default ://whatever is left over
				trace("shouldn't be here : " + nextScene);
				break;
		}
	}

	private function onSceneExit(e:CustomEvent):void 
	{
		trace("scene to remove: " + e.target);
		var scene = e.target;

		scene.removeEventListener(CustomEvent.SCENE_EXIT, onSceneExit);
		scene.removeEventListener(CustomEvent.GAME_RESET, onReset);
		this.removeChild(scene);
		scene = null;
		trace("scene removed");
		loadNextScene();
	}

	private function onReset(e:CustomEvent):void
	{
		trace("Game Resetting");
		trace("scene to remove: " + e.target);
		var scene = e.target;
		scene.removeEventListener(CustomEvent.SCENE_EXIT, onSceneExit);
		scene.removeEventListener(CustomEvent.GAME_RESET, onReset);
		this.removeChild(scene);
		scene = null;
		PlayerInfoManager.onReset();

		currentScene = 0;
		loadNextScene();
	}
}//class
}//package