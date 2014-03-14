package com.acg.forestpath
{
public class PlayerInfo extends Object
{
	private var _initials:String;
	private var _score:int = 0;
	private var _position:int;

	public function PlayerInfo(pInitials:String, pNumber:int):void
	{
		trace("player info instance ready for duty");
		_initials = pInitials;
		_position = pNumber;
	}
	internal function get initials():String
	{
		return _initials;
	}
	public function set score(playerScore:int):void
	{
		_score = playerScore;
	}
	public function get score():int
	{
		return _score;
	}
	internal function get position():int
	{
		return _position;
	}
}//class
}//package