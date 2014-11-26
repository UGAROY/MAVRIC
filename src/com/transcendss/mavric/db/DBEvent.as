package com.transcendss.mavric.db
{
	public class DBEvent
	{
		private var _id:Number;
		private var _type_id:Number;
		private var _begin_milepoint:Number;
		private var _end_milepoint:Number;
		private var _creation_date:Date;
		
		public function DBEvent()
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

		public function get end_milepoint():Number
		{
			return _end_milepoint;
		}

		public function set end_milepoint(value:Number):void
		{
			_end_milepoint = value;
		}

		public function get begin_milepoint():Number
		{
			return _begin_milepoint;
		}

		public function set begin_milepoint(value:Number):void
		{
			_begin_milepoint = value;
		}

		public function get type_id():Number
		{
			return _type_id;
		}

		public function set type_id(value:Number):void
		{
			_type_id = value;
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