package com.transcendss.mavric.events
{
	import flash.events.Event;	
	import com.transcendss.mavric.extended.models.Components.AccessPoint;
	
	public class AccessPointEvent extends Event
	{
		
		public static const NEWACCESSPOINT:String="newAccessPoint_event";
		private var _apType:int;
		
		public function AccessPointEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}

		public function get apType():int
		{
			return _apType;
		}

		public function set apType(value:int):void
		{
			_apType = value;
		}

	}
}