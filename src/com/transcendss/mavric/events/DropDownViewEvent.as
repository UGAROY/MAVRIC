package com.transcendss.mavric.events
{
	import flash.events.Event;
	
	public class DropDownViewEvent extends Event
	{
		public static const SIGN_SELECTED:String = "sign_selectedEvent";
		public static const CATEGORYSELCTED:String = "category_selectedEvent";
		public static const SUBCATEGORYSELCTED:String = "sub_cat_selectedEvent";
		public static const SUBCATBUTEVENT:String = "sub_cat_clickEvent";
		
		public static const CUSBUTFUNCEVENT:String = "callCustomButtonFunctionEvent";
		public static const POSTTYPESELEVENT:String = "postTypeisSelectedEvent";
		
		public static const NUMSIGNSSELEVENT:String = "numsignsisSelectedEvent";
		
		private var _category:String;
		private var _subcat:String;
		private var _Width:Number;
		private var _Height:Number;
		private var _color:String;
		private var _description:String;
		private var _mutcdID:Number;
		private var _dimensionID:String;
		private var _colorID:String;
		
		
		public function DropDownViewEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}

		public function get description():String
		{
			return _description;
		}

		public function set description(value:String):void
		{
			_description = value;
		}

		public function get color():String
		{
			return _color;
		}

		public function set color(value:String):void
		{
			_color = value;
		}

		public function get Width():Number
		{
			return _Width;
		}

		public function set Width(value:Number):void
		{
			_Width = value;
		}

		public function get subcat():String
		{
			return _subcat;
		}

		public function set subcat(value:String):void
		{
			_subcat = value;
		}

		public function get category():String
		{
			return _category;
		}

		public function set category(value:String):void
		{
			_category = value;
		}

		public function get Height():Number
		{
			return _Height;
		}

		public function set Height(value:Number):void
		{
			_Height = value;
		}
		
		
		public function get mutcdID():Number
		{
			return _mutcdID;
		}
		
		public function set mutcdID(value:Number):void
		{
			_mutcdID = value;
		}
		
		
		public function get dimensionID():String
		{
			return _dimensionID;
		}
		
		public function set dimensionID(value:String):void
		{
			_dimensionID = value;
		}
		
		
		public function get colorID():String
		{
			return _colorID;
		}
		
		public function set colorID(value:String):void
		{
			_colorID = value;
		}

	}
}