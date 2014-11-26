package com.transcendss.mavric.events
{
	import flash.events.Event;
	
	public class DomainRetrievalEvent extends Event
	{
		public static const FETCH_DOMAIN:String = "fetch_domain";
		private var _url:String;
		
		public function DomainRetrievalEvent(url:String, type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
			_url = url;
		}

		public function get url():String
		{
			return _url;
		}

		public function set url(value:String):void
		{
			_url = value;
		}

	}
}