package com.transcendss.mavric.util
{
	import com.transcendss.transcore.events.CameraEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.Video;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	//import mx.containers.Canvas;
	//import mx.containers.TitleWindow;
	//import mx.controls.Alert;
	import mx.controls.Button;
	//import mx.controls.Image;
	import mx.core.LayoutContainer;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	import spark.components.Label;
	import spark.core.SpriteVisualElement;

	public class TSSCamera extends UIComponent
	{
		public var hndlCam:Camera;
		public var video:Video;
		public var video2:Video;
		public var tmpLayout:LayoutContainer = new LayoutContainer();
		public var setupButton:Button = new Button();
		public var captureButton:Button = new Button();
		public var closeButton:Button = new Button();
		public var memo:TextField = new TextField();
		public var txtFormat:TextFormat = new TextFormat();

		public function TSSCamera()
		{
			tmpLayout.layout = "horizontal";
			
			captureButton.label = "Capture";
			captureButton.buttonMode = true;
			captureButton.width = 125;
			captureButton.height = 40;
			captureButton.addEventListener(MouseEvent.CLICK, captureImage);
			tmpLayout.addChild(captureButton);
			
			closeButton.label = "Close";
			closeButton.buttonMode = true;
			closeButton.width = 125;
			closeButton.height = 40;
			closeButton.addEventListener(MouseEvent.CLICK, closeWindow);
			tmpLayout.addChild(closeButton);
			
			tmpLayout.width = 400;
			tmpLayout.height = 50;
			tmpLayout.styleName = "ImgLayout";
			addChild(tmpLayout);
						
			hndlCam = Camera.getCamera();
			if (!(hndlCam != null))// Alert.show("No Camera could be found :(", "Notice");
			hndlCam.setMode(1280, 720, 15);
			video = new Video(300, 225);
			video.x = 0;
			video.y = 50;
			video.attachCamera(hndlCam);
			video2 = new Video(1280, 720);
			video2.attachCamera(hndlCam);
			var tmpUI:UIComponent = new UIComponent();
			tmpUI.width = 300;
			tmpUI.height = 300;
			tmpUI.addChild(video);
			memo.type = TextFieldType.INPUT;
			txtFormat.size = 20;
			memo.defaultTextFormat = txtFormat;
			memo.width = 300;
			memo.height = 75;
			memo.border = true;
			memo.background = true;
			
			memo.y = 275;
			tmpUI.addChild(memo);
			addChild(tmpUI);
			
			
			this.width = 450;
			this.height = 650;
			this.x = 900;
			this.y = 350;
		}
		
		public function setupCam(e:MouseEvent):void
		{		
		
			hndlCam = Camera.getCamera();
			
			if (!(hndlCam != null)) //Alert.show("No Camera could be found :(", "Notice");
			hndlCam.setMode(600, 480, 15);
			video = new Video(300, 225);
			video.x = 10;
			video.y = 50;
			video.attachCamera(hndlCam);
			var tmpUI:UIComponent = new UIComponent();
			tmpUI.width = 300;
			tmpUI.height = 225;
			tmpUI.addChild(video);
			addChild(tmpUI);
		}
		
		public function captureImage(e:MouseEvent):void
		{
			var tmpbmd:BitmapData = new BitmapData(1280, 720);
			tmpbmd.draw(video2);
			var tmpbmp:Bitmap = new Bitmap(tmpbmd);
			var tmpEvent:CameraEvent = new CameraEvent(CameraEvent.NEWPICTURE, true, true);
			tmpEvent.bitmap = tmpbmp;
			tmpEvent.memo = memo.text;
			dispatchEvent(tmpEvent);
		}
		
		public function closeWindow(e:MouseEvent):void
		{
			PopUpManager.removePopUp(this);
		}	
			
		
		public function startVideoCapture(e:MouseEvent):void
		{

		}
		
		public function endVideoCapture(e:MouseEvent):void
		{

		}
		
		public function startVoiceCapture(e:MouseEvent):void
		{

		}
		
		public function endVoiceCapture(e:MouseEvent):void
		{
			
		}

	}
}