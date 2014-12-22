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
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	
	import spark.formatters.DateTimeFormatter;
	
	public class DdotRandHSyncManager
	{
		public var dispatcher:GlobalDispatcher = new GlobalDispatcher();
		private var dbManager:MAVRICDBManager = MAVRICDBManager.newInstance();
		
		[Bindable]
		private var useAgsService:Boolean = FlexGlobals.topLevelApplication.useAgsService;
		private var dtFormatter:DateTimeFormatter = new DateTimeFormatter();
		private var mimeTyMap:MimeTypeMap = new MimeTypeMap();
		private var fileUtil:FileUtility = new FileUtility();
		private var agsManager:ArcGISServiceManager = new ArcGISServiceManager();
		private var gtArray:Array = new Array();
		private var layerID:String ="";
		private var objectID:String="";
		
		private var _supportEventLayerID:Number = 10;
		private var _signEventLayerID:Number = 18;
		private var _inspectionEventLayerID:Number = 14;
		private var _linkEventLayerID:Number = 15;
		private var _trEventLayerID:Number = 17;
		
		private var maxSupportIDOnServer:Number;
		private var maxSignIDOnServer:Number;
		private var maxInspectionIDOnServer:Number;
		
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
		
		private function getLocalRecords(assetType:String):Object
		{
			var dataArr:Array;
			var gtArr:Array;
			var assetData:Object = new Object();
			if (assetType == "1" || assetType == "SUPPORT")
			{
				dataArr= dbManager.exportAssets("SUPPORT");
				gtArr = dbManager.exportGeotagData("1");
				assetData = {eventLayerID:_supportEventLayerID,assetTy:"1", assetDesc:"SUPPORT", data: dataArr, geotags:gtArr, primaryKey:"POLEID"};
			}
			else if (assetType == "SIGN")
			{
				dataArr = dbManager.exportDdotRecords("SIGNS");
				gtArr = dbManager.exportGeotagData("SIGN");
				assetData = {eventLayerID:_signEventLayerID,assetTy:"SIGN", assetDesc:"SIGN", data: dataArr, geotags:gtArr, primaryKey:"SIGNID"};
			}
			else if (assetType == "INSPECTION")
			{
				dataArr = dbManager.exportDdotRecords("INSPECTIONS");
				gtArr = dbManager.exportGeotagData("INSPECTION");
				assetData = {eventLayerID:_inspectionEventLayerID,assetTy:"INSPECTION", assetDesc:"INSPECTION", data: dataArr, geotags:gtArr, primaryKey:"INSPECTIONID"};
			}
			
			return assetData;
		}
		
		public function syncChanges():void
		{
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
			
			// temporary codes
			dbManager.getDdotLocalGeoTags(-2, -999, false, "SUPPORT");
			return;
			
			// Fire off find max support id event
			fireMaxIDRequest("POLEID", this._supportEventLayerID);
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
			
			if (evt.eventLayerID == this._supportEventLayerID)
			{
				maxSupportIDOnServer = maxId;
				syncSupport();
				// fire off events to find the max sign id
				fireMaxIDRequest("SIGNID", this._signEventLayerID)
				
			}
			else if (evt.eventLayerID == this._signEventLayerID)
			{
				maxSignIDOnServer = maxId;
				syncSign();
				// fire off events to find the max inspection id
				fireMaxIDRequest("INSPECTIONID", this._inspectionEventLayerID);
			}
			else if (evt.eventLayerID == this._inspectionEventLayerID)
			{
				maxInspectionIDOnServer = maxId;
				syncInspection();
			}
		}
		
		private function syncSupport():void
		{	
			var supportAssetData:Object = getLocalRecords("SUPPORT");
			if (supportAssetData.data ==null)
				return;
			for each(var supportAsset:Object in supportAssetData.data)
			{
				if (supportAsset['POLEID'] < 0)
					// Based on the current code, the support starts from -2. So do an extra -1
					supportAsset['POLEID'] = maxSupportIDOnServer - supportAsset['POLEID'] - 1; 
			}
			applyEdits(supportAssetData);	
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
					if (signAsset['POLEID'] < 0)
						signAsset['POLEID'] = maxSupportIDOnServer - signAsset['POLEID'] - 1; 
					if (signAsset['SIGNID'] < 0)
					{
						signAsset['SIGNID'] = maxSignIDOnServer - signAsset['SIGNID'];
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
					if (inspection['POLEID'] < 0)
						inspection['POLEID'] = maxSupportIDOnServer - inspection['POLEID'] - 1; 
					if (inspection['SIGNID'] != null && inspection['SIGNID'] < 0)
						inspection['SIGNID'] = maxSignIDOnServer - inspection['SIGNID'];
					if (inspection['INSPECTIONID'] < 0)
					{
						inspection['INSPECTIONID'] = maxInspectionIDOnServer - inspection['INSPECTIONID'];	
						inspection['STATUS'] = "NEW";
					}
				}
				applyEdits(inspectionData);
			}	
		}
		
		private function applyEdits(assetTypeObj:Object):void
		{
			var applyEditsObj:Object = new Object();
			applyEditsObj.id= assetTypeObj.eventLayerID;
			
			for(var j:int =0;j< assetTypeObj.data.length;j++)
			{
				var editsArr:Array = new Array(); 
				var attrObj:Object = new Object();
				var asset:Object  = assetTypeObj.data[j];
				
				applyEditsObj.adds = new Array();
				applyEditsObj.updates = new Array();
				applyEditsObj.deletes = new Array();
				
				attrObj.attributes = asset;
				var sync:DdotSyncEvent = new DdotSyncEvent(DdotSyncEvent.APPLY_EDITS);
				sync.assetTy = assetTypeObj.assetTy;
				sync.assetID = asset[assetTypeObj.primaryKey];
				sync.assetPK = assetTypeObj.primaryKey;
				sync.serviceURL = agsManager.getURL("edits");
				
				// add support ID and signID
				try 
				{
					sync.supportID = asset['POLEID'];
					sync.signID = asset['SIGNID'];
				}
				catch(er:Error)
				{
					sync.supportID = -9999;
					sync.signID = -9999;
				}
				
				
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
				FlexGlobals.topLevelApplication.incrementEventStack();
				dispatcher.dispatchEvent(sync);
			}
		}
		
		public function clearLocalData(syncResult:Object, event:DdotSyncEvent):void
		{
			FlexGlobals.topLevelApplication.decrementEventStack();
			event.stopPropagation();
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
		}
		
		
		private function onSyncSuccess(layer:String,objID:String, assetTy:String, assetDesc:String, assetID:String, assetPK:String, supportID:Number, signID:Number):void
		{
			supportID = supportID > maxSupportIDOnServer ? maxSupportIDOnServer - supportID -1: supportID;
			signID = signID > maxSignIDOnServer ? maxSignIDOnServer - signID: signID;
			// Get the local id
			var localAssetID:Number = Number(assetID);
			if (assetTy == "1")
			{
				localAssetID = supportID;
				gtArray=dbManager.getDdotLocalGeoTags(supportID, signID, false, "SUPPORT");
			}
			else if (assetTy == "SIGN")
			{
				localAssetID = signID;
				gtArray=dbManager.getDdotLocalGeoTags(supportID, signID, false, "SIGN");
			}
			else if (assetTy == "INSPECTION")
			{
				localAssetID = localAssetID > maxInspectionIDOnServer ? maxInspectionIDOnServer - localAssetID: localAssetID;
				gtArray=dbManager.getDdotLocalGeoTags(supportID, signID, false, "INSPECTION");
			}
			
			layerID = layer;
			objectID = objID;
			
//			gtArray = dbManager.getLocalGeoTags(new Number(assetID),assetTy);
//			uploadAttachments();
			dbManager.deleteDdotLocalRecord(assetDesc, localAssetID.toString(), assetPK);
		}
		
		private function onSyncError(layerID:String,objID:String, assetTy:String,assetDesc:String,  assetID:String, assetPK:String, error:Object):void
		{
			FlexGlobals.topLevelApplication.failedSyncDetails += " \ntype: "+assetDesc + ", id: "+ assetID;
			displaySyncResult();
		}
		
		private function displaySyncResult():void
		{
			
			if(FlexGlobals.topLevelApplication.runningEvents==0 && FlexGlobals.topLevelApplication.failedSyncDetails=="")
				FlexGlobals.topLevelApplication.TSSAlert("Assets Synced Successfully.");
			else if(FlexGlobals.topLevelApplication.runningEvents==0 &&  FlexGlobals.topLevelApplication.failedSyncDetails!="")
				FlexGlobals.topLevelApplication.TSSAlert("Error occured when syncing asset: " + FlexGlobals.topLevelApplication.failedSyncDetails);
		}
		
		private function uploadAttachments():void
		{
			if(gtArray.length<1)
			{
				displaySyncResult();
				return;
			}
			FlexGlobals.topLevelApplication.incrementEventStack();
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
			
			
			urlLoader.addEventListener( Event.COMPLETE,function(event:Event):void{urlLoaderEventHandler(event,filename);} );
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorCallback);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, secErrorCallback);
			urlLoader.load(urlRequest);
		}
		
		private function  urlLoaderEventHandler(event:Event,filename:String):void {
			FlexGlobals.topLevelApplication.decrementEventStack();
			var response:Object = JSON.parse(String(event.target.data));
			if(response.error)
				FlexGlobals.topLevelApplication.failedSyncDetails += " \n"+response.error.message;
			else
			{
				dbManager.deleteGeoTag(gtArray[0].id);
				fileUtil.deleteFiles(filename);
			}
			gtArray.shift();
			uploadAttachments();
			
		}
		
		// Called on upload io error
		private function ioErrorCallback(event:IOErrorEvent):void {
			FlexGlobals.topLevelApplication.decrementEventStack();
			FlexGlobals.topLevelApplication.failedSyncDetails += " \nIO Error when uploading attachment";
			gtArray.shift();
			uploadAttachments();
		}
		
		// Called on upload security error
		private function secErrorCallback(event:SecurityErrorEvent):void {
			FlexGlobals.topLevelApplication.decrementEventStack();
			FlexGlobals.topLevelApplication.failedSyncDetails += " \nSecurity Error when uploading attachment";
			gtArray.shift();
			uploadAttachments();
			
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