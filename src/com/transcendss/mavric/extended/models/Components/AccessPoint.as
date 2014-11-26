package com.transcendss.mavric.extended.models.Components
{
	import com.transcendss.transcore.util.Graphics;
	
	import flash.display.GraphicsPath;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.*;
	
	import mx.core.*;
	
	public class AccessPoint extends Sprite
	{
		private var dataType:Number;
		private var apSprite:Sprite = new Sprite();
		private var diagramH:Number =0;
				
		public function AccessPoint(dataTypeVal:Number,xVal:Number,yVal:Number)
		{
			super();
			dataType = dataTypeVal;
			apSprite.x = xVal;
			diagramH= yVal;
			draw();
		}
		
		
		
		public function draw():void
		{
			clearContainer();  
			var Shp:Shape = new Shape();
			var tmpx:Number = 20;
			var tempy:Number = 40;
			var drawing:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			var path:GraphicsPath;
			
				if (dataType == 1301)
				{
					tmpx = 12;					
					Shp.graphics.lineStyle(2.75, 0,1);
					path = new GraphicsPath(Vector.<int>([1,2]),
						Vector.<Number>([tmpx,10, tmpx, 60]));
					drawing.push(path);
					path = new GraphicsPath(Vector.<int>([1,3]),
						Vector.<Number>([tmpx+1,60,tmpx-10 , 75,tmpx-20,75]));
					drawing.push(path);
					path = new GraphicsPath(Vector.<int>([1,2]),
						Vector.<Number>([tmpx+15,10, tmpx+15, 60]));
					drawing.push(path);
					path = new GraphicsPath(Vector.<int>([1,3]),
						Vector.<Number>([tmpx+16, 60,tmpx+25 , 75,tmpx+35,75]));
					drawing.push(path);
					Shp.graphics.drawGraphicsData(drawing);
					Shp = Graphics.addGlow(Shp,0xdfdfdf,0.4);
					apSprite.addChild(Shp);
					apSprite.height = Shp.height;
					apSprite.width = Shp.width;
					apSprite.y = 40;
				} else
				{
					
					tmpx = 27;					
					Shp.graphics.lineStyle(2.75, 0,1);
					path = new GraphicsPath(Vector.<int>([1,2]),
						Vector.<Number>([tmpx,10, tmpx, 60]));
					drawing.push(path);
					path = new GraphicsPath(Vector.<int>([1,3]),
						Vector.<Number>([tmpx+1,10,tmpx+10 , -5,tmpx+20,-5]));
					drawing.push(path);
					path = new GraphicsPath(Vector.<int>([1,2]),
						Vector.<Number>([tmpx-15,10, tmpx-15, 60]));
					drawing.push(path);
					path = new GraphicsPath(Vector.<int>([1,3]),
						Vector.<Number>([tmpx-16, 10,tmpx-25 , -5,tmpx-35,-5]));
					drawing.push(path);
					Shp.graphics.drawGraphicsData(drawing);
					Shp = Graphics.addGlow(Shp,0xdfdfdf,0.4);
					apSprite.addChild(Shp);
					apSprite.height = Shp.height;
					apSprite.width = Shp.width;
					apSprite.y = diagramH/2+40;
				}
			addChild(apSprite);
		}
		
		
		public function clearContainer():void{
			// clear all children of container
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
	}

}