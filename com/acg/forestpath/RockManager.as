package com.acg.forestpath
{
import flash.display.Sprite;
import flash.geom.Point;

public class RockManager extends Sprite
{
	private var spawnManager:SpawnManager; //reference to spawn manager
	private var aRocks:Array = []; //array to hold rocks
	private var _timeExpired:Boolean = false;
	private const startingPoints:Array = [new Point(375, 865), new Point(730, 865), new Point(1080, 865), new Point(1435, 865)]

	public function RockManager(manager:SpawnManager):void
	{
		spawnManager = manager;
	}

	internal function launchRock(requester:PlayerStation, dx:Number, dy:Number):void{
		var newRock:Rock = new Rock(requester, dx, dy, startingPoints[requester.stationNumber - 1]);
		newRock.addEventListener(CustomEvent.ROCK_IMPACT, onImpact);
		newRock.addEventListener(CustomEvent.ROCK_OFFSCREEN, removeRock);
		aRocks.push(newRock);
		this.addChild(newRock);
	}

	private function onImpact(e:CustomEvent):void
	{
		var rock:Rock = e.target as Rock;
		for each(var tnf:GPTNF in spawnManager.aTnf){
			if(rock.hitTestObject(tnf) && tnf.active == true){
				var globalPos:Point = spawnManager.localToGlobal(new Point(tnf.x, tnf.y));
				var localPos:Point = rock.globalToLocal(new Point(globalPos.x, globalPos.y));
				rock.nuetralizeTNF(spawnManager.removeFromArray(tnf, localPos.x, localPos.y));
				tnf.active = false;
			}
			if(rock.numTnf() == 1) break;
		}
		if(rock.numTnf() == 1){
			for each(var tnf2:GPTNF in spawnManager.aTnf){
				if(rock.hitTestObject(tnf2) && tnf2.active == true){
					var globalPos2:Point = spawnManager.localToGlobal(new Point(tnf2.x, tnf2.y));
					var localPos2:Point = rock.globalToLocal(new Point(globalPos2.x, globalPos2.y));
					rock.nuetralizeTNF(spawnManager.removeFromArray(tnf2, localPos2.x, localPos2.y));
					tnf2.active = false;
				}
				if(rock.numTnf() == 2) break;
			}
		}
		if(rock.numTnf() == 1)
			Audio.playSingleSound(rock._owner.stationNumber);
		if(rock.numTnf() == 2)
			Audio.playDoubleSound(rock._owner.stationNumber);

		offScreenRock(rock);
	}

	private function offScreenRock(rock:Rock):void
	{
		if(_timeExpired != true) rock.updateScore();
		rock.reloadRock();
		rock.greyScaleMove();
	}

	private function removeRock(e:CustomEvent):void
	{
		var rock:Rock = e.target as Rock;
		rock.removeEventListener(CustomEvent.ROCK_IMPACT, onImpact);
		rock.removeEventListener(CustomEvent.ROCK_OFFSCREEN, removeRock);
		this.removeChild(rock);
		rock = null;
	}
	internal function set timeExpired(timeUp:Boolean):void
	{
		_timeExpired = timeUp
	}
}
}