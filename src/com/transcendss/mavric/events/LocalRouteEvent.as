package com.transcendss.mavric.events
{
	import com.transcendss.mavric.db.CachedElement;
	import com.transcendss.mavric.db.CachedRoute;
	import com.transcendss.transcore.sld.models.components.Route;
	
	import flash.events.Event;
	
	public class LocalRouteEvent extends Event
	{
		public static const LOAD_ROUTE:String = "LocalRouteEvent_load";
		public static const LOAD_1:String = "LRE_Phase1";
		public static const LOAD_2:String = "LRE_Phase2";
		public static const LOAD_3:String = "LRE_Phase3";
		public static const LOAD_4:String = "LRE_Phase4";
		public static const LOAD_5:String = "LRE_Phase5";
		public static const LOAD_6:String = "LRE_Phase6";
		public static const LOAD_7:String = "LRE_Phase7";
		public static const LOAD_8:String = "LRE_Phase8";
		
		private var _routePkId:Number;
		private var _begin:Number;
		private var _end:Number;
		
		private var _cachedRoute:CachedRoute;
		private var _stickElement:CachedElement;
		private var _invElement:CachedElement;
		
		public var evtRoute:Route;
		
		public function LocalRouteEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

		public function get routePkId():Number
		{
			return _routePkId;
		}

		public function set routePkId(value:Number):void
		{
			_routePkId = value;
		}

		public function get begin():Number
		{
			return _begin;
		}

		public function set begin(value:Number):void
		{
			_begin = value;
		}

		public function get end():Number
		{
			return _end;
		}

		public function set end(value:Number):void
		{
			_end = value;
		}

		public function get cachedRoute():CachedRoute
		{
			return _cachedRoute;
		}

		public function set cachedRoute(value:CachedRoute):void
		{
			_cachedRoute = value;
		}

		public function get stickElement():CachedElement
		{
			return _stickElement;
		}

		public function set stickElement(value:CachedElement):void
		{
			_stickElement = value;
		}

		public function get invElement():CachedElement
		{
			return _invElement;
		}

		public function set invElement(value:CachedElement):void
		{
			_invElement = value;
		}


	}
}