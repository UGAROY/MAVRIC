package com.transcendss.mavric.db
{
	import com.google.maps.services.Route;
	import com.transcendss.mavric.extended.models.MAVRICDiagram;
	import com.transcendss.mavric.managers.AssetManager;
	import com.transcendss.mavric.util.TSSRectangle;
	import com.transcendss.transcore.sld.models.InventoryDiagram;
	import com.transcendss.transcore.sld.models.StickDiagram;
	import com.transcendss.transcore.sld.models.components.GeoTag;
	import com.transcendss.transcore.sld.models.managers.GeotagsManager;
	
	import flash.geom.Rectangle;
	
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