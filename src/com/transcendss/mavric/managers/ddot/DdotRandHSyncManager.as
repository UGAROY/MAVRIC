package com.transcendss.mavric.managers.ddot
{
	import com.adobe.net.MimeTypeMap;
	import com.asfusion.mate.core.GlobalDispatcher;
	import com.transcendss.mavric.db.MAVRICDBManager;
	import com.transcendss.mavric.events.SyncEvent;
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
		
		public function DdotRandHSyncManager()
		{
			mimeTyMap.addMimeType("video/3gpp", ["3gp","3gpp"]);
			dtFormatter.dateTimePattern = "MM/dd/yyyy HH:mm:ss";
			dtFormatter.useUTC=false;
			dtFormatter.errorText="";
		}
		
		private function getLocalData():ArrayCollection
		{
			var assetDef:Object = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetDefs;
			var assetsForSync:Array = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetsForSync;
			
			var assetData:ArrayCollection = new ArrayCollection();
			for each (var def:Object in assetDef) 
			{
				if(assetsForSync.indexOf(def.DESCRIPTION !=-1))//if asset sync is true
				{
					var dataArr:Array = dbManager.exportAssets(def.DESCRIPTION);
					var gtArr:Array = dbManager.exportGeotagData(def.ASSET_TYPE);
					assetData.addItem({eventLayerID:def.EVENT_LAYER_ID,assetTy:def.ASSET_TYPE, assetDesc:def.DESCRIPTION, data: dataArr, geotags:gtArr, primaryKey:def.ASSET_DATA_TEMPLATE.PRIMARY_KEY});
				}
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
			
			
		}
		
		public function applyEdits():void
		{
			var assetData:ArrayCollection = getLocalData();
			
			for (var i:int =0;i< assetData.length;i++)
			{
				var assetTypeObj:Object = assetData[i];
				if(assetTypeObj.data ==null)
				{
					continue;
				}
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
					var sync:SyncEvent = new SyncEvent(SyncEvent.APPLY_EDITS);
					sync.assetTy = assetTypeObj.assetTy;
					sync.assetID = asset[assetTypeObj.primaryKey];
					sync.assetPK = assetTypeObj.primaryKey;
					sync.serviceURL = agsManager.getURL("edits");
					
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
		}
		
		public function clearLocalData(syncResult:Object, event:SyncEvent):void
		{
			FlexGlobals.topLevelApplication.decrementEventStack();
			event.stopPropagation();
			var assetDesc:String = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetDefs[event.assetTy].DESCRIPTION;
			
			if(syncResult && syncResult.error)
				onSyncError(layerID,null, event.assetTy,assetDesc, event.assetID, event.assetPK, {error:{description:"Error occured during sync process."}});
				
			else if(syncResult)
			{
				var result:Array = syncResult as Array;
				var layerID:String = String(result[0].id);
				
				if(result[0].updateResults && result[0].updateResults.length>0 && result[0].updateResults[0].success ==true)
					onSyncSuccess(layerID,String(result[0].updateResults[0].objectId), event.assetTy,assetDesc, event.assetID, event.assetPK);
				else if(result[0].addResults && result[0].addResults.length>0 && result[0].addResults[0].success ==true)
					onSyncSuccess(layerID,String(result[0].addResults[0].objectId), event.assetTy,assetDesc, event.assetID, event.assetPK);
				else if(result[0].addResults && result[0].addResults.length>0 && result[0].addResults[0].success ==false)
					onSyncError(layerID,String(result[0].addResults[0].objectId), event.assetTy,assetDesc, event.assetID, event.assetPK, result[0].addResults[0].error);
				else if(result[0].addResults && result[0].updateResults.length>0 && result[0].updateResults[0].success ==false)
					onSyncError(layerID,String(result[0].updateResults[0].objectId), event.assetTy,assetDesc, event.assetID, event.assetPK, result[0].updateResults[0].error);
				else
					onSyncError(layerID,String(result[0].addResults[0].objectId), event.assetTy,assetDesc, event.assetID, event.assetPK, {error:{description:"Error occured during sync process."}});
			}
			
		}
		
		
		private function onSyncSuccess(layer:String,objID:String, assetTy:String, assetDesc:String, assetID:String, assetPK:String):void
		{
			gtArray = dbManager.getLocalGeoTags(new Number(assetID),assetTy);
			layerID = layer;
			objectID = objID;
			uploadAttachments();
			dbManager.deleteLocalAsset(assetDesc,assetID,assetPK);
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
		
	}
}