package com.transcendss.mavric.extended.models
{
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.mavric.events.DataEventEvent;
	import com.transcendss.mavric.events.GPSEvent;
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	
	import flash.events.Event;
	import flash.events.GeolocationEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.sensors.Geolocation;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.Panel;
	import spark.components.Scroller;
	import spark.components.TextInput;
	import spark.components.VGroup;
	import spark.events.IndexChangeEvent;
	import spark.layouts.VerticalLayout;

	public class CaptureBar extends Group
	{
		private var button:Button;
		private var mateDispatcher:Dispatcher = new Dispatcher();
		private var stickGroup:Group = new Group();
		private var invGroup:Group= new Group();
		private var signDrpDown:DropDownList;
		private var drpDown:DropDownList;
		private var BtnList:ArrayCollection;
		private var cbMP:Number;
		private var cbType:String;
		private var txtBoxOpen:Boolean;
		private var openTextBox:TextInput;
		private var cbScroller:Scroller;
		private var cpPanel:Panel = new Panel();
		private var tickTimer:Timer;
		
		private var gpsGroup:Group = new Group();
		private var valX:Label = new Label();
		private var valY:Label = new Label();
		private var valPrecision:Label = new Label();
		private var popUp:AccessPointPopup;
		private var geo:Geolocation = new Geolocation();
		private var gpsck:Image = new Image();
		
		public var GPS_ON:Boolean = false;
		public var lat:Number = 38.922928 ;
		public var long:Number = -77.029712;
		
		[Bindable]
		[Embed(source="../../../../../images/gray_icons/icon_Mav_GPS_40x40_off.png")] protected var gpsImageOff:Class
		[Bindable]
		[Embed(source="../../../../../images/gray_icons/icon_Mav_GPS_40x40_on.png")] protected var gpsImageOn:Class
		
		
		
		public function CaptureBar()
		{
			clearContainer();
			super();
//			this.width = 200;
//			this.height = 700;
			this.percentHeight = 100;
			this.percentWidth = 100;
			
			
			var sVL:VerticalLayout = new VerticalLayout();
			sVL.horizontalAlign = "center";
			stickGroup.layout = sVL;
			stickGroup.percentHeight = 100;
			stickGroup.percentWidth = 100;
			
			
			var iVL:VerticalLayout = new VerticalLayout();
			iVL.horizontalAlign = "center";
			invGroup.layout = iVL;
			invGroup.percentHeight = 100;
			invGroup.percentWidth = 100;
			cpPanel.setStyle("backgroundColor","0xc0c0c0"); 
			cpPanel.percentHeight = 100;
			cpPanel.percentWidth = 100;

		}
		
		private function clickHandler(ev:MouseEvent):void
		{
			var asset:BaseAsset;
			if(ev.target.styleName=="SUBSECTION")//for subsection it is always edit. So get the data
			{
				asset = FlexGlobals.topLevelApplication.GlobalComponents.stkDiagram.getSubsectionAtCurrentMP();
				
				if(asset==null)
				{
					FlexGlobals.topLevelApplication.TSSAlert("No subsection record found");
					return;
				}
			}
			else
				asset = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.createAsset(ev.target.styleName);				
			FlexGlobals.topLevelApplication.editAsset(asset, FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getFormClass(ev.target.styleName));
		}
		

		
		
		
		//once settings file is loaded and config manager is populated, add buttons and dropdown lists for each capture items found in the button list
		public function draw(btnClickHandler:Function, cWidth:Number=-2, cHeight:Number=-2):void{
			clearContainer();
			var list:Object = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetDefs;
			var buttonGroup:VGroup = new VGroup();
			buttonGroup.percentWidth = 100;
			buttonGroup.percentHeight = 100;
			//buttonGroup.addElement(gpsGroup);
			var top:int = ConfigUtility.getInt("top_pad");
			var left:int = ConfigUtility.getInt("left_pad");
			var bwidth:int = ConfigUtility.getInt("button_width");
			var bheight:int = ConfigUtility.getInt("button_height");
			
			for each (var item:Object in list)
			{
				if(item.CAPTURE_AVAILABLE != "false")
				{
					var tempButton:Button = new Button();
					tempButton.label = "Add "+ item.UI_NAME;
					tempButton.styleName = item.DESCRIPTION;
					tempButton.width = bwidth;
					tempButton.height = bheight;
					//tempButton.x = left;
					//tempButton.y = top;
					tempButton.addEventListener(MouseEvent.CLICK, clickHandler);
					buttonGroup.addElement(tempButton);
				}
				
			}
			
			gpsck.source = gpsImageOff;
			gpsck.x = 80;
			gpsck.y = 410;
			gpsck.addEventListener(MouseEvent.CLICK, chkGPSPoll_changeHandler);
			addElement(gpsck);
			
			buttonGroup.x = left;
			buttonGroup.y = top;
			
			addElement(buttonGroup);
			buttonGroup.addElement(gpsGroup);
			
			this.graphics.beginFill(0xcccccc,1);
			var gpsTop:Number = cHeight - 230;
			var rectHeight:int = 190;
			var rectWidth:int = 185;
			this.graphics.drawRoundRect(5,gpsTop, rectWidth,rectHeight, 20,20);
			var rectTop:int = gpsTop;
			this.graphics.endFill();
			
			gpsTop -= buttonGroup.height + 80;
			
			var lblX:Label = new Label();
			lblX.text = "Longitude : ";
			lblX.visible = true;
			lblX.height = 30;
			lblX.width = 85;
			lblX.x = left;
			lblX.y = gpsTop + 85;
			
			valX.id = "longVal";
			valX.text = "";
			valX.width = 75;
			valX.height = 30;
			valX.visible = true;
			valX.x = left + 105;
			valX.y = gpsTop + 85;
			
			drawComponent(this, lblX, 2 + rectWidth/2, rectTop + 0.25*rectHeight + lblX.height/4 + 30);
			drawComponent(this, valX, 2 + rectWidth/2 + lblX.width, rectTop + 0.25*rectHeight + lblX.height/4 + 30);
			
			
			
			var lblY:Label = new Label();
			lblY.text = "Latitude : ";
			lblY.visible = true;
			lblY.width = 75;
			lblY.height = 30;
			lblY.x = left;
			lblY.y = gpsTop + 85 + 45;
			
			valY.id = "latVal";
			valY.text = "";
			valY.visible = true;
			valY.width = 75;
			valY.height = 30;
			valY.x = left + 105;
			valY.y = gpsTop + 85 + 45;
			
			drawComponent(this, lblY, 5 + rectWidth/2, rectTop + 0.5*rectHeight + lblY.height/4 + 30)
			drawComponent(this, valY, 5 + rectWidth/2 + lblY.width, rectTop + 0.5*rectHeight + lblY.height/4 + 30)
			
			var lblPrecision:Label = new Label();
			if (FlexGlobals.topLevelApplication.useInternalGPS)
				lblPrecision.text = "Precision(M) : ";
			else
				lblPrecision.text = "PDOP : ";
			lblPrecision.visible = true;
			lblPrecision.width = 100;
			lblPrecision.height = 30;
			lblPrecision.x = left - 10;
			lblPrecision.y = gpsTop + 70 + 25;
			
			valPrecision.id = "precVal";
			valPrecision.text = "";
			valPrecision.visible = true;
			valPrecision.width = 75;
			valPrecision.height = 30;
			valPrecision.x = left + 105;
			valPrecision.y = gpsTop + 70 + 35;
			
			
			drawComponent(this, lblPrecision, 0 + rectWidth/2, rectTop + 0.75*rectHeight + lblPrecision.height/4 + 30)
			drawComponent(this, valPrecision, 0 + rectWidth/2 + lblPrecision.width, rectTop + 0.75*rectHeight + lblPrecision.height/4 + 30)
			
			
		}
		
/*		// Handler for the checkbox to turn on GPS retrieveal, dispaly and navigation
		protected function toggleGPS(event:Event):void
		{
			
			if (!GPS_ON)
			{			
				GPS_ON=true;
				gpsImg.source = gps_on_img;
				var internalGPS:Geolocation = new Geolocation();
				geo.setRequestedUpdateInterval(3000);
				geo.addEventListener(GeolocationEvent.UPDATE, internalGPSUpdateHandler);
				//btnRun.enabled = false;
			}
			else
			{ 
				GPS_ON=false;
				gpsImg.source = gps_off_img;
				clearGPS();
				geo.removeEventListener(GeolocationEvent.UPDATE, internalGPSUpdateHandler);	
				//btnRun.enabled = true;
			}
		}
		
		private function internalGPSUpdateHandler(event:GeolocationEvent):void
		{
			var ev:GPSEvent = new GPSEvent(GPSEvent.UPDATE);
//			var tmpGPSH:GPSHandler = FlexGlobals.topLevelApplication.btGPSHandler;
//			var tmpGPSData:GPSData;
			var isDispatchable:Boolean = false;
			
			if (FlexGlobals.topLevelApplication.useInternalGPS)
			{
				ev.x = event.longitude;
				ev.y = event.latitude;
				//trace("Raw GPS:" + ev.x + "," + ev.y);
				FlexGlobals.topLevelApplication.longitude = ev.x;
				FlexGlobals.topLevelApplication.latitude = ev.y;
				
				ev.precision = event.horizontalAccuracy;
				trace(ev.precision);
				if (ev.precision < 50)
					isDispatchable = true;
			} else
			{
				if (tmpGPSH != null)
				{
					tmpGPSData = tmpGPSH.getData();
					
					var yDeg:Number = Math.floor((tmpGPSData.lat / 100));
					var xDeg:Number = Math.ceil(((tmpGPSData.long / 100) * -1));
					
					var xDec:Number = ((tmpGPSData.long / 100) + (xDeg)) * 100;
					var yDec:Number = ((tmpGPSData.lat / 100) - yDeg) * 100;
					
					ev.x = xDeg - (xDec / 60);
					ev.y = yDeg + (yDec / 60);
					
					FlexGlobals.topLevelApplication.longitude = ev.x;
					FlexGlobals.topLevelApplication.latitude = ev.y;
					
					ev.precision = tmpGPSData.pdop;
					if (ev.precision < 6)
						isDispatchable = true;
				} 
			}
			handleGPSChange(ev);
			if (isDispatchable)
				dispatchEvent(ev);
			
		}*/

		
		private function drawComponent(component:Group, label:Label, centerX:int, centerY:int ): void {
			//var metrics:TextLineMetrics = label.measureText(text);
			
			//label.width = metrics.width;
			//label.height = metrics.height;
			label.x = centerX - Math.round(label.width/2) - 28;
			label.y = centerY - Math.round(label.height/2) - 5;
			
			component.addElement(label);
		}

		private function getDP(dataarray:String):ArrayList{
			//name = name.toLowerCase().replace(/\s+/g,"");
			
			var obj:Object = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.settingsAC.getItemAt(0);
			var retVal:ArrayList = null;
			for (var prop:String in obj)
			{
				if (prop == dataarray)
					retVal = new ArrayList(obj[prop]);
			}
			return retVal;
		}
		
		private function captureStickBtnClickHandler(event:MouseEvent):void{
			if(txtBoxOpen)
			{
				parentApplication.removeElement(openTextBox);
				txtBoxOpen = false;
				openTextBox = null;
			}
			var drpDwn:DropDownList;
			var lbl:String = String(event.target.label).toUpperCase().replace(" ","");

			drpDwn=  stickGroup.getChildByName("DRP_DOWN_"+lbl) as DropDownList;
			if (drpDwn)
			{
				/*var gcEvent:GestureControlEvent = new GestureControlEvent(GestureControlEvent.CHANGED);
				gcEvent.gestures = false;
				dispatchEvent(gcEvent);*/
//				drpDwn.width = 250;
				drpDwn.openDropDown();
				txtBoxOpen = false;
				openTextBox = null;
			}
			else
			{
				var	txtInp:TextInput = new TextInput();
				txtInp.width = 100;
				txtInp.height = 30;
				txtInp.y =  event.target.y+71;
				txtInp.x = event.target.x + event.target.width + 10;
				txtInp.name = "TXT_INP_" + lbl;
				
				txtInp.addEventListener(FlexEvent.ENTER,textInputHandler);
				txtBoxOpen = true;
				openTextBox = txtInp;
				parentApplication.addElement(txtInp);
			}
		}
		
		private function captureInvBtnClickHandler(event:MouseEvent):void{
			if(txtBoxOpen)
			{
				parentApplication.removeElement(openTextBox);
				txtBoxOpen = false;
				openTextBox = null;
			}
			var drpDwn:DropDownList;
			var lbl:String = String(event.target.label).toUpperCase().replace(" ","");
			
			drpDwn=  invGroup.getChildByName("DRP_DOWN_"+lbl) as DropDownList;
			if (drpDwn)
			{
				/*var gcEvent:GestureControlEvent = new GestureControlEvent(GestureControlEvent.CHANGED);
				gcEvent.gestures = false;
				dispatchEvent(gcEvent);*/
				drpDwn.openDropDown();
				//drpDwn.addEventListener(IndexChangedEvent.CHANGE, handleListSelection);
				txtBoxOpen = false;
				openTextBox = null;
			}
			else
			{
				var	txtInp:TextInput = new TextInput();
				txtInp.width = 100;
				txtInp.height = 30;
				txtInp.y =   event.target.y+71;
				txtInp.x = event.target.x + event.target.width+10;
				txtInp.name = "TXT_INP_" + lbl;
				
				txtInp.addEventListener(FlexEvent.ENTER,textInputHandler);
				txtBoxOpen = true;
				openTextBox = txtInp;
				parentApplication.addElement(txtInp);
			}
		}
		
	/*	private function handleListSelection(event:IndexChangedEvent):void
		{
			var tmpEvent:DataEventEvent = new DataEventEvent(DataEventEvent.NEWPOINTEVENT, true, true);
			tmpEvent.datatype = 1;
			dispatchEvent(tmpEvent);
		}*/
		
		public function hideTooltip(e:MouseEvent):void
		{
			
		}
		
		private function killMouseClick(event:MouseEvent):void{
			event.stopPropagation();
		}
		
		//When the capture bar dropdown value changes
		//save the record in local and draw new element on the diagram
		private function drpDownChangeHandler(event:IndexChangeEvent):void{
			
			var list:DropDownList = event.target as DropDownList;
			var tmpEvent:DataEventEvent;
			if (list.selectedItem.value > 999)
			{
				tmpEvent = new DataEventEvent(DataEventEvent.NEWPOINTEVENT, true, true);
				tmpEvent.datatype = list.selectedItem.value;
				dispatchEvent(tmpEvent);
				list.selectedIndex = 0;
			} else
			{	
				if (list.selectedItem.label.toString().indexOf("End") > -1)
				{
					list.selectedItem.label = list.selectedItem.label.toString().replace("End", "Start");
					tmpEvent = new DataEventEvent(DataEventEvent.NEWLINEAREVENTEND, true, true);
					tmpEvent.datatype = list.selectedItem.value;
					dispatchEvent(tmpEvent);
					list.selectedIndex = 0;
				} else
				{
					var isActive:Number = -1;
					for (var i:int = 0; i<list.dataProvider.length; i++)
					{
						if (list.dataProvider.getItemAt(i).label.indexOf("End ") > -1)
						{
							isActive = list.dataProvider.getItemAt(i).value;
							list.dataProvider.getItemAt(i).label = list.dataProvider.getItemAt(i).label.toString().replace("End", "Start");
							break;
						}
					}
					list.selectedItem.label = list.selectedItem.label.toString().replace("Start", "End");
					tmpEvent = new DataEventEvent(DataEventEvent.NEWLINEAREVENTSTART, true, true);
					tmpEvent.datatype = list.selectedItem.value;
					tmpEvent.endtype = isActive;
					dispatchEvent(tmpEvent);
					list.selectedIndex = 0;
				}
			}
			//type from currentCaptureType
			//milepoint from currentCaptureMP
			event.stopPropagation();
			/*var gcEvent:GestureControlEvent = new GestureControlEvent(GestureControlEvent.CHANGED);
			gcEvent.gestures = true;
			dispatchEvent(gcEvent);*/
		}
		
		//will be called when FlexEvent.ENTER occurs in the textbox
		//TODO: how will the enter event be captured in Zoom
		private function textInputHandler(event:FlexEvent):void{
			var value:String = event.target.text;
			
			//type from currentCaptureType
			//milepoint from currentCaptureMP
		}
		
		public function triangulateMouseUp(event:MouseEvent):void{
			if(txtBoxOpen && event.target != openTextBox)
			{
				parentApplication.removeElement(openTextBox);
				txtBoxOpen = false;
				openTextBox = null;
			}
		}
		public function set currentCaptureMP(mp:Number):void{
			cbMP=mp;
		}
		public function get currentCaptureMP():Number{
			return cbMP;
		}
		public function set currentCaptureType(typ:String):void{
			cbType=typ;
		}
		public function get currentCaptureType():String{
			return cbType;
		}
		
		public function get Lat():String{
			return valY.text;
		}
		
		public function get Long():String{
			return valX.text;
		}
		
		public function get Precision():String{
			return valPrecision.text;
		}
		
		public function clearContainer():void{
			stickGroup.removeAllElements();
			invGroup.removeAllElements();
			// clear all children of container
			while (this.numChildren > 0)
			{
				//this.removeChildAt(0);
				this.removeElementAt(0);
			}
		}
		
		public function handleGPSChange(evt:GPSEvent):void
		{
			valX.text = evt.x.toString().substr(0,9);
			valY.text = evt.y.toString().substr(0,8);
			valPrecision.text = evt.precision.toString();
		}
		
		public function clearGPS():void
		{
			valX.text = "";
			valY.text = "";
			valPrecision.text = "";
		}
		
		// Handler for the checkbox to turn on GPS retrieveal, dispaly and navigation
		protected function chkGPSPoll_changeHandler(event:Event):void
		{
			if (gpsck.source == gpsImageOff)
			{	
				GPS_ON=true;
				trace("chkGPSPoll");
				if (FlexGlobals.topLevelApplication.useInternalGPS) {
					var internalGPS:Geolocation = new Geolocation();
					geo.setRequestedUpdateInterval(3000);
					
				} else {
					tickTimer = new Timer(3000);
					tickTimer.addEventListener(TimerEvent.TIMER, function(ev:TimerEvent) {
						var nev:GeolocationEvent = new GeolocationEvent(GeolocationEvent.UPDATE);
//						nev.latitude = lat =lat+.01 ;
//						nev.longitude= long;
//						nev.longitude =-77.008896;
//						nev.latitude= 38.876498;
//						nev.horizontalAccuracy=10;
					
						//D st & 12th St--GPS
//						nev.longitude =-76.99032;
//						nev.latitude= 38.88406; 
						//D st and 12 st -- google maps
//						nev.latitude= 38.884112;
//						nev.longitude =-76.990289;
						
						geo.dispatchEvent(nev);
						trace("Update");
					});
					tickTimer.start();
				}
				
				geo.addEventListener(GeolocationEvent.UPDATE, internalGPSUpdateHandler);
				gpsck.source = gpsImageOn;
			}
			else
			{
				GPS_ON=false;
				FlexGlobals.topLevelApplication.sldDiagram.sldDiagram.captureBar.clearGPS();
				geo.removeEventListener(GeolocationEvent.UPDATE, internalGPSUpdateHandler);	
				gpsck.source = gpsImageOff;
			}
		}
		
		// Method to handle GPS hits from the internal GPS
		private function internalGPSUpdateHandler(event:GeolocationEvent):void
		{
			var ev:GPSEvent = new GPSEvent(GPSEvent.UPDATE);
			var isDispatchable:Boolean = false;
			
			if (FlexGlobals.topLevelApplication.useInternalGPS)
			{
				ev.x = event.longitude;
				ev.y = event.latitude;
				//trace("Raw GPS:" + ev.x + "," + ev.y);
				FlexGlobals.topLevelApplication.longitude = ev.x;
				FlexGlobals.topLevelApplication.latitude = ev.y;
				
				ev.precision = event.horizontalAccuracy;
				trace(ev.precision);
				if (ev.precision < 70)//changed from 50 for ipad--DDOT
					isDispatchable = true;
			} else
			{
				///Comment out in ios-------------------
//				var tmpGPSH:GPSHandler = FlexGlobals.topLevelApplication.btGPSHandler;
//				var tmpGPSData:GPSData;
//				
//				if (tmpGPSH != null)
//				{
//					try {
//						tmpGPSData = tmpGPSH.getData();
//						var yDeg:Number = Math.floor((tmpGPSData.lat / 100));
//						var xDeg:Number = Math.ceil(((tmpGPSData.long / 100) * -1));
//						var xDec:Number = ((tmpGPSData.long / 100) + (xDeg)) * 100;
//						var yDec:Number = ((tmpGPSData.lat / 100) - yDeg) * 100;
//						
//						ev.x = xDeg - (xDec / 60);
//						ev.y = yDeg + (yDec / 60);
//						
//						ev.x = tmpGPSData.long;
//						ev.y = tmpGPSData.lat;
//						
//						FlexGlobals.topLevelApplication.longitude = ev.x;
//						FlexGlobals.topLevelApplication.latitude = ev.y;
//						
//						ev.precision = tmpGPSData.pdop;
//						if (ev.precision < 6)
//							isDispatchable = true;
//					}
//					catch (err:Error) {
//						trace(err.message);
//					}
//				} 
				///End Comment out in ios-------------------
			}
			handleGPSChange(ev);
			if (isDispatchable)
				dispatchEvent(ev);
			
		}
	}
}