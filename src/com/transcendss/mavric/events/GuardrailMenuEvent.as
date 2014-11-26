package com.transcendss.mavric.events
{
	import com.transcendss.transcore.sld.models.components.Materials;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class GuardrailMenuEvent extends Event
	{
		public static const GUARDRAIL_MATERIAL_REQUEST:String = "GuardrailMenuEvent_materialRequest";
		public static const GUARDRAIL_MATERIAL_READY:String = "GuardrailMenuEvent_materialReady";
		public static const GUARDRAIL_PLACEMENT_REQUEST:String = "GuardrailMenuEvent_placementRequest";
		public static const GUARDRAIL_PLACEMENT_READY:String = "GuardrailMenuEvent_placementReady";
		public static const GUARDRAIL_RAIL_PURPOSE_REQUEST:String = "GuardrailMenuEvent_jointlocRequest";
		public static const GUARDRAIL_RAIL_PURPOSE_READY:String = "GuardrailMenuEvent_jointlocReady";
		public static const GUARDRAIL_CONDITION_REQUEST:String = "GuardrailMenuEvent_abutmentRequest";
		public static const GUARDRAIL_CONDITION_READY:String = "GuardrailMenuEvent_abutmentReady";
		public static const GUARDRAIL_GEOTAG_REQUEST:String = "GuardrailMenuEvent_geotagRequest";
		public static const GUARDRAIL_GEOTAG_READY:String = "GuardrailMenuEvent_geotagReady";

		public var serviceURL:String;
		private var _description:Materials;
		private var _dataProviderAC:ArrayCollection = new ArrayCollection();
//		private var _inspHistoryJson:String;
		
		public function GuardrailMenuEvent(type:String, description:Materials = null, bubbles:Boolean = true, cancellable:Boolean = true)
		{
			_description = description;
			super(type, bubbles, cancellable);
		}
		
//		public function get inspHistoryJson():String
//		{
//			return _inspHistoryJson;
//		}
//		
//		public function set inspHistoryJson(value:String):void
//		{
//			_inspHistoryJson = value;
//		}
//		
		public function get description():Materials
		{
			return _description;
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