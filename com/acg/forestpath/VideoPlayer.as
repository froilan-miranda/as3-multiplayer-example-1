package com.acg.forestpath
{

import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.events.NetStatusEvent;
import flash.events.AsyncErrorEvent;

public class VideoPlayer extends Video
{
	private var vSrc:String;
	private var vWidth:int;
	private var vHeight:int;
	private var nc:NetConnection;
	private var ns:NetStream;
	private var repeatStream:Boolean = false;
	private var playedOnce:Boolean = false;

	public function VideoPlayer(width:int, height:int, src:String, repeat:Boolean = false):void
	{
		trace("... and a VideoLoop instance was born");
		vSrc = new String(src);
		vWidth = width;
		vHeight = height;
		repeatStream = repeat;

		nc = new NetConnection();
		nc.addEventListener(NetStatusEvent.NET_STATUS, onStatus); 
		nc.connect(null);
	}
 
	private function InitVideo():void
	{
		this.width = vWidth;
		this.height = vHeight;

		ns = new NetStream(nc);
		ns.addEventListener(NetStatusEvent.NET_STATUS, onStatus);
		ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler); 
		this.attachNetStream(ns);
		if(ssGlobals.ssStartDir == null)
			ns.play(vSrc);
		else
			ns.play(ssGlobals.ssStartDir + "\\" + vSrc);
		
		var customClient:Object = new Object();
		customClient.onCuePoint = cuePointHandler;
		customClient.onMetaData = onMetaDataHandler;
		ns.client = customClient;
	}

	private function asyncErrorHandler(event:AsyncErrorEvent):void 
	{ 
           dispatchEvent(event); 
    }  

	private function onStatus(nse:NetStatusEvent):void 
	{ 
		switch(nse.info.code){
			case ("NetConnection.Connect.Success") :
				if(!playedOnce){
					playedOnce = true; 
					InitVideo();
				}
				break;
			case 	"NetStream.Play.Start" :
				trace("NetStream.Play.Start");  
				break;
			case  "NetStream.Play.Stop" :
				trace("NetStream.Play.Stop");  
				if(playedOnce && repeatStream) ns.seek(0);
				this.dispatchEvent(new CustomEvent(CustomEvent.VIDEO_STOP));
				break;
			case "NetStream.Buffer.Full" :
				//trace("Buffer Full"); 
				break;
			case  "NetStream.Play.StreamNotFound" :
				trace("Video not found")
				break;
			default :
				trace("not checking for video code: " + nse.info.code);
				break;
		}
	} 
	private function cuePointHandler(info:Object):void 
	{
	    trace("cuePoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
	    this.dispatchEvent(new CustomEvent(CustomEvent.CUE_POINT));
	}
	private  function onMetaDataHandler(info:Object):void 
	{
		trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
	}
	internal function play():void
	{ 
			ns.resume(); 
	}  
	internal function pause():void
	{ 
			ns.pause(); 
			trace("video paused");
	} 
	internal function closeStream():void
	{
		nc = null;
		ns.close();
		ns = null;
		this.attachNetStream(null);
	}
}//class
}//package