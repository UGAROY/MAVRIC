package com.transcendss.mavric.util
{
	import com.adobe.audio.format.WAVWriter;
	import com.transcendss.transcore.events.VoiceEvent;
	
	import flash.events.*;
	import flash.events.SampleDataEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
//	import mx.controls.Alert;
	import mx.controls.Button;
//	import mx.controls.Image;
	import mx.core.LayoutContainer;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	public class TSSVoiceMemo extends UIComponent
	{
		private var mic:Microphone;
		private var soundBytes:ByteArray;
		private var rec:Boolean = false;
		private var timer:Timer;
		private var volume:Number;
		private var pan:Number;
		private var soundMap:Object;
		public var tmpLayout:LayoutContainer = new LayoutContainer();
		public var setupButton:Button = new Button();
		public var captureButton:Button = new Button();
		public var closeButton:Button = new Button();

		
		public function TSSVoiceMemo()
		{
			
			tmpLayout.layout = "horizontal";
			
			captureButton.label = "Record";
			captureButton.buttonMode = true;
			captureButton.width = 75;
			captureButton.height = 40;
			captureButton.addEventListener(MouseEvent.CLICK, onToggleRecording);
			tmpLayout.addChild(captureButton);
			
			closeButton.label = "Close";
			closeButton.buttonMode = true;
			closeButton.width = 75;
			closeButton.height = 40;
			closeButton.addEventListener(MouseEvent.CLICK, closeWindow);
			tmpLayout.addChild(closeButton);
			
			tmpLayout.width = 200;
			tmpLayout.height = 50;
			tmpLayout.styleName = "ImgLayout";
			addChild(tmpLayout);

			this.width = 200;
			this.height = 100;
			this.x = 1000;
			this.y = 630;
		}
		
		private function onToggleRecording(event:MouseEvent):void
		{
			this.rec = !rec;
			if (rec)
			{
				captureButton.label = "Stop";
				this.soundBytes = new ByteArray();
				this.mic = Microphone.getMicrophone();
				this.mic.setSilenceLevel(40);
				this.mic.gain = 100;
				this.mic.rate = 44;
				this.mic.addEventListener(SampleDataEvent.SAMPLE_DATA, onMicSampleData);
			}
			else
			{
				captureButton.label = "Record";
				this.mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, onMicSampleData);
				this.mic = null;
				//this.playEcho();
				var tmpEvent:VoiceEvent = new VoiceEvent(VoiceEvent.NEWMEMO,true, true);
				tmpEvent.byteArray = this.soundBytes;
				dispatchEvent(tmpEvent);
			}
		}
		
		private function onMicSampleData(event:SampleDataEvent):void
		{
			while(event.data.bytesAvailable)
			{
				var sample:Number = event.data.readFloat();
				this.soundBytes.writeFloat(sample);
			}
		}
		
		private function playEcho():void
		{
			this.volume = 1;
			this.pan = 1;
			this.soundMap = new Object();
			startPlayback();
		}
		private function startPlayback():void
		{
			var soundCopy:ByteArray = new ByteArray();
			soundCopy.writeBytes(this.soundBytes);
			soundCopy.position = 0;
			var sound:Sound = new Sound();
			this.soundMap[sound] = soundCopy;
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSamplePlayback);
			sound.play();
			
		}
		
		
		
		
		
		private function onSamplePlayback(event:SampleDataEvent):void
		{
			var sound:Sound = event.target as Sound;
			var soundCopy:ByteArray = ByteArray(this.soundMap[sound]);
			for (var i:int = 0; i < 8192 && soundCopy.bytesAvailable > 0; i++)
			{
				var sample:Number = soundCopy.readFloat();
				event.data.writeFloat(sample);
				event.data.writeFloat(sample);
			}
		}
		
		public function closeWindow(e:MouseEvent):void
		{
			PopUpManager.removePopUp(this);
		}	
		
	}
}