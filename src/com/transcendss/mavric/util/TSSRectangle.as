package com.transcendss.mavric.util
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * TSSRectangle represents a Rectangle that is defined by its four corners, and thus can be easily rotated.
	 * Intersection algebra works for rotated rectangles.
	 * 
	 * TSSRectangle will throw an error if it is given an invalid set of points. 
	 * (i.e. a set that defines a shape other than a rectangle)
	 */
	public class TSSRectangle
	{
		private var _x1:Number;
		private var _y1:Number;
		
		private var _x2:Number;
		private var _y2:Number;
		
		private var _x3:Number;
		private var _y3:Number;
		
		private var _x4:Number;
		private var _y4:Number;
		
		/**
		 * fromJSON deserializes a TSSRectangle from a JSON string generated using JSON.stringify
		 * @see JSON.stringify
		 */
		public static function fromJSON(json:String):TSSRectangle
		{
			var obj:Object = JSON.parse(json);
			return new TSSRectangle(obj.x1, obj.y1, obj.x2, obj.y2, obj.x3, obj.y3, obj.x4, obj.y4);
		}
		
		
		/**
		 *	creates a TSSRectangle instance rotated about the  topleft corner by the given angle
		 * @param x1 the top left x coordinate
		 * @param y1 the top left y coordinate
		 * @param width the width of the rectangle
		 * @param height the height of the rectangle
		 * @param angle the angle about the top left corner to rotate counterclockwise IN RADIANS
		 * @return the generated TSSRectangle  
		 */
		public static function fromLeftAngledRect(x1:Number, y1:Number, width:Number, height:Number, angle:Number):TSSRectangle
		{	
			var tr:Point = rotatePoint(new Point(x1 + width, y1), angle, new Point(x1, y1));
			var bl:Point = rotatePoint(new Point(x1, y1 + height), angle, new Point(x1, y1));
			var br:Point = rotatePoint(new Point(x1 + width, y1 + height), angle, new Point(x1, y1));
			
			return new TSSRectangle(x1, y1, tr.x, tr.y, bl.x, bl.y, br.x, br.y);
		}
		
		/**
		 *	creates a TSSRectangle instance rotated about its center by the given angle
		 * @param x1 the top left x coordinate
		 * @param y1 the top left y coordinate
		 * @param width the width of the rectangle
		 * @param height the height of the rectangle
		 * @param angle the angle about the center to rotate counterclockwise IN RADIANS
		 * @return the generated TSSRectangle  
		 */
		public static function fromCenterAngledRect(x1:Number, y1:Number, width:Number, height:Number, angle:Number):TSSRectangle
		{
			var tl:Point = rotatePoint(new Point(x1, y1), angle, new Point(x1 + width / 2, y1 + height / 2));
			var tr:Point = rotatePoint(new Point(x1 + width, y1), angle, new Point(x1 + width / 2, y1 + height / 2));
			var bl:Point = rotatePoint(new Point(x1, y1 + height), angle, new Point(x1 + width / 2, y1 + height / 2));
			var br:Point = rotatePoint(new Point(x1 + width, y1 + height), angle, new Point(x1 + width / 2, y1 + height / 2));
			return new TSSRectangle(tl.x, tl.y, tr.x, tr.y, bl.x, bl.y, br.x, br.y);
		}
		
		/**
		 * creates a new TSSRectangle instance
		 * @param x1 the top left x coord
		 * @param y1 the top left y coord
		 * @param x2 top right
		 * @param y2 top right
		 * @param x3 bottom left
		 * @param y3 bottom left
		 * @param x4 bottom right
		 * @param y4 bottom right
		 */
		public function TSSRectangle(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, x4:Number, y4:Number)
		{
			_x1 = x1;
			_y1 = y1;
			
			_x2 = x2;
			_y2 = y2;
			
			_x3 = x3;
			_y3 = y3;
			
			_x4 = x4;
			_y4 = y4;
			
			if (Math.round(_x1 - _x2) != Math.round(_x3 - _x4) || Math.round(_y1 - _y2) != Math.round(_y3 - _y4)) // etc
				throw new Error("Not a valid rectangle.");
		}
		
		/**
		 *	determines whether a coordinate in the standard basis falls within the rectangle
		 *  @param point the point to find in the rectangle 
		 */
		public function hasPoint(point:Point):Boolean
		{
			var dx:Number = _x2 - _x1;
			var dy:Number = _y2 - _y1;
			var angle:Number;
			
			if (dx == 0)
				angle = Math.PI / 2;
			else
				angle = Math.atan(dy / dx);
			
			var transPnt:Point = rotatePoint(point, angle, new Point(_x1, _y1));
			var transBR:Point = rotatePoint(new Point(_x4, _y4), angle, new Point(_x1, _y1));
			
			//var transRect:Rectangle = new Rectangle(_x1, _y1, transBR.x - _x1, transBR.y - _y1);
			if (transPnt.x > Math.min(_x1, transBR.x) && transPnt.x < Math.max(_x1, transBR.x)
			 && transPnt.y > Math.min(_y1, transBR.y) && transPnt.y < Math.max(_y1, transBR.y))
				return true;
			else 
				return false;
		}
		
		/**
		 * renders the instance to a sprite (mostly for debugging)
		 * @return the sprite drawn to
		 */
		public function toSprite():Sprite
		{
			var retShp:Sprite = new Sprite();
			
			retShp.graphics.lineStyle(2, 0);
			retShp.graphics.moveTo(_x1, _y1);
			retShp.graphics.lineTo(_x2, _y2);
			retShp.graphics.lineTo(_x4, _y4);
			retShp.graphics.lineTo(_x3, _y3);
			retShp.graphics.lineTo(_x1, _y1);
			
			return retShp;
		}
		
		/**
		 * utility class to rotate a point 'angle' radians about a given axis
		 * @param point the point to rotate
		 * @param angle the angle IN RADIANS in which to rotate the point counterclockwise
		 * @param axis the point about which to rotate
		 * @return the rotated point
		 */ 
		public static function rotatePoint(point:Point, angle:Number, axis:Point=null):Point
		{
			var dx:Number = point.x - axis.x;
			var dy:Number = axis.y - point.y;
			
			var x2:Number = axis.x + (dx * Math.cos(angle) - dy * Math.sin(angle));
			var y2:Number = axis.y - (dx * Math.sin(angle) + dy * Math.cos(angle));
			
			return new Point(x2, y2);
		}

		/**
		 * the top left corner in the rectangle's relative coordinate basis
		 */
		public function get x1():Number
		{
			return _x1;
		}

		/**
		 * @private
		 */
		public function set x1(value:Number):void
		{
			_x1 = value;
		}

		public function get y1():Number
		{
			return _y1;
		}

		public function set y1(value:Number):void
		{
			_y1 = value;
		}

		/**
		 * the top left corner in the rectangle's relative coordinate basis
		 */
		public function get x2():Number
		{
			return _x2;
		}

		/**
		 * @private
		 */
		public function set x2(value:Number):void
		{
			_x2 = value;
		}

		public function get y2():Number
		{
			return _y2;
		}

		public function set y2(value:Number):void
		{
			_y2 = value;
		}

		/**
		 * the bottom left corner in the rectangle's relative coordinate basis
		 */
		public function get x3():Number
		{
			return _x3;
		}

		/**
		 * @private
		 */
		public function set x3(value:Number):void
		{
			_x3 = value;
		}

		public function get y3():Number
		{
			return _y3;
		}

		public function set y3(value:Number):void
		{
			_y3 = value;
		}

		/**
		 * the bottom right corner in the rectangle's relative coordinate basis
		 */
		public function get x4():Number
		{
			return _x4;
		}

		/**
		 * @private
		 */
		public function set x4(value:Number):void
		{
			_x4 = value;
		}

		public function get y4():Number
		{
			return _y4;
		}

		public function set y4(value:Number):void
		{
			_y4 = value;
		}

		
	}
}