package com.acg.forestpath
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.URLLoader;
import flash.net.URLRequest;

public class Settings extends EventDispatcher {
	private var settingsXML:XML;
	private var xmlLoader:URLLoader = new URLLoader  ;
	private static var _instance:Settings;

	public function Settings():void {
		xmlLoader.addEventListener(Event.COMPLETE,onXMLloadComplete);

		if (ssGlobals.ssStartDir == null) {
			xmlLoader.load(new URLRequest("DATA\\settings.ini"));
		} else {
			xmlLoader.load(new URLRequest(ssGlobals.ssStartDir + "\\DATA\\" + "settings.ini"));
		}
	}

	private function onXMLloadComplete(event:Event):void {
		settingsXML = new XML(event.target.data);
		_instance = this;

		trace("SETTINGS IMPORTED: \n" + settingsXML);

		this.dispatchEvent(new CustomEvent(CustomEvent.XML_LOADED, true));
		xmlLoader.removeEventListener(Event.COMPLETE,onXMLloadComplete);
	}

	internal function getValueInt(param:String):int {
		var paramValue:int = int(settingsXML.setting.(@param == param));
		ssDebug.trace(paramValue + " is the value for :" + param);
		return paramValue;
	}

	internal function getValueNum(param:String):Number {
		var paramValue:Number = Number(settingsXML.setting.(@param == param));
		ssDebug.trace(paramValue + " is the value for :" + param);
		return paramValue;
	}

	internal function getValueString(param:String):String {
		var paramString:String = settingsXML.setting.(@param == param);
		ssDebug.trace(paramString + " is the value for :" + param);
		return paramString;
	}

	internal static function get instance():Settings {
		return _instance;
	}
}
}