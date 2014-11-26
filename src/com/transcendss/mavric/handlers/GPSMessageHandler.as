package com.transcendss.mavric.handlers
{
	import com.transcendss.mavric.events.GPSEvent;
	
	import merapi.handlers.MessageHandler;
	import merapi.messages.IMessage;
	
	import mx.collections.ArrayList;
	
	
	public class GPSMessageHandler extends MessageHandler
	{
		public static var M_GPS_MESSAGE:String = "gpsPulse";
		
		private var xArray:ArrayList = new ArrayList();
		private var yArray:ArrayList = new ArrayList();
		private var pntCounter:Number = 0;
		
		public function GPSMessageHandler(type:String=null)
		{
			super(M_GPS_MESSAGE);
			xArray.addItem(-96.0805);
			xArray.addItem(-95.8762);
			xArray.addItem(-96.0346);
			xArray.addItem(-90.2401);
			
			yArray.addItem(41.5508);
			yArray.addItem(41.5650);
			yArray.addItem(41.5513);
			yArray.addItem(41.8156);
			
		}
		
		override public function handleMessage(message:IMessage):void
		{
			//mLabel.text = "received";
			var locObj:Object = JSON.parse(message.data as String);
			//mLabel.text = "(lat,long): (" + locObj.latitude + ", " + locObj.longitude +")";
			var ev:GPSEvent = new GPSEvent(GPSEvent.UPDATE);
			
			var yDeg:Number = Math.floor((parseFloat(locObj.latitude) / 100));
			var xDeg:Number = Math.ceil(((parseFloat(locObj.longitude) / 100) * -1));
			
			var xDec:Number = ((parseFloat(locObj.longitude) / 100) + (xDeg)) * 100;
			var yDec:Number = ((parseFloat(locObj.latitude) / 100) - yDeg) * 100;
					
			ev.x = xDeg - (xDec / 60);
			ev.y = yDeg + (yDec / 60);
			//ev.x = xArray.getItemAt(0) as Number;
			//ev.y = yArray.getItemAt(0) as Number;
			//pntCounter++;
			//if (pntCounter > 3)
			//	pntCounter = 0;
			ev.precision = parseInt(locObj.PDOP);
			//ev.horizantalPosition = parseInt(locObj.HDOP);
			
			this.dispatchEvent(ev);
		}
	}
}