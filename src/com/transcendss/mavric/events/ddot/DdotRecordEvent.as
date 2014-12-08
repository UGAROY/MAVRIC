package com.transcendss.mavric.events.ddot
{
	
	import flash.events.Event;
	
	import mx.rpc.IResponder;
	
	public class DdotRecordEvent extends Event
	{
		private var _supportID:Number;
		private var _eventLayerID:Number;
		private var _serviceURL:String;
		private var _responder:IResponder;
		
		public static const SIGN_REQUEST:String="relatedSign_event";
		public static const INSPECTION_REQUEST:String="relatedInspection_event";
		
		public function DdotRecordEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}


		public function get serviceURL():String
		{
			return _serviceURL;
		}

		public function set serviceURL(value:String):void
		{
			_serviceURL = value;
		}

		public function get responder():IResponder
		{
			return _responder;
		}

		public function set responder(value:IResponder):void
		{
			_responder = value;
		}

		public function get eventLayerID():Number
		{
			return _eventLayerID;
		}

		public function set eventLayerID(value:Number):void
		{
			_eventLayerID = value;
		}

		public function get supportID():Number
		{
			return _supportID;
		}

		public function set supportID(value:Number):void
		{
			_supportID = value;
		}

	}
}