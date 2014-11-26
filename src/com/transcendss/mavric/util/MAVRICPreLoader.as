package com.transcendss.mavric.util
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import mx.events.*;
	import mx.preloaders.*;

	public class MAVRICPreLoader extends Sprite implements IPreloaderDisplay
	{
		[ Embed(source="images/MavricSplashLogo2.png", mimeType="application/octet-stream") ]
		private var myLogo:Class;
		public var timer:Timer;
		private var logoLoader:flash.display.Loader;
		
		public function MAVRICPreLoader() {   
			super();        
		}
		
		// Specify the event listeners.
		public function set preloader(preloader:Sprite):void {
			preloader.addEventListener(
				FlexEvent.INIT_PROGRESS, handleInitProgress);
			preloader.addEventListener(
				FlexEvent.INIT_COMPLETE, handleInitComplete);
		}
		
		public function initialize():void {
			logoLoader = new flash.display.Loader();       
			logoLoader.contentLoaderInfo.addEventListener(
				Event.COMPLETE, logoLoaderComplete);
			logoLoader.visible = false;
			logoLoader.loadBytes( new myLogo() as ByteArray );
			addChild(logoLoader);
		}
		
		// After the gif is loaded then display it.
		private function logoLoaderComplete(event:Event):void
		{
			logoLoader.stage.addChild(this) 
			//logoLoader.filters=[f];; 
			logoLoader.x = logoLoader.stage.stageWidth/2 - logoLoader.width/2 
			logoLoader.y = logoLoader.stage.stageHeight/2 - logoLoader.height/2 
			logoLoader.visible=true; 
			
			logoLoader.contentLoaderInfo.removeEventListener( 
			Event.COMPLETE, logoLoaderComplete); 
		}   
		
		private function handleInitProgress(event:Event):void {
		}
		
		//Application has downloaded so start the fade out.
		private function handleInitComplete(event:Event):void {
			var timer:Timer = new Timer(1000,1);
			timer.addEventListener(TimerEvent.TIMER, dispatchComplete);
			timer.start();    
			closeScreen();  
		}
		
		private function dispatchComplete(event:TimerEvent):void {
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function closeScreen():void
		{
			timer = new Timer( 1 );
			timer.addEventListener( TimerEvent.TIMER, closeScreenFade );                    
			timer.start();
		}
		
		public function closeScreenFade( event:TimerEvent ):void
		{
			if( logoLoader.alpha > 0){ 
				logoLoader.alpha = logoLoader.alpha - .004; 
				this.alpha = this.alpha - .004; 
			} else { 
				timer.stop(); 
				this.removeChild(logoLoader);   
				
				Bitmap(logoLoader.content).bitmapData.dispose(); 
				logoLoader.unloadAndStop(); 
				logoLoader=null; 
				this.visible = false;
			}   
		}        
		
		public function get backgroundColor():uint {
			return 0;
		}
		
		public function set backgroundColor(value:uint):void {
		}
		
		public function get backgroundAlpha():Number {
			return 0;
		}
		
		public function set backgroundAlpha(value:Number):void {
		}
		
		public function get backgroundImage():Object {
			return null;
		}
		
		public function set backgroundImage(value:Object):void {
		}
		
		public function get backgroundSize():String {
			return "";
		}
		
		public function set backgroundSize(value:String):void {
		}
		
		public function get stageWidth():Number {
			return 0;
		}
		
		public function set stageWidth(value:Number):void {
		}
		
		public function get stageHeight():Number {
			return 0;
		}
		
		public function set stageHeight(value:Number):void {
		}
	}
}