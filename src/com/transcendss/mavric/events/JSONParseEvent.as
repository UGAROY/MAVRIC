package com.transcendss.mavric.events
{
	import flash.events.Event;
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	
	public final class JSONParseEvent extends Event
	{
		public static const DRAWSTRING_PARSED:String ="drawstring_parsed";
		private var _drawstringArray : Object;
		private var _asset:BaseAsset;
		
		public function JSONParseEvent(a:BaseAsset,dsa:Object, type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
			_drawstringArray = dsa;
			_asset = a;
		}
		
		
		public function get drawstringArray():Object
		{
			return _drawstringArray;
		}

		public function set drawstringArray(value:Object):void
		{
			_drawstringArray = value;
		}

		public function get asset():BaseAsset
		{
			return _asset;
		}

		public function set asset(value:BaseAsset):void
		{
			_asset = value;
		}


	}
}