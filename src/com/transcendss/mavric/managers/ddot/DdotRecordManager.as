package com.transcendss.mavric.managers.ddot
{
	import com.adobe.utils.StringUtil;
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.mavric.db.AgsMapService;
	import com.transcendss.mavric.db.MAVRICDBManager;
	import com.transcendss.mavric.events.ddot.DdotRecordEvent;
	import com.transcendss.mavric.util.FileUtility;
	import com.transcendss.transcore.sld.models.managers.CoreAssetManager;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.rpc.IResponder;
	
	public class DdotRecordManager extends CoreAssetManager
	{
		private var _mdbm : MAVRICDBManager;
		private var _requestEvent : DdotRecordEvent;
		private var _agsMapService:AgsMapService;
		private var fileUtil:FileUtility = new FileUtility();
		
		/**
		 * Creates tables for an list of different types of assets.
		 */
		public function DdotRecordManager()
		{
			_mdbm = MAVRICDBManager.newInstance();
			_agsMapService = FlexGlobals.topLevelApplication.agsMapService;
			_dispatcher = new Dispatcher(); 
		}
		
		public function getSigns(supportID:Number, eventLayerID:Number, responder:IResponder):void
		{
			_requestEvent = new DdotRecordEvent(DdotRecordEvent.SIGN_REQUEST);
			var whereClause:String =  StringUtil.replace("POLEID = '@poleId'", "@poleId", supportID.toString());
			_requestEvent.serviceURL = _agsMapService.getCustomEventUrl(eventLayerID, whereClause);
			_requestEvent.responder = responder;
			_dispatcher.dispatchEvent(_requestEvent);
			_requestEvent = null;
		}
		
		public function getInspections(supportID:Number, signIDs:Array, eventLayerID:Number, responder:IResponder):void
		{
			_requestEvent = new DdotRecordEvent(DdotRecordEvent.INSPECTION_REQUEST);
			var whereClause:String =  "POLEID = @poleId & SIGNID in (@signIds)"
				.replace("@poleId", supportID.toString())
				.replace('@signIds', signIDs.join(","));
			_requestEvent.serviceURL = _agsMapService.getCustomEventUrl(eventLayerID, whereClause);
			_requestEvent.responder = responder;
			_dispatcher.dispatchEvent(_requestEvent);
			_requestEvent = null;
		}
		
		public function onSignServiceResult(obj:Object,event:DdotRecordEvent):void
		{
			event.stopPropagation();
			
			var resp:IResponder = event.responder;
			
			var arrayColl:ArrayCollection = new ArrayCollection();
			var arr:Array = parseJsonObj(obj);
			var dataArr:Array = new Array();
			for each(var arrItem:Object in arr)
			{
				dataArr.push( arrItem.attributes);
			}
			
			resp.result(new ArrayCollection(dataArr));
		}
		
		public function parseJsonObj(obj:Object):Array
		{
			if(!obj)
				return new Array();
			var rawData:String = String(obj);
			
			var arr:Array = new Array();
			if (rawData.length >0)
			{
				//decode the data to ActionScript using the JSON API
				//in this case, the JSON data is a serialize Array of Objects.
				arr = (JSON.parse(rawData, function(k,value){
					var a;
					if (typeof value === 'string') {
						a = Date.parse(value);
						if (a) {
							return new Date(a);
						}    
					}
					return value;
				}).features) as Array;
			}
			return arr;
		}
		
	}
}