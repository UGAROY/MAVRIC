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
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
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
		
		public function createNewSign(poleID:Number):Object
		{
			var sign:Object = new Object();
			sign['SIGNID'] = -1;
			sign['POLEID'] = poleID;
			sign['SIGNNAME'] = null;
			sign['DESCRIPTION'] = null;
			sign['SIGNFACING'] = null;
			sign['SIGNSIZE'] = null;
			sign['SIGNHEIGHT'] = null;
			sign['SIGNSTATUS'] = null;
			sign['ARROWDIRECTION'] = null;
			sign['COMMENT'] = null;
			
			return sign;
		}
		
		public function prepareSignBeforeSave(sign:Object):Object
		{
			// Conver to the sign to SQLite type
			// Domain to integer
			sign['SIGNFACING'] = sign['SIGNFACING'] || null;
			sign['SIGNSIZE'] = sign['SIGNSIZE'] || null;
			sign['SIGNSTATUS'] = sign['SIGNSTATUS'] || null;
			
			return sign;
		}
		
		public function prepareSignBeforeLoad(sign:Object):Object
		{
			sign['SIGNFACING'] = sign['SIGNFACING'] != null ? sign['SIGNFACING'].toString() : null;
			sign['SIGNSIZE'] = sign['SIGNSIZE'] != null ? sign['SIGNSIZE'].toString() : null;
			sign['SIGNSTATUS'] = sign['SIGNSTATUS'] != null ? sign['SIGNSTATUS'].toString() : null;
			
			return sign;
		}
		
		public function getSigns(supportID:Number, eventLayerID:Number, responder:IResponder):void
		{
			_requestEvent = new DdotRecordEvent(DdotRecordEvent.SIGN_REQUEST);
			var whereClause:String =  StringUtil.replace("POLEID = '@poleId'", "@poleId", supportID.toString());
			_requestEvent.serviceURL = _agsMapService.getCustomEventUrl(eventLayerID, whereClause);
			_requestEvent.supportID = supportID;
			_requestEvent.responder = responder;
			_dispatcher.dispatchEvent(_requestEvent);
			_requestEvent = null;
		}

		public function onSignServiceResult(obj:Object,event:DdotRecordEvent):void
		{
			event.stopPropagation();
			
			var resp:IResponder = event.responder;
			var supportID:Number = event.supportID;
			var arrayColl:ArrayCollection = new ArrayCollection();
			var arr:Array = parseJsonObj(obj);
			var dataArr:Array = new Array();
			for each(var arrItem:Object in arr)
				dataArr.push(arrItem.attributes);
			var liveSigns:ArrayCollection = new ArrayCollection(dataArr);
				
			// Get Local signs 
			var signs:ArrayCollection = _mdbm.getDdotSignByPoleID(supportID);
			
			// Get existing signIds
			var signIDs:Array = new Array();
			for each(var item:Object in signs)
				signIDs.push(item['SIGNID']);
			
			// Add live signs to the signs if the sign id is different from the existing ones
			for each (var liveSign:Object in liveSigns)
				if (signIDs.indexOf(liveSign['SIGNID']) == -1)
					signs.addItem(liveSign);
				
			// Have to do a bit pre-processing on each sign to make sure they can communicate with flex components
			for each (var sign:Object in signs)
				prepareSignBeforeLoad(sign);
			
			resp.result(signs);
		}
		
		public function getInspections(supportID:Number, signIDs:Array, eventLayerID:Number, responder:IResponder):void
		{
			_requestEvent = new DdotRecordEvent(DdotRecordEvent.INSPECTION_REQUEST);
			var whereClause:String =  "POLEID = @poleId & SIGNID in (@signIds)"
				.replace("@poleId", supportID.toString())
				.replace('@signIds', signIDs.join(","));
			_requestEvent.serviceURL = _agsMapService.getCustomEventUrl(eventLayerID, whereClause);
			_requestEvent.supportID = supportID;
			_requestEvent.signIDs = signIDs;
			_requestEvent.responder = responder;
			_dispatcher.dispatchEvent(_requestEvent);
			_requestEvent = null;
		}
		
		public function createNewInspection(poleID:Number, signID:Number):Object
		{
			var inspection:Object = new Object();
			inspection['INSPECTIONID'] = -1;
			inspection['POLEID'] = poleID == 0 ? null: poleID;
			inspection['SIGNID'] = signID == 0 ? null: signID;
			inspection['INSPECTOR'] = null;
			inspection['TYPE'] = null;
			inspection['OVERALLCONDITION'] = null;
			inspection['ACTIONTAKEN'] = null;
			inspection['ADDITIONALACTIONNEEDED'] = null;
			inspection['BENT'] = null;
			inspection['TWISTED'] = null;
			inspection['LOOSE'] = null;
			inspection['RUSTED'] = null;
			inspection['FADED'] = null;
			inspection['PEELING'] = null;
			inspection['OTHER'] = null;
			inspection['COMMENT'] = null;
			
			return inspection;
		}
		
		public function prepareInspectionBeforeSave(inspection:Object):Object
		{
			// Conver to the inspection to SQLite type
			// Domain to integer
			inspection['TYPE'] = inspection['TYPE'] || null;
			inspection['OVERALLCONDITION'] = inspection['OVERALLCONDITION'] || null;
			inspection['ACTIONTAKEN'] = inspection['ACTIONTAKEN'] || null;
			inspection['ADDITIONALACTIONNEEDED'] = inspection['ADDITIONALACTIONNEEDED'] || null;
			inspection['DATEINSPECTED'] = Date.parse(inspection['DATEINSPECTED']);
			inspection['BENT'] = inspection['BENT'] ? 1 : 0;
			inspection['TWISTED'] = inspection['TWISTED'] ? 1 : 0;
			inspection['LOOSE'] = inspection['LOOSE'] ? 1 : 0;
			inspection['RUSTED'] = inspection['RUSTED'] ? 1 : 0;
			inspection['FADED'] = inspection['FADED'] ? 1 : 0;
			inspection['PEELED'] = inspection['PEELED'] ? 1 : 0;
			inspection['OTHER'] = inspection['OTHER'] ? 1 : 0;
			
			return inspection;
		}
		
		public function prepareInspectionBeforeLoad(inspection:Object):Object
		{
			inspection['TYPE'] = inspection['TYPE'] != null ? inspection['TYPE'].toString() : null;
			inspection['OVERALLCONDITION'] = inspection['OVERALLCONDITION'] != null ? inspection['OVERALLCONDITION'].toString() : null;
			inspection['ACTIONTAKEN'] = inspection['ACTIONTAKEN'] != null ? inspection['ACTIONTAKEN'].toString() : null;
			inspection['ADDITIONALACTIONNEEDED'] = inspection['ADDITIONALACTIONNEEDED'] != null ? inspection['ADDITIONALACTIONNEEDED'].toString() : null;
			inspection['DATEINSPECTED'] = new Date(inspection['DATEINSPECTED']);
			inspection['BENT'] = inspection['BENT'] == 1 || inspection['BENT'];
			inspection['TWISTED'] = inspection['TWISTED'] == 1 || inspection['TWISTED'];
			inspection['LOOSE'] = inspection['LOOSE'] == 1 || inspection['LOOSE'];
			inspection['RUSTED'] = inspection['RUSTED'] == 1 || inspection['RUSTED'];
			inspection['FADED'] = inspection['FADED'] == 1 || inspection['FADED'];
			inspection['PEELED'] = inspection['PEELED'] == 1 || inspection['PEELED'];
			inspection['OTHER'] = inspection['OTHER'] == 1 || inspection['OTHER'];
			
			return inspection;
		}

		public function onInspectionServiceResult(obj:Object,event:DdotRecordEvent):void
		{
			event.stopPropagation();
			
			var resp:IResponder = event.responder;
			var supportID:Number = event.supportID;
			var signIDs:Array = event.signIDs;
			var arrayColl:ArrayCollection = new ArrayCollection();
			var arr:Array = parseJsonObj(obj);
			var dataArr:Array = new Array();
			for each(var arrItem:Object in arr)
				dataArr.push( arrItem.attributes);
			var liveInspections:ArrayCollection = new ArrayCollection(dataArr);
			
			// Get local inspections
			var inspections:ArrayCollection = _mdbm.getDdotInspectionByPoleSignID(supportID, signIDs);
			
			// Get existing inspectionIDs
			var inspectionIDs:Array = new Array();
			for each(var item:Object in liveInspections)
				inspectionIDs.push(item['INSPECTIONID']);
				
			// Add live inspections to the inspection if the inspection id is different from the existing ones
			for each (var liveInspection:Object in liveInspections)
			if (inspectionIDs.indexOf(liveInspection['INSPECTIONID']) == -1)
				inspections.addItem(liveInspection);
			
			// Have to do a bit pre-processing on each inspection to make sure they can communicate with flex components
			for each (var inspection:Object in inspections)
				prepareInspectionBeforeLoad(inspection);
			
			resp.result(inspections);
		}
		
		public function getOtherSignsOnRoute(routeID:String, signID:Number, eventLayerID:Number, responder:IResponder):void
		{
			_requestEvent = new DdotRecordEvent(DdotRecordEvent.SIGN_REQUEST);
			var whereClause:String =  "ROUTEID = '@routeId' and SIGNID <> @signId".replace("@routeId", routeID)
				.replace("@signId", signID.toString());
			_requestEvent.serviceURL = _agsMapService.getCustomEventUrl(eventLayerID, whereClause);
			_requestEvent.responder = responder;
			_dispatcher.dispatchEvent(_requestEvent);
			_requestEvent = null;
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
		
		public function saveSigns(signs:ArrayCollection):void
		{
			for each(var sign:Object in signs)
			{
				sign = prepareSignBeforeSave(sign);
				if (sign['SIGNID'] == -1 || !_mdbm.isDdotSignExist(sign['SIGNID']))
					_mdbm.addDdotSign(sign);
				else
					_mdbm.updateDdotSign(sign);
			}
		}
		
		public function saveInspections(inspections:ArrayCollection):void
		{
			for each(var inspection:Object in inspections)
			{
				inspection = prepareInspectionBeforeSave(inspection);
				if (inspection['INSPECTIONID'] == -1 || !_mdbm.isDdotInspectionExist(inspection['INSPECTIONID']))
					_mdbm.addDdotInspection(inspection);
				else
					_mdbm.updateDdotInspection(inspection);
			}
		}
	}
}