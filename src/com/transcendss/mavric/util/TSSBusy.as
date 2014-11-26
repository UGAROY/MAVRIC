package com.transcendss.mavric.util
{
	
	import skins.TSSBusySkin1;
	
	import spark.components.SkinnableContainer;
	
	[SkinState("busy")]
	
	public class TSSBusy extends SkinnableContainer {
		
		public function TSSBusy() {
			super();
			setStyle("skinClass", TSSBusySkin1);
		}
		
		private var _busy:Boolean = false;
		public function set busy(val:Boolean):void {
			if(val != _busy){
				_busy = val;
				invalidateSkinState();
			}
		}
		public function get busy():Boolean {
			return _busy;
		}
		
		override protected function getCurrentSkinState():String {
			var skinState:String = super.getCurrentSkinState();
			if(_busy){
				skinState =  "busy";
			}
			return skinState;
		}
	}
}