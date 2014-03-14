package com.acg.forestpath
{
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import com.vanik.utils.TCPSocketNC;
//import flash.utils.*;

import com.acg.forestpath.VideoPlayer;
import com.gskinner.motion.GTween;

public class SceneStandby extends Sprite
{
	private var videoLoop:VideoPlayer;
	private var sceneTween:GTween;

	public function SceneStandby():void
	{
		trace("Standing by");
		this.alpha = 0.0;
		if (stage)
			initScene(null);
		else 
			this.addEventListener(Event.ADDED_TO_STAGE, initScene);
	}
	
	private function initScene(e:Event):void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, initScene);
		videoLoop = new VideoPlayer(ForestPath.STAGE_WIDTH, ForestPath.STAGE_HEIGHT, "assets/video/IntroLoop.flv", true);
		this.addChild(videoLoop);
		sceneTween = new GTween(this, 1, {alpha:1.0});
		TCPSocketNC.messageTarget = this;  //tell tcp class to use 'this' as reciever for messages
	}


	private function addPlayer1():void
	{
		PlayerInfoManager.addPlayer(1, "aaa");
		trace("added player one");
	}

	private function addPlayer2():void
	{
		PlayerInfoManager.addPlayer(2, "bbb");
		trace("added player two");
	}

	private function addPlayer3():void
	{
		PlayerInfoManager.addPlayer(3, "ccc");
		trace("added player three");
	}

	public function msgProcess(msg:String):void
	{
		ssDebug.trace(msg);
		msg = msg.slice(0, -1); //Remove end of string char
		var msgArray:Array = msg.split("|");
		switch(msgArray[0]){
			case "INITIALIZE":
				this.addPlayer(msgArray[1], msgArray[2]);
				break;
			case "CANCEL":
				this.removePlayer(msgArray[1]);
				break;
			case "GO_INTRO":
				this.EOS();
				break;
			case "RESET":
				onReset();
				break;
			default:
				ssDebug.trace("Unrecognized message: " + msgArray[0]);
				break;
		}
	}

	private function addPlayer(pos:String, name:String):void
	{
		var playerPos:int = int(pos.substring(1,2));
		PlayerInfoManager.addPlayer(playerPos, name);
	}

	private function removePlayer(pos:String):void
	{
		var playerPos:int = int(pos.substring(1,1));
		PlayerInfoManager.removePlayer(playerPos);
	}

	private function EOS():void
	{
		PlayerInfoManager.gatherActive();

		if(PlayerInfoManager.activePlayers.length > 0){
			trace("here is eos");

			var sceneTween:GTween = new GTween(this, 1, {alpha:0.0});
			sceneTween.onComplete = removeScene;
		}
	}

	private function removeScene(e:GTween):void
	{
		this.removeChild(videoLoop);
		videoLoop.closeStream();
		videoLoop = null;

		// Dispatch a 'custom' event.
		this.dispatchEvent(new CustomEvent(CustomEvent.SCENE_EXIT));
	}
	private function onReset():void
	{
		this.removeChild(videoLoop);
		videoLoop.closeStream();
		videoLoop = null;

		this.dispatchEvent(new CustomEvent(CustomEvent.GAME_RESET));
	}
}//class
}//package