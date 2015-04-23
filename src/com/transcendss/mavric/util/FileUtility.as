package com.transcendss.mavric.util
{
	import com.adobe.audio.format.WAVWriter;
	
	import flash.display.Bitmap;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Video;
	import flash.utils.ByteArray;
	
	import mx.core.FlexGlobals;
	import mx.graphics.codec.PNGEncoder;
	public class FileUtility
	{
		
		
		private var mp3Name:String;
		
		public function FileUtility()
		{
		}
		
		public function WritePicture(aName:String, aBmp:Bitmap):void
		{
			try
			{
			var path:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.geotagUrl + aName;
			var fTemp:File;
			if (FlexGlobals.topLevelApplication.platform == "IOS") {
				fTemp = File.applicationStorageDirectory.resolvePath(path);
			} else {
				fTemp= new File(path);
			}
			
			//			var fTemp:File = new File(BaseConfigUtility.get("geotags_folder") + aName);
			var fsTemp:FileStream = new FileStream();
			fsTemp.open(fTemp, FileMode.WRITE);
			var pngEnc:PNGEncoder = new PNGEncoder();
			var fileData:ByteArray = pngEnc.encode(aBmp.bitmapData);
			fsTemp.writeBytes(fileData, 0, 0);
			fsTemp.close();
			}catch(e:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert('Error Writing Picture' + e.message);
			}
		}
		
		public function WriteMapImage(aName:String, aBmp:Bitmap):void
		{
			//var fTemp:File = new File("/sdcard/mapimages/" + aName);
			//var fTemp:File = new File("C:/Projects/MAVRIC/mapimages/" + aName);
			var path:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.cachedMapUrl + aName;
			var fTemp:File;
			if (FlexGlobals.topLevelApplication.platform == "IOS") {
				fTemp = File.applicationStorageDirectory.resolvePath(path);
			} else {
				fTemp= new File(path);
			}

			var fsTemp:FileStream = new FileStream();
			fsTemp.open(fTemp, FileMode.WRITE);
			var pngEnc:PNGEncoder = new PNGEncoder();
			var fileData:ByteArray = pngEnc.encode(aBmp.bitmapData);
			fsTemp.writeBytes(fileData, 0, 0);
			fsTemp.close();
		}
		
		public function saveToWAV(soundBytes:ByteArray, aName:String):void
		{
			var writer:WAVWriter = new WAVWriter();
			writer.numOfChannels=1;
			writer.sampleBitRate=16;
			writer.samplingRate=11025;
			soundBytes.position=0;
			
			var path:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.geotagUrl + aName;
			var fTemp:File;
			if (FlexGlobals.topLevelApplication.platform == "IOS") {
				fTemp = File.applicationStorageDirectory.resolvePath(path);
			} else {
				fTemp= new File(path);
			}

			var fsTemp:FileStream = new FileStream();
			fsTemp.openAsync(fTemp, FileMode.WRITE);
			writer.processSamples(fsTemp, soundBytes, 11025);
			fsTemp.close();
		}
		
		public function saveToMP3(soundBytes:ByteArray, aName:String):void
		{
			/*mp3Name = aName;
			mp3Encoder = new ShineMP3Encoder(soundBytes);
			mp3Encoder.addEventListener(Event.COMPLETE, mp3EncodeComplete);
			mp3Encoder.addEventListener(ProgressEvent.PROGRESS, mp3EncodeProgress);
			mp3Encoder.addEventListener(ErrorEvent.ERROR, mp3EncodeError);
			mp3Encoder.start();*/
		}
		
		private function mp3EncodeProgress(event:ProgressEvent) : void {
			
			trace(event.bytesLoaded, event.bytesTotal);
		}
		
		private function mp3EncodeError(event:flash.events.ErrorEvent) : void {
			
			trace("Error : ", event.text);
		}
		
		private function mp3EncodeComplete(event : Event) : void {
			
			/*trace("Done !", mp3Encoder.mp3Data.length);
			mp3Encoder.mp3Data.position = 0;
			mp3Encoder.saveAs("/sdcard/geotags/" + mp3Name);*/
			/*var fTemp:File = new File("/sdcard/geotags/" + mp3Name);
			var fsTemp:FileStream = new FileStream();
			fsTemp.open(fTemp, FileMode.WRITE);
			fsTemp.writeBytes(mp3Encoder.mp3Data, 0, 0);
			fsTemp.close();*/
		}
		
		public function WriteVideo(vid:Video, aName:String, path:String):void
		{
			
			var sourceFile:File = File.applicationDirectory.resolvePath(path);
			
			var path2:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.geotagUrl + aName;
			var destinationFile:File;
			if (FlexGlobals.topLevelApplication.platform == "IOS") {
				destinationFile = File.applicationStorageDirectory.resolvePath(path2);
			} else {
				destinationFile = new File(path2);
			}
			
			/*var fsFlvEncoder:FileStreamFlvEncoder = new FileStreamFlvEncoder(fTempFile, 30);
			
			fsFlvEncoder.fileStream.openAsync(fTempFile, FileMode.UPDATE);
			
			fsFlvEncoder.setVideoProperties(320, 240, VideoPayloadMaker);
			fsFlvEncoder.setAudioProperties(FlvEncoder.SAMPLERATE_44KHZ , true, false, true);
			
			fsFlvEncoder.start();
			
			var chunksize:uint = fsFlvEncoder.audioFrameSize;
			var div:uint = Math.floor(stream.bytesAvailable/chunksize);//for quick testing without eof
			var totalBytes:ByteArray = new ByteArray();
			stream.readBytes(totalBytes, 0, stream.bytesAvailable);
			
			for (var i:int = 0; i< (div*chunksize)/chunksize; i++)
			{
				var chunk:ByteArray = new ByteArray();
				
				chunk.endian = Endian.BIG_ENDIAN; //vid.loaderInfo.bytes.endian;
				chunk.writeBytes(totalBytes, i*chunksize, chunksize);
				//stream.readBytes(chunk, i*chunksize, chunksize);
				var bmpDat:BitmapData = new BitmapData(320, 240);
				fsFlvEncoder.addFrame(totalBytes[i], chunk);
			}
			
			
			fsFlvEncoder.updateDurationMetadata();
			
			fsFlvEncoder.fileStream.close();
			
			fsFlvEncoder.kill();*/
			
			var fsStream:FileStream = new FileStream();
			fsStream.open(destinationFile, FileMode.WRITE);
			var fsExists:FileStream = new FileStream();
			fsExists.open(sourceFile, FileMode.READ);
			while (fsExists.bytesAvailable > 0)
				fsStream.writeByte(fsExists.readByte());
			
			fsStream.close();
			fsExists.close();
		}
		
		public function getFile(fileName:String):File
		{
			var path:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.geotagUrl+fileName;
			var file:File;
			if (FlexGlobals.topLevelApplication.platform == "IOS") {
				file = File.applicationStorageDirectory.resolvePath(path);
				
			} else {
				file = new File(path);
			}
			
			return file;
		}
		
		public function getFileExtenstion(fileName:String):String
		{
			var path:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.geotagUrl+fileName;
			var file:File;
			if (FlexGlobals.topLevelApplication.platform == "IOS") {
				file = File.applicationStorageDirectory.resolvePath(path);
				
			} else {
				file = new File(path);
			}
			
			return file.extension;
		}
		
		public function openFile(aName:String):String
		{
			var fTemp:File ;
			if (FlexGlobals.topLevelApplication.platform == "IOS") {
				fTemp = File.applicationStorageDirectory.resolvePath(aName);
			} else {
				fTemp = new File(aName);
			}
			var stream:FileStream = new FileStream();
			stream.open(fTemp, FileMode.READ);
			var fileText:String = stream.readUTFBytes(stream.bytesAvailable);
			return fileText;
		}
		
		public function readFile(fileName:String):ByteArray
		{
			var path:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.geotagUrl+fileName;
			var byteArr:ByteArray = new ByteArray();
			var fTemp:File ;
			if (FlexGlobals.topLevelApplication.platform == "IOS") {
				fTemp = File.applicationStorageDirectory.resolvePath(path);
			} else {
				fTemp = new File(path);
			}
			var stream:FileStream = new FileStream();
			stream.open(fTemp, FileMode.READ);
			stream.readBytes(byteArr,0,stream.bytesAvailable);
			return byteArr;
		}
		
		public function getFiles():Array
		{
			var path:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.geotagUrl;
			var file:File;
			if (FlexGlobals.topLevelApplication.platform == "IOS") {
				file = File.applicationStorageDirectory.resolvePath(path);
				// If not exists, create one
				if (!file.exists) {
					file.createDirectory();
				}
			} else {
				file = new File(path);
			}
			
			return file.getDirectoryListing();
		}
		

		
		public function getFileCount():Number
		{
			var path:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.geotagUrl;
			var file:File;
			if (FlexGlobals.topLevelApplication.platform == "IOS") {
				file = File.applicationStorageDirectory.resolvePath(path);
			} else {
				file = new File(path);
			}
			
			return file.getDirectoryListing().length;
		}
		
		public function deleteFiles(fname:String):void
		{
			var path:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.geotagUrl+ fname;
			var file:File;
			if (FlexGlobals.topLevelApplication.platform == "IOS") {
				file = File.applicationStorageDirectory.resolvePath(path);
			} else {
				file = new File(path);
			}

			file.deleteFile();
		}
		
		public function deleteMapImages():void
		{
			var path:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.cachedMapUrl;
			var mapFolder:File;
			if (FlexGlobals.topLevelApplication.platform == "IOS") {
				mapFolder = File.applicationStorageDirectory.resolvePath(path);
			} else {
				mapFolder = new File(path);
			}

			if (mapFolder.exists)
			{
				var mapFiles:Array = mapFolder.getDirectoryListing();
				
				for (var i:int;i<mapFiles.length;i++)
				{
				    var mapFile:File = mapFiles[i];
					mapFile.deleteFile();
				}
			}
		}
		
		public function deleteGeoTags():void
		{
			var path:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.geotagUrl;
			var gtFolder:File;
			if (FlexGlobals.topLevelApplication.platform == "IOS") {
				gtFolder = File.applicationStorageDirectory.resolvePath(path);
			} else {
				gtFolder = new File(path);
			}
			
			var gtFiles:Array = gtFolder.getDirectoryListing();
			
			for (var i:int;i<gtFiles.length;i++)
			{
				var gtFile:File = gtFiles[i];
				gtFile.deleteFile();
			}
		}
		
		
	}
}