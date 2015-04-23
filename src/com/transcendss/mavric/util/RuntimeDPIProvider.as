package com.transcendss.mavric.util
{
	import flash.system.Capabilities;
	
	import mx.core.DPIClassification;
	import mx.core.RuntimeDPIProvider;
	
	public class RuntimeDPIProvider extends mx.core.RuntimeDPIProvider
	{
		public function RuntimeDPIProvider()
		{
			super();
		}
		
		override public function get runtimeDPI():Number
			
		{
			
			var os:String =  Capabilities.os;
			
			
			
			if(os.indexOf("iPad") != -1)
				
			{
				
				if(Capabilities.screenResolutionX > 2000 || Capabilities.screenResolutionY > 2000)
					
				{
					
					return  DPIClassification.DPI_320;
					
				} else {
					
					return DPIClassification.DPI_160;
					
				}
				
			} else {
				
				return Capabilities.screenDPI;
				
			}
			
		}
	}
}