package com.transcendss.mavric.managers
{
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.transcore.events.*;
	
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.core.ByteArrayAsset;
	import mx.core.FlexGlobals;
	

	public class MenuManager
	{
		[Bindable]  
		[Embed(source="../../../../../Files/menuItems.txt", mimeType="application/octet-stream")]  
		private var menuItemsClass:Class;
		private var menuItems:ArrayCollection;
		public var dispatcher:IEventDispatcher;
		
		public function MenuManager()
		{
			
		}
		
		public function createMenu(event:MenuBarEvent):void
		{
			var eEvent:ExternalFileEvent;
			
			if(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.wifiConnected)
			{
				eEvent = new ExternalFileEvent(ExternalFileEvent.FILE_REQUESTED,"https://s3.amazonaws.com/mavric/menuItems.txt", "menuItems");
			}
			else
			{
				eEvent = new ExternalFileEvent(ExternalFileEvent.LOCAL_FILE_REQUESTED,"/sdcard/config/menuItems.txt", "menuItems");
//				eEvent = new ExternalFileEvent(ExternalFileEvent.LOCAL_FILE_REQUESTED,"Files/menuItems.txt", "menuItems");
			}
			
			dispatcher.dispatchEvent(eEvent);			
		}
		
		public function onClick(event:MenuBarEvent):void
		{
			event.stopPropagation();
			var menuEvent:MenuBarEvent;
			
				switch (event.clickedItem){
					case "routeSave":
						dispatcher.dispatchEvent(new MenuBarEvent(MenuBarEvent.ROUTE_SAVED,null, true, true));
						break;
					case "routeLoad":
						dispatcher.dispatchEvent(new MenuBarEvent(MenuBarEvent.ROUTE_LOADED,null, true, true));
						break;
					case "settings":
						dispatcher.dispatchEvent(new MenuBarEvent(MenuBarEvent.SETTINGS_ENABLED,null, true, true));
						break;
					case "routeSelector":
						dispatcher.dispatchEvent(new MenuBarEvent(MenuBarEvent.ROUTE_SELECTOR_ENABLED,null, true, true));
						break;
					case "settingsLoad":
//						loadSettings();
						break;
					case "controlbar":
						menuEvent = new MenuBarEvent(MenuBarEvent.CONTROLBAR_ENABLED,null, true, true);
						menuEvent.itemToggled = event.itemToggled;
						dispatcher.dispatchEvent(menuEvent);
						break;
					case "drive":
						menuEvent = new MenuBarEvent(MenuBarEvent.DRIVEMAP_ENABLED,null, true, true);
						menuEvent.itemToggled = event.itemToggled;
						dispatcher.dispatchEvent(menuEvent);
						break;
					case "overview":
						menuEvent = new MenuBarEvent(MenuBarEvent.OVERVIEW_ENABLED,null, true, true);
						menuEvent.itemToggled = event.itemToggled;
						dispatcher.dispatchEvent(menuEvent);
						break;
					case "fullscreen":
						menuEvent = new MenuBarEvent(MenuBarEvent.FULL_SCREEN_ENABLED,null,true,true);
						menuEvent.itemToggled = event.itemToggled;
						dispatcher.dispatchEvent(menuEvent);
						break;
				}
		}
	}
}