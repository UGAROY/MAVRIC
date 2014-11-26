package com.transcendss.mavric.events
{
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	
	import flash.events.Event;
	
	public class SaveEvent extends Event
	{
		public static const ON_SAVE:String = "onSave";
		private var _baseAsset : BaseAsset;
		
		public function SaveEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}
		
		public function set baseAsset(asset:BaseAsset):void
		{
			_baseAsset = asset;	
		}
		
		public function get baseAsset():BaseAsset{
			return _baseAsset;
		}
		
		
	}
}