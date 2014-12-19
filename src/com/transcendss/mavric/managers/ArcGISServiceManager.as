package com.transcendss.mavric.managers
{
	import com.transcendss.transcore.events.ElementEvent;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;

	public class ArcGISServiceManager
	{
		public var dispatcher:IEventDispatcher;
		public function ArcGISServiceManager()
		{
		}
		
		public function getURL(urlFor:String, useAgsService : Boolean=true, eventURL:String="", routeName:String="",begMile:Number=-1,endMile:Number=-1, eventLayerID:Number=-1):String{
			
			var useAgsLatLong:Boolean = ConfigUtility.getBool("use_ags_latlong");
			switch(urlFor)
			{
				case "route":
					return useAgsService ? FlexGlobals.topLevelApplication.agsMapService.getRouteUrl() : eventURL;
				case "latlong":
					return useAgsService || useAgsLatLong ? FlexGlobals.topLevelApplication.agsMapService.getLatLongUrl(routeName) : eventURL;
				case "minmax":
					return useAgsService ? FlexGlobals.topLevelApplication.agsMapService.getMinMaxUrl(routeName) : eventURL;
				case "assetevent":
					return useAgsService && eventLayerID!=-1 ? FlexGlobals.topLevelApplication.agsMapService.getEventUrl(eventLayerID,routeName,begMile,endMile) : eventURL;
				case "milemarker":
					return useAgsService && eventLayerID!=-1 ? FlexGlobals.topLevelApplication.agsMapService.getEventUrl(eventLayerID,routeName,begMile,endMile) : eventURL;
				case "edits":
					return  FlexGlobals.topLevelApplication.agsMapService.getEditsUrl();
					
				default:
					return "";
			}
			
		}
		
		
		public function getAddAttachmentUrl(layerID:String, featureID:String):String
		{
			return  FlexGlobals.topLevelApplication.agsMapService.getAddAttachmentUrl(layerID,featureID);
		}
		
		public function getAttachmentsUrl(layerID:String, featureID:String):String
		{
			return  FlexGlobals.topLevelApplication.agsMapService.getAttachmentsUrl(layerID,featureID);
		}
		
		public function getAttachmentByIDUrl(layerID:String, featureID:String, attachID:String):String
		{
			return  FlexGlobals.topLevelApplication.agsMapService.getAttachmentByIDUrl(layerID,featureID,attachID);
		}
		
		
		public function onRouteListResult(obj:Object,event:Event):ArrayCollection
		{
			var arrayColl:ArrayCollection = new ArrayCollection();
			event.stopPropagation();
			var arr:Array = parseJsonObj(obj);
			for each(var arrItem:Object in arr)
			{
				arrayColl.addItem({ "ROUTE_NAME" : arrItem.attributes[FlexGlobals.topLevelApplication.agsMapService.networkLayerContext.compositeRouteIdFieldName], "ROUTE_FULL_NAME":arrItem.attributes["RTE_COMMON_NM"]});
			}
			return arrayColl;
		}
		
		public function onLatLongResult(obj:Object,event:Event):ArrayCollection
		{
			var arrayColl:ArrayCollection = new ArrayCollection();
			event.stopPropagation();
			var arr:Array = parseJsonObj(obj);
			for each(var arrItem:Object in arr)
			{
				for each (var path:Array in arrItem.geometry.paths as Array)
				{
					// Temporarily fix, just append all the x y coordinations to one arraycollection
					for each (var coord:Array in path)
						arrayColl.addItem({ "X" : String(coord[0]) , "Y" : String(coord[1]), "M" : String(coord[2])});
				}
			}
			return arrayColl;
		}
		
		public function onMinMaxResult(obj:Object,event:Event):ArrayCollection
		{
		
			event.stopPropagation();
			
			var arrayColl:ArrayCollection = new ArrayCollection();
			var min:Number;
			var max:Number;
			
			var arr:Array = parseJsonObj(obj);
			
			min = Math.max(0, new Number(arr[0].attributes[FlexGlobals.topLevelApplication.agsMapService.calibPointLayerContext.measureFieldName]));
			max = new Number(arr[arr.length-1].attributes[FlexGlobals.topLevelApplication.agsMapService.calibPointLayerContext.measureFieldName]);
			arrayColl.addItem({ "MIN" : min, "MAX" : max});
			
			return arrayColl;
		}
		
		
		public function onAssetServiceResult(obj:Object,event:Event):ArrayCollection
		{
			
			
			event.stopPropagation();
			
			var arrayColl:ArrayCollection = new ArrayCollection();
			
			var atName:String="";
			var arr:Array = parseJsonObj(obj);
			var dataArr:Array = new Array();
			for each(var arrItem:Object in arr)
			{
				dataArr.push( arrItem.attributes);
			}
			
		
			if(event is ElementEvent)
			{
				atName = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.getBarElemLabel(event["elementType"]);
				arrayColl.addItem({"ID":event["elementType"], "ATT_NAME": atName, "DATA" : dataArr});
			}
			else
				arrayColl = new ArrayCollection(dataArr)
			return arrayColl;
			
		}
		
		public function onServiceObjResult(Obj:Object, event:Event):Object
		{
			event.stopPropagation();
			var rawData:String = String(Obj);
			
			
			if (rawData.length >0)
			{
				//decode the data to ActionScript using the JSON API
				//in this case, the JSON data is an Object.
				var obj:Object = JSON.parse(rawData);
				return obj;
				
				
				
			}
			return null;
		}
		
		
		public function parseJsonObj(obj:Object):Array
		{
			if(!obj)
				return new Array();
			var rawData:String = String(obj);
			
			var arr:Array = new Array();
			if (rawData.length >0)
			{
				//decode the data to ActionScript using the JSON API
				//in this case, the JSON data is a serialize Array of Objects.
				arr = (JSON.parse(rawData, function(k,value){
					var a;
					if (typeof value === 'string') {
						a = Date.parse(value);
						if (a) {
							return new Date(a);
						}    
					}
					return value;
				}).features) as Array;
			}
			return arr;
		}
		
		
	}
}