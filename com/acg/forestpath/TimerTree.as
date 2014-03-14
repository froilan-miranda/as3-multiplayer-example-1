package com.acg.forestpath
{
import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.Loader;
import flash.net.URLRequest;
import flash.events.Event;
public class TimerTree extends Sprite
{
	private var treeLoader:Loader;
	private var treeMC:MovieClip;

	public function TimerTree():void
	{
		loadTreeTimer();
	}
	private function loadTreeTimer():void
	{
		treeLoader = new Loader();
		var request:URLRequest = new URLRequest("assets/swf/TreeTimer.swf");
		treeLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, treeLoaded);
		treeLoader.load(request);
		request = null;
	}
	private function treeLoaded(e:Event):void
	{
		e.target.removeEventListener(Event.COMPLETE, treeLoaded);
		treeMC = e.target.content as MovieClip;
		treeMC.stop();
		treeMC.addFrameScript(treeMC.totalFrames - 1, stopAnime)
		this.addChild(treeMC);

		treeLoader.unload();
		treeLoader = null;
	}
	private function stopAnime():void
	{
		treeMC.stop();
	}
	internal function scaleTree(percent:Number):void
	{
		var stopFrame:int = int(treeMC.totalFrames * percent);
		treeMC.gotoAndStop(stopFrame);
	}
}
}