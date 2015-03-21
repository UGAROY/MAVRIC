package com.transcendss.mavric.managers.ddot
{
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.mavric.db.AgsMapService;
	import com.transcendss.mavric.db.MAVRICDBManager;
	import com.transcendss.mavric.events.ddot.DdotRecordEvent;
	import com.transcendss.mavric.util.FileUtility;
	import com.transcendss.transcore.sld.models.StickDiagram;
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	import com.transcendss.transcore.sld.models.components.Route;
	import com.transcendss.transcore.sld.models.managers.CoreAssetManager;
	
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.rpc.IResponder;
	
	
	public class DdotRecordManager extends CoreAssetManager
	{
		private var _mdbm : MAVRICDBManager;
		private var _requestEvent : DdotRecordEvent;
		private var _agsMapService:AgsMapService;
		private var _stkDiagram:StickDiagram;
		private var fileUtil:FileUtility = new FileUtility();
		
		public var signTypeDictionary:Object = new Object();
		
		private var _newSignID:Number;
		private var _newInspectionID:Number;
		
		private var _supportDict:Object;
		
		private var _signEventLayerID:Number = 17;
		private var _inspectionEventLayerID:Number = 15;
		private var _linkEventLayerID:Number = 16;
		private var _trEventLayerID:Number = 18;
		private var _wardEventLayerID:Number = 14;
		
		public var dispatcher:IEventDispatcher;
		
		private var _allSigns:ArrayCollection = new ArrayCollection();
		public var _allSupportsObj:Object = new Object;
		private var _allInspections:ArrayCollection = new ArrayCollection();
		private var _allLinks:ArrayCollection = new ArrayCollection();
		private var _allTimeRestrictions:ArrayCollection = new ArrayCollection();
		private var _intersectionList:ArrayCollection= new ArrayCollection();
		
		public function get signEventLayerID():Number
		{
			return _signEventLayerID;
		}
		public function get linkEventLayerID():Number
		{
			return _linkEventLayerID;
		}
		
		public function get trEventLayerID():Number
		{
			return _trEventLayerID;
		}
		
		public function get wardEventLayerID():Number
		{
			return _wardEventLayerID;
		}
		
		public function get inspectionEventLayerID():Number
		{
			return _inspectionEventLayerID;
		}
		
		public function get allIntersections():ArrayCollection
		{
			return _intersectionList;
		}
		
		
		public function get allSigns():ArrayCollection
		{
			return _allSigns;
		}
		
		public function get allInspections():ArrayCollection
		{
			return _allInspections;
		}
		
		public function get allLinks():ArrayCollection
		{
			return _allLinks;
		}
		
		public function get allTimeRestrictions():ArrayCollection
		{
			return _allTimeRestrictions;
		}
		
		public function set allSigns(a:ArrayCollection):void
		{
			 _allSigns = a;
		}
		
		public function set allInspections(a:ArrayCollection):void
		{
			 _allInspections=a;
		}
		
		public function set allLinks(a:ArrayCollection):void
		{
		  _allLinks=a;
		}
		
		public function set allTimeRestrictions(a:ArrayCollection):void
		{
		 _allTimeRestrictions=a;
		}
		
		/**
		 * Creates tables for an list of different types of assets.
		 */
		public function DdotRecordManager()
		{
			_mdbm = MAVRICDBManager.newInstance();
			_assetDefs = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetDefs;
			_assetDescriptions= FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetDescriptions;
			_barElementDefs= FlexGlobals.topLevelApplication.GlobalComponents.assetManager.barElementDefs;
			_barElementDescriptions= FlexGlobals.topLevelApplication.GlobalComponents.assetManager.barElementDescriptions;
			
			
			_agsMapService = FlexGlobals.topLevelApplication.agsMapService;
			_stkDiagram = FlexGlobals.topLevelApplication.GlobalComponents.stkDiagram;
			_dispatcher = new Dispatcher(); 
			
			// Get the mininum and <0  signID and InspectionID
			_newSignID = _mdbm.assignNewSignID();
			_newInspectionID = _mdbm.assignNewInspectionID();
			
		}
		
		// Update the support ids already drawn on sld with the id on server that we can retreive the inspections and signs correctly
		public function updateSupportIDs(maxSupportIDOnServer:Number):void
		{
			var supports:ArrayCollection = this.getAllSupports();
			for each(var support:BaseAsset in supports)
			{
				if (support.id < 0)
					support.id = maxSupportIDOnServer - support.id - 1;
			}
		}
		
		// reset the new sign inspection starting id after syncing
		public function resetNewSignInspectionID():void
		{
			_newSignID = _mdbm.assignNewSignID();
			_newInspectionID = _mdbm.assignNewInspectionID();
		}
		
		public function getAllSupports():ArrayCollection
		{
			//return _stkDiagram.spriteLists['SUPPORT'];
			return toArrayCollection(this._allSupportsObj.assets);
		}
		
		// Build a support dictionary. supportid as key and (measure, routeid) as value
		public function buildSupportDict():void
		{
			var allSupports:ArrayCollection = getAllSupports();
			this._supportDict = new Object();
			for each(var support:Object in allSupports)
			{
				var supportProperties:Object = new Object();
				supportProperties['MEASURE'] = support['invProperties'].MEASURE.value;
				supportProperties['ROUTEID'] = support['invProperties'].ROUTEID.value;
				this._supportDict[parseInt(support['invProperties'].POLEID.value)] = supportProperties;
			}
		}
		
		
		public function createNewSign(poleID:Number):Object
		{
			var sign:Object = new Object();
			sign['SIGNID'] = --this._newSignID;
			sign['POLEID'] = poleID;
			sign['SIGNNAME'] = null;
			sign['DESCRIPTION'] = null;
			sign['SIGNFACING'] = null;
			sign['SIGNSIZE'] = null;
			sign['SIGNHEIGHT'] = null;
			sign['SIGNSTATUS'] = null;
			sign['ARROWDIRECTION'] = null;
			sign['COMMENTS'] = null;
			sign['ISLOADINGZONE'] = null;
			
			sign['MEASURE'] = FlexGlobals.topLevelApplication.sldDiagram.sldDiagram.getCurrentMP();
			
			return sign;
		}
		
		public function prepareSignBeforeSave(sign:Object):Object
		{
			// Conver to the sign to SQLite type
			// Domain to integer
			sign['SIGNFACING'] = sign['SIGNFACING'] || null;
			sign['SIGNSIZE'] = sign['SIGNSIZE'] || null;
			sign['SIGNSTATUS'] = sign['SIGNSTATUS'] || null;
			
			sign['ISLOADINGZONE'] = sign['ISLOADINGZONE'] == true ? 1 : 0;
			
			return sign;
		}
		
		public function prepareSignBeforeLoad(sign:Object):Object
		{
			sign['SIGNFACING'] = sign['SIGNFACING'] != null ? sign['SIGNFACING'].toString() : null;
			sign['SIGNSIZE'] = sign['SIGNSIZE'] != null ? sign['SIGNSIZE'].toString() : null;
			sign['SIGNSTATUS'] = sign['SIGNSTATUS'] != null ? sign['SIGNSTATUS'].toString() : null;
			
			sign['ISLOADINGZONE'] = sign['ISLOADINGZONE'] == 1 ? true : false;
			
			// Set the DESCRIPTION. TODO: map it to the real description
			sign['DESCRIPTION'] = sign['DESCRIPTION'] || sign['SIGNNAME'];
			
			// Add the routeId and measure to the sign
			if (sign['POLEID'] < 0)
			{
				// if new sign, get the current route id and measure 
				sign['MEASURE'] = FlexGlobals.topLevelApplication.sldDiagram.sldDiagram.getCurrentMP();
				sign['ROUTEID'] = FlexGlobals.topLevelApplication.currentRouteName;
			} 
			else
			{
				sign['MEASURE'] = this._supportDict[sign['POLEID']]['MEASURE'];
				sign['ROUTEID'] = this._supportDict[sign['POLEID']]['ROUTEID'];
			}
			
			return sign;
		}
		
		public  function onDBRetrievalCompleteDDOT(arr:ArrayCollection, type:String, resp:IResponder, route:Route =null):void
		{
			this.route =  FlexGlobals.topLevelApplication.GlobalComponents.assetManager.route;
			var assetCollection:Vector.<BaseAsset> = new Vector.<BaseAsset>();
			
			
			if(type=="MILEMARKER")
			{
				origMileMarkers= arr;
				arr = this.filteredMileMarkers;
				FlexGlobals.topLevelApplication.GlobalComponents.assetManager.origMileMarkers = arr;
			}
			
			
			var supportIDList:Array =new Array();
			
			for each(var asset:Object in arr)
			{
				var temp:BaseAsset = mapDataToBaseAsset(asset, type);
				
				
				if(type=="SUPPORT")//store supports and id list
				{
					supportIDList.push(temp.id);
					if(temp.invProperties[temp.typeKey].value=='null')
						temp.invProperties[temp.typeKey].value='LEFT'; //set it to N by default
					if(temp.invProperties["POLESTATUS"].value!=5)//if it is not retired
						assetCollection.push(temp);
				}
				else if(type=="INT")
				{
					_intersectionList.addItem(temp);
					assetCollection.push(temp)
				}
				else
					assetCollection.push(temp);
				
			}
			
			
			if(type=="SUPPORT")
			{
				this._allSupportsObj = {assets: assetCollection, type: type};
				
				getSignsForAllSupports(supportIDList,resp);
			}
			else
				resp.result({assets: assetCollection, type: type, route:route});
		}
		
		private function toArrayCollection(iterable:*):ArrayCollection {
			var ret:Array = [];
			for each (var elem:BaseAsset in iterable) ret.push(elem);
			return new ArrayCollection(ret);
		}

		
		public function getSignsForAllSupports(supportIDList:Array,  responder:IResponder):void
		{
			FlexGlobals.topLevelApplication.incrementEventStack();
			_requestEvent = new DdotRecordEvent(DdotRecordEvent.SIGN_REQUEST);
			var whereClause:String =  "POLEID in (@poleIds)"
				.replace("@poleIds", supportIDList.join(','));
			_requestEvent.serviceURL = _agsMapService.getCustomEventUrl(this._signEventLayerID, whereClause);
			_requestEvent.supportIDs = supportIDList;
			_requestEvent.responder =  responder;
			_dispatcher.dispatchEvent(_requestEvent);
			_requestEvent = null;
		}
		
		
		
		public function onAllSignServiceResult(obj:Object,event:DdotRecordEvent):void
		{
			event.stopPropagation();
			
			
			var supportIDList:Array = event.supportIDs;
			
			var arrayColl:ArrayCollection = new ArrayCollection();
			var arr:Array = parseJsonObj(obj);
			var dataArr:Array = new Array();
			
			for each(var arrItem:Object in arr)
			dataArr.push(arrItem.attributes);
			
			var liveSigns:ArrayCollection = new ArrayCollection(dataArr);
			var signs:ArrayCollection = new ArrayCollection();
			var signIDs:Array = new Array();
			// Get Local signs 
			for each(var supportID in supportIDList)
			{
				signs.addAll( _mdbm.getDdotSignByPoleID(supportID));
				
				// Get existing signIds
				
				for each(var item:Object in signs)
				signIDs.push(item['SIGNID']);
				
				
			}
			// Add live signs to the signs if the sign id is different from the existing ones
			for each (var liveSign:Object in liveSigns)
			if (signIDs.indexOf(liveSign['SIGNID']) == -1)
			{
				signs.addItem(liveSign);
				signIDs.push(liveSign['SIGNID']);
			}
			
			// Have to do a bit pre-processing on each sign to make sure they can communicate with flex components
			buildSupportDict();
			for each (var sign:Object in signs)
			prepareSignBeforeLoad(sign);
			
			event.signIDs = signIDs;
			this._allSigns= signs;
			getAllInspections(event);
			FlexGlobals.topLevelApplication.decrementEventStack();
			
		}
		
		public function getAllInspections(ddotEvent:DdotRecordEvent):void
		{
			FlexGlobals.topLevelApplication.incrementEventStack();
			_requestEvent = new DdotRecordEvent(DdotRecordEvent.INSPECTION_REQUEST);
			var whereClause:String =  "POLEID in (@poleId) or SIGNID in (@signIds)"
				.replace("@poleId", ddotEvent.supportIDs.join(','))
				.replace('@signIds', ddotEvent.signIDs.join(","));
			_requestEvent.serviceURL = _agsMapService.getCustomEventUrl(this._inspectionEventLayerID, whereClause);
			_requestEvent.supportIDs = ddotEvent.supportIDs;
			_requestEvent.signIDs = ddotEvent.signIDs;
			_requestEvent.responder = ddotEvent.responder;
			_dispatcher.dispatchEvent(_requestEvent);
			_requestEvent = null;
		}
		
		public function createNewInspection(poleID:Number, signID:Number):Object
		{
			var inspection:Object = new Object();
			inspection['INSPECTIONID'] = --_newInspectionID;
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
			inspection['COMMENTS'] = null;
			
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
			inspection['DATEINSPECTED'] = (inspection['DATEINSPECTED'] && !isNaN(inspection['DATEINSPECTED'])) ? ((inspection['DATEINSPECTED'] is Date)? Date.parse(inspection['DATEINSPECTED']): inspection['DATEINSPECTED']):null;
			inspection['BENT'] = inspection['BENT'] ? 1 : 0;
			inspection['TWISTED'] = inspection['TWISTED'] ? 1 : 0;
			inspection['LOOSE'] = inspection['LOOSE'] ? 1 : 0;
			inspection['RUSTED'] = inspection['RUSTED'] ? 1 : 0;
			inspection['FADED'] = inspection['FADED'] ? 1 : 0;
			inspection['PEELING'] = inspection['PEELING'] ? 1 : 0;
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
			inspection['PEELING'] = inspection['PEELING'] == 1 || inspection['PEELING'];
			inspection['OTHER'] = inspection['OTHER'] == 1 || inspection['OTHER'];
			
			return inspection;
		}
		
		public function onAllInspectionServiceResult(obj:Object,event:DdotRecordEvent):void
		{
			event.stopPropagation();
			
			var resp:IResponder = event.responder;
			var supportIDList:Array = event.supportIDs;
			var signIDs:Array = event.signIDs;
			var arrayColl:ArrayCollection = new ArrayCollection();
			var arr:Array = parseJsonObj(obj);
			var dataArr:Array = new Array();
			for each(var arrItem:Object in arr)
			dataArr.push( arrItem.attributes);
			var liveInspections:ArrayCollection = new ArrayCollection(dataArr);
			var inspections:ArrayCollection = new ArrayCollection();
			var inspectionIDs:Array = new Array();
			
			for each(var supportID in supportIDList)
			{
				// Get local inspections
				inspections.addAll(_mdbm.getDdotInspectionByPoleSignID(supportID, signIDs));
				
				
				for each(var item:Object in inspections)
				inspectionIDs.push(item['INSPECTIONID']);
			}
			// Add live inspections to the inspection if the inspection id is different from the existing ones
			for each (var liveInspection:Object in liveInspections)
			if (inspectionIDs.indexOf(liveInspection['INSPECTIONID']) == -1)
				inspections.addItem(liveInspection);
			
			// Have to do a bit pre-processing on each inspection to make sure they can communicate with flex components
			buildSupportDict();
			for each (var inspection:Object in inspections)
			prepareInspectionBeforeLoad(inspection);
			
			this._allInspections = inspections;
			
			getLinkBySignIDList(signIDs);
			FlexGlobals.topLevelApplication.decrementEventStack();
			//resp.result(inspections);
			resp.result(this._allSupportsObj);
		}
		
		public function getSignsByPoleID(poleID:Number):Object {
			
			var curSignList:ArrayCollection = new ArrayCollection();
			var curSignIDList:Array= new Array();
			var tempSigns:ArrayCollection = new ArrayCollection();
			//tempSigns.addAll(_allSigns);
			tempSigns.addAll( _mdbm.getDdotSignByPoleID(poleID));
			
			for each(var sign:Object in tempSigns)
			{
				curSignList.addItem(sign);
				curSignIDList.push(sign.SIGNID);
			}
			
			
			for each (var liveSign:Object in _allSigns)
			{
				if (curSignIDList.indexOf(liveSign['SIGNID']) == -1 && liveSign.POLEID == poleID)
				{
					tempSigns.addItem(liveSign);
					curSignList.addItem(liveSign);
					curSignIDList.push(liveSign.SIGNID);
				}
				
			}
				
			
			
			
			
			return {signs:curSignList, signIDs:curSignIDList};
		}
		
		public function getInspectionsForAsset(poleID:Number,signIDs:Array):ArrayCollection {
			var inspID:Array = new Array();
			var localInsp:ArrayCollection = _mdbm.getDdotInspectionByPoleSignID(poleID, signIDs);
			
			for each (var localI:Object in localInsp)
				inspID.push(localI['INSPECTIONID'])
			
			
			var filterFunction:Function = function(element:*, index:int, arr:Array):Boolean {
				return (element.POLEID == poleID || signIDs.indexOf(element.SIGNID) != -1) && (inspID.indexOf(element.INSPECTIONID)==-1);
			}
			
				var inspections:ArrayCollection = new ArrayCollection(_allInspections.source.filter(filterFunction));
				inspections.addAll(localInsp);
			return inspections;
			
		}
		
		public function getOtherSigns(signID:Number):ArrayCollection{
			var otherSigns:ArrayCollection = new ArrayCollection();
			var tempSigns:ArrayCollection = new ArrayCollection();
			var localIDs:Array = new Array();
			
			tempSigns.addAll( _mdbm.getAllLocalDdotSign());
			
			for each(var localsign:Object in tempSigns)
			{
				if (localsign['SIGNID'] != signID)
				{
					otherSigns.addItem(localsign);
					localIDs.push(localsign['SIGNID']);
				}
			}
			
			for each (var sign:Object in _allSigns)
			{
				if (sign['SIGNID'] != signID && localIDs.indexOf('SIGNID')===-1)
					otherSigns.addItem(sign);
			}
			return otherSigns;
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
				if (!_mdbm.isDdotSignExist(sign['SIGNID']))
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
				if (!_mdbm.isDdotInspectionExist(inspection['INSPECTIONID']))
					_mdbm.addDdotInspection(inspection);
				else
					_mdbm.updateDdotInspection(inspection);
			}
		}
		
		public function getLinkBySignID(signID:Number):Object
		{

			var link:Object= new Object();
			
			for each(var links:Object in this._allLinks)
				if(links.signID == signID)
				{
					link["link"]=links.linkID;
					link["zoneid"]=links.zoneID;
				}
			
			var localLink:Object = _mdbm.getLinkBySignID(signID);
			
			if (localLink != null)
				 return localLink;
			else
				return link;
		}
		
		public function getLinkBySignIDList(signIDs:Array):void
		{
			FlexGlobals.topLevelApplication.incrementEventStack();
			_requestEvent = new DdotRecordEvent(DdotRecordEvent.LINK_REQUEST);
			var whereClause:String =  "SIGNID IN (@signIds)".replace("@signIds", signIDs.join(','));
			_requestEvent.serviceURL = _agsMapService.getCustomEventUrl(this._linkEventLayerID, whereClause);
			_requestEvent.signIDs = signIDs;
			_dispatcher.dispatchEvent(_requestEvent);
			_requestEvent = null;
		}
		
		public function onLinkResult(obj:Object,event:DdotRecordEvent):void
		{
			event.stopPropagation();
			
			FlexGlobals.topLevelApplication.decrementEventStack();
			
			var resp:IResponder = event.responder;
			var linkIDs:Array = new Array();
			var arr:Array = parseJsonObj(obj);
			
				for each (var linkObj in arr)
				{
					_allLinks.addItem({linkID:linkObj.attributes.LINKID, signID:linkObj.attributes.SIGNID, zoneID:linkObj.attributes.ZONEID});
					linkIDs.push(linkObj.attributes.LINKID);
				}
			
				if(linkIDs.length>0)
					getTimeRestrictions(linkIDs);
		}
		
		public function saveLink(link:Object):void
		{
			for (var key:String in link)
			{
				if (link[key]['NEW'] != null && link[key]['NEW'] != "")
				{
					var newLinkID:String = link[key]['NEW'];
					var oldLinkID:String = link[key]['OLD'];
					var zoneID:String = link[key]['ZONEID'];
					if (oldLinkID != null)
						_mdbm.deleteOldLinkByLinkID(oldLinkID);
					if (!_mdbm.isLinkExist(newLinkID))
					{
						var allSignIDs:Array = newLinkID.split('_');
						for each (var signID:String in allSignIDs)
						_mdbm.addLink(newLinkID, parseInt(signID), oldLinkID, zoneID);
					}
				}
			}
		}
		
		public function getTimeRestrictionByLinkID(linkID:String):ArrayCollection
		{
			var tres:ArrayCollection = new ArrayCollection();
			for each(var restriction in this._allTimeRestrictions)
			{
				if(restriction.LINKID ==linkID)
					tres.addItem(restriction);
			}
			
			return tres;
		}
		
		public function getTimeRestrictions(linkIDs:Array):void
		{
			FlexGlobals.topLevelApplication.incrementEventStack();
			_requestEvent = new DdotRecordEvent(DdotRecordEvent.TIME_RESTRICTION_REQUEST);
			var whereClause:String =  "LINKID IN ('@linkIds')".replace("@linkIds", linkIDs.join('\',\''));
			_requestEvent.serviceURL = _agsMapService.getCustomEventUrl(this._trEventLayerID, whereClause);
			_dispatcher.dispatchEvent(_requestEvent);
			_requestEvent = null;
		}
		
		public function onTimeRestrictionsResult(obj:Object,event:DdotRecordEvent):void
		{
			event.stopPropagation();
			
			var resp:IResponder = event.responder;
			var linkID:String = event.linkID;
			var arr:Array = parseJsonObj(obj);
			var dataArr:Array = new Array();
			for each(var arrItem:Object in arr)
			dataArr.push(arrItem.attributes);
			_allTimeRestrictions = new ArrayCollection(dataArr);
			FlexGlobals.topLevelApplication.decrementEventStack();
			
		}
		
		public function saveTimeRestriction(linkTrDict:Object):void
		{
			for (var key:String in linkTrDict)
			{
				_mdbm.deleteOldTrByLinkID(key);
				for each(var tr:Object in linkTrDict[key])
				_mdbm.addTimeRestriction(key, tr);
			}
		}
		
		public function getGeotags(supportID:Number):Array
		{
			return _mdbm.getDdotGeotagsBySupportID(supportID);
		}
		
		public function getUpdatedSupportID(support:BaseAsset):Number
		{
			return _mdbm.getDdotUpdatedSupportID(support);
		}
		
	}
}