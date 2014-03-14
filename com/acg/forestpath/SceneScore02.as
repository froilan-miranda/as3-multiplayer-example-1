package com.acg.forestpath
{
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.Loader;
import flash.text.TextFieldAutoSize;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.AntiAliasType;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.utils.setTimeout;
import flash.utils.clearTimeout;
import flash.net.URLRequest;
import com.vanik.utils.TCPSocketNC;
import com.gskinner.motion.GTween;

public class SceneScore02 extends Sprite
{
	private var rankTimeout:int;
	private var waitOnRank:int = 3000;
	private var bgLoader:Loader;
	private var bmpBG:Bitmap;
	private var aTextFields:Array = [];
	private var sceneTween:GTween;

	public function SceneScore02():void
	{
		this.alpha = 0.0;
		if(stage)
			initScene(null);
		else
			this.addEventListener(Event.ADDED_TO_STAGE, initScene);
	}

	private function initScene(e:Event):void
	{
		ssDebug.trace("top scores here");
		this.removeEventListener(Event.ADDED_TO_STAGE, initScene);
		loadBG();
		queAudioBG()
		
		TCPSocketNC.messageTarget = this;  //tell tcp class to use 'this' as reciever for messages
	}

	private function queAudioBG():void
	{
		Audio.playScoreSound(0);
	}

	private function loadBG():void
	{
		var imageUrl:URLRequest;
		if (ssGlobals.ssStartDir == null) {
			imageUrl = new URLRequest("assets/images/bg/bg_scores.png");
		}else{
			imageUrl = new URLRequest(ssGlobals.ssStartDir + "\\" + "assets/images/bg/bg_scores.png");			
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
		bmpBG.addEventListener(Event.ADDED_TO_STAGE, showScores);
		bmpBG.x = 0;
		bmpBG.y = 0;
		bgLoader.unload();
		this.addChild(bmpBG);
	}

	private function loaderIOErrorHandler(err:IOErrorEvent):void
	{
		trace("there is a problem loading: " + err.target)
	}

	private function showScores(e:Event):void
	{
		bmpBG.removeEventListener(Event.ADDED_TO_STAGE, showScores);
		//text formatting white
		var format1:TextFormat = new TextFormat();
		format1.font =  new Helvetica_ExtraCompressed().fontName;
		format1.color = 0xffffff;
		format1.size = 60;
		format1.align = "left";
		format1.letterSpacing = 3;

		//text formatting white
		var format2:TextFormat = new TextFormat();
		format2.font =  new Helvetica_ExtraCompressed().fontName;
		format2.color = 0x320608;
		format2.size = 60;
		format2.align = "left";
		format2.letterSpacing = 3;		

		var sortedScores = PlayerInfoManager.highScoreList;

		for(var i:uint = 0; i < sortedScores.length; i++) {
			var txtRank:TextField = new TextField();
			txtRank.embedFonts = true;
			txtRank.selectable=false;
			txtRank.autoSize = TextFieldAutoSize.LEFT;
			txtRank.antiAliasType = AntiAliasType.ADVANCED;
			txtRank.defaultTextFormat = (i%2 == 0)?format1:format2;
			txtRank.text = String(i + 1);
			txtRank.x = 462;
			txtRank.y = i * 77 + 365;
			this.addChild(txtRank);
			aTextFields.push(txtRank);

			var txtPlayer:TextField = new TextField();
			txtPlayer.embedFonts = true;
			txtPlayer.selectable=false;
			txtPlayer.autoSize = TextFieldAutoSize.LEFT;
			txtPlayer.antiAliasType = AntiAliasType.ADVANCED;
			txtPlayer.defaultTextFormat = (i%2 == 0)?format1:format2;
			txtPlayer.text = "PLAYER " + sortedScores[i].position;
			txtPlayer.x = 882;
			txtPlayer.y = i * 77 + 365;
			this.addChild(txtPlayer);
			aTextFields.push(txtPlayer);

			var txtScore:TextField = new TextField();
			txtScore.embedFonts = true;
			txtScore.selectable=false;
			txtScore.autoSize = TextFieldAutoSize.LEFT;
			txtScore.antiAliasType = AntiAliasType.ADVANCED;
			txtScore.defaultTextFormat = (i%2 == 0)?format1:format2;
			var txtComma = String(sortedScores[i].score);
			txtScore.text = txtComma.replace(/(\d)(?=(\d\d\d)+$)/g, "$1,");
			txtScore.x = 1320;
			txtScore.y = i * 77 + 365;
			this.addChild(txtScore);
			aTextFields.push(txtScore);
		}
		this.setChildIndex(bmpBG,0);
		format1 = null;
		format2 = null;

		sceneTween = new GTween(this, 1, {alpha:1.0});
	}

	public function msgProcess(msg:String):void
	{
		//ssDebug.trace(msg);
		msg = msg.slice(0, -1); //Remove end of string char
		var msgArray:Array = msg.split("|");
		switch(msgArray[0]){
			case "GO_TOP_SCORES":
				//GO_TOP_SCORES|DDD,600;CCC,500;BBB,300;AAA,200
				PlayerInfoManager.dailyHighScore = msgArray[1].split(";");
				this.EOS();
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
		sceneTween = new GTween(this, 1.0, {alpha:0.0});
		sceneTween.onComplete = removeScene;
	}

	private function removeScene(e:GTween):void
	{
		clearTimeout(rankTimeout);
		this.removeChild(bmpBG);
		bmpBG = null;
		for each(var txtField:TextField in aTextFields){
			this.removeChild(txtField);
			txtField = null;
		}
		aTextFields = [];
		Audio.stopSoundChannel(0);
		//clear out player data, from here we restart the game
		PlayerInfoManager.onReset();

		// Dispatch a 'custom' event.
		this.dispatchEvent(new CustomEvent(CustomEvent.SCENE_EXIT));
	} 

	private function onReset():void
	{
		this.removeChild(bmpBG);
		bmpBG = null;
		for each(var txtField:TextField in aTextFields){
			this.removeChild(txtField);
			txtField = null;
		}
		aTextFields = [];
		Audio.stopSoundChannel(0);
		this.dispatchEvent(new CustomEvent(CustomEvent.GAME_RESET));
	}
}
}