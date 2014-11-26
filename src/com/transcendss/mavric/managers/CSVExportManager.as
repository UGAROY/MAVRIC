package com.transcendss.mavric.managers
{
	import com.asfusion.mate.core.GlobalDispatcher;
	import com.transcendss.mavric.db.MAVRICDBManager;
	import com.transcendss.mavric.managers.SettingsManager;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayCollection;
	import mx.core.*;
	import mx.rpc.Responder;
	
	public class CSVExportManager
	{
		public var dispatcher:GlobalDispatcher = new GlobalDispatcher();
		private var dbManager:MAVRICDBManager = MAVRICDBManager.newInstance();
		private var _exportAssetDir:String = "";
		private var _exportGeotagDir:String = "";
		private var _outputAssetDir:File;
		private var _outputGeotagDir:File;
		private var _assetsExist:Boolean;
		private var _geotagsExist:Boolean;

		var assetData:ArrayCollection = new ArrayCollection();


		public function CSVExportManager()
		{
			exportAssetDir = BaseConfigUtility.get("export_folder");
			exportGeotagDir = BaseConfigUtility.get("geotags_folder");
		}
		
		public function get geotagsExist():Boolean
		{
			return _geotagsExist;
		}

		public function set geotagsExist(value:Boolean):void
		{
			_geotagsExist = value;
		}

		public function get assetsExist():Boolean
		{
			return _assetsExist;
		}

		public function set assetsExist(value:Boolean):void
		{
			_assetsExist = value;
		}

		public function get outputGeotagDir():File
		{
			return _outputGeotagDir;
		}

		public function set outputGeotagDir(value:File):void
		{
			_outputGeotagDir = value;
		}

		public function get exportGeotagDir():String
		{
			return _exportGeotagDir;
		}

		public function set exportGeotagDir(value:String):void
		{
			_exportGeotagDir = value;
		}

		public function get outputAssetDir():File
		{
			return _outputAssetDir;
		}

		public function set outputAssetDir(value:File):void
		{
			_outputAssetDir = value;
		}

		public function get exportAssetDir():String
		{
			return _exportAssetDir;
		}

		public function set exportAssetDir(value:String):void
		{
			_exportAssetDir = value;
		}

		public function syncChanges():void
		{
			assetsExist = false;
			geotagsExist = false;
			outputAssetDir =File.documentsDirectory.resolvePath(exportAssetDir);
			outputGeotagDir =File.documentsDirectory.resolvePath(exportGeotagDir);

			// If the output dir is not empty, as the user if the contents should be deleted.
			if(outputAssetDir.exists)
			{
				if(!isEmptyDir(outputAssetDir))
				{
					assetsExist = true;
					var msg:String = "Exported CSV files already exist. Continuing will replace the existing CSV files with new data.\n Are you sure you want to continue?";
					var resp:mx.rpc.Responder = new mx.rpc.Responder(emptyOutputDir, null);
					FlexGlobals.topLevelApplication.YesNoPrompt(msg, "Warning", resp);
				}
			}
			else
			{
				try{
					outputAssetDir.createDirectory();
				}
				catch(e:Error)
				{
					FlexGlobals.topLevelApplication.TSSAlert("Error creating export dir: " + e.message);
					return;
				}
			}
			
			// If no files exist in the output directory, export the asset data
			if(!assetsExist)
			{
				exportChanges();
			}
		}

		private function isEmptyDir(outputDir:File):Boolean
		{
			var filesList:Array = outputDir.getDirectoryListing();
			if(filesList != null && filesList.length > 0)
				return false;
			else
				return true;
		}
		
		// Called if the output dir is not empty and the user wants to empty it
		private function emptyOutputDir(emptyDir:Boolean):void
		{
			if(emptyDir)
			{
				try
				{
					if(assetsExist)
					{
						var filesList:Array = outputAssetDir.getDirectoryListing();
						if(filesList != null && filesList.length > 0)
						{
							for(var i:int=0; i<filesList.length; i++)
							{
								var tmpFile:File = filesList[i];
								tmpFile.deleteFile();
							}
						}
						assetsExist = false;
					}
				}
				catch(e:Error)
				{
					FlexGlobals.topLevelApplication.TSSAlert(e.message);
					
				}
				
				exportChanges();
			}
		}
		
		// Read asset and geotag changes from the local db and write them to files in the
		// export directory 
		public function exportChanges():void
		{
			
			if(FlexGlobals.topLevelApplication.menuBar.getCurrentUser()!="" && FlexGlobals.topLevelApplication.menuBar.getCurrentUser()!=null)
			{
				// Retrieve all the changed asset data
				exportModifiedDataFromLocalDB();
				if(assetData.length == 0)
				{
					FlexGlobals.topLevelApplication.TSSAlert("No asset data was found to export.");
					return;
				}
				
				try
				{
					FlexGlobals.topLevelApplication.setBusyStatus(true);
					
					// Let the user know if no asset data changes are found
					if (assetData == null)
					{
						FlexGlobals.topLevelApplication.TSSAlert("No Assets to export.");
					}
					else
					{
						// Export the changed asset data and associated geotags to files
						writeFileAsset(exportAssetDir);
						exportGeotags();
						FlexGlobals.topLevelApplication.TSSAlert("Modified assets and geotags exported to the export folder on the tablet.");
					}
					FlexGlobals.topLevelApplication.setBusyStatus(false);
				}
				catch(e:Error)
				{
					FlexGlobals.topLevelApplication.setBusyStatus(false);
					FlexGlobals.topLevelApplication.TSSAlert(e.message);
				}
			}
			else
				FlexGlobals.topLevelApplication.TSSAlert('Current User not specified. User name required for syncing');
		}
		

		// Retrieve asset data from the local db and store the comma-delimited data in the
		// assetData object.
		private function exportModifiedDataFromLocalDB():void
		{
			var assetDef:Object = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetDefs;
			var invHeaderArray:Array;
			var inspHeaderArray:Array;
			var invHeaderData:String;
			var inspHeaderData:String;

			assetData = new ArrayCollection();
			
			for each (var def:Object in assetDef) 
			{
				var dataArray:Array;
				invHeaderData = "";
				inspHeaderData = "";
				invHeaderArray = new Array();
				inspHeaderArray = new Array();
				
				dataArray = def.ASSET_DATA_TEMPLATE.INV_COLUMNS as Array;

				for(var i:int=0; i<dataArray.length; i++)
				{
					if(i > 0)
						invHeaderData += ",";
					invHeaderData += dataArray[i].NAME;
					invHeaderArray.push(dataArray[i].NAME);
				}
				
				dataArray = def.ASSET_DATA_TEMPLATE.INSP_COLUMNS as Array;

				for(var j:int=0; j<dataArray.length; j++)
				{
					if(j > 0)
						inspHeaderData += ",";
					inspHeaderData += dataArray[j].NAME;
					inspHeaderArray.push(dataArray[j].NAME);
				}

				var headerStr:String = invHeaderData + "," + inspHeaderData;
				var dataArr:Array = dbManager.exportAssets(def.DESCRIPTION);
				if(dataArr !=null && dataArr.length >0)
				{
					var resultsData:Array = new Array();
					resultsData = formatResultsForExport(dataArr, invHeaderArray, inspHeaderArray, headerStr);
					assetData.addItem({assetType: def.DESCRIPTION, data: resultsData});
				}
			}
		}
		
		// Format the results as and array of comma-delimited strings
		private function formatResultsForExport(dataArr:Array, invHeaderArray:Array, inspHeaderArray:Array, headerStr:String):Array
		{
			var resultsArray:Array = new Array();
			resultsArray.push(headerStr);
			for(var i:int=0; i<dataArr.length; i++)
			{
				var resultStr:String = "";
				for(var j:int=0; j<invHeaderArray.length; j++)
				{
					if(j > 0)
						resultStr += ",";
					resultStr += dataArr[i][invHeaderArray[j]];
				}
				for(var k:int=0; k<inspHeaderArray.length; k++)
				{
					resultStr += ",";
					resultStr += dataArr[i][inspHeaderArray[k]];
				}
				resultsArray.push(resultStr);
			}
			return resultsArray;
		}
		
		// For each asset type, write a file of changed asset data
		private function writeFileAsset(dirName:String):void
		{
			var assetType:String;
			for each (var obj:Object in assetData)
			{
				assetType = obj.assetType;
				assetType = assetType.toLowerCase() + "s";
				
				trace("Writing asset files");
				var file:File = File.createTempFile();
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);

				for(var i:int=0; i< obj.data.length; i++)
				{
					var dataStr:String = obj.data[i];
					var finalString:String = dataStr.replace(new RegExp("null,", "g"), ",");
					finalString = finalString.replace(new RegExp("null", "g"), "");

					stream.writeUTFBytes(finalString);
					stream.writeUTFBytes("\r\n");
				}

				stream.close();
				var newFile:File =File.documentsDirectory.resolvePath(exportAssetDir + "/" + assetType + ".txt");
				file.copyToAsync(newFile, true);
			}
			
		}
		
		// Write geotag data to the export directory and copy geotag files from the geotags directory
		// to the export directory
		public function exportGeotags():void
		{
			var data:Array = new Array();
			var newDirName:String = BaseConfigUtility.get("export_folder");
			
			try
			{
				data= dbManager.exportGeotagData();
				
				if (data == null) //If the local database has no geotags, print this.
				{
					FlexGlobals.topLevelApplication.TSSAlert("Modified assets exported to the export folder on tablet. No Geotags to export");
				}
				else
				{
					var gtString:String = "asset_type, asset_base_id, id, is_insp_tag, image_filename, video_filename, voice_filename, text_memo\r\n";
					writeFileGeotags(gtString, exportAssetDir, data);
					var tmpName:String = BaseConfigUtility.get("geotags_folder");
					var gdir:File = File.documentsDirectory.resolvePath(tmpName);
					
					var tmpArray:Array = gdir.getDirectoryListing();
					if(tmpArray != null)
					{
						if(tmpArray.length > 0)
						{
							var oldFile:File;
							var newFile:File;
							for(var i:int=0; i<tmpArray.length; i++)
							{
								oldFile =File.documentsDirectory.resolvePath(tmpName + tmpArray[i].name);
								newFile = File.documentsDirectory.resolvePath(newDirName + tmpArray[i].name);
								oldFile.copyToAsync(newFile, true);
							}
						}
					}
					
					FlexGlobals.topLevelApplication.setBusyStatus(false);
				}
			}
			
			catch(e:Error)
			{
				FlexGlobals.topLevelApplication.setBusyStatus(false);
				FlexGlobals.topLevelApplication.TSSAlert(e.message);
			}
		}

		private function writeFileGeotags(header:String, dirName:String, data:Array):void
		{
			if(data == null || data.length == 0)
				return; // No geotags to export
			
			var file:File = File.createTempFile();
			var stream:FileStream = new FileStream();
			
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(header);
			
			var paramString:String = header.substr(0, header.length - 2);
			paramString = paramString.replace(new RegExp(", ", "g"), ",");
			var params:Array = paramString.split(",");
			
			for each (var obj:Object in data)
			{
				var cmdString:String = "";
				
				for each (var item:String in params)
				{
					cmdString += obj[item] + ",";
				}
				cmdString = cmdString.substr(0, cmdString.length - 1);
				
				
				var finalString:String = cmdString.replace(new RegExp("null,", "g"), ",");
				finalString = cmdString.replace(new RegExp("null", "g"), "");
				stream.writeUTFBytes(finalString);
				stream.writeUTFBytes("\r\n");
			}
			
			stream.close();
			var newFile:File = File.documentsDirectory.resolvePath(dirName + "/geotags.txt");
			file.copyToAsync(newFile, true);
		}
//		
//		
//		private function writeGeotagDataFile(header:String, data:Array):File
//		{
//			trace("Writing geotoag file ");
//			var file:File = File.createTempFile();
//			var stream:FileStream = new FileStream();
//			stream.open(file, FileMode.WRITE);
//			stream.writeUTFBytes(header);
//			
//			var paramString:String = header.substr(0, header.length - 2);
//			paramString = paramString.replace(new RegExp(", ", "g"), ",");
//			var params:Array = paramString.split(",");
//			
//			for each (var obj:Object in data)
//			{
//				var cmdString:String = "";
//				
//				for each (var item:String in params)
//				{
//					cmdString += obj[item] + ",";
//				}
//				cmdString = cmdString.substr(0, cmdString.length - 1);
//				
//				
//				var finalString:String = cmdString.replace(new RegExp("null,", "g"), ",");
//				finalString = cmdString.replace(new RegExp("null", "g"), "");
//				stream.writeUTFBytes(finalString);
//				stream.writeUTFBytes("\r\n");
//			}
//			
//			
//			stream.close();
//			return file;
//		}

	}
}