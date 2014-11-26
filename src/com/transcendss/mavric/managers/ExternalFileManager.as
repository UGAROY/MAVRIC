package com.transcendss.mavric.managers
{
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.mavric.util.FileUtility;
	import com.transcendss.transcore.events.*;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
//	import mx.controls.Alert;
	import mx.core.*;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	

	public class ExternalFileManager
	{
	
		
		public var dispatcher:IEventDispatcher;
		
		public function ExternalFileManager()
		{
		}
		
		public function dispatchFileContents(arrayColl:ArrayCollection,fileName:String):void
		{
			var event:RouteSelectorEvent;
			switch (fileName){
				case "settings":
					FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.settingsArrayColl = arrayColl;
					break;

				case "menuItems":
					dispatcher.dispatchEvent(new MenuBarEvent(MenuBarEvent.MENU_READY,arrayColl, true, true));
					break;

			}
		}
		
		public function parseConfigFile(event:ExternalFileEvent):void
		{
			event.stopPropagation();
			
			var fileUtil:FileUtility = new FileUtility();
			
			var rawData:String = fileUtil.openFile(event.filePath);
			var ac:ArrayCollection = new ArrayCollection();
			if (rawData.length >0)
			{
				//decode the data to ActionScript using the JSON API
				//in this case, the JSON data is a serialize Array of Objects.
				try{
					var arr:Array = (JSON.parse(rawData)) as Array;
					ac = new ArrayCollection(arr);
				}
				catch( e:Error)
				{
					
				}
				
			}
			dispatchFileContents(ac, event.fileName);
		}
	}
}