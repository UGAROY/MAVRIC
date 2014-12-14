package com.transcendss.mavric.events.ddot
{
	
	import flash.events.Event;
	
	import mx.rpc.IResponder;
	
	public class DdotRecordEvent extends Event
	{
		private var _supportID:Number;
		private var _supportIDs:Array;
		private var _signID:Number;
		private var _signIDs:Array;
		private var _eventLayerID:Number;
		private var _serviceURL:String;
		private var _responder:IResponder;
		
		public static const SIGN_REQUEST:String="relatedSign_event";
		public static const INSPECTION_REQUEST:String="relatedInspection_event";
		public static const OTHER_SIGN_REQUEST:String="otherSign_event";
		public static const LINK_REQUEST:String="link_event";
		
		public function DdotRecordEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}


		public function get signID():Number
		{
			return _signID;
		}

		public function set signID(value:Number):void
		{
			_signID = value;
		}

		public function get supportIDs():Array
		{
			return _supportIDs;
		}

		public function set supportIDs(value:Array):void
		{
			_supportIDs = value;
		}

		public function get signIDs():Array
		{
			return _signIDs;
		}

		public function set signIDs(value:Array):void
		{
			_signIDs = value;
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