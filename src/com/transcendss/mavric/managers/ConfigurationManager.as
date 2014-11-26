package com.transcendss.mavric.managers
{
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.transcore.events.ConfigManagerEvent;
	import com.transcendss.transcore.events.ExternalFileEvent;
	import com.transcendss.transcore.util.Units;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	
	[Bindable]
	public class ConfigurationManager
	{ 
		public static const MC_SYNC:int=1;
		public static const RH_SYNC:int=2;
		public static const EXPORT_CHANGES:int=3;
		
		private var configArray:ArrayCollection = null;
		private var _settingsAC:ArrayCollection= null;
		private var rWidth:Number;
		private var rColor:uint;
		private var sColor:uint;
		private var scale:Number;
		private var scaleValArr:Array;
		private var dataElemArr:Array = new Array();
		private var dataElemDefObj:Object = new Object();
		private var dataElemDtlsArr:Array = new Array();
		private var sURL:String;
		private var mateDispatcher:Dispatcher;
		//private var attrView:Boolean;
		private var vlImageSize:String;
		private var gdeBarSwitch:Boolean;
		private var invFrmSwitch:Boolean;
		
		private var _feetMarkerSwitch:Boolean;
		private var _linearEditingSwitch:Boolean;
		private var _roadwayLanesSwitch:Boolean;

		//view Menu checkboxes
		private var _FullScreenSwitch:Boolean;
		private var _VideoLogSwitch:Boolean;
		private var _OverviewMapSwitch:Boolean;
		private var _ControlBarSwitch:Boolean = true; //default to true because control bar is shown by default
		private var _measureBarUnit:Number;
		
		private var elemBarHeight:Number=0;
		private var cpBarBtnList:Array;
		private var wifiConnect:Boolean;
		private var fileLoc:String;
		private var _inspDays:Number=120;
		private var _lanesFieldValue:String="Number of Lanes";
		
		private var _syncActivity:int=2;
		
		private var _setMan:SettingsManager = new SettingsManager();
		
		private var currBtmPanelContent:String = "";
		private var defBtmPanelContent:String = ""; 
		
		private var _assetSwitch:Object = new Object();
		
		private var scaleRepresentatives:ArrayCollection = new ArrayCollection();
		
		
		public function ConfigurationManager(connected:Boolean, disp:Dispatcher)
		{
			wifiConnect = connected;
			mateDispatcher = disp;
			
			
			scaleRepresentatives = new ArrayCollection([
				{scaleValue: .02 , scaleLabel:"1\" = 0.02 "+ unitsLabel },
				{scaleValue: .05 , scaleLabel:"1\" = 0.05 "+ unitsLabel},
				{scaleValue: .1 , scaleLabel:"1\" = 0.10 "+ unitsLabel},
				{scaleValue: .2 , scaleLabel:"1\" = 0.20 "+ unitsLabel},
				{scaleValue: .5 , scaleLabel:"1\" = 0.50 "+ unitsLabel},
				{scaleValue: 1 , scaleLabel:"1\" = 1.00 "+ unitsLabel},
				{scaleValue: 2 , scaleLabel:"1\" = 2.00 "+ unitsLabel},
				{scaleValue: 5 , scaleLabel:"1\" = 5.00 "+ unitsLabel},
				{scaleValue: 10 , scaleLabel:"1\" = 10.00 "+ unitsLabel}]);
		}
		
		
		
		public function get lanesFieldValue():String
		{
			return _lanesFieldValue;
		}

		public function set lanesFieldValue(value:String):void
		{
			_lanesFieldValue = value;
		}

		public function loadSettings():void
		{
			
			getDataElementDetails();
			syncActivity = parseInt(syncActivityValue);
			inspDays = parseInt(inspDaysValue);
			gdeBarSwitch =  _setMan.getSetting("GUIDEBAR_VIEW")?(_setMan.getSetting("GUIDEBAR_VIEW") == "true" ? true : false): ConfigUtility.getBool("guide_bool");
			_feetMarkerSwitch =_setMan.getSetting("FEET_VIEW")?(_setMan.getSetting("FEET_VIEW") == "true" ? true : false):ConfigUtility.getBool("ruler_bool");
			_linearEditingSwitch =_setMan.getSetting("LINEAR_DATA_EDIT_ENABLED")?(_setMan.getSetting("LINEAR_DATA_EDIT_ENABLED") == "true" ? true : false):ConfigUtility.getBool("linear_data_edit_enabled");
			_roadwayLanesSwitch =_setMan.getSetting("ROADWAY_LANES_ENABLED")?(_setMan.getSetting("ROADWAY_LANES_ENABLED") == "true" ? true : false):ConfigUtility.getBool("roadway_lanes_enabled");

			_measureBarUnit = _setMan.getSetting("TYPE_MEASURE")?int(_setMan.getSetting("TYPE_MEASURE")): ConfigUtility.getInt("type_measure");//( s=="kilometer"? Units.KILOMETER : (s=="meter"? Units.METER : (s=="mile"? Units.MILE : Units.FEET)));
			sURL = _setMan.getSetting("SERVICE_URL")?String(_setMan.getSetting("SERVICE_URL")):ConfigUtility.get("serviceURL");
			
			
			defBtmPanelContent = currBtmPanelContent = _setMan.getSetting("DEFAULT_BP_CONTENT")?String(_setMan.getSetting("DEFAULT_BP_CONTENT")):ConfigUtility.get("default_bp_content");
			elemBarHeight = _setMan.getSetting("DEFAULT_ELEMENT_BAR_HEIGHT")?Number(_setMan.getSetting("DEFAULT_ELEMENT_BAR_HEIGHT")):ConfigUtility.getNumber("default_element_bar_height");
			
			
			
			var assetDefs:Object = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetDefs;
			for each (var assetType:Object in assetDefs)
			{
				var switchVal:String = _setMan.getSetting(String(assetType.DESCRIPTION).toLowerCase()+ "_view");
				if(switchVal)
				{
					if( switchVal.toLowerCase()== "true" || switchVal.toLowerCase() =="false")
						_assetSwitch[assetType.DESCRIPTION] = switchVal.toLowerCase() == "true" ;
					else
					{
						_assetSwitch[assetType.DESCRIPTION] = String(assetType.VISIBLE_ON_STICK).toLowerCase() == "true";	
						//_setMan.saveSetting(String(assetType.DESCRIPTION).toLowerCase()+ "_view", String(assetType.VISIBLE_ON_STICK));
					}
				}
				
			}
			var event:ExternalFileEvent = new ExternalFileEvent(ExternalFileEvent.CONFIG_FILE_LOADED);
			mateDispatcher.dispatchEvent(event);
		}
		
		public function getDefScaleIndex():int{
			var defScaleIndex:int = 2;
			for(var i:int =0; i< this.scaleRepresentatives.length;i++)
			{
				if(this.scaleRepresentatives[i].scaleValue == this.defaultScale)
				{
					defScaleIndex = i;
					break;
				}
			}
			return defScaleIndex;
		}
		
		public function getDefScaleIndexLabel():String{
			var defScaleLbl:String="";
			for(var i:int =0; i< this.scaleRepresentatives.length;i++)
			{
				if(this.scaleRepresentatives[i].scaleValue == this.defaultScale)
				{
					defScaleLbl =String(this.scaleRepresentatives[i].scaleLabel);
					break;
				}
			}
			return defScaleLbl;
		}


		// Read the bar element definitions from json file
		private function getDataElementDetails():void
		{
			var meFile:File;
			var path:String=barElementDef;
			
			if(path.indexOf("app-storage")!= -1)
				meFile = File.applicationStorageDirectory.resolvePath(path.replace("app-storage:/",""));
			else
				meFile = File.applicationDirectory.resolvePath(path);
			
			
//			var path:String = barElementDef;
//			var meFile:File = File.applicationDirectory.resolvePath(path);
			
			var fs:FileStream = new FileStream();
			fs.open(meFile, FileMode.READ);
			
			var jsonString : String = fs.readUTFBytes(fs.bytesAvailable);
			var jsonObj:Object = JSON.parse(jsonString);
			buildDataElementDetails(jsonObj);
			
			fs.close();
		}
		
		public function getBarElemEventLayerID(elemtID:int):int{
			if(dataElemDefObj.hasOwnProperty(elemtID))
				return new int(dataElemDefObj[elemtID].EventLayerID);
			else
				return -1;
		}
		
		public function getBarElemLabel(elemtID:int):String{
			if(dataElemDefObj.hasOwnProperty(elemtID))
				return new String(dataElemDefObj[elemtID].AssetName);
			else
				return "";
		}
		
		public function getBarElemDef(elemtID:int):Object{
			if(dataElemDefObj.hasOwnProperty(elemtID))
				return dataElemDefObj[elemtID];
			else
				return null;
		}

		// Get the bar element names to display in the lanes field selection box
		public function getBarElemNames():Array{
			var namesArr:Array = new Array();
			var obj:Object;
			for each(obj in dataElemDefObj)
			{
				if(obj.AssetName == lanesFieldValue)
					namesArr.splice(0,0,obj.AssetName);
				else
					namesArr.push(obj.AssetName);
			}
			return namesArr;
		}

		// Store the bar element definitions for use by the code
		private function buildDataElementDetails(jsonObj:Object):void
		{
			var barArray:Array = jsonObj.BarAssets;
			for(var i:int=0; i<barArray.length; i++) 
			{
				if(barArray[i].UseElement == "true")
				{
					var assetID:int = parseInt(barArray[i].AssetLayerID);
					dataElemArr.push(assetID);
					//store the def boject for later use
					dataElemDefObj[assetID] = new Object();
					dataElemDefObj[assetID] = barArray[i];
					
					var order:String = barArray[i].Order;
					var desc:String = barArray[i].DESCRIPTION;
					var domainArr:Array = barArray[i].Domain;
					
					for(var j:int=0; j<domainArr.length; j++)
					{
						var detObj:Object = new Object();
						detObj.ID = assetID;
						detObj.Order = order;
						detObj.Description = desc;
						detObj.Color = domainArr[j].Color;
						detObj.TextColor = domainArr[j].TextColor;
						detObj.Range = domainArr[j].Range;
						detObj.Value = domainArr[j].Value;
						detObj.UniqueID = domainArr[j].UniqueID;
						detObj.isRange = barArray[i].isRange;
						detObj.eventLayerID = barArray[i].EventLayerID;
						dataElemDtlsArr.push(detObj);
					}
				}
			}
		}
		
		[Bindable(event="configManagerSyncTypeChanged")]
		public function get syncActivity():int
		{
			return _syncActivity;
		}
		
		public function set syncActivity(value:int):void
		{
			
			if (value != _syncActivity)
			{
				_syncActivity = value;
				var eventObj:ConfigManagerEvent = new ConfigManagerEvent(ConfigManagerEvent.SYNC_TYPE_CHANGED);
				
				mateDispatcher.dispatchEvent(eventObj);
			}
		}
		
		
		
		public function get inspDays():Number
		{
			return _inspDays;
		}
		
		public function set inspDays(value:Number):void
		{
			_inspDays = value;
		}
		


		[Bindable(event="configManagerMeasureBarUnitChanged")]
		public function get measureBarUnit():Number
		{
			return _measureBarUnit;
		}
		
		public function set measureBarUnit(u:Number):void
		{
			if (u != _measureBarUnit)
			{
				_measureBarUnit = u;
				var eventObj:ConfigManagerEvent = new ConfigManagerEvent(ConfigManagerEvent.MEASUREBAR_UNIT_CHANGED);
				eventObj.NewUnit = u;
				mateDispatcher.dispatchEvent(eventObj);
			}
			
		}
		
		public function get ControlBarSwitch():Boolean
		{
			return _ControlBarSwitch;
		}
		
		public function set ControlBarSwitch(value:Boolean):void
		{
			_ControlBarSwitch = value;
		}
		
		public function get OverviewMapSwitch():Boolean
		{
			return _OverviewMapSwitch;
		}
		
		public function set OverviewMapSwitch(value:Boolean):void
		{
			_OverviewMapSwitch = value;
		}
		
		public function get VideoLogSwitch():Boolean
		{
			return _VideoLogSwitch;
		}
		
		public function set VideoLogSwitch(value:Boolean):void
		{
			_VideoLogSwitch = value;
		}
		
		public function get FullScreenSwitch():Boolean
		{
			return _FullScreenSwitch;
		}
		
		public function set FullScreenSwitch(value:Boolean):void
		{
			_FullScreenSwitch = value;
		}
		
		public function get settingsAC():ArrayCollection
		{
			return _settingsAC;
		}
		
		public function set settingsAC(value:ArrayCollection):void
		{
			_settingsAC = value;
		}
		
		public function set dispatcher(disp:Dispatcher):void{
			mateDispatcher = disp;
		}
		public function get dispatcher():Dispatcher{
			return mateDispatcher;
		}
		
		public function set fileLocation(loc:String):void{
			fileLoc = loc;
		}
		public function get fileLocation():String{
			return fileLoc;
		}
		
		public function set wifiConnected(wifi:Boolean):void{
			wifiConnect = wifi;
		}
		public function get wifiConnected():Boolean{
			return wifiConnect;
		}
		
		
		public function get elementBarHeight():Number{
			return _setMan.getSetting("DEFAULT_ELEMENT_BAR_HEIGHT")?Number(_setMan.getSetting("DEFAULT_ELEMENT_BAR_HEIGHT")):ConfigUtility.getNumber("default_element_bar_height");
		}
		
		
		
		
		
		public function set guideBarSwitch(swtch:Boolean):void{
			if (swtch != gdeBarSwitch)
			{
				gdeBarSwitch = swtch;
				var eventObj:ConfigManagerEvent = new ConfigManagerEvent(ConfigManagerEvent.GUIDEBAR_CHANGED);
				eventObj.NewValue = swtch;
				mateDispatcher.dispatchEvent(eventObj);
			}
		}
		
		[Bindable(event="configManagerGuideBarChanged")]
		public function get guideBarSwitch():Boolean
		{
			
			return gdeBarSwitch;
		}
		
		public function set invPanelContent(swtch:String):void{
			if (swtch != currBtmPanelContent)
			{
				currBtmPanelContent = swtch;
				var eventObj:ConfigManagerEvent = new ConfigManagerEvent(ConfigManagerEvent.INV_PANEL_VIEW_CHANGED);
				eventObj.PanelContent = swtch;
				mateDispatcher.dispatchEvent(eventObj);
			}
		}
		
		[Bindable(event="configManagerInvPanelViewChanged")]
		public function get invPanelContent():String{
			return currBtmPanelContent;
		}
		
		public function get defaultBPContent():String{
			return _setMan.getSetting("DEFAULT_BP_CONTENT")?String(_setMan.getSetting("DEFAULT_BP_CONTENT")):ConfigUtility.get("default_bp_content");
		}
		
		[Bindable(event="configManagerFeetMarkerSwitchChanged")]
		public function get feetMarkerSwitch():Boolean
		{
			return _feetMarkerSwitch;
		}
		
		public function set feetMarkerSwitch(value:Boolean):void
		{
			if (value != _feetMarkerSwitch)
			{
				_feetMarkerSwitch = value;
				var eventObj:ConfigManagerEvent = new ConfigManagerEvent(ConfigManagerEvent.MEASUREBAR_SWITCH_CHANGED);
				eventObj.NewValue = value;
				mateDispatcher.dispatchEvent(eventObj);
			}
			
		}
		
		[Bindable(event="configManagerLinearEditingSwitchChanged")]
		public function get linearEditingSwitch():Boolean
		{
			return _linearEditingSwitch;
		}
		
		public function set linearEditingSwitch(value:Boolean):void
		{
			if (value != _linearEditingSwitch)
			{
				_linearEditingSwitch = value;
				var eventObj:ConfigManagerEvent = new ConfigManagerEvent(ConfigManagerEvent.LINEAREDITING_SWITCH_CHANGED);
				eventObj.NewValue = value;
				mateDispatcher.dispatchEvent(eventObj);
			}
			
		}
		
		[Bindable(event="configManagerRoadwayLanesSwitchChanged")]
		public function get roadwayLanesSwitch():Boolean
		{
			return _roadwayLanesSwitch;
		}
		
		public function set roadwayLanesSwitch(value:Boolean):void
		{
			if (value != _roadwayLanesSwitch)
			{
				_roadwayLanesSwitch = value;
				var eventObj:ConfigManagerEvent = new ConfigManagerEvent(ConfigManagerEvent.ROADWAYLANES_SWITCH_CHANGED);
				eventObj.NewValue = value;
			
				mateDispatcher.dispatchEvent(eventObj);
			}
			
		}
		
		
		public function set configArrayColl(configAC:ArrayCollection):void
		{
			configArray = configAC;
			//sURL = String(configAC.getItemAt(0).ServiceURL);
		}
		
		public function get settingsArrayColl():ArrayCollection
		{
			return settingsAC;
		}
		
		public function get configArrayColl():ArrayCollection
		{
			return configArray;
		}
		
		public function get roadWidth():Number
		{
			return rWidth;
		}
		
		public function set roadWidth(rw:Number):void
		{
			var old:Number = rWidth;
			rWidth =rw;
		}
		
		public function get roadColor():uint
		{
			return rColor;
		}
		
		public function set roadColor(rc:uint):void
		{
			var old:uint = rColor;
			rColor =rc;
		}
		public function get stripeColor():uint
		{
			return sColor;
		}
		
		public function set stripeColor(sc:uint):void
		{
			var old:uint = sColor;
			sColor =sc;
		}
		public function get defaultScale():Number
		{
			var s:String = _setMan.getSetting("DEFAULT_SCALE");
			return (s==""|| s ==null )?Number(ConfigUtility.get('default_scale')):Number(s);
		}
		
		public function get defaultLanesField():String
		{
			var s:String = _setMan.getSetting("DEFAULT_LANES_FIELD");
			return (s==""|| s ==null )?ConfigUtility.get('default_lanes_field'):s;
		}
		
		
		public function get dataUnits():int
		{
			var s:String = _setMan.getSetting("UNITS");
			return (s==""|| s ==null )?ConfigUtility.getInt('units'):int(s);
		}
		
		public function get unitsLabel():String
		{
			return Units.getLabelByUnit(dataUnits);
		}
		
		public function get scaleValues():ArrayCollection
		{
			return scaleRepresentatives;
		}
		
		public function set scaleValues(sv:ArrayCollection):void
		{
			scaleRepresentatives =sv;
		}
		
		public function get gdbValues():ArrayCollection
		{
			return FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getDomain("GDB_VERSION");
		}
		
		
		
		public function get dataElementValues():Array
		{
			return dataElemArr;
		}
		
		public function set dataElementValues(sv:Array):void
		{
			dataElemArr =sv;
		}	
		
		public function get dataElementDetails():Array
		{
			return dataElemDtlsArr;
		}
		
		public function set dataElementDetails(sv:Array):void
		{
			dataElemDtlsArr =sv;
		}
		
		public function get serviceURL():String
		{
			return sURL;
		}
		public function set serviceURL(url:String):void
		{
			sURL = url;
		}
		
		
		
		public function get VLImageSize():String
		{
			return vlImageSize;
		}
		public function set VLImageSize(size:String):void
		{
			vlImageSize = size;
		}
		
		
		public function get geotagUrl():String
		{		
			var url:String = _setMan.getSetting("GEOTAGS_FOLDER");
			return (url==""|| url ==null )?BaseConfigUtility.get('geotags_folder'):url;	
		}
		public function get cachedMapUrl():String
		{
			var url:String =_setMan.getSetting("CACHED_MAP_FOLDER");
			return (url==""|| url ==null )?BaseConfigUtility.get('cached_map_folder'):url;
		}
		public function get signImagesUrl():String
		{
			var url:String = _setMan.getSetting("SIGN_IMAGES_FOLDER");
			return (url==""|| url ==null )?BaseConfigUtility.get('sign_images_folder'):url;
		}
		public function get baseMapUrl():String
		{
			var url:String = _setMan.getSetting("BASEMAPLAYER");
			return (url==""|| url ==null )?BaseConfigUtility.get('basemapLayer'):url;
		}
		public function get baseMapSR():String
		{
			var url:String = _setMan.getSetting("BASEMAPSR");
			return (url==""|| url ==null )?BaseConfigUtility.get('basemapSR'):url;
		}
		public function get assetJsonDef():String
		{
			var url:String = _setMan.getSetting("ASSET_DEF");
			return (url==""|| url ==null )?ConfigUtility.get('asset_def'):url;	
		}
		public function get assetJsonTempl():String
		{
			var url:String = _setMan.getSetting("ASSET_DATA_TEMPLATE");
			return (url==""|| url ==null )?ConfigUtility.get('asset_data_template'):url;
		}
		public function get assetTemplates():String
		{
			var url:String =_setMan.getSetting("DATA_ENTRY_TEMPLATE");
			return (url==""|| url ==null )?ConfigUtility.get('data_entry_template'):url;
		}
		
		public function get domainDef():String
		{
			var url:String =_setMan.getSetting("DOMAIN_DEF");
			return (url==""|| url ==null )?ConfigUtility.get('domain_def'):url;
		}

		public function get barElementJsonDef():String
		{
			var url:String = _setMan.getSetting("BAR_ELEMENT_DEF");
			return (url==""|| url ==null )?ConfigUtility.get('bar_element_def'):url;	
		}
		public function get barElementJsonTempl():String
		{
			var url:String = _setMan.getSetting("BAR_ELEMENT_DATA_TEMPLATE");
			return (url==""|| url ==null )?ConfigUtility.get('bar_element_data_template'):url;
		}
		public function get barElementTemplates():String
		{
			var url:String =_setMan.getSetting("BAR_ELEMENT_DATA_ENTRY_TEMPLATE");
			return (url==""|| url ==null )?ConfigUtility.get('bar_element_data_entry_template'):url;
		}

		public function get barElementDomainDef():String
		{
			var url:String =_setMan.getSetting("BAR_ELEMENT_DOMAIN_DEF");
			return (url==""|| url ==null )?ConfigUtility.get('bar_element_domain_def'):url;
		}

		public function get syncActivityValue():String
		{
			var url:String = _setMan.getSetting("SYNC_ACTIVITY");
			return (url==""|| url ==null )?ConfigUtility.get('sync_activity'):url;	
		}

		public function get inspDaysValue():String
		{
			var url:String = _setMan.getSetting("INSP_DAYS");
			return (url==""|| url ==null )?ConfigUtility.get('inspect_days'):url;	
		}
		
		public function get barElementDef():String
		{
			var url:String = _setMan.getSetting("BAR_ELEMENTS");
			return (url==""|| url ==null )?ConfigUtility.get('bar_elements'):url;	
		}
		
		public function get linearEditFormSwitch():Boolean
		{
//			var url:String = _setMan.getSetting("LINEAR_EDIT_FORM_ENABLED");
//			return (url==""|| url ==null )?ConfigUtility.getBool('linear_edit_form_enabled'):(url=="true");	
			return true;
		}
		
		public function get useAgsService():Boolean
		{
			var url:String = _setMan.getSetting("USE_AGS_SERVICE");
			return (url==""|| url ==null )?ConfigUtility.getBool('use_ags_service'):(url=="true");	
		}
		
		public function get useAgsLatLong():Boolean
		{
			var url:String = _setMan.getSetting("USE_AGS_LATLONG");
			return (url==""|| url ==null )?ConfigUtility.getBool('use_ags_latlong'):(url=="true");	
		}
		
		public function get agsServiceURL():String
		{
			var url:String = _setMan.getSetting("AGS_SERVICE_URL");
			return (url==""|| url ==null )?ConfigUtility.get('ags_service_url'):url;	
		}
		
		public function get rollbackOnFailure():Boolean
		{
			var url:String = _setMan.getSetting("ROLLBACK_ON_FAILURE");
			return (url==""|| url ==null )?ConfigUtility.getBool('rollback_on_failure'):(url=="true");	
		}
		
		public function get gdbVersion():String
		{
			var url:String = _setMan.getSetting("GDB_VERSION");
			return (url==""|| url ==null )?ConfigUtility.get('gdb_version'):url;	
		}
		
		
		[Bindable(event="configManagerassetSwitchChanged")]
		public function get assetSwitch():Object
		{
			return _assetSwitch;
		}
		
		
		public function set assetSwitch(value:Object):void
		{
			if (value != _assetSwitch)
			{
				_assetSwitch = value;
				var eventObj:ConfigManagerEvent = new ConfigManagerEvent(ConfigManagerEvent.ASSET_SWITCH_CHANGED);
				eventObj.assetSwitchObj = value;
				mateDispatcher.dispatchEvent(eventObj);
			}
		}
		
		
		
		public function forceSettingsMenuProps(guideBar:Boolean, milePost:Boolean,  feetMarkerSwitch1:Boolean, 
											   measureUnit1:int):void
		{
			gdeBarSwitch = guideBar;
			_feetMarkerSwitch = feetMarkerSwitch1;
			_measureBarUnit = measureUnit1;
		}
	}
}