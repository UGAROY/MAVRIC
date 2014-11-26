package com.transcendss.mavric.db
{
	public class CachedElement
	{
		private var _id:Number;
		private var _type:int;
		private var _description:String;
		private var _content:String;
		
		public function CachedElement()
		{
		}
		
		public function get id():Number
		{
			return _id;
		}
		
		public function set id(value:Number):void
		{
			_id = value;
		}
		
		public function get type():int
		{
			return _type;
		}
		
		public function set type(value:int):void
		{
			_type = value;
		}

		public function get description():String
		{
			return _description;
		}

		public function set description(value:String):void
		{
			_description = value;
		}

		public function get content():String
		{
			return _content;
		}
		
		public function set content(value:String):void
		{
			_content = value;
		}

	}
}