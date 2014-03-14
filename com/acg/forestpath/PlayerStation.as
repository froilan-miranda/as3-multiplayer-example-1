package com.acg.forestpath
{
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.text.AntiAliasType;
import com.vanik.utils.TCPSocketNC;
import com.gskinner.motion.GTween;
public class PlayerStation extends Sprite
{
	private const X_OFFSET = 355;

	private var txtScore:TextField;
	private var p1Color:Array = new Array("0x76bfff", "0x044490");
	private var p2Color:Array = new Array("0x8f06b4", "0x51056a");
	private var p3Color:Array = new Array("0xdacb0b", "0x726d0b");
	private var p4Color:Array = new Array("0xff0340", "0x810223");
	private var p5Color:Array = new Array("0xffb60b", "0xa2610b");
	private var p6Color:Array = new Array("0xff500b", "0x6b1f0b");
	private var colorAtlas:Array = new Array(p1Color, p2Color, p3Color, p4Color, p5Color,  p6Color);

	private var _isFiring:Boolean = false;
	private var _jstickSerial:String;
	private var _targetX:Number;
	private var _targetY:Number;
	private var _stationNumber:int;
	private var playerInfo:PlayerInfo;
	private var slingshot:Slingshot;
	private var timerTree:TimerTree
	private var pointMultiplier:int;
	private var pointDouble:int;

	public function PlayerStation(pInfo:PlayerInfo, serial:String):void
	{
		trace("a new player station");

		_stationNumber = pInfo.position;
		_jstickSerial = serial;
		playerInfo = pInfo;

		var _sc:Settings = Settings.instance;
		pointMultiplier = _sc.getValueInt("pointMult");
		pointDouble = _sc.getValueInt("pointDbl");

		initStation();
	}

	private function initStation():void
	{
		this.graphics.beginFill(colorAtlas[_stationNumber - 1][0]);
		this.graphics.lineStyle(2, colorAtlas[_stationNumber - 1][1]);
		this.graphics.drawRoundRect(0, 165, 233, 84, 10, 10);
		this.graphics.endFill();

		this.x = 315 +((_stationNumber - 1) * X_OFFSET);
		this.y = ForestPath.STAGE_HEIGHT - 200;
		this.width = 233;

		createSlingshot();
		createTimerTree();
		createScoreBox();
		createNameBox(playerInfo.initials);
	}
	
	private function createSlingshot():void
	{
		slingshot = new Slingshot(_stationNumber);
		slingshot.addEventListener(CustomEvent.SLINGSHOT_COMPLETE, launchRock);
		this.addChild(slingshot);
		slingshot.x = 15;
		slingshot.y = 13;
	}

	private function createTimerTree():void
	{
		timerTree = new TimerTree();
		this.addChild(timerTree);
		timerTree.scaleX = 0.17;
		timerTree.scaleY = 0.17;
		timerTree.x = 145;
		timerTree.y = 15;
	}

	private function createScoreBox():void
	{
		//add text
		var format1:TextFormat = new TextFormat();
		format1.font =  new Tunga_Reg().fontName;
		format1.color = 0xFFFFFF;
		format1.size = 30;
		format1.align = "right";

		txtScore = new TextField();
		txtScore.embedFonts = true;
		txtScore.selectable=false;
		txtScore.autoSize = TextFieldAutoSize.RIGHT;
		txtScore.antiAliasType = AntiAliasType.ADVANCED;
		txtScore.defaultTextFormat = format1;
		txtScore.text = "0";
		txtScore.y = 145;
		txtScore.x = 210;
		this.addChild(txtScore);
		txtScore.text = String(playerInfo.score);
		
		trace("score box added" + txtScore.y + "|" + txtScore.x);

		format1 = null;
	}

	private function createNameBox(pName:String):void
	{
		//add text
		var format1:TextFormat = new TextFormat();
		format1.font =   new Tunga_Reg().fontName;
		format1.color = 0xFFFFFF;
		format1.size = 30;
		format1.align = "left";
		var txtName:TextField = new TextField();
		txtName.embedFonts = true;
		txtName.selectable=false;
		txtName.autoSize = TextFieldAutoSize.LEFT;
		txtName.antiAliasType = AntiAliasType.ADVANCED;
		txtName.defaultTextFormat = format1;
		txtName.text = pName;
		txtName.y = 145;
		txtName.x = 10;
		this.addChild(txtName);
		trace("name box added" + txtName.y + "|" + txtName.x);

		format1 = null;
	}

	internal function requestFire(tx:Number, ty:Number):void
	{
		if(_isFiring == false){
			_isFiring = true;
			targetX = tx;
			targetY = ty;
			slingshot.fireAnime();
			//launchRock();
		}
	}

	private function launchRock(e:CustomEvent):void
	{
		this.dispatchEvent(new CustomEvent(CustomEvent.FIRE_READY));
	}

	internal function updateScore(tnfCount:int):void
	{
		if(tnfCount == 1){
			playerInfo.score += tnfCount * pointMultiplier;
			TCPSocketNC.sendRequest("P" + _stationNumber + "|SINGLE|" + playerInfo.score);
		}else if(tnfCount == 2){
			playerInfo.score += tnfCount * pointMultiplier * 2;
			TCPSocketNC.sendRequest("P" + _stationNumber + "|DOUBLE|" + playerInfo.score);
		}
		var txtComma = String(playerInfo.score);
		txtScore.text = txtComma.replace(/(\d)(?=(\d\d\d)+$)/g, "$1,");
	}

	internal function updateTree(currentTime:int, totalTime:int):void
	{
		var percentDone:Number = currentTime/totalTime;
		timerTree.scaleTree(percentDone);
	}

	internal function globalTreePos():Point
	{
		return this.localToGlobal(new Point(timerTree.x, timerTree.y));
	}
	internal function winningTree():TimerTree
	{
		this.removeChild(timerTree);
		new GTween(this, 1, {alpha:0.0});
		return timerTree;
	}

	internal function get jstickSerial():String
	{
		return _jstickSerial;
	}
	internal function set targetX(tx:Number):void
	{
		//_targetX =(((tx + 1) * 0.5) * 1420) + 250;
		_targetX = tx + 250;
	}
	internal function get targetX():Number
	{
		return _targetX;
	}
	internal function set targetY(ty:Number):void
	{
		//_targetY = ((ty - 1) * 0.5) * -(GardenDefence.STAGE_HEIGHT-220);
		_targetY = ty;
	}
	internal function get targetY():Number
	{
		return _targetY;
	}
	internal function get stationNumber():int
	{
		return _stationNumber;
	}
	internal function set isFiring(control:Boolean)
	{
		_isFiring = control;
	}
}//class
}//package