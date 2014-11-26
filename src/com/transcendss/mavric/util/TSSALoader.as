package com.transcendss.mavric.util
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import com.transcendss.transcore.util.TSSAudio;
	
	public class TSSALoader extends URLLoader
	{
		private var _audio:TSSAudio;
		public function TSSALoader(request:URLRequest=null)
		{
			super(request);
		}

		public function get audio():TSSAudio
		{
			return _audio;
		}

		public function set audio(value:TSSAudio):void
		{
			_audio = value;
		}

	}
}