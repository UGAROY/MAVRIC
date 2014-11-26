package com.transcendss.mavric.util
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class MeasureSprite extends Sprite
	{
		private var _distance:Number;
		private var pixelDist:Number;
		private var label:TextField;
		private static const BAR_LEN:int = 10; 
		
		public function MeasureSprite(start:Number, end:Number, ratio:Number)
		{
			super();
			var starty:int = 15;
			_distance = Math.abs(end - start) * 5280;
			pixelDist = _distance * ratio;
			
			var format:TextFormat = new TextFormat();
			format.align = "center";
			label = new TextField();
			label.defaultTextFormat = format;
			label.text = ""+Math.round(_distance)+"\'";
			label.x = pixelDist/2 - label.width/2;
			addChild(label);
			this.graphics.lineStyle(1, 0x000000);
			this.graphics.beginFill(0x000000);
			this.graphics.moveTo(0, starty);
			this.graphics.lineTo(0, starty + BAR_LEN);
			
			this.graphics.moveTo(pixelDist, starty);
			this.graphics.lineTo(pixelDist, starty+BAR_LEN);
			
			this.graphics.moveTo(0, starty+BAR_LEN/2);
			this.graphics.lineTo(pixelDist, starty+BAR_LEN/2);
			
			//this.graphics.drawRect(0,0,100,100);
			this.graphics.endFill();
			
		}
	}
}