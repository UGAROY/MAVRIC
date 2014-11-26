package com.transcendss.mavric.db
{
	public class DataEdit
	{
		private var _id:Number;
		private var _category_id:Number;
		private var _text_value:String;
		private var _numeric_value:Number;
		private var _creation_date:Date;
		
		public function DataEdit()
		{
		}

		public function get creation_date():Date
		{
			return _creation_date;
		}

		public function set creation_date(value:Date):void
		{
			_creation_date = value;
		}

		public function get numeric_value():Number
		{
			return _numeric_value;
		}

		public function set numeric_value(value:Number):void
		{
			_numeric_value = value;
		}

		public function get text_value():String
		{
			return _text_value;
		}

		public function set text_value(value:String):void
		{
			_text_value = value;
		}

		public function get category_id():Number
		{
			return _category_id;
		}

		public function set category_id(value:Number):void
		{
			_category_id = value;
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