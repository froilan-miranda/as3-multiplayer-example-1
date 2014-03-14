package com.acg.forestpath
{
import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.Loader;
import flash.net.URLRequest;
import flash.events.Event;
public class Slingshot extends Sprite
{
	private var slingshotLoader:Loader;
	private var slingshotMC:MovieClip;
	private var stationNumber:int;

	public function Slingshot(stationNum:int):void
	{
		loadSlingshot();
		stationNumber = stationNum;
	}
	private function loadSlingshot():void
	{
		slingshotLoader = new Loader();
		var request:URLRequest = new URLRequest("assets/swf/Slingshot.swf");
		slingshotLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, slingshotLoaded);
		slingshotLoader.load(request);
		request = null;
	}
	private function slingshotLoaded(e:Event):void
	{
		e.target.removeEventListener(Event.COMPLETE, slingshotLoaded);
		slingshotMC = e.target.content as MovieClip;
		slingshotMC.stop();
		slingshotMC.addFrameScript(slingshotMC.totalFrames - 1, stopAnime)
		slingshotMC.addFrameScript(5, onslingshotComplete);
		this.addChild(slingshotMC);

		slingshotLoader.unload();
		slingshotLoader = null;
	}
	private function stopAnime():void
	{
		slingshotMC.gotoAndStop(1);
		slingshotMC.stop();
	}
	internal function fireAnime():void
	{
		slingshotMC.gotoAndPlay(2);
		Audio.playSlingshotSound(stationNumber);
	}
	private function onslingshotComplete():void
	{
		this.dispatchEvent(new CustomEvent(CustomEvent.SLINGSHOT_COMPLETE));
	}
	private function onEOL():void
	{
		this.removeChild(slingshotMC);
		slingshotMC = null;
	}
}
}