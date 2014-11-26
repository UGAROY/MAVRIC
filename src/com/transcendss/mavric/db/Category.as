package com.transcendss.mavric.db
{
	public class Category
	{
		private var _id:Number;
		private var _desription:String;
		private var _type:Number;
		private var _diagram_location:Number;
		private var _cached_route_id:Number;
		private var _data_type:Number;
		
		public function Category()
		{
		}

		public function get data_type():Number
		{
			return _data_type;
		}

		public function set data_type(value:Number):void
		{
			_data_type = value;
		}

		public function get cached_route_id():Number
		{
			return _cached_route_id;
		}

		public function set cached_route_id(value:Number):void
		{
			_cached_route_id = value;
		}

		public function get diagram_location():Number
		{
			return _diagram_location;
		}

		public function set diagram_location(value:Number):void
		{
			_diagram_location = value;
		}

		public function get type():Number
		{
			return _type;
		}

		public function set type(value:Number):void
		{
			_type = value;
		}

		public function get desription():String
		{
			return _desription;
		}

		public function set desription(value:String):void
		{
			_desription = value;
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