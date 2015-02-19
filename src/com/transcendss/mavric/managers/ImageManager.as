package com.transcendss.mavric.managers
{
	
	import com.transcendss.mavric.util.PNGDecoder;
	import com.transcendss.transcore.util.TSSLoader;
	import com.transcendss.transcore.util.TSSPicture;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.errors.SQLError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SQLEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.net.dns.AAAARecord;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.rpc.Responder;
	
	import spark.components.Group;
	
	public class ImageManager
	{
		
		private var sConn:SQLConnection = new SQLConnection();
		private var sStat:SQLStatement = new SQLStatement();
		private var table:String = "signs";
		private var catMap:String = "catMap";
		private var responder:Responder;
		//for Justin's machine
		//var curDir:String = "app:///InnerFiles/sign_inv/";
		private var curDir:String;
		private var baseDir:String;
		private var db:String;
		
		public function ImageManager()
		{
			//Change this, and when you do, call setupDB(db) once to populate your database.
			db = "app:///InnerFiles/signs.db";
			sConn.open(new File(db));
			sStat.sqlConnection = sConn;
			//var folder:File = File.userDirectory.resolvePath(BaseConfigUtility.get("sign_images_SD_folder"));
			//curDir = folder.exists? BaseConfigUtility.get("sign_images_SD_folder"):BaseConfigUtility.get("sign_images_Desktop_folder");
			//			baseDir = BaseConfigUtility.get("sign_images_folder")
			baseDir = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.signImagesUrl;
			//setupDB(db);
		}
		
		//For testing purposes
		public function setupTable():void
		{
			setupDB("mavric.db");
		}
		
		// Open the database and make the table for the first time. Must provide databse location as a string.
		public function setupDB(db:String):void
		{
			//sConn.close();
			//sConn.open(File.applicationStorageDirectory.resolvePath(db));
			
			sStat.sqlConnection = sConn;
			
			sStat.text = "DROP TABLE IF EXISTS " + table;
			sStat.execute();
			sStat.text = "DROP TABLE IF EXISTS " + catMap;
			sStat.execute();
			
			// Create the schema if it does not already exist
			sStat.text = "CREATE TABLE " + table + " (id INTEGER PRIMARY KEY, " +
				"category INTEGER, " +
				"mutcd varchar(255), " +
				"dir varchar(255), " +
				"cmt varchar(255));";
			sStat.execute();
			
			sStat.text = "CREATE TABLE " + catMap + " (catNum INTEGER, catString TEXT)";
			sStat.execute();
			
			var dir:File = new File(curDir);
			var folders:Array = dir.getDirectoryListing();
			var category:int = 1;
			var id:int = 1;
			for each (var folder:File in folders)
			{
				var signs:Array = folder.getDirectoryListing();
				var folderPath:String = dir.getRelativePath(folder);
				sStat.text = "INSERT INTO " + catMap + " (catNum, catString)" +
					" Values ('" +
					category + "', '" +
					folderPath + "')";
				sStat.execute();
				for each (var sign:File in signs)
				{
					var path:String = dir.getRelativePath(sign);
					var mutcd:String = folder.getRelativePath(sign);
					mutcd = mutcd.substring(0, mutcd.length - 4);
					sStat.text = "INSERT INTO " + table + " (id, category, mutcd, dir)" +
						" VALUES (" +
						id + ", " +
						category + ", '" +
						mutcd + "', '" +
						path + "')";
					id++;
					sStat.execute();
					trace("added " + id + " of 1343");
				}
				category++;
			}
		}
		
		//Must be called before bitmaps can be accessed.
		public function setBaseDir(dir:String):void
		{
			baseDir = dir;
		}
		
		public function getCats():ArrayCollection
		{
			sStat.text = "SELECT catString FROM " + catMap;
			sStat.execute();
			var result:SQLResult = sStat.getResult();
			if (!result.data)
				return null;
			
			var cats:ArrayCollection = new ArrayCollection();
			
			for each (var entry:Object in result.data)
			{
				cats.addItem(entry.catString);
			}
			
			return cats;
		}
		
		public function getMUTCDs():ArrayCollection
		{
			sStat.text = "SELECT mutcd FROM " + table;
			sStat.execute();
			var result:SQLResult = sStat.getResult();
			if (!result.data)
				return null;
			
			var names:ArrayCollection = new ArrayCollection();
			
			for each (var entry:Object in result.data)
			{
				names.addItem(entry.mutcd);
			}
			
			return names
		}
		
		public function getAll():ArrayCollection
		{
			sStat.text = "SELECT dir FROM " + table;
			sStat.execute();
			var result:SQLResult = sStat.getResult();
			if (!result.data)
				return null;
			
			var images:Array = new Array();
			
			for each (var entry:Object in result.data)
			{
				images.push(getData(entry.dir));
			}
			
			return new ArrayCollection(images);
		}
		
		private function getCatByMUTCD(mutcd:String):int
		{
			var retVal:int;
			sStat.text = "SELECT category FROM " + table +  " WHERE mutcd = '" + mutcd + "'";
			sStat.execute();
			var result:SQLResult = sStat.getResult();
			if (!result.data)
				return retVal;
			
			retVal = result.data[0].category;
			return retVal;
		}
		
		public function getCatStringByMUTCD(mutcd:String):String
		{
			var catNum:int = getCatByMUTCD(mutcd);
			
			sStat.text = "SELECT catString FROM " + catMap + " WHERE catNum = '" + catNum + "'";
			sStat.execute();
			var result:SQLResult = sStat.getResult();
			if (!result.data)
				return null;
			
			return result.data[0].catString;
		}
		
		public function getMUTCDByCatString(catString:String):ArrayCollection
		{
			sStat.text = "SELECT catNum FROM " + catMap + " WHERE catString = '" + catString + "'";
			sStat.execute();
			var result:SQLResult = sStat.getResult();
			if (!result.data)
				return null;
			
			return getMUTCDByCat(result.data[0].catNum);
		}
		
		private function getMUTCDByCat(cat:int):ArrayCollection
		{
			sStat.text = "SELECT mutcd FROM " + table + " WHERE category = '" + cat + "'";
			sStat.execute();
			var result:SQLResult = sStat.getResult();
			if (!result.data)
				return null;
			
			var names:ArrayCollection = new ArrayCollection();
			
			for each (var entry:Object in result.data)
			{
				names.addItem(entry.mutcd);
			}
			
			return names
		}
		
		public function getByCat(cat:int):ArrayCollection
		{
			sStat.text = "SELECT dir FROM " + table + " WHERE category = '" + cat + "'";
			sStat.execute();
			var result:SQLResult = sStat.getResult();
			if (!result.data)
				return null;
			
			var images:Array = new Array();
			
			for each (var entry:Object in result.data)
			{
				images.push(getData(entry.dir));
			}
			
			return new ArrayCollection(images);
		}
		
		public function getById(mutcd:String):Bitmap
		{
			var extension:String = "";
			if (mutcd == "OTR")
				mutcd="R1-2";
			if (mutcd!="multiples")
			{
				sStat.text = "SELECT dir FROM " + table + " WHERE mutcd = '" + mutcd + "'";
				sStat.execute();
				var result:SQLResult = sStat.getResult();
				if (!result.data)
					return getData("NoFile.png");
				extension = result.data[0].dir;
			}
			else
				extension = "M.png";
			
			return getData(extension);
		}
		
		private function getData(extension:String):Bitmap
		{
			
			var path:String = baseDir + extension;
			var meFile:File;
			if (FlexGlobals.topLevelApplication.platform == "IOS") {
				meFile = File.applicationStorageDirectory.resolvePath(path);
				if (!meFile.exists) {
					meFile = File.applicationDirectory.resolvePath(baseDir + 'Missing.png');
				}
			} else {
				meFile = new File(path);
				if (!meFile.exists) {
					meFile = new File(baseDir + "Missing.png");
				}
			}
			
			
			var fs:FileStream = new FileStream();
			fs.open(meFile, FileMode.READ);
			
			var byteArray:ByteArray = new ByteArray();
			fs.readBytes(byteArray, 0, fs.bytesAvailable);
			
			var bitmapData:BitmapData = PNGDecoder.decodeImage(byteArray);
			
			return new Bitmap(bitmapData);
		}
		
		/*private function getData(extension:String):void
		{
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onFault);
		loader.contentLoaderInfo.addEventListener(ErrorEvent.ERROR, onFault);
		loader.load(new URLRequest(baseDir + extension));
		}
		
		function onComplete(event:Event):void
		{
		var bitmap:Bitmap = Bitmap(LoaderInfo(event.target).content);
		responder.result(bitmap);
		}
		
		function onFault(event:Event):void
		{
		trace("Error");
		}*/
		public function scaleImage(btmp:Bitmap , parentGrp:Group):Bitmap
		{
			
			var scaleFactor:Number=0.65;
			var originalBitmapData:BitmapData=btmp.bitmapData;
			var hFactor:Number = originalBitmapData.height / parentGrp.height; 
			var wFactor:Number = originalBitmapData.width / parentGrp.width; 
			
			// First scale widt to fit the space available
			if (wFactor > 1)
			{
				scaleFactor = parentGrp.width / originalBitmapData.width;
			} else
			{
				scaleFactor = (1 - (originalBitmapData.width / parentGrp.width)) + 1;
			}
			
			
			var newHeight:Number=originalBitmapData.height*scaleFactor;
			// If the scaled height is too large for the space, rescale to fit height
			if (newHeight > parentGrp.height)
			{
				if (hFactor > 1)
				{
					scaleFactor = parentGrp.height / originalBitmapData.height;
				} else
				{
					scaleFactor = (1 - (originalBitmapData.height / parentGrp.height)) + 1;
				}
				newHeight = originalBitmapData.height*scaleFactor;
			}
			
			//Scale the image and add to the display
			var newWidth:Number=originalBitmapData.width*scaleFactor;
			var scaledBitmapData:BitmapData=new BitmapData(newWidth,newHeight,true,0xFFFFFFFF);
			var scaleMatrix:Matrix=new Matrix();
			scaleMatrix.scale(scaleFactor,scaleFactor);
			scaledBitmapData.draw(originalBitmapData,scaleMatrix);
			btmp.bitmapData=scaledBitmapData; 
			return btmp;
		}
	}
}
