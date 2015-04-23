package com.transcendss.mavric.db
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.core.FlexGlobals;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	import mx.utils.URLUtil;
	
	public class AgsMapService
	{
		private var _server:Object = new Object();
		private var _query:Object = new Object();
		
		private var _serverDefinition:Object = new Object();
		private var _networkLayerContext:Object = new Object();
		private var _networkLayerId:Number = 0;
		
		private var _calibPointLayerContext:Object = new Object();
		private var _calibPointLayerId:Number = 0;
		
		private var _allLayerInfo:Object = new Object();
		
		public function AgsMapService(url: String, mapServerEndPoint:String="MapServer", featureServerEndPoint:String="FeatureServer")
		{
			_server = {
				url: url,
				mapServer:mapServerEndPoint,
				featureServer:featureServerEndPoint,
				port: '',
				params: {
					f: 'pjson'
				},
				endpoints: {
					
					query: '/@layerId/query',
					find: '/find',
					layer: '/@layerId',
					allEventLayers: '/exts/LRSServer/Layers',
					lrsDefinition: '/exts/LRSServer',
					eventLayer: '/exts/LRSServer/eventLayers/@layerId',
					calibrationPointLayer:'/exts/LRSServer/calibrationPointLayers/@layerId',
					networkLayer: '/exts/LRSServer/networkLayers/@layerId',
					geometryToMeasure: '/exts/LRSServer/networkLayers/@layerId/geometryToMeasure',
					applyEdits: '/applyEdits',
					addAttachments:'/addAttachment',
					attachments:'/attachments',
					measureToGeometry: '/measureToGeometry?locations=[{routeId:\'@routeId\', measure:@measure}]'
				}
			};
			
			
			_query = {
				params: {
					where: '@whereClause',
					
					text:'',
					objectIds:'',
					//		time:'',
					geometry: '',
					geometryType: '',
					inSR: '',
					spatialRel: 'esriSpatialRelIntersects',
					//		relationParam:'',
					outFields:"*",
					returnGeometry: false,
					//		maxAllowableOffset:'',
					//		geometryPrecision:'',
					outSR: '',
					returnIdsOnly:false,
					returnCountOnly:false,
					orderByFields:'',
					//	    groupByFieldsForStatistics:'',
					//		outStatistics:'',
					returnZ:false,
					returnM: false,
					gdbVersion:ConfigUtility.get("gdb_version"),
						returnDistinctValues:false,
						f: 'pjson'
				},
				findEventWhereCluase:'searchText=@searchText&contains=true&searchFields=@searchFields&sr=&layers=@layerIds&layerDefs=&returnGeometry=false&maxAllowableOffset=&geometryPrecision=&dynamicLayers=&returnZ=false&returnM=false&gdbVersion=@gdbVersion&f=pjson',
				allRoutesEventWhereClause:'@routeIdFieldName is not null',
				routeEventWhereClause: '@routeIdFieldName = \'@routeId\'',
				pointEventWhereClause: '@routeIdFieldName = \'@routeId\' and (@fromMeasureFieldName between @fromMeasure and @toMeasure)',
				linearEventWhereClause: '@routeIdFieldName = \'@routeId\' and ((@fromMeasureFieldName between @fromMeasure and @toMeasure) or (@toMeasureFieldName between @fromMeasure and @toMeasure) or (@fromMeasureFieldName < @fromMeasure and @toMeasureFieldName > @toMeasure))',
				dateWhereClause: '((@fromDateFieldName is null or @fromDateFieldName <=  CURRENT_DATE) and (@toDateFieldName is null or @toDateFieldName >  CURRENT_DATE))',
				retrieveSymbology: true
			};
			
			getServerDefinition();
			getallEventLayerInfo();
		}
		
		private function getServerDefinition():void
		{
			var url:String = _server.url +_server.mapServer + _server.endpoints.lrsDefinition + '?' + URLUtil.objectToString(_server.params,"&");
			var urlRequest:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, function (evt:Event): void {
				
				_serverDefinition = JSON.parse(evt.target.data);
				if(_serverDefinition.error)
				{
					FlexGlobals.topLevelApplication.TSSAlert("Error contacting map service. Please try later");
					return;
				}
				// Currently just set it to the first networkLayer
				var nlayerIndex:int= ConfigUtility.getInt("network_layer")?ConfigUtility.getInt("network_layer"):0;
				_networkLayerId = _serverDefinition.networkLayers[nlayerIndex].id;
				_calibPointLayerId = _serverDefinition.calibrationPointLayers[0].id;
				getNetworkLayerContext();
				getCalibPointLayerContext();
			});
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleAgsError);
			urlLoader.load(urlRequest);
		}
		
		private function getallEventLayerInfo():void
		{
			var url:String = _server.url +_server.mapServer+ _server.endpoints.allEventLayers + '?' + URLUtil.objectToString(_server.params,"&");
			var urlRequest:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, function (evt:Event): void {
				var layerArr:Array = JSON.parse(evt.target.data).eventLayers as Array;
				for each (var layer:Object in layerArr)
				{
					_allLayerInfo[layer.id] = layer;	
				}
				layerArr = JSON.parse(evt.target.data).calibrationPointLayers as Array;
				for each (var layer2:Object in layerArr)
				{
					_allLayerInfo[layer2.id] = layer2;	
				}
				layerArr = JSON.parse(evt.target.data).intersectionLayers as Array;
				for each (var layer3:Object in layerArr)
				{
					_allLayerInfo[layer3.id] = layer3;	
				}
				layerArr = JSON.parse(evt.target.data).nonLRSLayers as Array;
				for each (var layer4:Object in layerArr)
				{
					_allLayerInfo[layer4.id] = layer4;	
				}
			});
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleAgsError);
			urlLoader.load(urlRequest);
		}
		
		private function getCalibPointLayerContext():void
		{
			var url:String = _server.url +_server.mapServer+ _server.endpoints.calibrationPointLayer.replace(/@layerId/gi, _calibPointLayerId) + '?' + URLUtil.objectToString(_server.params,"&");
			var urlRequest:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, function (evt:Event): void {
				_calibPointLayerContext = JSON.parse(evt.target.data)
			});
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleAgsError);
			urlLoader.load(urlRequest);
		}
		
		private function getNetworkLayerContext():void
		{
			var url:String = _server.url +_server.mapServer+ _server.endpoints.networkLayer.replace(/@layerId/gi, _networkLayerId) + '?' + URLUtil.objectToString(_server.params,"&");
			var urlRequest:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, function (evt:Event): void {
				_networkLayerContext = JSON.parse(evt.target.data);
			});
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleAgsError);
			urlLoader.load(urlRequest);
		}
		
		private function handleAgsError(evt:Event):void
		{
			FlexGlobals.topLevelApplication.TSSAlert('Unable to retrive context from ArcGIS server.');
		}
		
		public function getMaxRecordIDUrl(idFieldName:String, layerID:Number):String
		{
//			return _server.url +_server.mapServer+ _server.endpoints.query.replace(/@layerId/gi, layerID) 
//				+ StringUtil.substitute('?f=json&outStatistics=[{"statisticType":"max","onStatisticField":"{0}","outStatisticFieldName":"max{0}"}]', idFieldName)
			return _server.url +_server.mapServer+ _server.endpoints.query.replace(/@layerId/gi, layerID) 
				+ StringUtil.substitute('?f=json&outFields={0}&orderByFields={0} DESC&returnGeometry=false&where=1=1&gdbVersion=' + _query.params.gdbVersion, idFieldName);
		}
		
		public function getLatLongUrl(routeName:String):String
		{
			var whereClause:String = _query.routeEventWhereClause.replace(/@routeIdFieldName\b/gi, _networkLayerContext.compositeRouteIdFieldName)
				.replace(/@routeId\b/gi,routeName);
			whereClause = whereClause + ' and ' + _query.dateWhereClause.replace(/@fromDateFieldName\b/gi, _networkLayerContext.fromDateFieldName).replace(/@toDateFieldName\b/gi, _networkLayerContext.toDateFieldName);
			return _server.url +_server.mapServer+ _server.endpoints.query.replace(/@layerId/gi, _networkLayerId) 
				+ '?f=json&outSR=@sr&returnM=true&returnGeometry=true&outFields=*&gdbVersion=@gdbv&where='
				.replace(/@gdbv\b/gi, _query.params.gdbVersion)
				.replace('@sr', FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.baseMapSR) 
				+ escape(whereClause);
		}
		
		public function getRouteUrl():String
		{
			var whereClause:String = _query.allRoutesEventWhereClause.replace(/@routeIdFieldName\b/gi, _networkLayerContext.compositeRouteIdFieldName) ;
			var queryUrl = _server.url +_server.mapServer+ _server.endpoints.query.replace(/@layerId/gi, _networkLayerId) + '?f=json&returnDistinctValues=true&outSR=&returnM=false&returnGeometry=false&gdbVersion=@gdbv&orderByFields='+_networkLayerContext.compositeRouteIdFieldName+'&outFields='+_networkLayerContext.compositeRouteIdFieldName+',ROUTENAME&where=' + escape(whereClause);
			return queryUrl.replace(/@gdbv\b/gi, _query.params.gdbVersion);
		}
		
		public function getMinMaxUrl(routeName:String):String
		{
			var whereClause:String = _query.routeEventWhereClause.replace(/@routeIdFieldName\b/gi, _calibPointLayerContext.routeIdFieldName).replace(/@routeId\b/gi, routeName);
			whereClause = whereClause + ' and ' + _query.dateWhereClause.replace(/@fromDateFieldName\b/gi, _calibPointLayerContext.fromDateFieldName).replace(/@toDateFieldName\b/gi, _calibPointLayerContext.toDateFieldName);
			var queryUrl = _server.url +_server.mapServer+ _server.endpoints.query.replace(/@layerId/gi, _calibPointLayerId) + '?f=json&outSR=&returnM=false&returnGeometry=false&gdbVersion=@gdbv&orderByFields='+_calibPointLayerContext.measureFieldName+'&outFields='+_calibPointLayerContext.measureFieldName+'&where=' + escape(whereClause);
			return queryUrl.replace(/@gdbv\b/gi, _query.params.gdbVersion);
		}
		
		public function getEditsUrl():String
		{
			return _server.url +_server.featureServer + _server.endpoints.applyEdits;
		}
		
		public function getAddAttachmentUrl(layerID:String, featureID:String):String
		{
			return _server.url +_server.featureServer +"/"+ layerID+"/"+featureID+ _server.endpoints.addAttachments+"?gdbVersion=" + _query.params.gdbVersion+"&f="+_query.params.f;
		}
		
		public function getAttachmentsUrl(layerID:String, featureID:String):String
		{
			return _server.url +_server.mapServer +"/"+ layerID+"/"+featureID+ _server.endpoints.attachments+"?gdbVersion=" + _query.params.gdbVersion+"&f="+_query.params.f;
		}
		
		public function getAttachmentByIDUrl(layerID:String, featureID:String, attachID:String):String
		{
			return _server.url +_server.mapServer +"/"+ layerID+"/"+featureID+ _server.endpoints.attachments+"/"+attachID+"?gdbVersion=" + _query.params.gdbVersion+"&f="+_query.params.f;
		}
		
		
		
		public function getEventUrl(layerID:Number, routeName:String, routeFromMeasure:Number, routeToMeasure:Number):String
		{
			
			var queryParams:Object =  ObjectUtil.clone( _query.params);
			
			var whereClause:String 
			if(layerID==-1 || !this._allLayerInfo[layerID] )
				return _server.url;//temp
			if(this._allLayerInfo[layerID].type=="esriLRSPointEventLayer" )
			{
				whereClause= _query.pointEventWhereClause
					.replace(/@routeIdFieldName\b/gi, this._allLayerInfo[layerID].routeIdFieldName)
					.replace(/@fromMeasureFieldName\b/gi, this._allLayerInfo[layerID].fromMeasureFieldName)
					.replace(/@fromMeasure\b/gi, routeFromMeasure)
					.replace(/@toMeasure\b/gi, routeToMeasure)
					.replace(/@routeId\b/gi, routeName);
			}
			else if(this._allLayerInfo[layerID].type=="esriNonLRSLayer" )
			{
				var assetTemplate:Object = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getAssetDataTemplateByEventLayerID(layerID);
				if(assetTemplate.TO_MEASURE_COLUMN)
					_query.linearEventWhereClause
						.replace(/@routeIdFieldName\b/gi, assetTemplate.ROUTE_ID_COLUMN)
						.replace(/@fromMeasureFieldName\b/gi, assetTemplate.FROM_MEASURE_COLUMN)
						.replace(/@toMeasureFieldName\b/gi, assetTemplate.TO_MEASURE_COLUMN)
						.replace(/@fromMeasure\b/gi, routeFromMeasure)
						.replace(/@toMeasure\b/gi, routeToMeasure)
						.replace(/@routeId\b/gi, routeName)
				else
					whereClause= _query.pointEventWhereClause
					.replace(/@routeIdFieldName\b/gi, assetTemplate.ROUTE_ID_COLUMN)
					.replace(/@fromMeasureFieldName\b/gi, assetTemplate.FROM_MEASURE_COLUMN)
					.replace(/@fromMeasure\b/gi, routeFromMeasure)
					.replace(/@toMeasure\b/gi, routeToMeasure)
					.replace(/@routeId\b/gi, routeName);
			}
			else  if( this._allLayerInfo[layerID].type=="esriLRSCalibrationPointLayer" || this._allLayerInfo[layerID].type=="esriLRSIntersectionLayer")
			{
				whereClause= _query.pointEventWhereClause
					.replace(/@routeIdFieldName\b/gi, this._allLayerInfo[layerID].routeIdFieldName)
					.replace(/@fromMeasureFieldName\b/gi, this._allLayerInfo[layerID].measureFieldName)
					.replace(/@fromMeasure\b/gi, routeFromMeasure)
					.replace(/@toMeasure\b/gi, routeToMeasure)
					.replace(/@routeId\b/gi, routeName);
			}
			else
			{
				
				whereClause = _query.linearEventWhereClause
					.replace(/@routeIdFieldName\b/gi, this._allLayerInfo[layerID].routeIdFieldName)
					.replace(/@fromMeasureFieldName\b/gi, this._allLayerInfo[layerID].fromMeasureFieldName)
					.replace(/@toMeasureFieldName\b/gi, this._allLayerInfo[layerID].toMeasureFieldName)
					.replace(/@fromMeasure\b/gi, routeFromMeasure)
					.replace(/@toMeasure\b/gi, routeToMeasure)
					.replace(/@routeId\b/gi, routeName);
			}
			
			if (this._allLayerInfo[layerID].fromDateFieldName && this._allLayerInfo[layerID].toDateFieldName)
			{
				whereClause = whereClause + ' and ' + _query.dateWhereClause.replace(/@fromDateFieldName\b/gi, this._allLayerInfo[layerID].fromDateFieldName).replace(/@toDateFieldName\b/gi, this._allLayerInfo[layerID].toDateFieldName);
			}
			
			var tempQueryStr:String = URLUtil.objectToString(queryParams,"&");
			tempQueryStr = tempQueryStr.replace(/%40whereClause\b/gi, escape(whereClause));

			return _server.url +_server.mapServer+ _server.endpoints.query.replace(/@layerId/gi, layerID) + '?' + tempQueryStr;
		}
		
		public function getCustomEventUrl(layerID:Number, whereClause:String):String
		{
			var queryParams:Object =  ObjectUtil.clone( _query.params);
			
			var tempQueryStr:String = URLUtil.objectToString(queryParams,"&");
			tempQueryStr = tempQueryStr.replace(/%40whereClause\b/gi, escape(whereClause));
			return _server.url +_server.mapServer+ _server.endpoints.query.replace(/@layerId/gi, layerID) + '?' + tempQueryStr;
		}
		
		public function getCustomEventUrlForPost(layerID:Number):String
		{
			
			return _server.url +_server.mapServer+ _server.endpoints.query.replace(/@layerId/gi, layerID);
		}
		
		public function getFindEventUrl(layerIDList:Array, searchText:String, searchField:String):String
		{
			//searchText=@routeId&contains=true&searchFields=@routeIdFieldName&sr=&layers=@layerIds&layerDefs=&returnGeometry=false&maxAllowableOffset=&geometryPrecision=&dynamicLayers=&returnZ=false&returnM=false&gdbVersion=@gdbVersion&f=pjson
			
			return _server.url +_server.mapServer+ _server.endpoints.find + '?' + _query.findEventWhereCluase
																						.replace(/@layerIds/gi, layerIDList.join(','))
																						.replace(/@searchText/gi, searchText)
																						.replace(/@searchFields/gi, searchField)
																						.replace(/@gdbVersion/gi, _query.params.gdbVersion);
		}
		
		
		public function get networkLayerContext():Object
		{
			return _networkLayerContext;
		}
		
		public function get calibPointLayerContext():Object
		{
			return _calibPointLayerContext;
		}
		
	}
}