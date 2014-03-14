package com.acg.forestpath
{
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;

import com.acg.forestpath.VideoPlayer;
import com.vanik.utils.TCPSocketNC;
import com.gskinner.motion.GTween;

public class SceneIntro02 extends Sprite
{
	private var videoIntro:VideoPlayer;
	private var videoComplete:Boolean = false;
	private var sceneTween:GTween;

	public function SceneIntro02():void
	{
		ssDebug.trace("introduction 02");
		this.alpha = 0.0;
		if(stage)
			initScene(null);
		else
			this.addEventListener(Event.ADDED_TO_STAGE, initScene);
	}

	private function initScene(e:Event):void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, initScene);
		videoIntro = new VideoPlayer(ForestPath.STAGE_WIDTH, ForestPath.STAGE_HEIGHT, "assets/video/Intro02.flv", false);
		videoIntro.addEventListener(CustomEvent.VIDEO_STOP, onPlayStop);
		this.addChild(videoIntro);

		sceneTween = new GTween(this, 1, {alpha:1.0});

		TCPSocketNC.messageTarget = this;  //tell tcp class to use 'this' as reciever for messages

		queAudioBG();
	}

	private function queAudioBG():void
	{
		Audio.playAlertSound(0);
	}

	private function onCuePoint(e:CustomEvent):void
	{
		TCPSocketNC.sendRequest("INTRO_CUE");
		videoIntro.pause();
	}

	private function onPlayStop(e:CustomEvent):void
	{
		TCPSocketNC.sendRequest("INTRO_END");
		videoComplete = true;
	}

	public function msgProcess(msg:String):void
	{
		ssDebug.trace(msg);
		msg = msg.slice(0, -1); //Remove end of string char
		var msgArray:Array = msg.split("|");
		switch(msgArray[0]){
			case "GO_INTRO":
				videoIntro.play();
				break;
			case "GO_LEVEL":
				//send level 2 the time
				SceneLevel02.timeLimit = msgArray[1];
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

	private function EOS():void
	{
		trace("here is eos");
		sceneTween = new GTween(this, 1.0, {alpha:0.0});
		sceneTween.onComplete = removeScene;
	}

	private function removeScene(e:GTween):void
	{
		this.removeChild(videoIntro);
		videoIntro.removeEventListener(CustomEvent.VIDEO_STOP, EOS);
		videoIntro.closeStream();
		videoIntro = null;
		Audio.stopSoundChannel(0);

		// Dispatch a 'custom' event.
		this.dispatchEvent(new CustomEvent(CustomEvent.SCENE_EXIT));
	}

	private function onReset():void
	{
		this.removeChild(videoIntro);
		videoIntro.removeEventListener(CustomEvent.VIDEO_STOP, EOS);
		videoIntro.closeStream();
		videoIntro = null;
		Audio.stopSoundChannel(0);
		this.dispatchEvent(new CustomEvent(CustomEvent.GAME_RESET));
	}
}//class
}//package