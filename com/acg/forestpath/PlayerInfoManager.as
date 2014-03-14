package com.acg.forestpath
{
import com.acg.forestpath.PlayerInfo;

public class PlayerInfoManager extends Object
{
	private static const MAX_PLAYERS:int = 4;

	private static var playerArray:Array; //keep track of active and inactive positions

	private static  var _activePlayers:Array; // keep track of active positions
	private static var _dailyHighScore:Array; // holds the current high scores

	{
		(function():void{
			trace("here is a player info manager");
			//initiate array
			playerArray = [];
			_activePlayers = [];

			//null out player array
			for (var i:int = 0; i < MAX_PLAYERS; i++){
				playerArray[i] = null;
			}
		}());
	}

	internal static function addPlayer(position:int, initials:String):void
	{
		//create a new player
		playerArray[position - 1] = new PlayerInfo(initials, position);
		ssDebug.trace("player added");
	}

	internal static function removePlayer(position:int):void
	{
		playerArray[position -1] = null;
		ssDebug.trace("player removed");
	}

	internal static function gatherActive():void
	{
		for each(var index:PlayerInfo in playerArray){
			if(index != null)
				_activePlayers.push(index);
		}
	}

	internal static function onEOG():void
	{
		//null out player array
		for (var i:int = 0; i < MAX_PLAYERS; i++){
			playerArray[i] = null;
		}
		//null out active player array
		for (var j:int = 0; i < _activePlayers.length; i++){
			_activePlayers[i] = null;
		}
		_activePlayers = [];
	}

	internal static function onReset():void
	{
		//null out player array
		for (var i:int = 0; i < MAX_PLAYERS; i++){
			playerArray[i] = null;
		}
		//null out active player array
		for (var j:int = 0; i < _activePlayers.length; i++){
			_activePlayers[i] = null;
		}
		_activePlayers = [];
	}

	internal static function get activePlayers():Array
	{
		return _activePlayers;
	}

	internal static function get highScore():Array
	{
		var highScore:Array = [0, 0];
		for each(var index:PlayerInfo in activePlayers){
			if(index.score >= highScore[1]){
				highScore[0] = index.position;
				highScore[1] = index.score;
			}
		}
		return highScore;
	}

	internal static function get allScores():String
	{
		var allScores:String = "SCORES|";
		for each(var index:PlayerInfo in playerArray){
			if(index == null)
				allScores += "0,";
			else
			 	allScores = allScores + String(index.score) + ",";
		}
		allScores = allScores.slice(0,-1); //get rid of last comma. not eligant but works ;)

		return allScores;
	}

	internal static function get highScoreList():Array
	{
		return activePlayers.sortOn("score", Array.NUMERIC | Array.DESCENDING);
	}

	internal static function set dailyHighScore(scores:Array):void
	{
		//GO_TOP_SCORES|DDD,600;CCC,500;BBB,300;AAA,200
		_dailyHighScore = scores;
	}

	internal static function get dailyHighScore():Array
	{
		return _dailyHighScore;
	}
}
}