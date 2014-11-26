package com.transcendss.mavric.events
{
	
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class AssetEvent extends Event
	{
		private var _cul:BaseAsset;
		private var _data:Object;
		private var _id:Number;
		private var _gtArray:ArrayCollection;
		private var _saveCulvert:Boolean;
		private var _routeFullName:String;
		
		public static const NEWCULVERT:String="newCulvert_event";
		public static const CULVERTFORMLOADED:String="culvertFormLoaded_event";
		public static const NEWCULVERTINSERTED:String="newCulvertInserted_event";
		
		public function AssetEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
			_saveCulvert = true;
			
		}

		public function get geoTags():ArrayCollection
		{
			return _gtArray;
		}
		public function set geoTags(gt:ArrayCollection):void
		{
			 _gtArray= gt;
		}
		public function get id():Number
		{
			return _id;
		}
		
		public function set id(i:Number):void
		{
			_id=i;
		}
		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}

		public function get culvert():BaseAsset
		{
			return _cul;
		}

		public function set culvert(value:BaseAsset):void
		{
			_cul = value;
		}
		
		public function get routeFullName():String
		{
			return _routeFullName;
		}
		
		public function set routeFullName(value:String):void
		{
			_routeFullName = value;
		}

		public function get saveCulvert():Boolean
		{
			return _saveCulvert;
		}

		public function set saveCulvert(value:Boolean):void
		{
			_saveCulvert = value;
		}


	}
}