package com.transcendss.mavric.util
{
	import com.transcendss.transcore.events.TextMemoEvent;
	
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
//	import mx.containers.Canvas;
//	import mx.containers.TitleWindow;
//	import mx.controls.Alert;
	import mx.controls.Button;
//	import mx.controls.Image;
	import mx.core.LayoutContainer;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	import spark.components.Label;
	import spark.core.SpriteVisualElement;

	public class TSSTextMemo extends UIComponent
	{
		
		public var tmpLayout:LayoutContainer = new LayoutContainer();
		public var captureButton:Button = new Button();
		public var closeButton:Button = new Button();
		public var memo:TextField = new TextField();
		public var txtFormat:TextFormat = new TextFormat();

		public function TSSTextMemo()
		{
			tmpLayout.layout = "horizontal";
			captureButton.label = "Capture";
			captureButton.buttonMode = true;
			captureButton.width = 75;
			captureButton.height = 40;
			captureButton.addEventListener(MouseEvent.CLICK, captureText);
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
						
			
			var tmpUI:UIComponent = new UIComponent();
			tmpUI.width = 200;
			tmpUI.height = 100;
			
			memo.type = TextFieldType.INPUT;
			txtFormat.size = 20;
			memo.defaultTextFormat = txtFormat;
			memo.width = 200;
			memo.height = 100;
			memo.border = true;
			memo.background = true;
			
			memo.y = 75;
			tmpUI.addChild(memo);
			addChild(tmpUI);
			
			this.width = 200;
			this.height = 100;
			this.x = 1000;
			this.y = 630;
		}
		
		
		
		public function captureText(e:MouseEvent):void
		{
			var tmpEvent:TextMemoEvent = new TextMemoEvent(TextMemoEvent.NEWMEMO, true, true);
			tmpEvent.memo = memo.text;
			
			dispatchEvent(tmpEvent);
		}
		
		public function closeWindow(e:MouseEvent):void
		{
			PopUpManager.removePopUp(this);
		}	
			
		
		

	}
}