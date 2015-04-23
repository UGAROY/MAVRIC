package com.transcendss.mavric.db
{
	import com.transcendss.mavric.extended.models.MAVRICDiagram;
	import com.transcendss.mavric.managers.AssetManager;
	import com.transcendss.mavric.util.TSSRectangle;
	import com.transcendss.transcore.sld.models.InventoryDiagram;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	
	public class CachedRoute
	{
		private var _id:Number;
		private var _routeid:String;
		private var _beginmile:Number;
		private var _endmile:Number;
		private var _content:String;
		private var _points:String;
		private var _bbox:String;
		private var _boundary:String;
		private var _routeName:String;
		
		
		public static function generateFromServices(route:Object, xing:String, coords:String, feats:ArrayCollection, boundary:String = null, gtagsC:ArrayCollection = null):CachedRoute
		{
			var compatRouteObj:Object = {route: {routeName: route.ROUTE_NAME, beginMi: route.BEGIN_MP, endMi: route.END_MP, routeNumber: route.D_ROUTE_ID}}; 
			var compatRouteJSON:String = JSON.stringify(compatRouteObj);
			
			var mastarr:Array = new Array();
			xing = xing.replace("\\", "/");
			var assetMan:AssetManager = FlexGlobals.topLevelApplication.GlobalComponents.assetManager;
			
			if(xing != "")
			{
				var pxing:Object = JSON.parse(xing);
				
				
				
				for (var type:String in assetMan.assetDescriptions)
				{
					try
					{
						var mastobj:Object = new Object();
						mastobj.ArrayColl = pxing[type];
						mastobj.Name = type;
						mastarr.push(mastobj);
					}
					catch (er:Error)
					{
						trace("WARNING: JSON XING Data for route: " + route.ROUTE_NAME + "is invalid! The service needs to be fixed.");
						return null;	
					}
				}
			}
			
			var xingFeatsJSON:String = JSON.stringify(mastarr);
			
			var invMenu:InventoryDiagram = new InventoryDiagram();
			var featsArc:ArrayCollection = feats as ArrayCollection;
			
			for each (var arr1:Array in featsArc)
			{
				invMenu.drawElemsFrmSrvceRes(new ArrayCollection(arr1), true);
			}
			
			var invElemsJSON:String = invMenu.invElementsToJSON();
			
			
			var cRoute:CachedRoute = new CachedRoute();
			cRoute.routeid = route.ROUTE_NAME;
			cRoute.beginmile = route.BEGIN_MP;
			cRoute.endmile = route.END_MP;
			
			cRoute.content = compatRouteJSON;
			cRoute.path = coords;
			cRoute.boundary = boundary;
			var bbox:TSSRectangle = MAVRICDiagram.getBoundingBox(new ArrayCollection(JSON.parse(coords) as Array));
			cRoute.bbox = JSON.stringify(bbox);
			
			var cStickElement:CachedElement = new CachedElement();
			cStickElement.type = 1;
			cStickElement.description = "stick elements";
			cStickElement.content = xingFeatsJSON;
			
			var cInvElement:CachedElement = new CachedElement();
			cInvElement.type = 2;
			cInvElement.description = "inventory elements";
			cInvElement.content = invElemsJSON;
			
			
			assetMan.cacheRoute(cRoute, cStickElement, cInvElement);
			if(gtagsC.length>0)
			{
				var gtags:Array = gtagsC[0];
				assetMan.cacheGeotags(gtags,false);
			}
			return cRoute;
		}
		
		public static function generateFromAgsServices(route:Object, xing:Object, coords:Object, feats:Object, boundary:String = null, gtagsC:ArrayCollection = null, subObjs:Object=null):CachedRoute
		{
			var compatRouteObj:Object = {route: {routeName: route.routeName, beginMi: route.beginMi, endMi: route.endMi, routeNumber: route.routeName}}; 
			var compatRouteJSON:String = JSON.stringify(compatRouteObj);
			
			var mastarr:Array = new Array();
			//xing = xing.replace("\\", "/");
			var assetMan:AssetManager = FlexGlobals.topLevelApplication.GlobalComponents.assetManager;
			
			//			if(xing != "")
			//			{
			
			for (var type:String in assetMan.assetDescriptions)
			{
				try
				{
					var mastobj:Object = new Object();
					var features:Array
					if(xing[assetMan.assetDescriptions[type]])
						features = JSON.parse(xing[assetMan.assetDescriptions[type]]).features;
					else
						features = new Array();
					mastobj.ArrayColl = new Array();
					for each(var asset:Object in features)
					mastobj.ArrayColl.push(asset.attributes);
					mastobj.Name = type;
					mastarr.push(mastobj);
				}
				catch (er:Error)
				{
					trace("WARNING: JSON XING Data for route: " + route.routeName + "is invalid! The service needs to be fixed.");
					throw new Error("Asset caching failed");
				}
			}
			//			}
			
			var xingFeatsJSON:String = JSON.stringify(mastarr);
			
			var invMenu:InventoryDiagram = new InventoryDiagram();
			var featsArc:ArrayCollection = new ArrayCollection();
			
			
			try
			{
				var elemDesc:Object =assetMan.barElementDescriptions;
				for each (var elemType in elemDesc)
				{
					if(!feats[elemType])
						continue;
					var temp:Array = new Array();
					var arrayColl:ArrayCollection = new ArrayCollection();
					var elems:Array= feats[elemType].features;
					for each(var feature:Object in elems)
					temp.push(feature.attributes);
					//var atName = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.getBarElemLabel(event["elementType"]);
					arrayColl.addItem({"ID":elemType, "ATT_NAME": FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.getBarElemLabel(elemType), "DATA" : temp});	
					
					invMenu.drawElemsFrmSrvceRes(arrayColl, true);
				}
			}
			catch (er:Error)
			{
				trace("WARNING: JSON Elemetns Data for route: " + route.routeName + "is invalid! The service needs to be fixed.");
				throw new Error("Element caching failed");
			}
			var invElemsJSON:String = invMenu.invElementsToJSON();
			
			
			var cRoute:CachedRoute = new CachedRoute();
			cRoute.routeid = route.routeName;
			cRoute.beginmile = route.beginMi;
			cRoute.endmile = route.endMi;
			
			cRoute.content = compatRouteJSON;
			cRoute.path = JSON.stringify(coords);
			cRoute.boundary = boundary;
			
			try
			{
				var coordArr:Array = coords as Array;
				if(coordArr.length >0)
					{
				var bbox:TSSRectangle = MAVRICDiagram.getBoundingBox(new ArrayCollection(coordArr));
				cRoute.bbox = JSON.stringify(bbox);
					}
					else
						cRoute.bbox = null;
			}
			catch (er:Error)
			{
				trace("WARNING: BBOX Data for route: " + route.routeName + "is invalid! The service needs to be fixed.");
				throw new Error("Coordinates caching failed for " + route.routeName);
			}
			var cStickElement:CachedElement = new CachedElement();
			cStickElement.type = 1;
			cStickElement.description = "stick elements";
			cStickElement.content = xingFeatsJSON;
			
			var cInvElement:CachedElement = new CachedElement();
			cInvElement.type = 2;
			cInvElement.description = "inventory elements";
			cInvElement.content = invElemsJSON;
			
			var signElement:CachedElement = new CachedElement();
			var timeRes:CachedElement = new CachedElement();
			var supp:CachedElement = new CachedElement();
			var links:CachedElement = new CachedElement();
			
			try
			{
				if(subObjs)
				{
					
					signElement.type = 3;
					signElement.description = "signs";
					signElement.content = JSON.stringify(subObjs.signs);
					
					
					timeRes.type = 4;
					timeRes.description = "time restrictions";
					timeRes.content = JSON.stringify(subObjs.timeRes);
					
					
					supp.type = 5;
					supp.description = "support inspections";
					supp.content = JSON.stringify(subObjs.insp);
					
					
					links.type = 6;
					links.description = "links";
					links.content = JSON.stringify(subObjs.links);
					
					
				}
			}
			catch (er:Error)
			{
				trace("WARNING: JSON XING Data for route: " + route.routeName + "is invalid! The service needs to be fixed.");
				throw new Error("Other Asset caching failed");
			}
			
			try
			{
				
				assetMan.cacheDDOTRoute(cRoute, cStickElement, cInvElement, signElement, timeRes,supp, links);
				
			}
			catch (er:Error)
			{
				
				throw new Error("Error saving route to local database");
			}
			try
			{
				
				
				assetMan.cacheDDOTGeotags2(gtagsC.source);
			}
			catch (er:Error)
			{
				trace("WARNING: Attachment Data for route: " + route.routeName + "is invalid! The service needs to be fixed.");
				throw new Error("Error saving attachments");
			}
			
			return cRoute;
		}
		
		
		public function CachedRoute()
		{
		}
		
		public function get content():String
		{
			return _content;
		}
		
		public function set content(value:String):void
		{
			_content = value;
		}
		
		public function get endmile():Number
		{
			return _endmile;
		}
		
		public function set endmile(value:Number):void
		{
			_endmile = value;
		}
		
		public function get beginmile():Number
		{
			return _beginmile;
		}
		
		public function set beginmile(value:Number):void
		{
			_beginmile = value;
		}
		
		public function get routeid():String
		{
			return _routeid;
		}
		
		public function set routeid(value:String):void
		{
			_routeid = value;
		}
		
		public function get routeName():String
		{
			return _routeName;
		}
		
		public function set routeName(value:String):void
		{
			_routeName = value;
		}
		
		public function get id():Number
		{
			return _id;
		}
		
		public function set id(value:Number):void
		{
			_id = value;
		}
		
		public function get path():String
		{
			return _points;
		}
		
		public function set path(value:String):void
		{
			_points = value;
		}
		
		public function get bbox():String
		{
			return _bbox;
		}
		
		public function set bbox(value:String):void
		{
			_bbox = value;
		}
		
		public function get boundary():String
		{
			return _boundary;
		}
		
		public function set boundary(value:String):void
		{
			_boundary = value;
		}
		
		
	}
}