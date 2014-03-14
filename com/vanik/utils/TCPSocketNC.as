package com.vanik.utils
{

import flash.utils.Timer;
import flash.events.TimerEvent;

public class TCPSocketNC extends Object
{
	private static var tcpConnected:Boolean = false;
	private static var tcpRetryCnt:int = 0;
	private static var lastMSG:String = "";
	private static var tmrReconnect:Timer;
	private static var isClient:int;
	private static var serverPort:int;
	private static var serverIP:String;
	private static var _messageTarget:* = null; // this will be the object to recieve messages

	{
		(function():void{
			// run setup code here
		}());
	}
	
	public static function test():void
	{
		ssDebug.trace("test worked!");
	}

	public static function  init(ip:String, port:int):void
	{
		serverIP = ip;
		serverPort = port
		tmrReconnect = new Timer(5000,1);
		tmrReconnect.addEventListener(TimerEvent.TIMER_COMPLETE,tmlReconnect);
	}

	public static function set messageTarget(theTarget:*):void
	{
		_messageTarget = theTarget;
	}

	private static function tmlReconnect(event:TimerEvent):void
	{
		createSocket();
		ssDebug.trace("re-connecting. . . client: " + isClient);
	}

	public static function createSocket():void
	{
		stopTCP();
		ssCore.TCP.setNotify({event:'onReceive'},{callback:processReceive});
		ssCore.TCP.setNotify({event:"onConnect"}, {callback:onTCPConnect});
		ssCore.TCP.setNotify({event:"onDisconnect"}, {callback:onTCPDisconnect});
		ssCore.TCP.setNotify({event:"onReceiveError"}, {callback:onTCPError});
		ssCore.TCP.setNotify({event:"onSendError"}, {callback:onTCPError});
		ssCore.TCP.open({destination:serverIP,port:serverPort},{callback:processOpen });
	}

	private static function stopTCP():void
	{
		tcpConnected = false;
		ssCore.TCP.close();
		ssDebug.trace("TCP Closed.");
	}

	private static function processOpen(return_obj,callback_obj,error_obj):void
	{
		if (return_obj.success) {
			ssDebug.trace("LB SOCKET OPEN");
		} else {
			//mcTCP.play();
			tcpConnected = false;
			ssDebug.trace("LB SOCKET FAILED TO OPEN");
			tmrReconnect.reset();
			tmrReconnect.start();
		}
	}

	private static function onTCPConnect(return_obj,callback_obj,error_obj):void
	{
		//mcTCP.gotoAndStop(15);
		sendRequest("CONNECTED")
		tcpConnected = true;
		ssDebug.trace("LB TCP CONNECTED");
	}

	private static function onTCPDisconnect(return_obj,callback_obj,error_obj):void
	{
		//mcTCP.play();
		tcpConnected = false;
		ssDebug.trace("LB DISCONNECTED");
		tmrReconnect.reset();
		tmrReconnect.start();
	}

	private static function processReceive(return_obj,callback_obj,error_obj):void
	{
		var theMSG:String = return_obj.result;
		ssDebug.trace("LB RECEIVED: " + theMSG);
		if(_messageTarget != null)	
			_messageTarget.msgProcess(theMSG);
		else
			ssDebug.trace("Their is no target to process incomimg messages");
	}

	public static function sendRequest(theMSG:String, targetNum:int=1):void
	{
		ssDebug.trace("LB SENDING: " + theMSG);
		/*TARGET NUMBERS:
		1 - host only
		2 - clients only
		3 - leaderboard only
		4 - broadcast
		*/

		//ssCore.TCP.sendMsg({data:String.fromCharCode(targetNum)+theMSG+String.fromCharCode(9)},{callback:messageSent,scope:this});
	 	// cannot use 'this' keyword for scope inside static function
		ssCore.TCP.sendMsg({data:String.fromCharCode(targetNum)+theMSG+String.fromCharCode(9)},{callback:messageSent});
	}

	private static function messageSent(return_obj,callback_obj,error_obj):void
	{
		if (return_obj.success) {
			//ssDebug.trace("MSG SENT: " + lastMSG);
		} else {
			ssDebug.trace("LB ERROR -  SEDING AGAIN: "+error_obj.description);
		}
	}

	private static function onTCPError(return_obj,callback_obj,error_obj):void
	{
		ssDebug.trace("LB ERROR: "+return_obj.result);
	}
}//class
}//package