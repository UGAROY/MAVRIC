package com.transcendss.mavric.managers
{
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.mavric.db.CachedElement;
	import com.transcendss.mavric.db.CachedRoute;
	import com.transcendss.mavric.db.MAVRICDBManager;
	import com.transcendss.mavric.util.FileUtility;
	import com.transcendss.mavric.util.PNGDecoder;
	import com.transcendss.transcore.events.AssetManagerEvent;
	import com.transcendss.transcore.sld.models.StickDiagram;
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	import com.transcendss.transcore.sld.models.components.GeoTag;
	import com.transcendss.transcore.sld.models.components.Route;
	import com.transcendss.transcore.sld.models.managers.CoreAssetManager;
	import com.transcendss.transcore.sld.models.managers.GeotagsManager;
	import com.transcendss.transcore.util.AssetSymbol;
	import com.transcendss.transcore.util.Converter;
	import com.transcendss.transcore.util.RedLineSymbol;
	import com.transcendss.transcore.util.TSSAudio;
	import com.transcendss.transcore.util.TSSPicture;
	import com.transcendss.transcore.util.TSSVideo;
	import com.transcendss.transcore.util.Tippable;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.rpc.IResponder;
	
	import spark.components.Image;
	
	// need to add pdfutil package
	
	/**
	 * AssetManager is the general management and factory class for the new MAVRIC dynamic Asset structure.
	 * Asset types are defined in JSON files (whose locations are defined in the settings.properties file) and
	 * AssetManager parses and creates Assets based on these definitions.
	 * */
	public class AssetManager extends CoreAssetManager
	{
		private var _mdbm : MAVRICDBManager;
		private var _sprites:Object = new Object();
		private var _rebuildArr:Array = new Array();
		private var _imageMan:ImageManager = new ImageManager();
		private var fileUtil:FileUtility = new FileUtility();
		
		private var serviceCallName:String = "Domains/";
		private var defaultDescCol:String = "DESCRIPTION";
		
		
		private var _domainDefs:Object = new Object();
		
		public var assetsForSync:Array=new Array();
		public var eventLayerIDs:Array=new Array();
		public var barElementsForSync:Array=new Array();
		private var _barElementDomainDefs:Object = new Object();
		public var barElementNames:Array = new Array();
		
		
		/**
		 * Creates tables for an list of different types of assets.
		 */
		public function AssetManager()
		{
			_mdbm = MAVRICDBManager.newInstance();
			_dispatcher = new Dispatcher(); 
			//			getAssetDefinitions(ConfigUtility.get("asset_json_def"));
			getAssetDefinitions(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.assetJsonDef);
			cacheDrawStrings();
			getDomainList(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.domainDef);
			
			// Get bar element definitions and domains
			getAssetDefinitions(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.barElementJsonDef, false);
			//getDomainList(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.barElementDomainDef, false);
		}
		
		public function getBarElementIDField(type:String):String
		{
			var uiName:String = "";
			uiName = _barElementDefs[type].BAR_ELEMENT_DATA_TEMPLATE.PRIMARY_KEY;
			return uiName;
		}
		
		public function getBarElementFromMeasure(type:String):String
		{
			var uiName:String = "";
			uiName = _barElementDefs[type].BAR_ELEMENT_DATA_TEMPLATE.FROM_MEASURE_COLUMN
			return uiName;
		}
		public function getBarElementToMeasure(type:String):String
		{
			var uiName:String = "";
			uiName = _barElementDefs[type].BAR_ELEMENT_DATA_TEMPLATE.TO_MEASURE_COLUMN;
			return uiName;
		}
		public function getBarElementValueField(type:String):String
		{
			var uiName:String = "";
			uiName = _barElementDefs[type].TYPE_KEY;
			return uiName;
		}
		
		private function cacheDrawStrings():void
		{
			for (var def:String in _assetDefs)
			{
				_sprites[_assetDefs[def].DESCRIPTION] = new Array();
				var subtypeCount:int = 1;
				
				
				for each (var subtype:Object in _assetDefs[def].DEFINITION.SUBTYPES)
				{
					var meFile:File = new File("app:///" + subtype.DRAWING.DRAWSTRING);
					
					if (!meFile.exists || subtype.DRAWING.DRAWSTRING == "")
						continue;
					
					
					var fs:FileStream = new FileStream();
					fs.open(meFile, FileMode.READ);
					
					if ((subtype.DRAWING.DRAWSTRING as String).indexOf(".json") != -1)
					{
						var jsonString : String = fs.readUTFBytes(fs.bytesAvailable);
						var drawStringObject : Object = JSON.parse(jsonString);
						
						_sprites[_assetDefs[def].DESCRIPTION].push(drawStringObject);
					}
					else
					{
						var data:ByteArray = new ByteArray();
						fs.readBytes(data, 0, fs.bytesAvailable);
						var bmpData:BitmapData = PNGDecoder.decodeImage(data);
						var bitmap:Bitmap = new Bitmap(bmpData);
						_sprites[_assetDefs[def].DESCRIPTION].push(bitmap);
					}
					
					/*
					* Stores alternate drawings for subtypes where the key = "Description-Subtype-AltPropertyValue" 
					*/
					_sprites[_assetDefs[def].DESCRIPTION+"-"+subtypeCount] = new Array();
					for each(var alt_drawstring:Object in subtype.DRAWING.ALTERNATES)
					{
						var fs2:FileStream = new FileStream();
						var altFile:File = new File("app:/"+alt_drawstring.DRAWSTRING);
						fs2.open(altFile, FileMode.READ);
						
						
						if (alt_drawstring.DRAWSTRING.indexOf(".json") != -1)
						{
							jsonString = fs2.readUTFBytes(fs2.bytesAvailable);
							drawStringObject = JSON.parse(jsonString);
							_sprites[_assetDefs[def].DESCRIPTION+"-"+subtypeCount].push(drawStringObject);
						}
						else
						{
							data = new ByteArray();
							fs2.readBytes(data, 0, fs2.bytesAvailable);
							bmpData = PNGDecoder.decodeImage(data);
							bitmap = new Bitmap(bmpData);
							_sprites[_assetDefs[def].DESCRIPTION+"-"+subtype.SUBTYPE].push(bitmap);
						}
					}
					subtypeCount++;
				}
			}
		}
		
		public function isCaptureAvailable(def:String):Boolean
		{
			return String(_assetDefs[def].CAPTURE_AVAILABLE).toLowerCase() == "true";
		}
		
		private function getAssetDefinitions(path:String, isAsset:Boolean=true):void
		{	
			var meFile:File ;
			
			if(path.indexOf("app-storage")!= -1)
				meFile = File.applicationStorageDirectory.resolvePath(path.replace("app-storage:/",""));
			else
				meFile = File.applicationDirectory.resolvePath(path);
			
			var fs:FileStream = new FileStream();
			fs.open(meFile, FileMode.READ);
			
			var jsonString : String = fs.readUTFBytes(fs.bytesAvailable);
			var jsonObj:Object = JSON.parse(jsonString);
			buildDefinitionList(jsonObj, isAsset);
			
			fs.close();
		}
		
		private function buildDefinitionList(jsonObj: Object, isAsset:Boolean):void
		{
			var arr:Array = jsonObj as Array;
			if(isAsset)
			{
				for (var i:int = 0; i < arr.length; i++)
				{
					if (jsonObj[i].ASSET_DEF.DEFINITION.hasOwnProperty("SUBTYPES"))
					{	
						_assetDefs[jsonObj[i].ASSET_DEF.ASSET_TYPE] = jsonObj[i].ASSET_DEF;
						_assetDescriptions[jsonObj[i].ASSET_DEF.DESCRIPTION] = jsonObj[i].ASSET_DEF.ASSET_TYPE; 
					}	
					if(String(jsonObj[i].ASSET_DEF.SYNC).toLowerCase()=="true")
						this.assetsForSync.push({ID:jsonObj[i].ASSET_DEF.ASSET_TYPE,DESCRIPTION:jsonObj[i].ASSET_DEF.DESCRIPTION, EVENT_LAYER_ID:jsonObj[i].ASSET_DEF.EVENT_LAYER_ID} );
					eventLayerIDs.push(jsonObj[i].ASSET_DEF.EVENT_LAYER_ID);
				}
				
				//			var meFile:File = File.applicationDirectory.resolvePath(ConfigUtility.get("asset_json_template"));
				var meFile:File ;
				var path:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.assetJsonTempl;
				if(path.indexOf("app-storage")!= -1)
					meFile=File.applicationStorageDirectory.resolvePath(path.replace("app-storage:/",""))
				else
					meFile = File.applicationDirectory.resolvePath(path);
				
				var fs:FileStream = new FileStream();
				fs.open(meFile, FileMode.READ);
				
				var jsonString : String = fs.readUTFBytes(fs.bytesAvailable);
				var jsonObj:Object = JSON.parse(jsonString);
				
				arr = jsonObj as Array;
				
				_rebuildArr = arr;
				
				_mdbm.createAssetTables(arr);
				
				for (i = 0; i < arr.length; i++)
				{
					_assetDefs[arr[i].ASSET_DATA_TEMPLATE.ASSET_TYPE].ASSET_DATA_TEMPLATE = arr[i].ASSET_DATA_TEMPLATE;
				}
			}
			else
			{
				for (var j:int = 0; j < arr.length; j++)
				{
					//					if (jsonObj[i].BAR_ELEMENT_DEF.DEFINITION.hasOwnProperty("SUBTYPES"))
					//					{	
					_barElementDefs[jsonObj[j].BAR_ELEMENT_DEF.ELEMENT_TYPE] = jsonObj[j].BAR_ELEMENT_DEF;
					_barElementDescriptions[jsonObj[j].BAR_ELEMENT_DEF.DESCRIPTION] = jsonObj[j].BAR_ELEMENT_DEF.ELEMENT_TYPE; 
					//					}	
					if(String(jsonObj[j].BAR_ELEMENT_DEF.SYNC).toLowerCase()=="true")
						this.barElementsForSync.push(jsonObj[j].BAR_ELEMENT_DEF.DESCRIPTION);
				}
				
				//			var meFile:File = File.applicationDirectory.resolvePath(ConfigUtility.get("asset_json_template"));
				var meFile2:File ;
				var path2:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.barElementJsonTempl;
				if(path2.indexOf("app-storage")!= -1)
					meFile2=File.applicationStorageDirectory.resolvePath(path2.replace("app-storage:/",""))
				else
					meFile2 = File.applicationDirectory.resolvePath(path2);
				
				var fs2:FileStream = new FileStream();
				fs2.open(meFile2, FileMode.READ);
				
				var jsonString2 : String = fs2.readUTFBytes(fs2.bytesAvailable);
				var jsonObj2:Object = JSON.parse(jsonString2);
				
				arr = jsonObj2 as Array;
				
				_rebuildArr = arr;
				
				_mdbm.createBarElementTables(arr);
				
				for (i = 0; i < arr.length; i++)
				{
					_barElementDefs[arr[i].BAR_ELEMENT_DATA_TEMPLATE.ELEMENT_TYPE].BAR_ELEMENT_DATA_TEMPLATE = arr[i].BAR_ELEMENT_DATA_TEMPLATE;
					barElementNames.push(arr[i].BAR_ELEMENT_DATA_TEMPLATE.DESCRIPTION);
				}
			}
		}
		
		
		
		
		private function getDomainList(path:String, isAsset:Boolean=true):void
		{	
			var meFile:File ;
			
			if(path.indexOf("app-storage")!= -1)
				meFile = File.applicationStorageDirectory.resolvePath(path.replace("app-storage:/",""));
			else
				meFile = File.applicationDirectory.resolvePath(path);
			var fs:FileStream = new FileStream();
			fs.open(meFile, FileMode.READ);
			
			var jsonString : String = fs.readUTFBytes(fs.bytesAvailable);
			var jsonObj:Object = JSON.parse(jsonString);
			buildDomainList(jsonObj, isAsset);
			
			fs.close();
		}
		
		private function buildDomainList(jsonObj: Object, isAsset:Boolean):void
		{
			var arr:Array = jsonObj as Array;
			if(isAsset)
			{
				for (var i:int = 0; i < arr.length; i++)
				{
					_domainDefs[arr[i].DOMAIN_DEF.TYPE] = arr[i].DOMAIN_DEF.LIST;
				}
			}
			else
			{
				for ( i = 0; i < arr.length; i++)
				{
					_barElementDomainDefs[arr[i].BAR_ELEMENT_DOMAIN_DEF.TYPE] = arr[i].BAR_ELEMENT_DOMAIN_DEF.LIST;
				}
			}
		}
		
		public function getDomain(type:String):ArrayCollection
		{
			var dom:Array = _domainDefs[type] as Array;
			return new ArrayCollection(dom);
		}
		
		public function getBarElementDomain(type:String):ArrayCollection
		{
			var dom:Array = _barElementDomainDefs[type] as Array;
			return new ArrayCollection(dom);
		}
		
		public function getUsersDomainByBoundry(boundry:String):ArrayCollection
		{
			var dom:Array = _domainDefs["USERS"] as Array;
			var userDom:Array=new Array();
			for each (var obj:Object in dom)
			{
				if(String(obj.BUSINESS_UNIT) == boundry || String(obj.BUSINESS_UNIT) == "All Boundries")
					userDom.push({USER_NAME: obj.DESCRIPTION});	
			}
			return new ArrayCollection(userDom);
		}
		
		// Drop and recreate all asset tables
		public function clearAssetTables():void
		{
			for each (var def:Object in _assetDefs) 
			{
				_mdbm.dropAssetTables(def);
			}
			_mdbm.createAssetTables(_rebuildArr);
		}
		
		// Drop and recreate all bar element tables
		public function clearBarElementTables():void
		{
			for each (var def:Object in _barElementDefs) 
			{
				_mdbm.dropBarElementTables(def);
			}
			_mdbm.createBarElementTables(_rebuildArr);
		}
		
		public function mapAndAssignAssetSymbols(data:Object,type:String, resp:IResponder, assign:Boolean = true):void
		{
			var asset:BaseAsset;
			if (data is BaseAsset)
				asset = data as BaseAsset;
			else
				asset = mapDataToBaseAsset(data,type);
			if (assign )
				assignAssetSymbol(asset, type,resp);
		}
		
		public function getAssetPrimaryKeyColName(type:String):String{
			return _assetDefs[_assetDescriptions[type]].ASSET_DATA_TEMPLATE.PRIMARY_KEY;
		}
		
		public function isShortDate(type:String, colName:String):Boolean{
			var isShortDate:Boolean = false;
			for(var i:int=0;i<_assetDefs[_assetDescriptions[type]].ASSET_DATA_TEMPLATE.INV_COLUMNS.length;i++)
			{
				var obj:Object = _assetDefs[_assetDescriptions[type]].ASSET_DATA_TEMPLATE.INV_COLUMNS[i];
				if(obj.hasOwnProperty("SHORT_DATE") && obj["SHORT_DATE"])
					return true;
			}
			for(var j:int=0;j<_assetDefs[_assetDescriptions[type]].ASSET_DATA_TEMPLATE.INSP_COLUMNS.length;j++)
			{
				var obj2:Object = _assetDefs[_assetDescriptions[type]].ASSET_DATA_TEMPLATE.INSP_COLUMNS[j];
				if(obj2.hasOwnProperty("SHORT_DATE") && obj["SHORT_DATE"])
					return true;
			}
			return false;
		}
		
		public function getAssetById(id : int, type:String):BaseAsset
		{
			var asset:Object = _mdbm.getAssetById(id.toString(), type, _assetDefs[_assetDescriptions[type]].ASSET_DATA_TEMPLATE.PRIMARY_KEY);
			if (asset == null)
				return null;
			
			var returnVal:BaseAsset = mapDataToBaseAsset(asset, type);
			
			assignAssetSymbol(returnVal,type,null);
			return returnVal;
		}
		
		public function getBarElementById(id : int, type:String):BaseAsset
		{
			var barElement:Object = _mdbm.getAssetById(id.toString(), type, _barElementDefs[_barElementDescriptions[type]].BAR_ELEMENT_DATA_TEMPLATE.PRIMARY_KEY);
			if (barElement == null)
				return null;
			
			var returnVal:BaseAsset = mapDataToBaseAsset(barElement, type, false);
			
			//assignAssetSymbol(returnVal,type,null);
			return returnVal;
		}
		
		// Returns the properties for a bar element.  Used by the Element Edit functions
		public function getBarElementInvProperties(elem:Object, rteName:String):Object
		{
			var tmpElem:Object = new Object();
			tmpElem["REFPT"] = elem.secBegMile;
			tmpElem["ENDREFPT"] = elem.secEndMile;
			tmpElem["ID"] = elem.secID;
			tmpElem["ELEM_VALUE"] = elem.value;
			tmpElem["ELEM_DESC"] = elem.elemDesc;
			tmpElem["ROUTE"] = rteName;
			tmpElem["ROUTE_NAME"] = "";
			//tmpElem["STATUS"] = elem.status;
			return tmpElem;
		}
		
		public function getBarElementUIName(desc:String):String
		{
			var uiName:String = "";
			uiName = _barElementDefs[_barElementDescriptions[desc]].UI_NAME;
			return uiName;
		}
		
		/**
		 * returns a list of all local (cached) assets by the given route
		 * @param route the route to check out the assets from
		 * @see com.transcendss.transcore.sld.models.components.Route
		 * 
		 * @return an ArrayCollection of all matching BaseAsset intances in the local DB
		 */
		public function getAssetsByRoute(type:String, route:Route):ArrayCollection
		{
			var arrColl:ArrayCollection = new ArrayCollection(_mdbm.getAssetsByType(type,_assetDefs[_assetDescriptions[type]].ASSET_DATA_TEMPLATE.PRIMARY_KEY));
			var retArr:ArrayCollection = new ArrayCollection();
			
			for each (var throng:Object in arrColl)
			{
				var bastet:BaseAsset = mapDataToBaseAsset(throng, type);
				var val:Number = bastet.invProperties[bastet.fromMeasureColName].value;
				if (bastet.routeName == route.routeName 
					&& route.beginMi <= val
					&& route.endMi >= val)
				{
					assignAssetSymbol(bastet, type, null);
					retArr.addItem(bastet);
				}
			}
			
			return retArr;
		}
		
		/**
		 * returns a list of all local (cached) bar elements by the given route
		 * @param route the route to check out the assets from
		 * @see com.transcendss.transcore.sld.models.components.Route
		 * 
		 * @return an ArrayCollection of all matching BaseAsset intances in the local DB
		 */
		public function getBarElementsByRoute(type:String, route:Route):ArrayCollection
		{
			var arrColl:ArrayCollection = new ArrayCollection(_mdbm.getAssetsByType(type,_barElementDefs[_barElementDescriptions[type]].BAR_ELEMENT_DATA_TEMPLATE.PRIMARY_KEY));
			var retArr:ArrayCollection = new ArrayCollection();
			
			for each (var throng:Object in arrColl)
			{
				var begMile:Number = throng.REFPT;
				var endMile:Number = throng.ENDREFPT;
				if ((throng.ROUTE == route.routeName || throng.ROUTE_NAME == route.routeName)
					&& route.beginMi <= begMile
					&& route.endMi >= endMile)
				{
					retArr.addItem(throng);
				}
			}
			
			return retArr;
		}
		
		
		/**
		 * saves a given asset to the local database
		 * If an asset with a given id is already in the local database, it updates that asset. 
		 * @param asset the asset to save
		 * @return true if the asset was added, false if the asset was updated
		 */
		public function saveAsset(asset:BaseAsset):Boolean
		{
			if (getAssetById(asset.id, asset.description) == null)
			{
				_mdbm.addAsset(asset);
				return true;
			}
			else
				_mdbm.updateAsset(asset);
			return false;
		}
		
		/**
		 * saves a given bar element to the local database
		 * If an element with a given id is already in the local database, it updates that element. 
		 * @param barElement the element to save
		 * @return true if the element was added, false if the element was updated
		 */
		public function saveBarElement(barElement:BaseAsset, isNew:Boolean=false, isRetired:Boolean=false):Boolean
		{
			var tmpAsset:BaseAsset = getBarElementById(barElement.id, barElement.description);
			if (tmpAsset == null)
			{
				_mdbm.addBarElement(barElement, isNew, isRetired);
				return true;
			}
			else
			{
				// If the asset is new, delete it since there is nothing in the main db to retire
				if(tmpAsset.status == "NEW" && barElement.status == "RETIRED")
					_mdbm.deleteBarElement(tmpAsset);
				else
					_mdbm.updateBarElement(barElement);
			}
			return false;
		}
		
		// Used to get a bar element description from an attribute name
		public function getTypeFromAttName(attName:String):String
		{
			while(attName.indexOf(".") >= 0)
			{
				attName = attName.replace(".","");
			}
			while(attName.indexOf(" ") >= 0)
			{
				attName = attName.replace(" ","_");
			}
			return attName.toUpperCase();
		}
		
		
		//For the purpose of matching the asset to the proper drawstring (by subtype)
		//		private function getDrawstringURL(subType:String, subtypes:Array):String
		//		{
		//			var fileName:String = "";
		//			
		//			var i:int = parseInt(subType);
		//			if (i < 1)
		//				return null;
		//			if(subtypes[i - 1].DRAWING.DRAWSTRING != null && subtypes[i - 1].DRAWING.DRAWSTRING !== "")
		//				fileName = subtypes[i - 1].DRAWING.DRAWSTRING;
		//			else
		//				fileName = subtypes[i - 1].DRAWING.URL;
		//
		//			return fileName;//jsonParseDrawstring(fileName);
		//		}
		
		private function getAssetSubTypeDef(assetType:String, subtype:String):Object{
			var subTyArr:Array = _assetDefs[assetType].DEFINITION.SUBTYPES;
			var subTyObject:Object = null;
			for each(var subTypO:Object in subTyArr)
			{
				if(String(subTypO.SUBTYPE).toUpperCase() == subtype.toUpperCase())
					subTyObject =  subTypO;
			}
			if(subTyObject)
			return subTyObject;
			else
				return subTyArr[0];//if the type is not found return first one in list as defualt
		}
		
		private function getAssetSubTypeIndex(assetType:String, subtype:String):int{
			var subTyArr:Array = _assetDefs[assetType].DEFINITION.SUBTYPES;
			var subTyIndex:int = -1;
			for (var i:int=0;i<  subTyArr.length;i++)
			{
				var subTypO:Object = subTyArr[i];
				if(String(subTypO.SUBTYPE).toUpperCase() == subtype.toUpperCase())
					subTyIndex =  i;
			}
			if(subTyIndex!=-1)
				return subTyIndex;
			else
				return 0;
		}
		
		public function assignAssetSymbol(asset:BaseAsset, type:String, resp:IResponder = null, multiples:Boolean=false):void
		{
			//var fileName :String = getDrawstringURL(asset.subType.toString(), _assetDefs[asset.assetType].DEFINITION.SUBTYPES);
			
			//else
			//trace("No culvert");
			var img:Image;
			if (asset.subType =="")
				return;
			
			var drawString:Object;
			var drawing:Object;
			if(asset.invProperties[asset.typeKey] && asset.invProperties[asset.typeKey].value as String === "D10-1")
				return;
			if (type == "SIGN" || type == "5" || asset.description =='SIGN')
			{
				if(multiples || asset.invProperties["NUM_OF_SIGNS"] && new Number(asset.invProperties["NUM_OF_SIGNS"].value)  >1)
					drawString = _imageMan.getById("multiples");
				else
					drawString = _imageMan.getById( asset.invProperties[asset.typeKey].value as String);
				
				drawing = _assetDefs[asset.assetType].DEFINITION.SUBTYPES[0].DRAWING;
			}
			else
			{
				var assetSubty:Object = getAssetSubTypeDef(asset.assetType,asset.subType);
				if(_assetDefs[asset.assetType].DEFINITION.SUBTYPES.length > 0)
				{
					var altProperty:String = assetSubty.DRAWING.ALTERNATE_PROPERTY;
					
					if (altProperty)
					{
						var propertyVal:String = asset.invProperties[altProperty] ? asset.invProperties[altProperty].value : asset.inspProperties[altProperty].value;
						if(propertyVal && propertyVal !== "")
						{
							drawString = _sprites[asset.description + "-" + asset.subType][new Number(propertyVal) - 1];
						}
					}
					if (_sprites[type] && drawString == null)
						drawString = _sprites[type][getAssetSubTypeIndex(asset.assetType,asset.subType) ];
					else if (drawString == null)
						drawString = _sprites[_assetDefs[type].DESCRIPTION][getAssetSubTypeIndex(asset.assetType,asset.subType)];	
				}
				
				drawing = assetSubty.DRAWING;				
			}
			
			if (drawString is Bitmap)
			{
				asset.symbol = new AssetSymbol(asset);
				asset.symbol.usesPic = true;
				var drawBit:Bitmap = drawString as Bitmap;//drawString as Bitmap;
				drawBit.smoothing = true;
				asset.symbol.addChild(new Bitmap(drawBit.bitmapData.clone()));
				asset.symbol.stdHeight = drawing.HEIGHT;
				asset.symbol.stdWidth = drawing.WIDTH;
				if (drawing.SCALE != null && drawing.SCALE.toUpperCase() == "TRUE")
				{
					var ratio:Number = drawBit.width / drawBit.height;
					asset.symbol.getChildAt(0).height = drawing.HEIGHT;
					asset.symbol.getChildAt(0).width = drawing.HEIGHT * ratio;
					asset.symbol.stdHeight = drawing.HEIGHT;
					asset.symbol.stdWidth = drawing.HEIGHT * ratio;
				}
				asset.symbol.centerH = drawing.CENTER_HORIZONTALLY === "True" ? true : false;
				asset.symbol.centerV = drawing.CENTER_VERTICALLY === "True" ? true : false;
				asset.symbol.placement_y = drawing.PLACEMENT_Y;
				asset.symbol.drawSelectRect();
				if(_assetDefs[asset.assetType].CAPTURE_AVAILABLE != null && _assetDefs[asset.assetType].CAPTURE_AVAILABLE == "true")
				{
					asset.symbol.selectRect.addEventListener(MouseEvent.CLICK, onSpriteClick);
					asset.symbol.buttonMode = true;
					asset.symbol.useHandCursor = true;
				}
				//				if(asset.description === "INT")
				//				{
				//					var bmd:BitmapData = (drawString as Bitmap).bitmapData.clone();
				//					asset.symbol.removeChildAt(0);
				//					asset.symbol.addChild(new Bitmap(bmd));
				//					asset.symbol.addEventListener(MouseEvent.RIGHT_CLICK, onIntDoubleClick);
				//				}
				
				//asset.symbol.addEventListener(MouseEvent.CLICK, onSpriteClick);
				//asset.symbol.name = String(asset.invProperties[vName])+ " ft";
				
			}
			else
			{
				asset.symbol = buildAssetSymbol(asset, drawString.SHAPES as Array, drawString.ROTATION, _assetDefs[asset.assetType].ASSET_DATA_TEMPLATE.LENGTH_COLUMN,drawing.TEXT, drawing.TEXT_COLOR);
				
				asset.symbol.placement_y = drawing.PLACEMENT_Y;
				asset.symbol.centerH = drawing.CENTER_HORIZONTALLY === "True" ? true : false;
				asset.symbol.centerV = drawing.CENTER_VERTICALLY=== "True" ? true : false;
			}
			
			if (_assetDefs[asset.assetType].hasOwnProperty("TIP_FIELD"))
			{
				var intLnSprite:Tippable = new Tippable(Tippable.SLD, FlexGlobals.topLevelApplication.GlobalComponents.stkDiagram);
				intLnSprite.name = asset.invProperties[_assetDefs[asset.assetType].TIP_FIELD].value;
				intLnSprite.tipText = asset.invProperties[_assetDefs[asset.assetType].TIP_FIELD].value;
				
				var featureShp:Shape = new Shape();
				featureShp.graphics.beginFill(0x000000, 0.0);
				featureShp.graphics.drawRect(0, 0, asset.symbol.selectRect.width, asset.symbol.selectRect.height);
				featureShp.graphics.endFill();
				intLnSprite.addChild(featureShp);			
				intLnSprite.buttonMode = true;
				intLnSprite.useHandCursor = true;
				
				asset.symbol.addChild(intLnSprite);
			}
			
			//if(drawing.TEXT != null && drawing.TEXT != "")
			//{
			//asset.symbol.addText(drawing.TEXT, drawing.TEXT_COLOR);
			
			//}
			if(asset.symbol.baseAsset.assetType != "8")
				asset.symbol.cacheAsBitmap = true;	//...
			
			if (resp != null)
				resp.result({ftName:asset.description, bAsset:asset});
		}
		
		private function onDoubleClick(event:MouseEvent):void
		{
			/*var sym:AssetSymbol = event.currentTarget as AssetSymbol;
			sym.x += 100;
			trace(sym.parent.numChildren);
			var array:Array = new Array();
			for(var i:int = 0; i< sym.parent.numChildren;i++)
			{
			array.push(sym.parent.getChildAt(i));
			}
			trace(array);*/
			
		}
		
		/**
		 * This code may come in handy when trying to optimize drawing sprites
		 */
		private function drawString(target:AssetSymbol,text:String,x:Number,y:Number):void {
			var tf:TextField = new TextField();
			tf.text = text; 
			var bmd:BitmapData = new BitmapData(tf.width,tf.height);
			bmd.draw(tf);
			var mat:Matrix= new Matrix();
			mat.translate(x,y);
			var bmp:Bitmap = new Bitmap(bmd);
			target.addChild(bmp);
			bmd.dispose();
		}
		
		//We can probably get rid of this. It was meant to be used with Inventory Diagram
		//		public function copyAndScaleSymbol(asset:BaseAsset, ratio:Number):AssetSymbol
		//		{
		//			//var fileName :String = getDrawstringURL(asset.subType.toString(), _assetDefs[asset.assetType].DEFINITION.SUBTYPES);
		//			var img:Image;
		//			var type:String = asset.description;
		//			var symbol:AssetSymbol;
		//			
		//			if (asset.subType < 1)
		//				return null;
		//			
		//			var drawString:Object;
		//			if (_sprites[type])
		//				drawString = _sprites[type][asset.subType - 1];
		//			else
		//				drawString = _sprites[_assetDefs[type].DESCRIPTION][asset.subType - 1];
		//			
		//			var drawing:Object = _assetDefs[asset.assetType].DEFINITION.SUBTYPES[asset.subType - 1].DRAWING;
		//			if (drawString is Bitmap)
		//			{
		//				symbol = new AssetSymbol(asset);
		//				symbol.addChild(drawString as Bitmap);
		//				symbol.stdHeight = drawing.HEIGHT;
		//				symbol.stdWidth = drawing.WIDTH;
		//				symbol.centerH = drawing.CENTER_HORIZONTALLY === "True" ? true : false;
		//				symbol.centerV = drawing.CENTER_VERTICALLY === "True" ? true : false;
		//			}
		//			else
		//			{
		//				symbol = buildAssetSymbol(asset, drawString.SHAPES as Array, drawString.ROTATION, drawString.VARIABLE_NAME,drawing.TEXT, drawing.TEXT_COLOR, ratio);
		//				
		//				symbol.placement_y = drawing.PLACEMENT_Y;
		//				symbol.centerH = drawing.CENTER_HORIZONTALLY === "True" ? true : false;
		//				symbol.centerV = drawing.CENTER_VERTICALLY=== "True" ? true : false;
		//			}
		//			//if(drawing.TEXT != null && drawing.TEXT != "")
		//			//{
		//				//symbol.addText(drawing.TEXT, drawing.TEXT_COLOR);
		//				
		//			//}
		//			if(asset.symbol.baseAsset.assetType != "8")
		//				symbol.cacheAsBitmap = true;
		//			return symbol;
		//		}
		//		
		public function assetSymLoaded(eventResObj:Object,type:String, resp:IResponder,asset:BaseAsset):void
		{
			var jsonString : String = eventResObj as String;
			
			var drawStringArray:Object;
			var drawStringObject : Object = JSON.parse(jsonString);//jsonString);
			drawStringArray = drawStringObject.SHAPES as Array;
			var assetSubty:Object = getAssetSubTypeDef(asset.assetType,asset.subType);
			//var asset:BaseAsset = _currentAsset;
			
			//asset.symbol = buildAssetSymbol(asset, drawStringArray, drawStringObject.ROTATION, drawStringObject.VARIABLE_NAME);
			
			//			asset.symbol.stdWidth = drawStringObject.WIDTH;
			//			asset.symbol.stdHeight = drawStringObject.HEIGHT;
			
			asset.symbol.placement_y = assetSubty.DRAWING.PLACEMENT_Y;
			asset.symbol.centerH = assetSubty.DRAWING.CENTER_HORIZONTALLY === "True"? true:false;
			asset.symbol.centerV = assetSubty.DRAWING.CENTER_VERTICALLY=== "True"? true:false;
			asset.symbol.usesPic = false;
			resp.result({ftName:type, bAsset:asset})
		}
		
		private function imageFailed(event:IOErrorEvent):void  
		{  
			//Alert.show("Image Loading Failed");  
		}
		
		private function buildAssetSymbol(asset:BaseAsset, drawStringArray:Object, rotation:Number, vName:String, rampText:String, textColor:uint, ratio:Number = -1):AssetSymbol
		{
			var symbol:AssetSymbol = new AssetSymbol(asset);
			//symbol.cacheAsBitmap = true;
			//var g : Graphic = symbol.graphics;
			var rshape:Shape = null;
			var shapes:Array = drawStringArray as Array;
			var rlsym :RedLineSymbol;
			
			var ofs:int = 0;
			var len:int;
			var maxx: int = 0;
			var maxy: int = 0;
			var minx:int = int.MAX_VALUE;
			var miny:int = int.MAX_VALUE;
			for each (var shape:Object in shapes)
			{	
				var now:Date = new Date();
				//var inspVal:Object = asset.inspProperties["MODIFY_DT"].value ? asset.inspProperties["MODIFY_DT"].value : asset.inspProperties["CREATE_DT"].value;
				//var inspVal:Object = asset.inspProperties["INSP_DT"].value;
				if (asset.inspProperties["INSP_DT"] && Math.ceil((now.time - Date.parse(asset.inspProperties["INSP_DT"].value))/(1000*60*60*24)) > FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.inspDays)
				{
					shape.COLOR = 16711680; // Red
				}
				else
				{
					shape.COLOR = 0x000000;
				}
				
				if(shape.VARIABLE_VAL != null && shape.VARIABLE_VAL === "True")
				{
					var stick:StickDiagram = FlexGlobals.topLevelApplication.GlobalComponents.stkDiagram;
					if(ratio == -1)
					{
						var unit:String = getEventLengthUnits(asset.description);
						if(unit.toUpperCase()=="MI")
							len = Converter.scaleMileToPixel(Number(asset.invProperties[vName].value), stick.scale());
						else if(unit.toUpperCase()=="FT")
							len = Converter.scaleMileToPixel(Converter.feetToMiles(Number(asset.invProperties[vName].value)), stick.scale());
						else
							FlexGlobals.topLevelApplication.TSSAlert("Length unit not set in asset def");
					}
					else
						len = (new Number(asset.invProperties[vName].value)) * ratio;
					switch (shape.D_REDLINE_TYPE_CODE)
					{
						case 1002:
							rlsym = new RedLineSymbol(rshape, shape.D_REDLINE_TYPE_CODE,shape.ORIGIN_X, shape.ORIGIN_Y, shape.COORD.x + len, shape.COORD.y, shape.REDLINE_SIZE, null, 0, null,"",shape.COLOR);
							
							break;
						
						case 1001:
							//if(shape.VARIABLE_VAL.WIDTH != null)
							rlsym = new RedLineSymbol(rshape, shape.D_REDLINE_TYPE_CODE, shape.ORIGIN_X, shape.ORIGIN_Y, shape.COORD.x+ len-shape.ORIGIN_X, shape.COORD.y - shape.ORIGIN_Y, shape.REDLINE_SIZE, null, 0, null,"",shape.COLOR);
							//							else
							//								rlsym = new RedLineSymbol(shape.D_REDLINE_TYPE_CODE, shape.ORIGIN_X, shape.ORIGIN_Y, shape.COORD.x, shape.COORD.y + len, shape.REDLINE_SIZE, null, 0, null,"",shape.COLOR);
							break;
						case 1000:
							rlsym = new RedLineSymbol(rshape, shape.D_REDLINE_TYPE_CODE, shape.ORIGIN_X - len, shape.ORIGIN_Y - len, 0, 0, shape.REDLINE_SIZE, null, len, null, "", shape.COLOR, shape.D_FILLSTYLE_CODE?shape.D_FILLSTYLE_CODE:-1);
							break;
						
						
					}
					if(shape.D_REDLINE_TYPE_CODE != 1000)
					{
						if (shape.ORIGIN_X > maxx)
							maxx = shape.ORIGIN_X;
						else if (shape.COORD.x+ len > maxx)
							maxx = shape.COORD.x+ len;
						if (shape.ORIGIN_Y > maxy)
							maxy = shape.ORIGIN_Y;
						else if (shape.COORD.y > maxy)
							maxy =shape.COORD.y;
						if (shape.ORIGIN_X <minx)
							minx = shape.ORIGIN_X;
						else if (shape.COORD.x+ len < minx)
							minx = shape.COORD.x+ len;
						if (shape.ORIGIN_Y < miny)
							miny = shape.ORIGIN_Y;
						else if (shape.COORD.y < miny)
							miny = shape.COORD.y;
						ofs = len;
					}
					
				}
				else
				{
					switch (shape.D_REDLINE_TYPE_CODE)
					{
						case 1003:
							rlsym = new RedLineSymbol(rshape, shape.D_REDLINE_TYPE_CODE, shape.ORIGIN_X + ofs, shape.ORIGIN_Y, 0, 0, shape.REDLINE_SIZE, null, shape.RADIUS, null, "", shape.COLOR);
							break;
						case 1002: 
							rlsym = new RedLineSymbol(rshape, shape.D_REDLINE_TYPE_CODE, shape.ORIGIN_X + ofs, shape.ORIGIN_Y, shape.COORD.x + ofs, shape.COORD.y, shape.REDLINE_SIZE, null, 0, null, "", shape.COLOR);
							break;
						case 1001:
							rlsym = new RedLineSymbol(rshape, shape.D_REDLINE_TYPE_CODE, shape.ORIGIN_X + ofs, shape.ORIGIN_Y, shape.COORD.x+ ofs - shape.ORIGIN_X, shape.COORD.y - shape.ORIGIN_X, shape.REDLINE_SIZE, null, 0, null,"",shape.COLOR);
							break;
						case 1000:
							var fcode:Number =(shape.D_FILLSTYLE_CODE!=null)?shape.D_FILLSTYLE_CODE:-1;
							rlsym = new RedLineSymbol(rshape, shape.D_REDLINE_TYPE_CODE, shape.ORIGIN_X + ofs, shape.ORIGIN_Y, 0, 0, shape.REDLINE_SIZE, null, shape.RADIUS, null, "", shape.COLOR,fcode );
							break;
					}
					if(shape.D_REDLINE_TYPE_CODE != 1000 && shape.D_REDLINE_TYPE_CODE != 1003)
					{
						if (shape.ORIGIN_X > maxx)
							maxx = shape.ORIGIN_X;
						else if (shape.COORD.x+ ofs > maxx)
							maxx = shape.COORD.x+ ofs;
						if (shape.ORIGIN_Y > maxy)
							maxy = shape.ORIGIN_Y;
						else if(shape.COORD.y > maxy)
							maxy =shape.COORD.y;
						if (shape.ORIGIN_X <minx)
							minx = shape.ORIGIN_X;
						else if (shape.COORD.x+ ofs < minx)
							minx = shape.COORD.x+ ofs;
						if (shape.ORIGIN_Y < miny)
							miny = shape.ORIGIN_Y;
						else if (shape.COORD.y < miny)
							miny = shape.COORD.y;
					}else if(shape.D_REDLINE_TYPE_CODE == 1000)
					{
						if(shape.ORIGIN_X+shape.RADIUS > maxx)
							maxx = shape.ORIGIN_X+shape.RADIUS;
						else if(shape.ORIGIN_X-shape.RADIUS>maxx)
							maxx = shape.ORIGIN_X-shape.RADIUS;
						maxy = findMax(shape.ORIGIN_Y+shape.RADIUS, shape.ORIGIN_Y-shape.RADIUS, maxy);
						minx = findMin(shape.ORIGIN_X-shape.RADIUS, shape.ORIGIN_X+shape.RADIUS, minx);
						miny = findMin(shape.ORIGIN_Y+shape.RADIUS, shape.ORIGIN_Y-shape.RADIUS, miny);
						
					}else if(shape.D_REDLINE_TYPE_CODE == 1003)
					{
						maxx = findMax(shape.ORIGIN_X, shape.ORIGIN_X - shape.RADIUS, maxx);
						maxy = findMax(shape.ORIGIN_Y - shape.RADIUS, shape.ORIGIN_Y + shape.RADIUS, maxy);
						minx = findMin(shape.ORIGIN_X, shape.ORIGIN_X - shape.RADIUS, minx);
						miny = findMin(shape.ORIGIN_Y - shape.RADIUS, shape.ORIGIN_Y + shape.RADIUS, miny);
					}
					
				}	
				
				rshape = rlsym.redShape;
				//temp.addChild(rlsym);
			}
			
			/*while(temp.numChildren != 0)
			{
			rlsym = temp.getChildAt(0) as RedLineSymbol;
			symbol.addChild(rlsym);
			}*/
			
			symbol.graphics.copyFrom(rshape.graphics);
			if(asset.symbol.baseAsset.assetType != "8") //Turn off the cacheAsBitmap for GuardRail
				symbol.cacheAsBitmap = true;
			symbol.rotation += rotation;
			// assumes rotations of strictly 90 degrees
			if (symbol.rotation != 0)
			{
				var max:int = maxy;
				var min:int = miny;
				maxy = maxx;
				miny = minx;
				maxx = max;
				minx = min;
			}
			
			symbol.stdHeight = Math.max(Math.abs(maxy-miny),15);
			symbol.stdWidth = Math.max(Math.abs(maxx - minx),15);
			if(rampText != null && rampText != "")
			{
				symbol.addText(rampText, textColor);
				
			}
			symbol.drawSelectRect();
			
			//symbol.addEventListener(MouseEvent.CLICK, onSpriteClick);
			if(_assetDefs[asset.assetType].CAPTURE_AVAILABLE != null && _assetDefs[asset.assetType].CAPTURE_AVAILABLE == "true")
			{
				symbol.selectRect.addEventListener(MouseEvent.CLICK, onSpriteClick);	
				symbol.buttonMode = true;
				symbol.useHandCursor = true;
			}
			//symbol.name = String(asset.invProperties[vName])+ " ft";
			
			
			symbol.usesPic = false;
			
			return symbol;
		}
		
		private function findMax(a:int, b:int, max:int):int
		{
			if(a> b && a > max)
				max = a;
			else if(b > max)
				max = b;
			return max;
		}
		
		private function findMin(a:int, b:int, min:int):int
		{
			if(a< b && a<min)
				min = a;
			else if(b<min)
				min = b;
			return min;
		}
		
		
		protected function onSpriteClick(event:MouseEvent):void
		{
			var selectRect:Sprite = event.currentTarget as Sprite;
			var symbol:AssetSymbol = selectRect.parent as AssetSymbol;
			
			var selectionEvent:AssetManagerEvent = new AssetManagerEvent( AssetManagerEvent.ASSET_SELECTED_EVENT,true,true,null,symbol.baseAsset);
			
			_dispatcher.dispatchEvent(selectionEvent);
			
			
		}
		
		public function clearAssets():void
		{
			for each (var prop:Object in _assetDefs)
			{
				_mdbm.clearAssetTable(prop.DESCRIPTION);
			}
			_mdbm.clearGeotagsTable();
		}
		
		public function clearBarElements():void
		{
			for each (var prop:Object in _barElementDefs)
			{
				_mdbm.clearBarElementTable(prop.DESCRIPTION);
			}
			//_mdbm.clearGeotagsTable();
		}
		
		public function clearCachedRoutes():void
		{
			_mdbm.clearCachedRoutes();
		}
		
		public function cacheRoute(cRoute:CachedRoute, cStkElements:CachedElement, cInvElements:CachedElement):void
		{
			var cID:Number = _mdbm.addCachedRoute(cRoute);
			_mdbm.addElement(cID, cStkElements);
			_mdbm.addElement(cID, cInvElements);
		}
		
		public function cacheDDOTRoute(cRoute:CachedRoute, cStkElements:CachedElement, cInvElements:CachedElement,signElement:CachedElement, timeResElement:CachedElement, inspElement:CachedElement, linkElement:CachedElement):void
		{
			var cID:Number = _mdbm.addCachedRoute(cRoute);
			_mdbm.addElement(cID, cStkElements);
			_mdbm.addElement(cID, cInvElements);
			_mdbm.addElement(cID,signElement);
			_mdbm.addElement(cID,timeResElement);
			_mdbm.addElement(cID,inspElement);
			_mdbm.addElement(cID,linkElement);
		}
		
		public function getFormClass(assetDesc:String):String
		{
			return _assetDefs[assetDescriptions[assetDesc]].FORM_CLASS as String;
		}
		
		
		
		public function getAssetSyncHeaders(assetDesc:String):String
		{
			if(_assetDefs[assetDescriptions[assetDesc]].hasOwnProperty("SYNC_COL_LIST"))
				return _assetDefs[assetDescriptions[assetDesc]].SYNC_COL_LIST;
			else
				return "";
		}
		
		public function getEventLayerID(assetDesc:String):Number
		{
			if(_assetDefs[assetDescriptions[assetDesc]].hasOwnProperty("EVENT_LAYER_ID"))
				return _assetDefs[assetDescriptions[assetDesc]].EVENT_LAYER_ID;
			else
				return -1;
		}
		
		public function getEventLayerIDByType(assetTy:String):Number
		{
			if(_assetDefs[assetTy].hasOwnProperty("EVENT_LAYER_ID"))
				return _assetDefs[assetTy].EVENT_LAYER_ID;
			else
				return -1;
		}
		
		
		public function getEventLengthUnits(assetDesc:String):String
		{
			if(_assetDefs[assetDescriptions[assetDesc]].hasOwnProperty("LENGTH_UNIT"))
				return _assetDefs[assetDescriptions[assetDesc]].LENGTH_UNIT;
			else
				return "";
		}
		
		// We don't want this in the long run.
		public function get mdbm():MAVRICDBManager
		{
			return _mdbm;
		}
		
		public function cacheGeotags(gtags:Array,showAlert:Boolean):void
		{
			var tempGTArr:Array = new Array();
			
			if (gtags != null) //make sure the object is not null before using the length
			{
				for( var i:int =0; i<gtags.length;i++)
				{
					var begM:Number = 0;
					var endM:Number = 0;
					//{"size":25646,"isInspection":false,"attachmentId":964,"name":"1419349071036.wav","objectId":57922,"contentType":"audio/x-wav","fromMeasure":0.108,"type":"support","routeId":"11000132"}
					if(gtags[i].hasOwnProperty("END_MILE"))
						endM = Number(gtags[i].END_MILE);
					if(gtags[i].hasOwnProperty("BEGIN_MILE"))
						begM = Number(gtags[i].BEGIN_MILE);
					
					var tmpGT:GeoTag = new GeoTag(Number(gtags[i].ATTACH_ID), String(gtags[i].ASSET_TYPE), String(gtags[i].ROUTE_NAME),String(gtags[i].ASSET_BASE_ID),String(gtags[i].ASSET_ID)
						,new Number(gtags[i].IS_INSP),begM,endM,String(gtags[i].IMAGE_FILENAME),String(gtags[i].VIDEO_FILENAME),String(gtags[i].VOICE_FILENAME),String(gtags[i].TEXT_MEMO));
					
					
					if((tmpGT.video_file_name!=null && tmpGT.video_file_name.length>0)||(tmpGT.voice_file_name!=null && tmpGT.voice_file_name.length>0)||(tmpGT.image_file_name!=null && tmpGT.image_file_name.length>0))
						tempGTArr.push({gtag:tmpGT, url:gtags[i].URL});
					//add gt info to local DB			
					mdbm.addGeoTag(tmpGT, true);
					
				}
			}
			if(tempGTArr.length<=0 && showAlert)
			{				
				FlexGlobals.topLevelApplication.TSSAlert("Route saved to local database");
				FlexGlobals.topLevelApplication.setBusyStatus(false);
				return;
			}
			for(i =0; i<tempGTArr.length;i++)
			{
				//download each file and save locally
				downloadGeotag(new GeotagsManager().ConvertGeotags(tempGTArr[i].gtag,tempGTArr[i].url,"server",false),i, tempGTArr.length-1, showAlert);
			}
		}
		
		public function cacheDDOTGeotags(gtags:Array,asset:Object,layerID:String, parentObject:BaseAsset=null, assetType:String=""):void
		{
			
			var tempAsset:BaseAsset =null;
			
			
			if (gtags != null) //make sure the object is not null before using the length
			{
				if(asset is BaseAsset)
					tempAsset = asset as BaseAsset;
				
				for( var i:int =0; i<gtags.length;i++)
				{
					FlexGlobals.topLevelApplication.incrementEventStack();	
					var begM:Number = 0;
					var endM:Number = 0;
					var assetBaseID:String = "";
					var localAssetID:String = "";
					var assetTypeID:String = "";
					var assetLabelText:String = "";
					var isInsp:int = 0;
					var routeName:String ="";
					var mileP:Number =0;
					var image_fileName:String = "";
					var video_fileName:String = "";
					var voice_fileName:String = "";
					var objID:String = "";
					var attachID:String = gtags[i]["id"];
					if(tempAsset)
					{
						assetBaseID = "" + tempAsset.id;
						localAssetID = "" + tempAsset.id;
						assetTypeID = tempAsset.assetType;
						assetLabelText = "Support -- " + localAssetID;
						isInsp = 0;
						routeName = tempAsset.routeName;
						objID =String(tempAsset.invProperties["OBJECTID"].value);
						mileP= tempAsset.invProperties[tempAsset.fromMeasureColName].value;
					}
					else if (assetType=='SIGN')
					{
						assetBaseID = "" + parentObject.id;
						localAssetID = "" + asset['SIGNID'];
						assetTypeID = "SIGN";
						assetLabelText = "Sign -- " + localAssetID;
						isInsp = 0;
						routeName = parentObject.routeName;
						objID =String(asset["OBJECTID"]);
						mileP= parentObject.invProperties[parentObject.fromMeasureColName].value;
					} 
					else if (assetType=='INSP')
					{
						assetBaseID = "" +  parentObject.id;
						routeName = parentObject.routeName;
						objID =String(asset["OBJECTID"]);
						mileP= parentObject.invProperties[parentObject.fromMeasureColName].value;
						if (asset['POLEID'] != null)
						{
							localAssetID = "" + asset['POLEID'];
							assetLabelText = "Support -- " + localAssetID;
							assetTypeID = parentObject.assetType;
						}
						else
						{
							localAssetID = "" + asset['SIGNID'];
							assetLabelText = "Sign -- " + localAssetID;
							assetTypeID = "SIGN";
						}
						
						
						isInsp = 1;
					}
					
					
					
					//	var fileName:String = new Date().time + ".3gp";
					
					var tmpGT:GeoTag = new GeoTag();
					tmpGT.cached_route_id = routeName ;
					tmpGT.begin_mile_point = mileP;
					tmpGT.end_mile_point = 0;
					
					
					
					
					tmpGT.image_file_name = String(gtags[i].contentType).toLowerCase().indexOf("image")!=-1 ? String(gtags[i].name):"";
					tmpGT.video_file_name = String(gtags[i].contentType).toLowerCase().indexOf("video")!=-1 ? String(gtags[i].name):"";
					tmpGT.voice_file_name = String(gtags[i].contentType).toLowerCase().indexOf("audio")!=-1 ? String(gtags[i].name):"";
					
					tmpGT.asset_base_id = assetBaseID;
					tmpGT.local_asset_id = localAssetID;
					tmpGT.is_insp = isInsp;
					tmpGT.asset_ty_id = assetTypeID;;
					
					//geoTagsArr.addItem(tmpGT);
					//add gt info to local DB			
					mdbm.addGeoTag(tmpGT, true);
					
					var url:String = FlexGlobals.topLevelApplication.GlobalComponents.agsManager.getAttachmentByIDUrl(layerID, objID, attachID);
					downloadGeotag(new GeotagsManager().ConvertGeotags(tmpGT,url,"server",false), i, gtags.length-1, true);
				}
			}
			FlexGlobals.topLevelApplication.decrementEventStack();
			
		}
		
		
		public function cacheDDOTGeotags2(gtags:Array):void
		{
			
			if (gtags != null) //make sure the object is not null before using the length
			{
				
				for( var i:int =0; i<gtags.length;i++)
				{
					FlexGlobals.topLevelApplication.incrementEventStack();	
					var begM:Number = 0;
					var endM:Number = 0;
					var assetBaseID:String = "";
					var localAssetID:String = "";
					var assetTypeID:String = "";
					var assetLabelText:String = "";
					var isInsp:int = 0;
					var routeName:String ="";
					var mileP:Number =0;
					var image_fileName:String = "";
					var video_fileName:String = "";
					var voice_fileName:String = "";
					var objID:String = "";
					var attachID:String = gtags[i]["attachmentId"];
					if(gtags[i].type=="support" && !gtags[i].isInspection)
					{
						
						assetTypeID = "1";
						assetLabelText = "Support -- " + localAssetID;
						
						isInsp = 0;
						
					}
					else if (gtags[i].type=='SIGN' && !gtags[i].isInspection)
					{
					
						assetTypeID = "SIGN";
						assetLabelText = "Sign -- " + localAssetID;
						isInsp = 0;
						
					} 
					else if (gtags[i].isInspection)
					{
						
						if (gtags[i].type=="support")
						{
							
							assetLabelText = "Support -- " + localAssetID;
							assetTypeID = "1";
						}
						else
						{
							assetLabelText = "Sign -- " + localAssetID;
							assetTypeID = "SIGN";
						}
						
						
						isInsp = 1;
					}
					
					assetBaseID = "" + gtags[i].objectId;
					localAssetID = "" + gtags[i].objectId;
					assetTypeID = "1";
					assetLabelText = "Support -- " + localAssetID;
					isInsp = 0;
					routeName = gtags[i].routeId;
					objID =String(gtags[i].objectId);
					mileP= gtags[i].fromMeasure;
					
					//	var fileName:String = new Date().time + ".3gp";
					
					var tmpGT:GeoTag = new GeoTag();
					tmpGT.cached_route_id = routeName ;
					tmpGT.begin_mile_point = mileP;
					tmpGT.end_mile_point = 0;
					
					
					
					
					tmpGT.image_file_name = String(gtags[i].contentType).toLowerCase().indexOf("image")!=-1 ? String(gtags[i].name):"";
					tmpGT.video_file_name = String(gtags[i].contentType).toLowerCase().indexOf("video")!=-1 ? String(gtags[i].name):"";
					tmpGT.voice_file_name = String(gtags[i].contentType).toLowerCase().indexOf("audio")!=-1 ? String(gtags[i].name):"";
					
					tmpGT.asset_base_id = assetBaseID;
					tmpGT.local_asset_id = localAssetID;
					tmpGT.is_insp = isInsp;
					tmpGT.asset_ty_id = assetTypeID;;
					
					//geoTagsArr.addItem(tmpGT);
					//add gt info to local DB			
					mdbm.addGeoTag(tmpGT, true);
					
					var url:String = "";
					var layerID:String="";
					
					if(assetTypeID =="1" && isInsp==0)
						layerID = String(getEventLayerID("SUPPORT"));
					else if(assetTypeID =="SIGN" && isInsp==0)
						layerID = FlexGlobals.topLevelApplication.GlobalComponents.recordManager.signEventLayerID();
					else
						layerID = FlexGlobals.topLevelApplication.GlobalComponents.recordManager.inspectionEventLayerID();
					
						url = FlexGlobals.topLevelApplication.GlobalComponents.agsManager.getAttachmentByIDUrl(layerID, objID, attachID);
					downloadGeotag(new GeotagsManager().ConvertGeotags(tmpGT,url,"server",false), i, gtags.length-1, true);
				}
			}
			FlexGlobals.topLevelApplication.decrementEventStack();
			
		}
		
		/**
		 * Download the file realted to the TSSPicture/TSSVoice/TSSVideo that is passed in, to the local geotags folder 
		 * @param TSSObj - Type TSSPicture, TSSVoice or TSSVideo
		 * 
		 */
		public static function downloadGeotag(TSSObj:*,currentDwldIndex:int,maxDwnldLength:int, showAlert:Boolean):void
		{
			var sourceURL:String ="";
			var fileName:String ="";
			
			if (TSSObj is TSSPicture)
			{
				sourceURL = (TSSObj as TSSPicture).sourceURL;
				fileName =  (TSSObj as TSSPicture).label;
			}
			else if (TSSObj is TSSVideo)
			{
				sourceURL = (TSSObj as TSSVideo).filePath;
				fileName =  (TSSObj as TSSVideo).label;
			}
			else if (TSSObj is TSSAudio)
			{
				sourceURL = (TSSObj as TSSAudio).sourceURL;
				fileName =  (TSSObj as TSSAudio).label;
			}
			
			if (sourceURL.substring(0, 4) == "http") 
			{
				
				var URLLdr:URLLoader = new URLLoader();
				URLLdr.dataFormat = URLLoaderDataFormat.BINARY;
				
				URLLdr.addEventListener(Event.COMPLETE, 
					function(e:Event):void { 
						var fTemp:File = new File(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.geotagUrl + fileName);
						//						var fTemp:File = new File(BaseConfigUtility.get("geotags_folder") + fileName);
						var fsTemp:FileStream = new FileStream();
						fsTemp.open(fTemp, FileMode.WRITE);
						
						var fileData:ByteArray =URLLdr.data;
						fsTemp.writeBytes(fileData, 0, 0);
						fsTemp.close();
						//						if(currentDwldIndex==maxDwnldLength && showAlert && FlexGlobals.topLevelApplication.attachmentDownloadError)
						//						{
						//							FlexGlobals.topLevelApplication.setBusyStatus(false);
						//							FlexGlobals.topLevelApplication.TSSAlert("Route saved to local database.\n Attachment download errors encountered");
						//						}
						//						else if(currentDwldIndex==maxDwnldLength && showAlert && !FlexGlobals.topLevelApplication.attachmentDownloadError)
						//						{
						//							FlexGlobals.topLevelApplication.TSSAlert("Route saved to local database");
						//							FlexGlobals.topLevelApplication.setBusyStatus(false);
						//						}
						FlexGlobals.topLevelApplication.decrementEventStack();				
						//						
						
					});
				URLLdr.addEventListener(IOErrorEvent.IO_ERROR, 
					function(e:Event):void { 
						
						//						if(currentDwldIndex==maxDwnldLength && showAlert)
						//						{
						//							FlexGlobals.topLevelApplication.TSSAlert("Route saved to local database.\n Attachment download errors encountered");
						//							FlexGlobals.topLevelApplication.setBusyStatus(false);
						//						}
						//						else
						//							FlexGlobals.topLevelApplication.attachmentDownloadError = true;
						FlexGlobals.topLevelApplication.decrementEventStack();
					});
				URLLdr.load(new URLRequest(sourceURL));
			}
			
			//return BaseConfigUtility.get("geotags_folder") + fileName;
		}
		
		
		/**
		 * Download the file realted to the TSSPicture/TSSVoice/TSSVideo that is passed in, to the local geotags folder 
		 * @param TSSObj - Type TSSPicture, TSSVoice or TSSVideo
		 * 
		 */
		public static function downloadDDOTGeotag(TSSObj:*,currentDwldIndex:int,maxDwnldLength:int, showAlert:Boolean):void
		{
			var sourceURL:String ="";
			var fileName:String ="";
			
			if (TSSObj is TSSPicture)
			{
				sourceURL = (TSSObj as TSSPicture).sourceURL;
				fileName =  (TSSObj as TSSPicture).label;
			}
			else if (TSSObj is TSSVideo)
			{
				sourceURL = (TSSObj as TSSVideo).filePath;
				fileName =  (TSSObj as TSSVideo).label;
			}
			else if (TSSObj is TSSAudio)
			{
				sourceURL = (TSSObj as TSSAudio).sourceURL;
				fileName =  (TSSObj as TSSAudio).label;
			}
			
			if (sourceURL.substring(0, 4) == "http") 
			{
				var URLLdr:URLLoader = new URLLoader();
				URLLdr.dataFormat = URLLoaderDataFormat.BINARY;
				
				URLLdr.addEventListener(Event.COMPLETE, 
					function(e:Event):void { 
						var fTemp:File = new File(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.geotagUrl + fileName);
						//						var fTemp:File = new File(BaseConfigUtility.get("geotags_folder") + fileName);
						var fsTemp:FileStream = new FileStream();
						fsTemp.open(fTemp, FileMode.WRITE);
						
						var fileData:ByteArray =URLLdr.data;
						fsTemp.writeBytes(fileData, 0, 0);
						fsTemp.close();
						//						if(currentDwldIndex==maxDwnldLength && showAlert && FlexGlobals.topLevelApplication.attachmentDownloadError)
						//						{
						//							FlexGlobals.topLevelApplication.setBusyStatus(false);
						//							FlexGlobals.topLevelApplication.TSSAlert("Route saved to local database.\n Attachment download errors encountered");
						//						}
						//						else if(currentDwldIndex==maxDwnldLength && showAlert && !FlexGlobals.topLevelApplication.attachmentDownloadError)
						//						{
						//							FlexGlobals.topLevelApplication.TSSAlert("Route saved to local database");
						//							FlexGlobals.topLevelApplication.setBusyStatus(false);
						//						}
						
						FlexGlobals.topLevelApplication.decrementEventStack();
						
						//						
						
					});
				URLLdr.addEventListener(IOErrorEvent.IO_ERROR, 
					function(e:Event):void { 
						
						//						if(currentDwldIndex==maxDwnldLength && showAlert)
						//						{
						//							FlexGlobals.topLevelApplication.TSSAlert("Route saved to local database.\n Attachment download errors encountered");
						//							FlexGlobals.topLevelApplication.setBusyStatus(false);
						//						}
						//						else
						//							FlexGlobals.topLevelApplication.attachmentDownloadError = true;
						
						FlexGlobals.topLevelApplication.decrementEventStack();
						
					});
				URLLdr.load(new URLRequest(sourceURL));
			}
			
			//return BaseConfigUtility.get("geotags_folder") + fileName;
		}
		
		
		public function deleteCachedGeotagFiles():void
		{
			var fList:Array = fileUtil.getFiles();
			for each (var file:File in fList)
			{
				if(mdbm.isCachedGeotag(file.name))
					fileUtil.deleteFiles(file.name);
			}
		}
		
		public function deleteNonCachedGeotagFiles():void
		{
			var fList:Array = fileUtil.getFiles();
			for each (var file:File in fList)
			{
				if(!mdbm.isCachedGeotag(file.name))
					fileUtil.deleteFiles(file.name);
			}
		}
		
		//		public function getAssetDomains():void
		//		{
		//			var tableName:String;
		//
		//			if (!mdbm.isCulvertDomainAvailable())
		//			{
		//				tableName = "CULVERT_DOMAIN";
		//				fetchDomainValues("D_CULV_COND_ID", defaultDescCol, tableName);
		//				fetchDomainValues("D_CULV_MAT_ID", defaultDescCol, tableName);
		//				fetchDomainValues("D_CULV_PLACEMENT_TY_ID", defaultDescCol, tableName);
		//				fetchDomainValues("D_CULV_SHAPE_ID", defaultDescCol, tableName);
		//				fetchDomainValues("D_BEAM_MAT_ID", defaultDescCol, tableName);
		//				fetchDomainValues("D_ABUTMENT_MAT_ID", defaultDescCol, tableName);
		//				fetchDomainValues("D_BARL_RMK_ID", defaultDescCol, tableName);
		//				fetchDomainValues("D_CHNL_RMK_ID", defaultDescCol, tableName);
		//				fetchDomainValues("D_FLOW_RMK_ID", defaultDescCol, tableName);
		//				fetchDomainValues("D_ENDS_RMK_ID", defaultDescCol, tableName);
		//				fetchDomainValues("D_JOINT_RMK_ID", defaultDescCol, tableName);
		//				fetchDomainValues("D_JOINT_SEP_LOC_ID", defaultDescCol, tableName);
		//				fetchDomainValues("D_MAINT_EQUIP_ID", defaultDescCol, tableName);
		//				fetchDomainValues("D_MAINT_WORK_TY_ID", defaultDescCol, tableName);
		//			}
		//			
		//			tableName = "ASSET_DOMAIN";
		//			fetchDomainValues("D_DIRECTION_ID", defaultDescCol, tableName);
		//			fetchDomainValues("D_SHEETING_MAT_ID", defaultDescCol, tableName);
		//			fetchDomainValues("D_BLANK_MAT_ID", defaultDescCol, tableName);
		//			fetchDomainValues("D_DIR_TRAVEL_ID", defaultDescCol, tableName);
		//			fetchDomainValues("D_POST_TY_ID", defaultDescCol, tableName);
		//			fetchDomainValues("D_SIDE_ROAD_ID", defaultDescCol, tableName);
		//			fetchDomainValues("D_POST_SIZE_ID", defaultDescCol, tableName);
		//			fetchDomainValues("D_SIGN_RATING_ID", defaultDescCol, tableName);
		//			fetchDomainValues("DIMENSION_ID", "DIMENSION_DESC", tableName);
		//			fetchDomainValues("COLOR_ID", "COLOR_DESC", tableName);
		//			fetchDomainValues("D_URGENCY_ID", "URGENCY_NAME", tableName);
		//			fetchDomainValues("D_GRAIL_MATERIAL_ID", defaultDescCol, tableName);
		//			fetchDomainValues("D_GRAIL_LOC_ID", defaultDescCol, tableName);
		//			fetchDomainValues("D_GRAIL_PURPOSE_ID", defaultDescCol, tableName);
		//			fetchDomainValues("D_GRAIL_CONDITION_ID", defaultDescCol, tableName);
		//			fetchDomainValues("SIGN_MAJOR_CAT_ID", "SIGN_MAJ_CAT_DESC", tableName);
		//			fetchDomainValues("D_MARKER_TYPE_ID", defaultDescCol, tableName);
		//			fetchDomainValues("D_COUNTY_NO_ID", defaultDescCol, tableName);
		//			fetchDomainValues("D_INTERSECT_TYPE_ID", defaultDescCol, tableName);
		//			fetchDomainValues("D_SIGN_LOCATION_ID", defaultDescCol, tableName);
		//			
		//			getSubCatDomains();
		//			
		//		}
		//		
		//		private function getSubCatDomains():void
		//		{
		//			if(mdbm.isAssetDomainAvailable("SIGN_SUB_CATEGORY_ID"))
		//				return;
		//			var httpServ:HTTPService = new HTTPService();
		//			httpServ.url = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL +"Subcats";
		//			httpServ.method = "GET";
		//			httpServ.resultFormat = "text";
		//			httpServ.addEventListener(FaultEvent.FAULT, fault);
		//			httpServ.addEventListener(ResultEvent.RESULT, setSubCatDomainFromService);
		//			httpServ.send();
		//		}
		//		
		//		public function setSubCatDomainFromService(event:ResultEvent):void
		//		{
		//			var resp:Array = JSON.parse(event.result as String) as Array;
		//			var ac:ArrayCollection= new ArrayCollection(resp);
		//			mdbm.insertAssetDomain(ac, "SIGN_SUB_CATEGORY_ID", "SIGN_MAJOR_CAT_ID");
		//		}
		//
		//		private function fetchDomainValues(idCol:String, descCol:String, tableName:String):void
		//		{
		//			
		//			if(!idCol || idCol ==="")
		//				return;
		//			
		//			if(tableName == "ASSET_DOMAIN")
		//			{
		//				if (mdbm.isAssetDomainAvailable(idCol))
		//					return;
		//			}
		//			
		//			var httpServ:HTTPService = new HTTPService();
		//			httpServ.url = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL +"Domains/"+ idCol +"/" + descCol;
		//			httpServ.method = "GET";
		//			httpServ.resultFormat = "text";
		//			// Need this so the request is available in the resultEvent
		//			httpServ.request["service"] = httpServ; 
		//			httpServ.addEventListener(FaultEvent.FAULT, fault);
		//			
		//			if(tableName == "ASSET_DOMAIN")
		//			{
		//				httpServ.addEventListener(ResultEvent.RESULT, setDomainFromService);
		//			}
		//			else if(tableName == "CULVERT_DOMAIN")
		//			{
		//				httpServ.addEventListener(ResultEvent.RESULT, setCulvertDomainFromService);
		//			}
		//			httpServ.send();
		//		}
		//
		//		public function setDomainFromService(event:ResultEvent):void
		//		{
		//			var resp:Array = JSON.parse(event.result as String) as Array;
		//			var domainArr:ArrayCollection = new ArrayCollection(resp);
		//			// Get the request data so the domain name can be extracted
		//			var eventService : HTTPService = HTTPService( AbstractOperation( event.currentTarget ).request["service"] );
		//			var urlStr:String = eventService.url;
		//			
		//			var indx:int = (urlStr.indexOf(serviceCallName))+serviceCallName.length;
		//			var tmpStr:String = urlStr.substr(indx);
		//			var indx2:int = tmpStr.indexOf("/");
		//			var nameStr:String = tmpStr.substr(0,indx2);
		//			mdbm.insertAssetDomain(domainArr, nameStr);	
		//		}
		//		
		//		public function setCulvertDomainFromService(event:ResultEvent):void
		//		{
		//			var resp:Array = JSON.parse(event.result as String) as Array;
		//			var domainArr:ArrayCollection = new ArrayCollection(resp);
		//			// Get the request data so the domain name can be extracted
		//			var eventService : HTTPService = HTTPService( AbstractOperation( event.currentTarget ).request["service"] );
		//			var urlStr:String = eventService.url;
		//			
		//			var indx:int = (urlStr.indexOf(serviceCallName))+serviceCallName.length;
		//			var tmpStr:String = urlStr.substr(indx);
		//			var indx2:int = tmpStr.indexOf("/");
		//			var idStr:String = tmpStr.substr(0,indx2);
		//			var nameStr:String;
		//			
		//			// Use the name that is used for the domain in the code
		//			if(idStr == "D_MAINT_EQUIP_ID")
		//				nameStr = "MaintEquipList";
		//			else if(idStr == "D_CULV_MAT_ID")
		//				nameStr = "MaterialList";
		//			else if(idStr == "D_CULV_PLACEMENT_TY_ID")
		//				nameStr = "PlacementList";
		//			else if(idStr == "D_CULV_SHAPE_ID")
		//				nameStr = "ShapeList";
		//			else if(idStr == "D_CULV_COND_ID")
		//				nameStr = "GeneralList";
		//			else if(idStr == "D_JOINT_SEP_LOC_ID")
		//				nameStr = "JointLocList";
		//			else if(idStr == "D_ABUTMENT_MAT_ID")
		//				nameStr = "AbutmentList";
		//			else if(idStr == "D_BEAM_MAT_ID")
		//				nameStr = "BeamList";
		//			else if(idStr == "D_FLOW_RMK_ID")
		//				nameStr = "FlowList";
		//			else if(idStr == "D_JOINT_RMK_ID")
		//				nameStr = "JointsList";
		//			else if(idStr == "D_BARL_RMK_ID")
		//				nameStr = "BarrelList";
		//			else if(idStr == "D_ENDS_RMK_ID")
		//				nameStr = "EndsList";
		//			else if(idStr == "D_CHNL_RMK_ID")
		//				nameStr = "ChannelList";
		//			else if(idStr == "D_MAINT_WORK_TY_ID")
		//				nameStr = "MaintList";
		//			
		//			mdbm.insertDomain(domainArr, nameStr);	
		//		}
		//
		//		private function fault(e:FaultEvent):void
		//		{
		//			// Get the request data so the domain name can be extracted
		//			var eventService : HTTPService = HTTPService( AbstractOperation( e.currentTarget ).request["service"] );
		//			var urlStr:String = eventService.url;
		//			
		//			var indx:int = (urlStr.indexOf(serviceCallName))+serviceCallName.length;
		//			var tmpStr:String = urlStr.substr(indx);
		//			var indx2:int = tmpStr.indexOf("/");
		//			var nameStr:String = tmpStr.substr(0,indx2);
		//
		//			FlexGlobals.topLevelApplication.TSSAlert("Error in Domain retrieval for " + nameStr);
		//		}
		//		
		
		
		
		
		public function isAssetOnStick(type:String):Boolean
		{
			return String(_assetDefs[_assetDescriptions[type]].VISIBLE_ON_STICK).toLowerCase()=="true";
		}
		
		public function isAssetCaptureAvailable(type:String):Boolean
		{
			return String(_assetDefs[_assetDescriptions[type]].CAPTURE_AVAILABLE).toLowerCase()=="true";
		}
		
		public function getSignDescriptionByMUTCD(mutcd:String):String
		{
			var mutcdDomain:ArrayCollection = getDomain("BARCODEID");
			
			for each(var obj:Object in mutcdDomain)
			{
				if(mutcd == obj.ID)
					return obj.DESCRIPTION;
			}
			 
			 
			return "";
			 
			 

		}
		
		
		
	}
}