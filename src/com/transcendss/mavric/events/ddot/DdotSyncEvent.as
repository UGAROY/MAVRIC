package com.transcendss.mavric.events.ddot
{
	import flash.events.Event;
	
	import mx.core.FlexGlobals;
	public class DdotSyncEvent extends Event
	{
		
		public static const SYNC_REQUESTED:String="newsync_event";
		public static const SYNC_INITIATE:String="initsync_event";
		public static const APPLY_EDITS:String="syncEvent_applyEdits";
		public static const ADD_ATTACHMENTS:String="syncEvent_addAttachments";
		public static const SET_PROCESS_STATUS_ON_SYNC_ERROR:String="set_proc_status_on_error_event";
		
		public var serviceURL:String;
		public var fileUploads:Number=0;
		public var editsJson:String ="";
		public var userName:String = FlexGlobals.topLevelApplication.menuBar.getCurrentUser();
		public var assetTy:String ="";
		public var assetID:String="";
		public var assetPK:String="";
		public var supportID:Number;
		public var signID:Number;
		
		
		public function DdotSyncEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}
		
		
		
	}
}