package com.ddw.gardendefence
{
public class TCPSocketNC extends Object
{
	private static var tcpConnected:Boolean = false;
	private static var tcpRetryCnt:int = 0;
	private static var lastMSG:String = "";
	private static var tmrReconnect:Timer;
	public function TCPSocketNC():void
	{

	}


}//class
}//package






var tmrReconnect:Timer = new Timer(5000,1);
tmrReconnect.addEventListener(TimerEvent.TIMER_COMPLETE,tmlReconnect);

function tmlReconnect(event:TimerEvent):void {
	createSocket();
	ssDebug.trace("re-connecting. . . client: " + isClient);
}


function createSocket() {
	stopTCP();
	ssCore.TCP.setNotify({event:'onReceive'},{callback:'processReceive'});
	ssCore.TCP.setNotify({event:"onConnect"}, {callback:'onTCPConnect'});
	ssCore.TCP.setNotify({event:"onDisconnect"}, {callback:'onTCPDisconnect'});
	ssCore.TCP.setNotify({event:"onReceiveError"}, {callback:'onTCPError'});
	ssCore.TCP.setNotify({event:"onSendError"}, {callback:'onTCPError'});
	ssCore.TCP.open({destination:serverIP,port:serverPort},{callback:'processOpen'});
}


function stopTCP():void {
	tcpConnected = false;
	ssCore.TCP.close();
	ssDebug.trace("TCP Closed.");
}


function processOpen(return_obj,callback_obj,error_obj) {
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

function onTCPConnect(return_obj,callback_obj,error_obj) {
	//mcTCP.gotoAndStop(15);
	tcpConnected = true;
	ssDebug.trace("LB TCP CONNECTED");
}

function onTCPDisconnect(return_obj,callback_obj,error_obj) {
	//mcTCP.play();
	tcpConnected = false;
	ssDebug.trace("LB DISCONNECTED");
	tmrReconnect.reset();
	tmrReconnect.start();
}

function processReceive(return_obj,callback_obj,error_obj) {
	var theMSG:String = return_obj.result;
	ssDebug.trace("LB RECEIVED: " + theMSG);	
	readResponse(theMSG);
}

function sendRequest(theMSG:String, targetNum:int=1) {
	ssDebug.trace("LB SENDING: " + theMSG);
	/*TARGET NUMBERS:
	1 - host only
	2 - clients only
	3 - leaderboard only
	4 - broadcast
	*/
	ssCore.TCP.sendMsg({data:String.fromCharCode(targetNum)+theMSG+String.fromCharCode(9)},{callback:"messageSent",scope:this});
}

function messageSent(return_obj,callback_obj,error_obj) {
	if (return_obj.success) {
		//ssDebug.trace("MSG SENT: " + lastMSG);
	} else {
		ssDebug.trace("LB ERROR -  SEDING AGAIN: "+error_obj.description);
	}
}

function onTCPError(return_obj,callback_obj,error_obj) {
	ssDebug.trace("LB ERROR: "+return_obj.result);
}