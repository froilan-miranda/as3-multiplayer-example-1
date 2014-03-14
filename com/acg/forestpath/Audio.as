package com.acg.forestpath
{
import flash.media.SoundChannel;
import flash.media.Sound;
import flash.net.URLRequest;

public class Audio extends Object
{
	private static var sndChannel0:SoundChannel = new SoundChannel();	//background 
	private static var sndChannel1:SoundChannel = new SoundChannel();	//player 1
	private static var sndChannel2:SoundChannel = new SoundChannel();	//player 2
	private static var sndChannel3:SoundChannel = new SoundChannel();	//player 3
	private static var sndChannel4:SoundChannel = new SoundChannel();	//player 4
	private static var sndChannel5:SoundChannel = new SoundChannel(); //player 5
	private static var sndChannel6:SoundChannel = new SoundChannel();	//player 6
	private static var sndChannel7:SoundChannel = new SoundChannel();	//misc game sounds

	private static var arrSoundChanels:Array = [sndChannel0,sndChannel1,sndChannel2,sndChannel3,sndChannel4,sndChannel5,sndChannel6]

	private static var sndIntro:Sound = new Sound;
	private static var sndIntroPath:URLRequest = new URLRequest("assets/audio/Introductions.mp3");

	private static var sndGame:Sound = new Sound;
	private static var sndGamePath:URLRequest = new URLRequest("assets/audio/Game_Alt_02.mp3");

	private static  var sndScore:Sound = new Sound;
	private static var sndScorePath:URLRequest = new URLRequest("assets/audio/Score_Alt_01.mp3");

	private static var sndSlingshot:Sound = new Sound;
	private static var sndSlingshotPath:URLRequest = new URLRequest("assets/audio/Slingshot.mp3");

	private static var sndSingle:Sound = new Sound;
	private static var sndSinglePath:URLRequest = new URLRequest("assets/audio/Single.mp3");

	private static var sndDouble:Sound = new Sound;
	private static var sndDoublePath:URLRequest = new URLRequest("assets/audio/Double.mp3");

	private static var sndCongrats:Sound = new Sound;
	private static var sndCongratsPath:URLRequest = new URLRequest("assets/audio/Congrats.mp3");

	private static var sndTimeOut:Sound = new Sound;
	private static var sndTimeOutPath:URLRequest = new URLRequest("assets/audio/TimeOut.mp3");

	private static var sndWind:Sound = new Sound;
	private static var sndWindPath:URLRequest = new URLRequest("assets/audio/Wind.mp3");

	private static var sndAlert:Sound = new Sound;
	private static var sndAlertPath:URLRequest = new URLRequest("assets/audio/Alert.mp3");

	//public function Audio():void
	{
		sndIntro.load(sndIntroPath);
		sndGame.load(sndGamePath);
		sndScore.load(sndScorePath);
		sndSlingshot.load(sndSlingshotPath);
		sndSingle.load(sndSinglePath);
		sndDouble.load(sndDoublePath);
		sndCongrats.load(sndCongratsPath);
		sndTimeOut.load(sndTimeOutPath);
		sndWind.load(sndWindPath);
		sndAlert.load(sndAlertPath);
	}

	internal static function playIntroSound(sideId:int) {
		arrSoundChanels[sideId] = sndIntro.play(0, int.MAX_VALUE);
	}

	internal  static  function playGameSound(sideId:int) {
		arrSoundChanels[sideId]  = sndGame.play(0, int.MAX_VALUE);
	}

	internal  static function playScoreSound(sideId:int) {
		arrSoundChanels[sideId]  = sndScore.play(0);
	}

	internal static function playSlingshotSound(sideId:int) {
		arrSoundChanels[sideId] = sndSlingshot.play(0);
	}

	internal  static function playSingleSound(sideId:int) {
		arrSoundChanels[sideId]  = sndSingle.play(0);
	}

	internal static function playDoubleSound(sideId:int) {
		arrSoundChanels[sideId] = sndDouble.play(0);
	}

	internal static function playCongratsSound(sideId:int) {
		arrSoundChanels[sideId] = sndCongrats.play(0);
	}

	internal static function playTimeOutSound(sideId:int) {
		arrSoundChanels[sideId] = sndTimeOut.play(0);
	}

	internal static function playWindSound(sideId:int) {
		arrSoundChanels[sideId] = sndWind.play(0);
	}

	internal static function playAlertSound(sideId:int) {
		arrSoundChanels[sideId] = sndAlert.play(0);
	}
/*
	internal  static  function playSelectSound(sideId:int){
		arrSoundChanels[sideId]  = sndSelect.play(0);
	}

	internal  static  function playScanSound(sideId:int){
		arrSoundChanels[sideId]  =sndScan.play(0);
	}

	internal static  function playStaticSound(sideId:int){
		arrSoundChanels[sideId]  =sndStatic.play(0, int.MAX_VALUE);
	}

	internal  static  function playBGSound(sideId:int){
		arrSoundChanels[sideId]  =sndBG.play(0, int.MAX_VALUE);
	}
*/

	internal  static  function stopSoundChannel(sideId:int):void {
		arrSoundChanels[sideId].stop();
	}

}
}