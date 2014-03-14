package com.acg.forestpath
{

import flash.events.Event;

public class CustomEvent extends Event
{
	public static const XML_LOADED:String = "XmlLoaded";
	public static const SCENE_EXIT:String = "SceneExit";
	public static const GAME_RESET:String = "GameReset";
	
	public static const JOYSTICK_DATA_READY:String = "JoystickDataReady";

	public static const VIDEO_STOP:String = "VideoStop";
	public static const CUE_POINT:String = "CuePoint";

	public static const DESTROY_TNF:String = "DestroyTnf";
	public static const DESTROY_OTHER:String = "DestroyOther";

	public static const FIRE_READY:String = "FireReady";
	public static const SLINGSHOT_COMPLETE:String = "CatapultComplete";
	public static const ROCK_IMPACT:String = "RockImpact";
	public static const ROCK_OFFSCREEN:String = "RockOffscreen";
	
	public static const EVENT_DEFUALT:String = "Defualt";

	public function CustomEvent(type:String = CustomEvent.EVENT_DEFUALT, bubbles:Boolean = false, cancelable:Boolean = false)
	{
		super(type, bubbles, cancelable);
	}
	
	override public function clone():Event
	{
		return new CustomEvent(type, bubbles, cancelable);
	}
}
}