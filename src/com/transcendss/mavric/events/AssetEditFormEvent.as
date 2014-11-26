package com.transcendss.mavric.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class AssetEditFormEvent extends Event
	{
		public static const DOMAIN_REQUEST:String = "domain_request";
		public static const GEOTAG_REQUEST:String = "geotag_request";
		public static const GEOTAG_READY:String = "geotag_ready";
		private var _domain:String;
		public var serviceURL:String;
		private var _dataProviderAC:ArrayCollection = new ArrayCollection();
		
		public function AssetEditFormEvent(domain:String, type:String, bubbles:Boolean=true, cancelable:Boolean=true, ac:ArrayCollection = null)
		{
			super(type, bubbles, cancelable);
			_domain = domain;
			_dataProviderAC = ac;
		}

		public function get domain():String
		{
			return _domain;
		}

		public function set domain(value:String):void
		{
			_domain = value;
		}
		public function get dataProviderAC():ArrayCollection
		{
			return _dataProviderAC;
		}
		
		public function set dataProviderAC(value:ArrayCollection):void
		{
			_dataProviderAC = value;
		}
	}
}