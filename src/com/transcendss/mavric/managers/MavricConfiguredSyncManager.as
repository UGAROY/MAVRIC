package com.transcendss.mavric.managers
{
	import com.adobe.utils.StringUtil;
	import com.asfusion.mate.core.GlobalDispatcher;
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.mavric.db.MAVRICDBManager;
	import com.transcendss.mavric.events.SyncEvent;
	import com.transcendss.mavric.util.FileUtility;
	
	import flash.errors.IOError;
	import flash.events.DataEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import mx.core.*;
	
	import spark.formatters.DateTimeFormatter;
	
	public class MavricConfiguredSyncManager
	{
		private var _refUploadFile:FileReference = new FileReference();
		public var dispatcher:GlobalDispatcher = new GlobalDispatcher();
		private var fileArray:Array = new Array();
		private var dbManager:MAVRICDBManager = MAVRICDBManager.newInstance();
		private var fileUtil:FileUtility = new FileUtility();
		private var assetFileIndex:Number = 0;
		private var tempMessage:String;
		
		private static var attemptingCulvertUpload:Boolean = true;
		
		private var dtFormatter:DateTimeFormatter = new DateTimeFormatter();
		private var shrtDtFormatter:DateTimeFormatter = new DateTimeFormatter();
		
	
		
		public function MavricConfiguredSyncManager()
		{
			dtFormatter.dateTimePattern = "MM/dd/yyyy HH:mm:ss";
			//dtFormatter.dateTimePattern = "MM/dd/yyyy";
			dtFormatter.useUTC=false;
			dtFormatter.errorText="";
			
			shrtDtFormatter.dateTimePattern = "MM/dd/yyyy";
			//dtFormatter.dateTimePattern = "MM/dd/yyyy";
			shrtDtFormatter.useUTC=false;
			shrtDtFormatter.errorText="";
		}
		
		public function syncInitiate():void
		{
			
			if(FlexGlobals.topLevelApplication.menuBar.getCurrentUser()!="" && FlexGlobals.topLevelApplication.menuBar.getCurrentUser()!=null)
			{
				var sync:SyncEvent = new SyncEvent(SyncEvent.SYNC_INITIATE);
				sync.serviceURL = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL+"InitiateSync";
				FlexGlobals.topLevelApplication.setBusyStatus(true);
				dispatcher.dispatchEvent(sync);
			}
			else
				FlexGlobals.topLevelApplication.TSSAlert('Current User not specified. User name required for syncing');
		}
		
		public function setLogIDAndContinueSync(obj:Object,event:SyncEvent):void{
			
			var rawData:String = String(obj);
			if (rawData.length >0)
			{
				try{
					var configObj:Object = JSON.parse(rawData) as Object;
					if(configObj.error)
					{
						
						throw new IOError(configObj.error);
					}
					else if(configObj.logid)
					{
						assetFileIndex = 0;
						FlexGlobals.topLevelApplication.SyncLogID = String(configObj.logid);
						
						syncAssets(FlexGlobals.topLevelApplication.GlobalComponents.stkDiagram.route.routeName);
					}
						
				}
				catch(e:Error)
				{
					if(e.message != "Assets are currently syncing for another process. Please wait for approximately 1 minute and try again.")
						showSyncError('Error initiating sync process');
					else
					{
						FlexGlobals.topLevelApplication.setBusyStatus(false);
						FlexGlobals.topLevelApplication.TSSAlert(e.message );
					}
				}
			}
		}
		
		
		public function showSyncError(errText:String):void
		{
			setProcessStatusinDBonError(errText);
			FlexGlobals.topLevelApplication.TSSAlert(errText+". Updating process status...");
		}
		
		public function syncAssets(route_name:String):void
		{
			var assetsForSync:Array = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetsForSync;
			if(assetFileIndex<assetsForSync.length)
			{
				var currentAssetType:String = assetsForSync[assetFileIndex].DESCRIPTION;
				
				try
				{
					
					var data:Array  = dbManager.exportAssets(currentAssetType); 
					
					var _strUploadUrl:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL+"FileUpload/Mavric"+currentAssetType+".txt";
					
					fileUpload(_strUploadUrl,
						writeAssetFile(FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getAssetSyncHeaders(currentAssetType),data,currentAssetType),
						checkFileUploadResponse,
						onUploadIoError,
						onUploadSecurityError);
					
				}
				catch(e:Error)
				{
					showSyncError("Error uploading "+currentAssetType+" text file");
				}
				
				
				
			}
			else
				syncGeotagData(route_name);
		}
		
		private function writeAssetFile(header:String,data:Array,assetType:String):File{
			
			var file:File = File.createTempFile();
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(header);
			
			stream.writeUTFBytes("\r\n");
			if(data)
			{
				
			for each (var obj:Object in data)
			{
				var cmdString:String = "";
				
				var arr:Array = header.split("|");
				
				
				for each (var item:String in arr)
				{
						
					if(obj[item] || obj[item]==0)
						if(Date.parse(obj[item]))
						{
							if(FlexGlobals.topLevelApplication.GlobalComponents.assetManager.isShortDate(assetType, item))
								cmdString += this.shrtDtFormatter.format(obj[item]) + "|";
							else
								cmdString += dtFormatter.format(obj[item]) + "|";
						}
						else if(String(obj[item]).indexOf("\r")!=-1 || String(obj[item]).indexOf("\n")!=-1)
							cmdString += String(obj[item]).replace(new RegExp("\r", "g"), "<br/>").replace(new RegExp("\n", "g"), "<br/>") + "|";
						else
							cmdString += obj[item] + "|";
					else
						cmdString +=   "|";
				}
				cmdString = cmdString.substr(0, cmdString.length - 1).replace(new RegExp("null", "g"), "").replace(new RegExp("undefined", "g"), "");
				
				stream.writeUTFBytes(cmdString);
				stream.writeUTFBytes("\r\n");
			}
			}
			
			stream.close();
			return file;
		}
		
		private function fileUpload(uploadUrl:String,fl:File, callbackUploadComplete:Function, ioErrorCallback:Function,secErrorCallback:Function):void
		{
			var request:URLRequest = new URLRequest();
			request.url = uploadUrl;
			request.method = URLRequestMethod.POST;
			_refUploadFile = fl;
			_refUploadFile.addEventListener(flash.events.DataEvent.UPLOAD_COMPLETE_DATA, callbackUploadComplete);
			_refUploadFile.addEventListener(IOErrorEvent.IO_ERROR, ioErrorCallback);
			_refUploadFile.addEventListener(SecurityErrorEvent.SECURITY_ERROR, secErrorCallback);
			
			_refUploadFile.upload(request, "file", false);
		}
		
		public function syncGeotagData(route_name:String):void
		{
			trace("Syncing Geotags ");
			var data:Array = new Array();
			try
			{
				FlexGlobals.topLevelApplication.setBusyStatus(true);
				data= dbManager.exportGeotagData();
				
				var _strUploadUrl:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL+"FileUpload/MavricGeoTags.txt";
				
				fileUpload(_strUploadUrl,
					writeGeotagDataFile("asset_type|cached_route_id|asset_base_id|local_asset_id|is_insp_tag|begin_mile|end_mile|image_filename|video_filename|voice_filename|text_memo\r\n",data)
					,checkGTFileUploadResponse
					,onUploadIoError
					,onUploadSecurityError);
				
			}
			catch(e:Error)
			{
				showSyncError("Error uploading geotag data file");
			}
		}
		
		private function uploadGeotags():void{
			trace("Checking upload GT files response");
			
			
			if (fileArray.length>0 )
			{
				try
				{
					FlexGlobals.topLevelApplication.setBusyStatus(true);
					var tmpFl:File = fileArray[0] as File;
					var _strUploadUrl:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL+"FileUpload/" +FlexGlobals.topLevelApplication.SyncLogID+"_"+ tmpFl.name;
					fileUpload(_strUploadUrl,fileArray[0], checkMultiFileUploadResponse,onUploadMultiIoError,onUploadMultiSecurityError);
				}catch(e:Error)
				{
					showSyncError("Error uploading image/video files");
				}
			}
			else
			{
				clearUpload(checkMultiFileUploadResponse,onUploadMultiIoError,onUploadMultiSecurityError);
				try
				{
					FlexGlobals.topLevelApplication.setBusyStatus(true);
					
					var sync:SyncEvent = new SyncEvent(SyncEvent.SYNC_REQUESTED);
					sync.serviceURL = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL+"SyncDB/" + FlexGlobals.topLevelApplication.menuBar.getCurrentUser() + "/" + FlexGlobals.topLevelApplication.SyncLogID;
					//sync.fileUploads = mainFileUploads;
					dispatcher.dispatchEvent(sync);
				}
				catch(e:Error)
				{
					showSyncError("Error calling sync after the file uploads");
				}
				
			}
			
			
		}
		
		
		public function clearLocalTables(obj:Object,event:SyncEvent):void{
			trace("Clearing data if success");
			var rawData:String = String(obj);
			if (rawData.length >0)
			{
				try{
					var configObj:Object = JSON.parse(rawData) as Object;
					if(configObj.error)
						throw new IOError(configObj.error);
					else if(configObj.Status)//Success response from server; Extract file info
					{
						
							FlexGlobals.topLevelApplication.TSSAlert("Data sync completed:\n"+String(configObj.Status)+"\n"+ FlexGlobals.topLevelApplication.GlobalComponents.uploadedFileList.length.toString()+ " attachment files uploaded.\n"+ String(FlexGlobals.topLevelApplication.GlobalComponents.gtFilesToUploadCount - FlexGlobals.topLevelApplication.GlobalComponents.uploadedFileList.length) + " attachment file uploads failed") ;
							var assetsForSync:Array = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetsForSync;
								
							for(var i:int =0 ; i< assetsForSync.length; i++)
								dbManager.clearAssetTable(assetsForSync[i]);
							dbManager.clearGeotagsTable();
							deleteUploadedFiles();//delete uploaded attachment files. Sicne we reached so far all the attachment files are uploaded and only the sync failed.
					}

					
				}
				catch(e:Error)
				{
					
					FlexGlobals.topLevelApplication.setBusyStatus(false);
					FlexGlobals.topLevelApplication.TSSAlert(e.message );
				}
				
			}
			
			
			FlexGlobals.topLevelApplication.setBusyStatus(false);
		}
		
		
		private function writeGeotagDataFile(header:String, data:Array):File
		{
			trace("Writing geotoag file ");
			var file:File = File.createTempFile();
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(header);
			
			var paramString:String = header.substr(0, header.length - 2);
			//paramString = paramString.replace(new RegExp("|", "g"), "|");
			var params:Array = paramString.split("|");
			
			for each (var obj:Object in data)
			{
				var cmdString:String = "";
				
				for each (var item:String in params)
				{
					if(StringUtil.trim(item).toLowerCase().lastIndexOf("_filename")!=-1 && obj[StringUtil.trim(item)] !=null && obj[StringUtil.trim(item)]!="")
						obj[StringUtil.trim(item)]=FlexGlobals.topLevelApplication.SyncLogID + "_"+obj[StringUtil.trim(item)];
					if(obj.hasOwnProperty(StringUtil.trim(item)))
						cmdString += obj[StringUtil.trim(item)] + "|";
					else
					cmdString += "|";
				}
				cmdString = cmdString.substr(0, cmdString.length - 1);
				
				
				var finalString:String = cmdString.replace(new RegExp("null|", "g"), "|");
				finalString = cmdString.replace(new RegExp("null", "g"), "");
				stream.writeUTFBytes(finalString);
				stream.writeUTFBytes("\r\n");
			}
			
			
			stream.close();
			return file;
		}
		
		//Chedck the server response to see if the status is success or error
		private function checkFileUploadResponse(event:flash.events.DataEvent):void {
			trace("Checking asset file upload response");
			event.stopPropagation();
			
			var rawData:String = String(event.data);
			if (rawData.length >0)
			{
				try{
					var configObj:Object = JSON.parse(rawData) as Object;
					//Error response from server
					if(configObj.error)
					{
						clearUpload(checkFileUploadResponse
							,onUploadIoError
							,onUploadSecurityError);
						throw new IOError(configObj.error);
					}
					else
					{
						this.assetFileIndex++;
						syncAssets(FlexGlobals.topLevelApplication.GlobalComponents.stkDiagram.route.routeName);
					}
				}
				catch(e:Error)
				{
					this.showSyncError("Error uploading text file");
				}
				
			}
		}	
		
		//Chedck the server response to see if the status is success or error
		private function checkGTFileUploadResponse(event:flash.events.DataEvent):void {
			trace("Checking GT file upload response");
			event.stopPropagation();
			var rawData:String = String(event.data);
			if (rawData.length >0)
			{
				try{
					var configObj:Object = JSON.parse(rawData) as Object;
					//Error response from server
					if(configObj.error)
					{
						clearUpload(checkGTFileUploadResponse
							,onUploadIoError
							,onUploadSecurityError);
						throw new IOError(configObj.error);
					}
					else//Success response from server; Extract file info
					{
						
						fileArray = filterCachedGeotags(fileUtil.getFiles());
						FlexGlobals.topLevelApplication.GlobalComponents.uploadedFileList = new Array();
						FlexGlobals.topLevelApplication.GlobalComponents.gtFilesToUploadCount = fileArray.length;
						uploadGeotags();
					}
					
				}
				catch(e:Error)
				{
					showSyncError("Error uploading geotag file");
				}
				
			}
		}	
		
		
		//filter the cached files out of files to be uploaded
		private function filterCachedGeotags(arr:Array):Array
		{
			var fileArrayFiltered:Array = new Array();
			
			for each (var file:File in arr)
			{
				if(dbManager.isNotCachedAndInDBGeotag(file.name))
					fileArrayFiltered.push(file);
			}
			return fileArrayFiltered;
		}
		
		//Chedck the server response to see if the status is success or error
		private function checkMultiFileUploadResponse(event:flash.events.DataEvent):void {
			trace("Checking multiple GT file response");
			event.stopPropagation();
			var rawData:String = String(event.data);
			if (rawData.length >0)
			{
				try{
					var configObj:Object = JSON.parse(rawData) as Object;
					var arrObj:Array = fileArray.splice(0,1) as Array;
					var file:File = arrObj[0] as File;
					
					//Error response from server
					if(!configObj.error)
						FlexGlobals.topLevelApplication.GlobalComponents.uploadedFileList.push(file);
					
					//continue file upload
					uploadGeotags();
				}
				catch(e:Error)
				{
					showSyncError("Error uploading image/video files");
				}
				
			}
		}	
		
		private function deleteUploadedFiles():void
		{
			trace("deleting uploaded GT files");
			var uploadedFiles:Array = FlexGlobals.topLevelApplication.GlobalComponents.uploadedFileList;
			for each (var fl:File in uploadedFiles)
			{
				fileUtil.deleteFiles(fl.name);
			}
		}
			
		// Called on upload io error
		private function onUploadIoError(event:IOErrorEvent):void {
			clearUpload(checkGTFileUploadResponse
				,onUploadIoError
				,onUploadSecurityError);
			clearUpload(checkFileUploadResponse
				,onUploadIoError
				,onUploadSecurityError);
			showSyncError("IO Error uploading file");
		}
		
		// Called on upload security error
		private function onUploadSecurityError(event:SecurityErrorEvent):void {
			clearUpload(checkGTFileUploadResponse
				,onUploadIoError
				,onUploadSecurityError);
			clearUpload(checkFileUploadResponse
				,onUploadIoError
				,onUploadSecurityError);
			showSyncError("Security Error uploading file");
			
		}
		
		// Called on upload io error
		private function onUploadMultiIoError(event:IOErrorEvent):void {
			fileArray.splice(0,1);
			uploadGeotags();
		}
		
		// Called on upload security error
		private function onUploadMultiSecurityError(event:SecurityErrorEvent):void {
			fileArray.splice(0,1);
			uploadGeotags();
		}
		
		private function clearUpload( callbackUploadComplete:Function, ioErrorCallback:Function,secErrorCallback:Function):void {
			_refUploadFile.removeEventListener(flash.events.DataEvent.UPLOAD_COMPLETE_DATA, callbackUploadComplete);
			_refUploadFile.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorCallback);
			_refUploadFile.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, secErrorCallback);
			_refUploadFile.cancel();
		}
		
		
		public function syncFaultHandler():void
		{
			showSyncError("Error occured while calling sync");
			
		}
		public function setProcessStatusinDBonError(errorMsg:String):void
		{
			var sync:SyncEvent = new SyncEvent(SyncEvent.SET_PROCESS_STATUS_ON_SYNC_ERROR);
			sync.serviceURL = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL+"SetProceessStatus/ERROR/"+errorMsg+"/"+FlexGlobals.topLevelApplication.SyncLogID;
			
			dispatcher.dispatchEvent(sync);
		}
		
		public function setProcStatusResponseHandler(obj:Object,event:SyncEvent):void{
			trace("status set to failure in DB");
			var rawData:String = String(obj);
			FlexGlobals.topLevelApplication.setBusyStatus(false);
			if (rawData.length >0)
			{
				try{
					var configObj:Object = JSON.parse(rawData) as Object;
					if(configObj.error)
						throw new IOError(configObj.error);
					else
						FlexGlobals.topLevelApplication.TSSAlert("Failed sync process status update completed.");
				}
				catch(e:Error)
				{
					FlexGlobals.topLevelApplication.TSSAlert(e.message);
					
				}
					
			}
		}
		public function setInitiateSyncFaultHandler(event:SyncEvent):void{
			FlexGlobals.topLevelApplication.setBusyStatus(false);
			FlexGlobals.topLevelApplication.TSSAlert("Error initiating the sync. Please contact administrator.");
		}
		public function setProcStatusFaultHandler(event:SyncEvent):void{
			FlexGlobals.topLevelApplication.setBusyStatus(false);
			FlexGlobals.topLevelApplication.TSSAlert("Error updating the sync status in database. Please contact administrator.");
		}
	}
}