package com.transcendss.mavric.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class GestureControlEvent extends Event
	{
		public static const CHANGED:String = "gestureEvent_Changed";
		
		private var _gestures:Boolean;
		
				
		public function GestureControlEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}
	

		public function get gestures():Boolean
		{
			return _gestures;
		}

		public function set gestures(value:Boolean):void
		{
			_gestures = value;
		}

	}
}