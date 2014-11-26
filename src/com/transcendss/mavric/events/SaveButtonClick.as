package com.transcendss.mavric.events
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class SaveButtonClick extends MouseEvent
	{
		public static const CLICKED:String = "SaveButtonClick_clicked";
		private var textValue:*;
		
		public function SaveButtonClick(type:String, value:* = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			textValue = value;
		}
		
		public function get textVal():*{
			return textValue;
		} 
		
		public function set textVal(val:*):void{
			textValue= textVal;
		}
	}
}