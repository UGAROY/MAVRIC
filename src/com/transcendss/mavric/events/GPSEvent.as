package com.transcendss.mavric.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class GPSEvent extends Event
	{
		public static const UPDATE:String = "gpsEvent_Changed";
		
		private var _x:Number;
		private var _y:Number;
		private var _precision:int;
		private var _horizontalPrecision:int;
				
		public function GPSEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}
		
		
		public function get horizantalPosition():int
		{
			return _horizontalPrecision;
		}
		
		public function set horizantalPosition(value:int):void
		{
			_horizontalPrecision = value;
		}
		
		public function get precision():int
		{
			return _precision;
		}

		public function set precision(value:int):void
		{
			_precision = value;
		}

		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			_y = value;
		}

		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			_x = value;
		}

	}
}