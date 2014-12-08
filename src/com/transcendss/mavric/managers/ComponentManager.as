package com.transcendss.mavric.managers
{
	import com.transcendss.mavric.managers.ddot.DdotRecordManager;
	import com.transcendss.mavric.views.componentviews.LocalRoutesForm;
	import com.transcendss.transcore.sld.models.InventoryDiagram;
	import com.transcendss.transcore.sld.models.StickDiagram;
	import com.transcendss.transcore.sld.models.components.Route;
	
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;

	public class ComponentManager
	{
		private var _sldRoute:Route;
		private var _stickDiagram:StickDiagram;
		private var _invDiagram:InventoryDiagram;
		[Bindable]
		private var _ConfigManager:ConfigurationManager;
		private var _routeList:ArrayCollection;
		private var _captureEventSource:String ="";
		private var _errorFileList:Array = new Array();
		private var _assetManager:AssetManager;
		private var _recordManager:DdotRecordManager;
		private var _agsManager:ArcGISServiceManager = new ArcGISServiceManager();
		private var _localRoutesForm:LocalRoutesForm;
		public var dispatcher:IEventDispatcher;
		public var gtFilesToUploadCount:Number =0;
		
		
		
		
		public function ComponentManager()
		{
		}

		public function get recordManager():DdotRecordManager
		{
			return _recordManager;
		}

		public function set recordManager(value:DdotRecordManager):void
		{
			_recordManager = value;
		}

		public function set uploadedFileList(ar:Array):void
		{
			_errorFileList = ar;
		}
		public function get uploadedFileList():Array
		{
			return _errorFileList;
		}
		
		
		public function set filesToUpload(ar:Array):void
		{
			_errorFileList = ar;
		}
		public function get filesToUpload():Array
		{
			return _errorFileList;
		}
		
		public function set capturEventSource(s:String):void
		{
			_captureEventSource = s;
		}
		public function get capturEventSource():String
		{
			return _captureEventSource;
		}
		
		public function set ConfigManager(configManagerObj:ConfigurationManager):void
		{
			_ConfigManager = configManagerObj;
		}
		[Bindable]
		public function get ConfigManager():ConfigurationManager
		{
			return _ConfigManager;
		}
		
		public function set sldRoute(routeObj:Route):void
		{
			_sldRoute = routeObj;
		}
		
		public function get sldRoute():Route
		{
			return _sldRoute;
		}
		
		public function set stkDiagram(diagramObj:StickDiagram):void
		{
			_stickDiagram = diagramObj;
		}
		
		
		public function get stkDiagram():StickDiagram
		{
			return _stickDiagram;
		}
		
		
		public function set invDiagram(diagramObj:InventoryDiagram):void
		{
			_invDiagram = diagramObj;
		}
		
		public function get invDiagram():InventoryDiagram
		{
			return _invDiagram;
		}

		public function get routeList():ArrayCollection
		{
			return _routeList;
		}

		public function set routeList(value:ArrayCollection):void
		{
			_routeList = value;
		}

		public function get assetManager():AssetManager
		{
			return _assetManager;
		}

		public function set assetManager(value:AssetManager):void
		{
			_assetManager = value;
		}
		
		public function get agsManager():ArcGISServiceManager
		{
			return _agsManager;
		}
		
		public function set agsManager(value:ArcGISServiceManager):void
		{
			_agsManager = value;
		}

		public function get localRoutesForm():LocalRoutesForm
		{
			return _localRoutesForm;
		}

		public function set localRoutesForm(value:LocalRoutesForm):void
		{
			_localRoutesForm = value;
		}


	}
}