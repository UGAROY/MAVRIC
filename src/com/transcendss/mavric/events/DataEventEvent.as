package com.transcendss.mavric.events
{
	import com.transcendss.transcore.util.TSSPicture;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class DataEventEvent extends Event
	{
		public static const NEWPOINTEVENT:String = "dataEventEvent_NewPointEvent";
		public static const NEWLINEAREVENTSTART:String = "dataEventEvent_NewLinearEventStart";
		public static const NEWLINEAREVENTEND:String = "dataEventEvent_NewLinearEventEnd";
		

		private var _tsspicture:TSSPicture;
		private var _beginmp:Number;
		private var _endmp:Number;
		private var _type:Number;
		private var _endtype:Number = -1;
		
		[Embed(source="/images/sld/96px-Speed_Limit_25_sign.svg.png")] protected var speed_25:Class
		[Embed(source="/images/sld/96px-Speed_Limit_30_sign.svg.png")] protected var speed_30:Class
		[Embed(source="/images/sld/96px-Speed_Limit_35_sign.svg.png")] protected var speed_35:Class
		[Embed(source="/images/sld/96px-Speed_Limit_40_sign.svg.png")] protected var speed_40:Class
		[Embed(source="/images/sld/96px-Speed_Limit_45_sign.svg.png")] protected var speed_45:Class
		[Embed(source="/images/sld/96px-Speed_Limit_50_sign.svg.png")] protected var speed_50:Class
		[Embed(source="/images/sld/96px-Speed_Limit_55_sign.svg.png")] protected var speed_55:Class
		[Embed(source="/images/sld/96px-Speed_Limit_60_sign.svg.png")] protected var speed_60:Class
		[Embed(source="/images/sld/96px-Speed_Limit_65_sign.svg.png")] protected var speed_65:Class
		[Embed(source="/images/sld/96px-Speed_Limit_70_sign.svg.png")] protected var speed_70:Class
		[Embed(source="/images/sld/96px-Speed_Limit_75_sign.svg.png")] protected var speed_75:Class
		[Embed(source="/images/sld/96px-Speed_Limit_80_sign.svg.png")] protected var speed_80:Class
		[Embed(source="/images/sld/bridge.png")] protected var bridge:Class
		[Embed(source="/images/sld/fc1.png")] protected var fc1:Class
		[Embed(source="/images/sld/fc2.png")] protected var fc2:Class
		[Embed(source="/images/sld/fc8.png")] protected var fc6:Class
		[Embed(source="/images/sld/fc7.png")] protected var fc7:Class
		[Embed(source="/images/sld/fc8.png")] protected var fc8:Class
		[Embed(source="/images/sld/fc9.png")] protected var fc9:Class
		[Embed(source="/images/sld/fc11.png")] protected var fc11:Class
		[Embed(source="/images/sld/fc12.png")] protected var fc12:Class
		[Embed(source="/images/sld/fc14.png")] protected var fc14:Class
		[Embed(source="/images/sld/fc16.png")] protected var fc16:Class
		[Embed(source="/images/sld/fc17.png")] protected var fc17:Class
		[Embed(source="/images/sld/rrxing1.png")] protected var rrxing1:Class
		[Embed(source="/images/sld/rrxing2.png")] protected var rrxing2:Class
		[Embed(source="/images/sld/access_pt.png")] protected var access_pt_rt:Class
		[Embed(source="/images/sld/access_pt_lft.png")] protected var access_pt_lft:Class
		[Embed(source="/images/sld/culvert_cross.png")] protected var culvert_cross:Class
		[Embed(source="/images/sld/culvert_parallel.png")] protected var culvert_parallel:Class
		
				
		public function DataEventEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}


		public function get endtype():Number
		{
			return _endtype;
		}

		public function set endtype(value:Number):void
		{
			_endtype = value;
		}

		public function get datatype():Number
		{
			return _type;
		}

		public function set datatype(value:Number):void
		{
			_type = value;
		}

		public function get endmp():Number
		{
			return _endmp;
		}

		public function set endmp(value:Number):void
		{
			_endmp = value;
		}

		public function get beginmp():Number
		{
			return _beginmp;
		}

		public function set beginmp(value:Number):void
		{
			_beginmp = value;
		}

		public function get tsspicture():TSSPicture
		{
			return _tsspicture;
		}

		public function set tsspicture(value:TSSPicture):void
		{
			_tsspicture = value;
		}
		
		public function getTypeIcon():Class
		{
			if (_type == 1 || _type == 1001)
				return speed_25;
			else if (_type == 2 || _type == 1002)
				return speed_30;
			else if (_type == 3 || _type == 1003)
				return speed_35;
			else if (_type == 4 || _type == 1004)
				return speed_40;
			else if (_type == 5 || _type == 1005)
				return speed_45;
			else if (_type == 6 || _type == 1006)
				return speed_50;
			else if (_type == 7 || _type == 1007)
				return speed_55;
			else if (_type == 8 || _type == 1008)
				return speed_60;
			else if (_type == 9 || _type == 1009)
				return speed_65;
			else if (_type == 10 || _type == 1010)
				return speed_70;
			else if (_type == 11 || _type == 1011)
				return speed_75;
			else if (_type == 12 || _type == 1012)
				return speed_80;
			else if (_type == 1021)
				return bridge;
			else if (_type == 1022)
				return bridge;
			else if (_type == 1023)
				return bridge;
			else if (_type == 1024)
				return bridge;
			else if (_type == 1025)
				return bridge;
			else if (_type == 21)
				return fc1;
			else if (_type == 22)
				return fc2;
			else if (_type == 23)
				return fc6;
			else if (_type == 24)
				return fc7;
			else if (_type == 25)
				return fc8;
			else if (_type == 26)
				return fc9;
			else if (_type == 27)
				return fc11;
			else if (_type == 28)
				return fc12;
			else if (_type == 29)
				return fc14;
			else if (_type == 30)
				return fc16;
			else if (_type == 31)
				return fc17;
			else if (_type == 1031)
				return rrxing1;
			else if (_type == 1031)
				return rrxing2;
			else if (_type == 1301)
				return access_pt_lft;
			else if (_type == 1302)
				return access_pt_rt;
			else if (_type == 1101)
				return culvert_cross;
			else if (_type == 1102)
				return culvert_parallel;
			else if (_type == 1103)
				return culvert_parallel;
			else
				return null;
			
		}

		public function getEndTypeIcon():Class
		{
			if (_endtype == 1 || _endtype == 1001)
				return speed_25;
			else if (_endtype == 2 || _endtype == 1002)
				return speed_30;
			else if (_endtype == 3 || _endtype == 1003)
				return speed_35;
			else if (_endtype == 4 || _endtype == 1004)
				return speed_40;
			else if (_endtype == 5 || _endtype == 1005)
				return speed_45;
			else if (_endtype == 6 || _endtype == 1006)
				return speed_50;
			else if (_endtype == 7 || _endtype == 1007)
				return speed_55;
			else if (_endtype == 8 || _endtype == 1008)
				return speed_60;
			else if (_endtype == 9 || _endtype == 1009)
				return speed_65;
			else if (_endtype == 10 || _endtype == 1010)
				return speed_70;
			else if (_endtype == 11 || _endtype == 1011)
				return speed_75;
			else if (_endtype == 12 || _endtype == 1012)
				return speed_80;
			else if (_endtype == 1021)
				return bridge;
			else if (_endtype == 1022)
				return bridge;
			else if (_endtype == 1023)
				return bridge;
			else if (_endtype == 1024)
				return bridge;
			else if (_endtype == 1025)
				return bridge;
			else if (_endtype == 21)
				return fc1;
			else if (_endtype == 22)
				return fc2;
			else if (_endtype == 23)
				return fc6;
			else if (_endtype == 24)
				return fc7;
			else if (_endtype == 25)
				return fc8;
			else if (_endtype == 26)
				return fc9;
			else if (_endtype == 27)
				return fc11;
			else if (_endtype == 28)
				return fc12;
			else if (_endtype == 29)
				return fc14;
			else if (_endtype == 30)
				return fc16;
			else if (_endtype == 31)
				return fc17;
			else if (_endtype == 1031)
				return rrxing1;
			else if (_endtype == 1031)
				return rrxing2;
			else
				return null;
			
		}

	}
}