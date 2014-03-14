package com.acg.forestpath
{
import flash.display.Sprite;
import flash.utils.setInterval;
import flash.utils.clearInterval;

public class JoyStickController extends Sprite
{
	private var success:Boolean = false;
	private var jstickIntervalId:int;
	private var jstickIntervalTime:int;
	private var _joystickData:XML;
	private static var _instance:JoyStickController;

	public function JoyStickController():void
	{
		//jstickIntervalTime = 100;
		setVIcontrol();
	}

 	private function setVIcontrol():void
	{
		// authenticate
		var vi_initCtl=ssCore.viJoystickLib.initCtl({authCode:"26fbaea1-954f-4263-b31a-4b272a70befa"});

		if (vi_initCtl.success) {
			success = true;
			_instance = this;
			//jstickIntervalId = setInterval(runMany, 100)
		} else {
			ssDebug.trace("Failure: "+vi_initCtl.Error.description);
		}
		ssDebug.trace("Done initializing joystick");
	}

	private function runMany():void 
	{
		var joystickDataObj:Object = ssCore.viJoystickLib.getData();
		_joystickData = new XML(joystickDataObj.result);
		this.dispatchEvent(new CustomEvent(CustomEvent.JOYSTICK_DATA_READY));
		//processJoystickData(joystickData);
	}

	internal function jStickStart():void
	{
		var _sc:Settings = Settings.instance;
		jstickIntervalTime = _sc.getValueInt("jStickIntervalTime");

		if(success)	jstickIntervalId = setInterval(runMany, jstickIntervalTime)
	}

	internal function jStickStop():void
	{
		clearInterval(jstickIntervalId);
	}

	internal function get joystickData():XML
	{
		return _joystickData;
	}

	internal static function get instance():JoyStickController 
	{
		return _instance;
	}
}
}