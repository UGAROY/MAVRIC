package com.transcendss.mavric.events
{
	import com.transcendss.transcore.util.TSSPicture;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import spark.primitives.BitmapImage;
	
	public class SignInvEvent extends Event
	{
		public static const NEWSIGNEVENT:String = "signInvEvent_NewSignEvent";
		//public static const CUSBUTFUNCEVENT:String = "callCustomButtonFunctionEvent";
		//public static const POSTTYPESELEVENT:String = "postTypeisSelectedEvent";
		
		private var _tsspicture:TSSPicture;
		private var _beginmp:Number;
		private var _endmp:Number;
		private var _type:Number;
		private var _img:BitmapImage;
		private var _mutcd:String;
		
		private var _geoTags:ArrayCollection = new ArrayCollection();
		private var _signs:ArrayCollection = new ArrayCollection();
				
		public function SignInvEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}


		public function get mutcd():String
		{
			return _mutcd;
		}

		public function set mutcd(value:String):void
		{
			_mutcd = value;
		}

		public function get img():BitmapImage
		{
			return _img;
		}

		public function set img(value:BitmapImage):void
		{
			_img = value;
			this.tsspicture = new TSSPicture();
			this.tsspicture.source = img.bitmapData;
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
		
		public function set geoTags(arr:ArrayCollection):void
		{
			_geoTags= arr;	
		}
		public function get geoTags():ArrayCollection
		{
			return _geoTags;
		}
		public function set signs(arr:ArrayCollection):void
		{
			_signs= arr;	
		}
		public function get signs():ArrayCollection
		{
			return _signs;
		}
	}
}