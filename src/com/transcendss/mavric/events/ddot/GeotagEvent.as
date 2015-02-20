package com.transcendss.mavric.events.ddot
{
	import flash.events.Event;
	
	import mx.rpc.IResponder;

	public class GeotagEvent extends Event
	{
		public static const GEOTAG_REQUEST:String="geotagRequest";
		public static const GEOTAG_INFO_READY:String="geotagReady";
		
		public var assetType:String;
		public var assetId:String;
		public var layerId:String;
		public var fromMeasure:Number;
		public var isInsp:Boolean;
		public var serviceURL:String;
		public var irespond:IResponder;
		public var result:Object;
		
		public function GeotagEvent(type:String,assetTypeP:String,assetIdP:String,isInspP:Boolean,layerIdP:String, fromMeasureP:Number,resultP:Object=null, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			assetType = assetTypeP;
			assetId = assetIdP;
			isInsp = isInspP;
			result = resultP;
			layerId = layerIdP;
			fromMeasure = fromMeasureP;
			super(type, bubbles, cancelable);
		}
		
		
	}
}