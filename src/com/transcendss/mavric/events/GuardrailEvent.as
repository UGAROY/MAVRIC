package com.transcendss.mavric.events
{
	
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class GuardrailEvent extends Event
	{
		private var _guardrail:BaseAsset;
		private var _data:Object;
		private var _id:Number;
		private var _gtArray:ArrayCollection;
		private var _saveGuardrail:Boolean;
		private var _routeFullName:String;
		
		public static const NEW_GUARDRAIL:String="newGuardrail_event";
		public static const GUARDRAIL_FORM_LOADED:String="guardrailFormLoaded_event";
		public static const NEW_GUARDRAIL_INSERTED:String="newGuardrailInserted_event";
		
		public function get saveGuardrail():Boolean
		{
			return _saveGuardrail;
		}

		public function set saveGuardrail(value:Boolean):void
		{
			_saveGuardrail = value;
		}

		public function get guardrail():BaseAsset
		{
			return _guardrail;
		}

		public function set guardrail(value:BaseAsset):void
		{
			_guardrail = value;
		}

		public function GuardrailEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
			_saveGuardrail = true;
			
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
		
		public function get routeFullName():String
		{
			return _routeFullName;
		}
		
		public function set routeFullName(value:String):void
		{
			_routeFullName = value;
		}
		
	}
}