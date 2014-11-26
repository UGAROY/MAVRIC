package com.transcendss.mavric.db
{
	public class Type
	{
		private var _id:Number;
		private var _value:Number;
		private var _description:String;
		
		public function Type()
		{
		}

		public function get description():String
		{
			return _description;
		}

		public function set description(value:String):void
		{
			_description = value;
		}

		public function get value():Number
		{
			return _value;
		}

		public function set value(value:Number):void
		{
			_value = value;
		}

		public function get id():Number
		{
			return _id;
		}

		public function set id(value:Number):void
		{
			_id = value;
		}

	}
}