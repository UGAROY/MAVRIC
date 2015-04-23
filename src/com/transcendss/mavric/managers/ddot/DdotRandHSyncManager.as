package com.transcendss.mavric.managers.ddot
{
	import com.adobe.net.MimeTypeMap;
	import com.asfusion.mate.core.GlobalDispatcher;
	import com.transcendss.mavric.db.MAVRICDBManager;
	import com.transcendss.mavric.events.ddot.DdotRecordEvent;
	import com.transcendss.mavric.events.ddot.DdotSyncEvent;
	import com.transcendss.mavric.managers.ArcGISServiceManager;
	import com.transcendss.mavric.util.FileUtility;
	import com.transcendss.mavric.util.UploadPostHelper;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	import mx.core.FlexGlobals;
	import mx.utils.StringUtil;
	
	import spark.formatters.DateTimeFormatter;
	
	public class DdotRandHSyncManager
	{
		public var dispatcher:GlobalDispatcher = new GlobalDispatcher();
		private var dbManager:MAVRICDBManager = MAVRICDBManager.newInstance();
		private var recordManager:DdotRecordManager = FlexGlobals.topLevelApplication.GlobalComponents.recordManager;
		
		[Bindable]
		private var useAgsService:Boolean = FlexGlobals.topLevelApplication.useAgsService;
		private var dtFormatter:DateTimeFormatter = new DateTimeFormatter();
		private var mimeTyMap:MimeTypeMap = new MimeTypeMap();
		private var fileUtil:FileUtility = new FileUtility();
		private var agsManager:ArcGISServiceManager = new ArcGISServiceManager();
		//private var gtArray:Array = new Array();
		private var layerID:String ="";
		private var objectID:String="";
		
		//private var _supportEventLayerID:Number ;
		//		private var _signEventLayerID:Number = 19;
		//		private var _inspectionEventLayerID:Number = 15;
		//		private var _linkEventLayerID:Number = 16;
		//		private var _trEventLayerID:Number = 18;
		
//		private var maxSupportIDOnServer:Number;
//		private var maxSignIDOnServer:Number;
//		private var maxInspectionIDOnServer:Number;
		
		private var supportGtArray:Array = new Array();
		private var signGtArray:Array = new Array();
		private var inspectionGtArray:Array = new Array();
		
		private var links:Array;
		private var timeRestrictions:Array;
		
		public function DdotRandHSyncManager()
		{
			mimeTyMap.addMimeType("video/3gpp", ["3gp","3gpp"]);
			dtFormatter.dateTimePattern = "MM/dd/yyyy HH:mm:ss";
			dtFormatter.useUTC=false;
			dtFormatter.errorText="";
			
		}
		
		//		private function getLocalData():ArrayCollection
		//		{
		//			var assetDef:Object = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetDefs;
		//			var assetsForSync:Array = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetsForSync;
		//			
		//			var assetData:ArrayCollection = new ArrayCollection();
		//			for each (var def:Object in assetDef) 
		//			{
		//				if(assetsForSync.indexOf(def.DESCRIPTION !=-1))//if asset sync is true
		//				{
		//					var dataArr:Array = dbManager.exportAssets(def.DESCRIPTION);
		//					var gtArr:Array = dbManager.exportGeotagData(def.ASSET_TYPE);
		//					assetData.addItem({eventLayerID:def.EVENT_LAYER_ID,assetTy:def.ASSET_TYPE, assetDesc:def.DESCRIPTION, data: dataArr, geotags:gtArr, primaryKey:def.ASSET_DATA_TEMPLATE.PRIMARY_KEY});
		//				}
		//			}
		//			
		//			return assetData;
		//		}
		
		private function getAssetCount():Number
		{
			
			var changeCount:Number =0 ;
			
			
			var data:Array 	 = dbManager.exportAssets("SUPPORT");
			changeCount   	+=  data && data.length>0?data.length:0;
			data 		  	 = dbManager.exportGeotagData("1");
			changeCount 	+=    data && data.length>0?data.length:0;
			data 			 = dbManager.exportDdotRecords("SIGNS");
			changeCount 	+=    data && data.length>0?data.length:0;
			data 			 = dbManager.exportGeotagData("SIGN");
			changeCount		+=   data && data.length>0?data.length:0;
			data 			 = dbManager.exportDdotRecords("INSPECTIONS");
			changeCount 	+=   data && data.length>0?data.length:0;
			data 			 = dbManager.exportGeotagData("INSPECTION");
			changeCount 	+=   data && data.length>0?data.length:0;
			
			FlexGlobals.topLevelApplication.syncAssetsCount = changeCount;
//			FlexGlobals.topLevelApplication.TSSAlert(changeCount);
			return changeCount ;
		}
		
		private function getLocalRecords(assetType:String):Object
		{
			
			var dataArr:Array;
			var gtArr:Array;
			var assetData:Object = new Object();
			if (assetType == "1" || assetType == "SUPPORT")
			{
				dataArr= dbManager.exportAssets("SUPPORT");
				gtArr = dbManager.exportGeotagData("1");
				assetData = {eventLayerID:FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getEventLayerIDByType("1"),assetTy:"1", assetDesc:"SUPPORT", data: dataArr, geotags:gtArr, primaryKey:"SUPPORTID"};
			}
			else if (assetType == "SIGN")
			{
				dataArr = dbManager.exportDdotRecords("SIGNS");
				gtArr = dbManager.exportGeotagData("SIGN");
				assetData = {eventLayerID:recordManager.signEventLayerID,assetTy:"SIGN", assetDesc:"SIGN", data: dataArr, geotags:gtArr, primaryKey:"SIGNID"};
			}
			else if (assetType == "INSPECTION")
			{
				dataArr = dbManager.exportDdotRecords("INSPECTIONS");
				gtArr = dbManager.exportGeotagData("INSPECTION");
				assetData = {eventLayerID:recordManager.inspectionEventLayerID,assetTy:"INSPECTION", assetDesc:"INSPECTION", data: dataArr, geotags:gtArr, primaryKey:"INSPECTIONID"};
			}
			
			return assetData;
		}
		
		public function syncChanges():void
		{
			//_supportEventLayerID = ;
			FlexGlobals.topLevelApplication.failedSyncDetails ="";
			var uname:String = FlexGlobals.topLevelApplication.menuBar.getCurrentUser();
			var edits:Array = new Array();
			if(uname=="" || uname==null)
			{
				FlexGlobals.topLevelApplication.TSSAlert('Current User not specified. User name required for syncing');
				return;
			}
			
			if(!useAgsService)
			{
				FlexGlobals.topLevelApplication.TSSAlert('Please enable ArcGIS service use for R&H Sync');
				return;
			}
			
			if(getAssetCount()<1){
				FlexGlobals.topLevelApplication.TSSAlert('No Data Changes Available for Sync');
				return;
			}
			
			//			// temporary codes
			//			syncLink();
			//			return;
			FlexGlobals.topLevelApplication.setBusyStatus(true);
			// Fire off find max support id event
			fireMaxIDRequest("SUPPORTID", FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getEventLayerIDByType("1"));
		}
		
		private function fireMaxIDRequest(idField:String, eventLayerID:Number)
		{
			
			var maxRecordIDEvent:DdotRecordEvent = new DdotRecordEvent(DdotRecordEvent.MAX_RECORD_ID_REQUEST);
			maxRecordIDEvent.idField = idField;
			maxRecordIDEvent.eventLayerID = eventLayerID;
			dispatcher.dispatchEvent(maxRecordIDEvent);
		}
		
		// Do it this way to kind of make a chain
		public function onMaxIdServiceResult(obj:Object, evt:DdotRecordEvent):void
		{
			var maxId:Number = extractMaxIDFromServiceResult(obj, evt.idField);
			if (maxId == -9999)
			{
				FlexGlobals.topLevelApplication.TSSAlert("Failed contacting the server.");
				return;
			}
			
			if (evt.eventLayerID == FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getEventLayerIDByType("1"))
			{
				recordManager.maxSupportIDOnServer = maxId;
				syncSupport();
				// fire off events to find the max sign id
				fireMaxIDRequest("SIGNID", recordManager.signEventLayerID)
			}
			else if (evt.eventLayerID == recordManager.signEventLayerID)
			{
				recordManager.maxSignIDOnServer = maxId;
				syncSign();
				// fire off events to find the max inspection id
				fireMaxIDRequest("INSPECTIONID", recordManager.inspectionEventLayerID);
				
				// sync link
				syncLink();
				
				// sync time restriction
				syncTimeRestriction();
			}
			else if (evt.eventLayerID == recordManager.inspectionEventLayerID)
			{
				recordManager.maxInspectionIDOnServer = maxId;
				syncInspection();
			}
		}
		
		private function syncSupport():Boolean
		{	
			var supportAssetData:Object = getLocalRecords("SUPPORT");
			if (supportAssetData.data ==null)
			{
				
				return false;
			}
			for each(var supportAsset:Object in supportAssetData.data)
			{
				if (supportAsset['SUPPORTID'] < 0)
					// Based on the current code, the support starts from -2. So do an extra -1
					supportAsset['SUPPORTID'] = recordManager.maxSupportIDOnServer - supportAsset['SUPPORTID'] - 1; 
			}
			applyEdits(supportAssetData);	
			return true;
		}
		
		private function syncSign():void
		{
			var signAssetData:Object = getLocalRecords("SIGN");
			if (signAssetData.data ==null)
				return;
			if (signAssetData.data && signAssetData.data.length >0)
			{
				for each(var signAsset:Object in signAssetData.data)
				{
					if (signAsset['SUPPORTID'] < 0)
						signAsset['SUPPORTID'] = recordManager.maxSupportIDOnServer - signAsset['SUPPORTID'] - 1; 
					if (signAsset['SIGNID'] < 0)
					{
						signAsset['SIGNID'] = recordManager.maxSignIDOnServer - signAsset['SIGNID'];
						signAsset['STATUS'] = "NEW";
					}
				}
				applyEdits(signAssetData);	
			}
		}
		
		private function syncInspection():void
		{
			var inspectionData:Object = getLocalRecords("INSPECTION");
			if (inspectionData.data !=null && inspectionData.data.length > 0)
			{
				for each(var inspection:Object in inspectionData.data)
				{
					if (inspection['SUPPORTID'] < 0)
						inspection['SUPPORTID'] = recordManager.maxSupportIDOnServer - inspection['SUPPORTID'] - 1; 
					if (inspection['SIGNID'] != null && inspection['SIGNID'] < 0)
						inspection['SIGNID'] = recordManager.maxSignIDOnServer - inspection['SIGNID'];
					if (inspection['INSPECTIONID'] < 0)
					{
						inspection['INSPECTIONID'] = recordManager.maxInspectionIDOnServer - inspection['INSPECTIONID'];	
						inspection['STATUS'] = "NEW";
					}
				}
				applyEdits(inspectionData);
			}	
		}
		
		private function syncLink():void
		{
			links = dbManager.exportDdotRecords("LINKEDSIGN", ["LINKID", "ZONEID", "SIGNID"]);
			if (!links || links.length <= 0)
				return;
			var signIDs:Array = new Array();
			for each (var link:Object in links)
			{
				if (link['SIGNID'] < 0)
					link['SIGNID'] = recordManager.maxSignIDOnServer - link['SIGNID'];
				var linkIDArray:Array = String(link['LINKID']).split('_');
				for (var i:int = 0; i < linkIDArray.length; i++)
				{
					var linkID:Number = parseInt(linkIDArray[i]);
					if (linkID < 0)
						linkIDArray[i] = (recordManager.maxSignIDOnServer - linkID).toString();
				}
				link['LINKID'] = linkIDArray.join('_');
				signIDs.push(link['SIGNID']);
			}
			
			var getLinkIDsEvent:DdotSyncEvent = new DdotSyncEvent(DdotSyncEvent.LINK_ID_REQUEST);
			var whereClause:String = StringUtil.substitute("SIGNID in ({0})", signIDs.join(','));
			getLinkIDsEvent.serviceURL = agsManager.getCustomEventUrl(recordManager.linkEventLayerID, whereClause);
			dispatcher.dispatchEvent(getLinkIDsEvent);
		}
		
		public function onLinkIDsResult(obj:Object, evt:DdotSyncEvent):void
		{
			if (obj != null && obj.features && obj.features.length > 0)
			{
				// the linkID to be deleted
				var tbdLinkIDs:Array = new Array();
				
				for each (var feature:Object in obj.features)
				{
					tbdLinkIDs.push(feature.attributes['LINKID']);
				}
				
				// Get the object ids of the link id records to be deleted
				var getLinkObjectIDsEvent:DdotSyncEvent = new DdotSyncEvent(DdotSyncEvent.LINK_OBJECTID_REQUEST);
				var whereClause:String = StringUtil.substitute("LINKID in ({0})", "'" + tbdLinkIDs.join("','") + "'");
				getLinkObjectIDsEvent.serviceURL = agsManager.getCustomEventUrl(recordManager.linkEventLayerID, whereClause);
				dispatcher.dispatchEvent(getLinkObjectIDsEvent);
			}
			else
			{
				uploadLinks();
			}
		}
		
		public function onLinkObjectIDsResult(obj:Object, evt:DdotSyncEvent):void
		{
			if (obj != null && obj.features && obj.features.length > 0)
			{
				var objectIDs:Array = new Array();
				
				for each (var feature:Object in obj.features)
				{
					objectIDs.push(feature.attributes['OBJECTID']);
				}
				
				uploadLinks(objectIDs);
			}
		}
		
		private function uploadLinks(deleteOIDs:Array=null):void
		{
			var editsArr:Array = new Array(); 
			
			var applyEditsObj:Object = new Object();
			applyEditsObj.id= recordManager.linkEventLayerID;
			if (deleteOIDs != null)
				applyEditsObj.deletes = deleteOIDs;
			applyEditsObj.adds = new Array();
			
			for(var j:int =0;j< links.length;j++)
			{
				var attrObj:Object = new Object();
				var asset:Object  = links[j];
				attrObj.attributes = asset;
				applyEditsObj.adds.push(attrObj);
			}
			editsArr.push(applyEditsObj);
			
			var sync:DdotSyncEvent = new DdotSyncEvent(DdotSyncEvent.APPLY_EDITS);
			sync.assetTy = "LINK";
			sync.assetPK = "ID";
			sync.assetID = "";
			sync.serviceURL = agsManager.getURL("edits");
			sync.editsJson = JSON.stringify(editsArr, function (k,v):* { 
				if(this[k] is Date)
					return Date.parse(this[k]); 
				else
					return this[k];
			});
			
			
			//FlexGlobals.topLevelApplication.incrementEventStack();
			dispatcher.dispatchEvent(sync);
		}
		
		private function syncTimeRestriction():void
		{
			timeRestrictions = dbManager.exportDdotRecords("TIMERESTRICTIONS");
			if (!timeRestrictions || timeRestrictions.length <= 0)
				return;
			var tbdLinkIDs:Array = new Array();
			for each (var timeRestriction:Object in timeRestrictions)
			{
				var linkIDArray:Array = String(timeRestriction['LINKID']).split('_');
				for (var i:int = 0; i < linkIDArray.length; i++)
				{
					var linkID:Number = parseInt(linkIDArray[i]);
					if (linkID < 0)
						linkIDArray[i] = (recordManager.maxSignIDOnServer - linkID).toString();
				}
				timeRestriction['LINKID'] = linkIDArray.join('_');
				tbdLinkIDs.push(timeRestriction['LINKID']);
			}
			
			// Get the object ids of the link id records to be deleted
			var getTRObjectIDsEvent:DdotSyncEvent = new DdotSyncEvent(DdotSyncEvent.TR_OBJECTID_REQUEST);
			var whereClause:String = StringUtil.substitute("LINKID in ({0})", "'" + tbdLinkIDs.join("','") + "'");
			getTRObjectIDsEvent.serviceURL = agsManager.getCustomEventUrl(recordManager.trEventLayerID, whereClause);
			dispatcher.dispatchEvent(getTRObjectIDsEvent);
		}
		
		public function onTRObjectIDsResult(obj:Object, evt:DdotSyncEvent):void
		{
			if (obj != null && obj.features && obj.features.length > 0)
			{
				var objectIDs:Array = new Array();
				
				for each (var feature:Object in obj.features)
				{
					objectIDs.push(feature.attributes['OBJECTID']);
				}
				
				uploadTRs(objectIDs);
			} 
			else
			{
				uploadTRs();
			}
		}
		
		private function uploadTRs(deleteOIDs:Array=null):void
		{
			var editsArr:Array = new Array(); 
			
			var applyEditsObj:Object = new Object();
			applyEditsObj.id= recordManager.trEventLayerID;
			if (deleteOIDs != null)
				applyEditsObj.deletes = deleteOIDs;
			applyEditsObj.adds = new Array();
			
			for(var j:int =0;j< timeRestrictions.length;j++)
			{
				var attrObj:Object = new Object();
				var asset:Object  = timeRestrictions[j];
				attrObj.attributes = asset;
				applyEditsObj.adds.push(attrObj);
			}
			editsArr.push(applyEditsObj);
			
			var sync:DdotSyncEvent = new DdotSyncEvent(DdotSyncEvent.APPLY_EDITS);
			sync.assetTy = "TIMERESTRICTION";
			sync.assetPK = "ID";
			sync.assetID = "";
			sync.serviceURL = agsManager.getURL("edits");
			sync.editsJson = JSON.stringify(editsArr, function (k,v):* { 
				if(this[k] is Date)
					return Date.parse(this[k]); 
				else
					return this[k];
			});
			//FlexGlobals.topLevelApplication.incrementEventStack();
			dispatcher.dispatchEvent(sync);
		}
		
		private function applyEdits(assetTypeObj:Object):void
		{
			try
			{
			var applyEditsObj:Object = new Object();
			applyEditsObj.id= assetTypeObj.eventLayerID;
			
			for(var j:int =0;j< assetTypeObj.data.length;j++)
			{
				var editsArr:Array = new Array(); 
				var attrObj:Object = new Object();
				var asset:Object  = assetTypeObj.data[j];
				var geometry:Object = new Object();
				
				
				applyEditsObj.adds = new Array();
				applyEditsObj.updates = new Array();
				applyEditsObj.deletes = new Array();
				
				if(asset.LATITUDE && asset.LONGITUDE && asset.STATUS == 'NEW')
				{
					geometry.x = Number(asset.LONGITUDE);
					geometry.y =  Number(asset.LATITUDE);
					geometry.z =  0;
					geometry.spatialReference = {"wkid" : 4326}; //GPS lat longs are in 4326
					attrObj.geometry = geometry;
				}
				
				attrObj.attributes = asset;
				
				
				var sync:DdotSyncEvent = new DdotSyncEvent(DdotSyncEvent.APPLY_EDITS);
				sync.assetTy = assetTypeObj.assetTy;
				sync.assetID = asset[assetTypeObj.primaryKey];
				sync.assetPK = assetTypeObj.primaryKey;
				sync.serviceURL = agsManager.getURL("edits");
				
				// add support ID and signID
				sync.supportID = asset.hasOwnProperty('SUPPORTID') && asset['SUPPORTID'] != null? asset['SUPPORTID'] : -9999;
				sync.signID = asset.hasOwnProperty('SIGNID') && asset['SIGNID'] != null? asset['SIGNID'] : -9999;
				
				if(asset.STATUS == 'NEW')
					applyEditsObj.adds.push(attrObj);
				else
					applyEditsObj.updates.push(attrObj);
				
				editsArr.push(applyEditsObj);
				sync.editsJson = JSON.stringify(editsArr, function (k,v):* { 
					if(this[k] is Date)
						return Date.parse(this[k]); 
					else
						return this[k];
				});
				//FlexGlobals.topLevelApplication.incrementEventStack();
				dispatcher.dispatchEvent(sync);
			}
			}catch(e:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert('Error in Syncing');
			}
		}
		
		public function clearLocalData(syncResult:Object, event:DdotSyncEvent):void
		{
			
		//	FlexGlobals.topLevelApplication.decrementEventStack();
			event.stopPropagation();
			FlexGlobals.topLevelApplication.syncAssetsCount--;
			try
			{
			var assetDesc:String;
			if (event.assetTy == "1")
				assetDesc = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetDefs[event.assetTy].DESCRIPTION;
			else
				assetDesc = event.assetTy;
			
			if(syncResult && syncResult.error)
				onSyncError(layerID,null, event.assetTy,assetDesc, event.assetID, event.assetPK, {error:{description:"Error occured during sync process."}});
				
			else if(syncResult)
			{
				var result:Array = syncResult as Array;
				var layerID:String = String(result[0].id);
				
				if(result[0].updateResults && result[0].updateResults.length>0 && result[0].updateResults[0].success ==true)
					onSyncSuccess(layerID,String(result[0].updateResults[0].objectId), event.assetTy,assetDesc, event.assetID, event.assetPK, event.supportID, event.signID);
				else if(result[0].addResults && result[0].addResults.length>0 && result[0].addResults[0].success ==true)
					onSyncSuccess(layerID,String(result[0].addResults[0].objectId), event.assetTy,assetDesc, event.assetID, event.assetPK, event.supportID, event.signID);
				else if(result[0].addResults && result[0].addResults.length>0 && result[0].addResults[0].success ==false)
					onSyncError(layerID,String(result[0].addResults[0].objectId), event.assetTy,assetDesc, event.assetID, event.assetPK, result[0].addResults[0].error);
				else if(result[0].addResults && result[0].updateResults.length>0 && result[0].updateResults[0].success ==false)
					onSyncError(layerID,String(result[0].updateResults[0].objectId), event.assetTy,assetDesc, event.assetID, event.assetPK, result[0].updateResults[0].error);
				else
					onSyncError(layerID,String(result[0].addResults[0].objectId), event.assetTy,assetDesc, event.assetID, event.assetPK, {error:{description:"Error occured during sync process."}});
			}
			
		}catch(e:Error)
		{
			FlexGlobals.topLevelApplication.TSSAlert('Error in reading sync response');
		}
			
		}
		
		
		private function onSyncSuccess(layer:String,objID:String, assetTy:String, assetDesc:String, assetID:String, assetPK:String, supportID:Number, signID:Number):void
		{
			
			supportID = supportID > recordManager.maxSupportIDOnServer ? recordManager.maxSupportIDOnServer - supportID -1: supportID;
			signID = signID > recordManager.maxSignIDOnServer ? recordManager.maxSignIDOnServer - signID: signID;
			// Get the local id
			var localAssetID:Number = Number(assetID);
			if (assetTy == "1")
			{
				localAssetID = supportID;
				supportGtArray=dbManager.getDdotLocalGeoTags(supportID, signID, false, "SUPPORT");
				uploadAttachments(supportGtArray, layer, objID);
			}
			else if (assetTy == "SIGN")
			{
				localAssetID = signID;
				signGtArray=dbManager.getDdotLocalGeoTags(supportID, signID, false, "SIGN");
				uploadAttachments(signGtArray, layer, objID);
			}
			else if (assetTy == "INSPECTION")
			{
				localAssetID = localAssetID > recordManager.maxInspectionIDOnServer ? recordManager.maxInspectionIDOnServer - localAssetID: localAssetID;
				inspectionGtArray=dbManager.getDdotLocalGeoTags(supportID, signID, false, "INSPECTION");
				uploadAttachments(inspectionGtArray, layer, objID);
			}
			else if (assetTy == "LINK")
			{
				dbManager.clearLinks();
				displaySyncResult();
				return;
			}
			else if (assetTy == "TIMERESTRICTION")
			{
				dbManager.clearTimeRestrictions();
				displaySyncResult();
				return;
			}
			
			dbManager.deleteDdotLocalRecord(assetDesc, localAssetID.toString(), assetPK);
		}
		
		private function onSyncError(layerID:String,objID:String, assetTy:String,assetDesc:String,  assetID:String, assetPK:String, error:Object):void
		{
			
			//FlexGlobals.topLevelApplication.decrementEventStack();
			FlexGlobals.topLevelApplication.failedSyncDetails += " \ntype: "+assetDesc + ", id: "+ assetID;
			displaySyncResult();
		}
		
		private function displaySyncResult():void
		{
			//if(FlexGlobals.topLevelApplication.runningEvents<1 && FlexGlobals.topLevelApplication.failedSyncDetails=="")
			
			if(FlexGlobals.topLevelApplication.syncAssetsCount==0)
				//.topLevelApplication.setBusyStatus(false);
			{
				FlexGlobals.topLevelApplication.setBusyStatus(false);
				FlexGlobals.topLevelApplication.TSSAlert("Assets Synced Successfully.");
				recordManager.updateSupportIDs(recordManager.maxSupportIDOnServer);
				recordManager.resetNewSignInspectionID();
			}
			else if(FlexGlobals.topLevelApplication.syncAssetsCount==0 &&  FlexGlobals.topLevelApplication.failedSyncDetails!="")
			{
				FlexGlobals.topLevelApplication.setBusyStatus(false);
				FlexGlobals.topLevelApplication.TSSAlert("Error occured when syncing asset: " + FlexGlobals.topLevelApplication.failedSyncDetails);
			}
		}
		
		private function uploadAttachments(gtArray:Array, layerID:String, objectID:String):void
		{
			if(gtArray.length<1)
			{
				displaySyncResult();
				return;
			}
			//FlexGlobals.topLevelApplication.incrementEventStack();
			var filename :String = gtArray[0].image_file_name||gtArray[0].video_file_name||gtArray[0].voice_file_name;
			var byteArr:ByteArray = fileUtil.readFile(filename);
			var urlRequest:URLRequest = new URLRequest();
			var urlLoader:URLLoader = new URLLoader();
			
			urlRequest.url = agsManager.getAddAttachmentUrl(layerID,objectID);
			urlRequest.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
			urlRequest.method = URLRequestMethod.POST;
			
			urlRequest.data = UploadPostHelper.getPostData(filename,
				byteArr, mimeTyMap.getMimeType(fileUtil.getFileExtenstion(filename)),
				{gdbVersion:ConfigUtility.get("gdb_version"),f:"pjson"});
			urlRequest.requestHeaders.push( new URLRequestHeader( 'Cache-Control', 'no-cache' ) );
			urlLoader.dataFormat =  URLLoaderDataFormat.BINARY;
			
			
			urlLoader.addEventListener(Event.COMPLETE,function(event:Event):void{urlLoaderEventHandler(event,filename, gtArray, layerID, objectID);});
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{ioErrorCallback(event, gtArray, layerID, objectID);});
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void{secErrorCallback(event, gtArray, layerID, objectID);});
			urlLoader.load(urlRequest);
		}
		
		private function  urlLoaderEventHandler(event:Event,filename:String, gtArray:Array, layerID:String, ObjectID:String):void {
			//FlexGlobals.topLevelApplication.decrementEventStack();
			FlexGlobals.topLevelApplication.syncAssetsCount--;
			var response:Object = JSON.parse(String(event.target.data));
			if(response.error)
				FlexGlobals.topLevelApplication.failedSyncDetails += " \n"+response.error.message;
			else
			{
				dbManager.deleteGeoTag(gtArray[0].id);
				fileUtil.deleteFiles(filename);
			}
			gtArray.shift();
			uploadAttachments(gtArray, layerID, ObjectID);
		}
		
		// Called on upload io error
		private function ioErrorCallback(event:IOErrorEvent, gtArray:Array, layerID:String, ObjectID:String):void {
//			FlexGlobals.topLevelApplication.decrementEventStack();
			FlexGlobals.topLevelApplication.syncAssetsCount--;
			FlexGlobals.topLevelApplication.failedSyncDetails += " \nIO Error when uploading attachment";
			gtArray.shift();
			uploadAttachments(gtArray, layerID, ObjectID);
		}
		
		// Called on upload security error
		private function secErrorCallback(event:SecurityErrorEvent, gtArray:Array, layerID:String, ObjectID:String):void {
//			FlexGlobals.topLevelApplication.decrementEventStack();
			FlexGlobals.topLevelApplication.syncAssetsCount--;
			FlexGlobals.topLevelApplication.failedSyncDetails += " \nSecurity Error when uploading attachment";
			gtArray.shift();
			uploadAttachments(gtArray, layerID, ObjectID);
		}
		
		private function extractMaxIDFromServiceResult(obj:Object, idField:String):Number
		{
			var maxId:Number = -9999;
			var rawData:String = String(obj);
			var arr:Array = (JSON.parse(rawData).features) as Array;
			if (arr == null)
				return maxId;
			if (arr != null && arr.length > 0)
				maxId = arr[0].attributes[idField]; 
			else 
				maxId = 0;
			
			return maxId;
		}
	}
}