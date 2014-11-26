package com.transcendss.mavric.managers
{
	import com.transcendss.mavric.db.MAVRICDBManager;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class SettingsManager
	{
		private var app:MAVRIC2 = FlexGlobals.topLevelApplication as MAVRIC2;
		private var _mdbm:MAVRICDBManager;
		public function SettingsManager()
		{
			_mdbm = MAVRICDBManager.newInstance();
		}
		
		public function getSetting(key:String):String
		{
			var arr:Array = _mdbm.getSettingByKey(key);
			
			if (! arr || arr.length == 0)
				return null;
			
			return arr[0].VALUE as String;
		}
		
		public function getKeys():ArrayCollection
		{
			return _mdbm.getKeys();
		}
		
		public function saveSetting(key:String, value:String):void
		{
			if (getSetting(key) == null)
				_mdbm.insertSetting(key, value);
			else
				_mdbm.updateSetting(key, value);
		}

		public function requestDistricts(resp:Responder = null):Object
		{
			var httpService:HTTPService = new HTTPService();
			
			httpService.url = ConfigUtility.get("serviceURL") + ConfigUtility.get("district_b"); // baseAsset.get___();
			
			httpService.resultFormat = "text";
			
			var token:AsyncToken = httpService.send();
			
			if (resp)
				token.addResponder(resp);
			
			return token.result;
		}
		
		
	}
}