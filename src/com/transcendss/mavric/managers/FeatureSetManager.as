package com.transcendss.mavric.managers
{
	import com.cartogrammar.shp.*;
	import com.transcendss.transcore.util.PolarToUTM;
	
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.utils.ColorUtil;
	import mx.utils.NameUtil;
	import mx.utils.StringUtil;
	
	import org.vanrijkom.shp.*;
	
	import spark.filters.ShaderFilter;
	
	/**
	 * FeatureSetManager monitors a set of Shapefile features and determines
	 * what milepoint a current position is along a feature (right now, only polygons).
	 * It also provides a number of other useful spatial features.
	 * 
	 * @author nkorzekwa
	 * */
	public class FeatureSetManager
	{
		private var mFeatures:Array;
		private var mLatitude:Number;
		private var mLongitude:Number;
		private var _utmX:Number;
		private var _utmY:Number;
		private var closestIsBefore:Boolean;
		private var _routeCoords:ArrayCollection;
		private static var M_ENDPOINT_THRESH:Number = 1.5;
		
		/**
		 * FeatureSetManager is a simple constructor
		 * @param cFeatures is the list of features that are to be monitored by this class
		 * 
		 * */
		public function FeatureSetManager(cFeatures:Array = null, loadBoundary:Boolean = false)
		{
			mFeatures = cFeatures;
			if (mFeatures == null || loadBoundary == true)
				return ;
			var curIndex0:int = 0;
			var orderedList:ArrayList = new ArrayList();
			

			
			for each (var feature:ShpFeature in mFeatures)
			{
				var curIndex1:int = 0;
				var polygon:PolygonFeature = null;
				if (feature is PolygonFeature)
				{
					polygon = feature as PolygonFeature;
				}
				else
				{
					curIndex0++;
					continue;
				}
				var rings:Array = polygon.geometry;
				orderedList.addItem(rings[0]);
				rings.splice(0, 1);
				for (var forIndex0:int = 0; forIndex0 < orderedList.length; forIndex0++)
				{
					var ring:* = orderedList.getItemAt(forIndex0);
					for (var forIndex:int = 0; forIndex < rings.length; forIndex++)
					{
						var tRing:Array = rings[forIndex];
						var tD:Number = accurateDistance_miles(tRing[0].y, tRing[0].x, ring[ring.length - 1].y, ring[ring.length - 1].x);
						var tD2:Number = accurateDistance_miles(tRing[tRing.length - 1].y, tRing[tRing.length - 1].x, ring[0].y, ring[0].x);
						
						if (tD < M_ENDPOINT_THRESH)
						{
							orderedList.addItemAt(tRing, orderedList.getItemIndex(ring) + 1);
							rings.splice(forIndex, 1);
							forIndex--;
						}
						else if (tD2 < M_ENDPOINT_THRESH)
						{
							orderedList.addItemAt(tRing, orderedList.getItemIndex(ring));
							rings.splice(forIndex, 1);
							forIndex--;
						}
						else
						{
							var tDBackwards:Number = accurateDistance_miles(tRing[tRing.length - 1].y, tRing[tRing.length - 1].x, ring[ring.length - 1].y, ring[ring.length - 1].x);
							// Backwards Freaking ring
							if (tDBackwards < M_ENDPOINT_THRESH)
							{
								tRing = tRing.reverse();	
								orderedList.addItemAt(tRing, orderedList.getItemIndex(ring) + 1);
								rings.splice(forIndex, 1);
								forIndex--;
							}
						}
					}
				}
				
			polygon.geometry = orderedList.toArray();
			}
			
			
			this.mLatitude = 42.007;
			this.mLongitude = -93.405;
			var tmpNum:Number = this.calculateMilepoint();
			
		}
		
		public function get utmY():Number
		{
			return _utmY;
		}

		public function set utmY(value:Number):void
		{
			_utmY = value;
		}

		public function get utmX():Number
		{
			return _utmX;
		}

		public function set utmX(value:Number):void
		{
			_utmX = value;
		}

		public function get routeCoords():ArrayCollection
		{
			return _routeCoords;
		}

		public function set routeCoords(value:ArrayCollection):void
		{
			if (!value)
				trace("bad, bad, bad");
			for (var i:int=1;i<value.length;i++)
			{	
				if (!value[i] || !value[i-1])
					trace("nullity");
				if (value[i].M == value[i-1].M)
				{
					value.removeItemAt(i);
					i--;
				}
			}
			_routeCoords = value;
		}

		/**
		 * Deg2Rad is a simple function to convert degrees to radians
		 * @param aDegrees the value, in degrees, that you wish to convert to radians
		 * @return the value of aDegrees in radians
		 * */
		public static function Deg2Rad(aDegrees:Number):Number
		{
			return (aDegrees/180) * Math.PI; 	
		}
		
		public static function Rad2Deg(aRad:Number):Number
		{
			return aRad * (180 / Math.PI);
		}
		
		/**
		 * accurateDistance_miles is a function that uses the Haversine equation to accuractly measure distance
		 * between two lat/long points. It should be noted that while this method is fairly accurate, it still has
		 * error because it assumes a perfect sphere, which the Earth is not.
		 * @param aLat1 the first latitude
		 * @param aLong1 the first longitude
		 * @param aLat2 the second latitude
		 * @param aLong2 the second longitude
		 * 
		 * @return the distance between the two points, in miles
		 * */
		public static function accurateDistance_miles(aLat1:Number, aLong1:Number, aLat2:Number, aLong2:Number):Number
		{
			var R:Number = 3959; // miles
			var dLat:Number = Deg2Rad(aLat1-aLat2);
			var dLon:Number = Deg2Rad(aLong1 - aLong2);
			var lat1:Number = Deg2Rad(aLat1);
			var lat2:Number = Deg2Rad(aLat2);
			
			var a:Number = Math.sin(dLat/2) * Math.sin(dLat/2) +
				Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
			var c:Number = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
			var d:Number = R * c;
			return d;
		}
		
		/**
		 * approxDistance_miles is a function that uses equirectangular projection to find the distance 
		 * between two points. It is relatively inaccurate (unless right on a meridian), but fast. 
		 * @param aLat1 the first latitude
		 * @param aLong1 the first longitude
		 * @param aLat2 the second latitude
		 * @param aLong2 the second longitude
		 * 
		 * @return the approximate distance between the two points, in miles
		 * */
		public static function approxDistance_miles(aLat1:Number, aLong1:Number, aLat2:Number, aLong2:Number):Number
		{
			// d is distance in miles since 3959 is the mean Earth radius in miles
			var x:Number = (Deg2Rad(aLong1) - Deg2Rad(aLong2)) * 
				Math.cos((Deg2Rad(aLat1) + Deg2Rad(aLat2)) / 2);
			var y:Number = (Deg2Rad(aLat1) - Deg2Rad(aLat2));
			var d:Number = Math.sqrt(x*x + y*y) * 3959;
			return d;
		}
		
		/**
		 * linearDistance_pixels calculates the Pathagorean distance bettween to linear points,
		 * specifically, in this case, treating two lat/long pair coordinates as x/y coordinates.
		 * 
		 * @param aLat1 the first latitude
		 * @param aLong1 the first longitude
		 * @param aLat2 the second latitude
		 * @param aLong2 the second longitude
		 * 
		 * @return the exact linear distance between the two points, in pixels
		 * */
		public static function linearDistance_pixels(aLat1:Number, aLong1:Number, aLat2:Number, aLong2:Number):Number
		{
			return Math.sqrt(Math.pow((aLat1 - aLat2), 2) + Math.pow((aLong1 - aLong2), 2));
		}
		
		/**
		 * polyContainsPoint determines whether a given point is in a given polygon
		 * @param aPoly the polygon to test
		 * @param x the x coordinate of the point
		 * @param y the y coordinate of the point
		 * 
		 * @return whether the point is in the polygon or not
		 * */
		public static function polyContainsPoint(aPoly:Array, x:Number, y:Number):Boolean
		{
			/*
			Adapted from:
			http://paulbourke.net/geometry/insidepoly/
			*/
			var i:int, j:int = 0;
			var c:Boolean = false;
			for (i = 0, j = aPoly.length-1; i < aPoly.length; j = i++) 
			{
				if (((((aPoly[i] as ShpPoint).y <= y) && (y < (aPoly[j] as ShpPoint).y)) ||
					(((aPoly[j] as ShpPoint).y <= y) && (y < (aPoly[i] as ShpPoint).y))) &&
					(x < ((aPoly[j] as ShpPoint).x - (aPoly[i] as ShpPoint).x) * (y - (aPoly[i] as ShpPoint).y) / 
						((aPoly[j] as ShpPoint).y - (aPoly[i] as ShpPoint).y) + (aPoly[i] as ShpPoint).x))
					c = !c;
			}
			return c;
		}
		
		/**
		 * findIntersectingPolygon finds all the polygons that contain the current lat/long position.
		 * 
		 * @return a list of polygons
		 * */
		public function findIntersectingPolygon():Vector.<PolygonFeature>
		{
			var retVal0:Vector.<PolygonFeature> = new Vector.<PolygonFeature>();
			var retVal:Vector.<PolygonFeature> = new Vector.<PolygonFeature>();
			for each (var feat2:ShpFeature in mFeatures)
			{
				var feat:PolygonFeature = null;
				if (feat2 is PolygonFeature)
				{
					feat = feat2 as PolygonFeature;
				}
				else
					continue;
				var pnt:Point = new Point(mLongitude, mLatitude);
				//var rect:Rectangle = feat.record.box;
				
				// TODO: Optimization Opportunity
				//if (rect.containsPoint(pnt))
				retVal0.push(feat);
			}
			
			for each (var feat3:PolygonFeature in retVal0)
			{
				var rings:Array = feat3.geometry;
				for each (var ring:Array in rings)
				{
					if (polyContainsPoint(ring, mLongitude, mLatitude))
					{
						retVal.push(feat3);
					}
				}
			}
			return retVal;
		}
		
		/**
		 * getPolygonExtent returns the extent of the polygon for the specified ID.
		 * 
		 * @return a list of polygons
		 * */
		public function getPolygonExtent(polyID:String):Array
		{
			var retVal:Array = null;
			var minx:Number;
			var miny:Number;
			var maxx:Number;
			var maxy:Number;
			
			for each (var feat2:ShpFeature in mFeatures)
			{
				var feat:PolygonFeature = null;
				if (feat2 is PolygonFeature)
				{
					feat = feat2 as PolygonFeature;
					if (parseInt(feat.values.DISTRICT_N).toString() == polyID)
					{
						
						minx = feat.geometry[0][0].x;
						maxx = feat.geometry[0][0].x;
						miny = feat.geometry[0][0].y;
						maxy = feat.geometry[0][0].y;
						for (var i:int=0;i<feat.geometry.length;i++)
						{
							var tmp:Array = feat.geometry[i] as Array;
							for (var k:int=0;k<tmp.length;k++)
							{
								if (feat.geometry[i][k].x < minx)
								{
									minx = feat.geometry[i][k].x;
								} else if (feat.geometry[i][k].x > maxx)
								{
									maxx = feat.geometry[i][k].x;
								}
								if (feat.geometry[i][k].y < miny)
								{
									miny = feat.geometry[i][k].y;
								} else if (feat.geometry[i][k].y > maxy)
								{
									maxy = feat.geometry[i][k].y;
								}
								
							}
						}
						retVal = new Array();
						retVal[0] = minx;
						retVal[1] = miny;
						retVal[2] = maxx;
						retVal[3] = maxy;
						break;
					}	
				}
			
			}
			return retVal;
		}
		
		/**
		 * getPolygonExtent returns the extent of the polygon for the specified Name.
		 * 
		 * @return a list of polygons
		 * */
		public function getPolygonExtentByName(polyName:String):Array
		{
			var retVal:Array = null;
			var minx:Number;
			var miny:Number;
			var maxx:Number;
			var maxy:Number;
		
			for each (var feat2:ShpFeature in mFeatures)
			{
				var feat:PolygonFeature = null;
				if (feat2 is PolygonFeature)
				{
					feat = feat2 as PolygonFeature;
					if (StringUtil.trim(feat.values.CO_NAME) == polyName)
					{
						
						minx = feat.geometry[0][0].x;
						maxx = feat.geometry[0][0].x;
						miny = feat.geometry[0][0].y;
						maxy = feat.geometry[0][0].y;
						for (var i:int=0;i<feat.geometry.length;i++)
						{
							var tmp:Array = feat.geometry[i] as Array;
							for (var k:int=0;k<tmp.length;k++)
							{
								if (feat.geometry[i][k].x < minx)
								{
									minx = feat.geometry[i][k].x;
								} else if (feat.geometry[i][k].x > maxx)
								{
									maxx = feat.geometry[i][k].x;
								}
								if (feat.geometry[i][k].y < miny)
								{
									miny = feat.geometry[i][k].y;
								} else if (feat.geometry[i][k].y > maxy)
								{
									maxy = feat.geometry[i][k].y;
								}
								
							}
						}
						retVal = new Array();
						retVal[0] = minx;
						retVal[1] = miny;
						retVal[2] = maxx;
						retVal[3] = maxy;
						break;
					}	
				}
				
			}
			return retVal;
		}
		
		/**
		 * interpolateLatLong finds a point along an arc between two points
		 * that's closest to a third point.
		 * @param aPoint the point that the final result should be closest to
		 * @param aAdjacentPoints the two points that generate the line or arc
		 * 
		 * @return the optimal point
		 * 
		 * */
		public function interpolateLatLong(aPoint:ShpPoint, aAdjacentPoints:Vector.<ShpPoint>):ShpPoint
		{
			// point before
			var minLat:Number = aPoint.y;
			var minLong:Number = aPoint.x;
			//trace("Closest point x,y: " + aPoint.x + "," + aPoint.y);
			var minDistance:Number = Number.MAX_VALUE;
			var bSlope:Number = (aPoint.y - aAdjacentPoints[0].y)/(aPoint.x - aAdjacentPoints[0].x);
			var smallerPoint:Number = (aAdjacentPoints[0].x < aPoint.x) ? aAdjacentPoints[0].x : aPoint.x;
			var smallerPointY:Number = (aAdjacentPoints[0].x < aPoint.x) ? aAdjacentPoints[0].y : aPoint.y;
			var largerPoint:Number = (aAdjacentPoints[0].x > aPoint.x) ? aAdjacentPoints[0].x : aPoint.x;
			var dFor:Number = 0;
			for (var forIndex:Number = smallerPoint; forIndex < largerPoint; forIndex += 0.0001)
			{
				var point:Point = new Point();
				
				//TODO: Major Optimization Opportunity -- Get equation derived and solved
				point.x = forIndex;
				point.y = smallerPointY + bSlope * dFor;
				var tD:Number = approxDistance_miles(mLatitude, mLongitude, point.y, point.x);
				//trace("xy: " + mLatitude + "," + mLongitude + "," + point.y + "," + point.x + "Dist: " + tD);
				//trace("Min Dist " + minDistance);
				if (tD < minDistance)
				{
					minDistance = tD;
					minLat = point.y;
					minLong = point.x;
					closestIsBefore = true;
				}
				dFor += 0.0001;
			}
			
			//point after
			bSlope = (aPoint.y - aAdjacentPoints[1].y)/(aPoint.x - aAdjacentPoints[1].x);
			smallerPoint = (aAdjacentPoints[1].x < aPoint.x) ? aAdjacentPoints[1].x : aPoint.x;
			smallerPointY = (aAdjacentPoints[1].x < aPoint.x) ? aAdjacentPoints[1].y : aPoint.y;
			largerPoint = (aAdjacentPoints[1].x > aPoint.x) ? aAdjacentPoints[1].x : aPoint.x;
			dFor = 0;
			for (var forIndex2:Number = smallerPoint; forIndex2 < largerPoint; forIndex2 += 0.0001)
			{
				var point2:Point = new Point();
				
				//TODO: Major Optimization Opportunity -- Get equation derived and solved
				point2.x = forIndex2;
				point2.y = smallerPointY + bSlope * dFor;
				var tDw:Number = approxDistance_miles(mLatitude, mLongitude, point2.y, point2.x);
				if (tDw < minDistance)
				{
					minDistance = tDw;
					minLat = point2.y;
					minLong = point2.x;
					closestIsBefore = false;
				}
				dFor += 0.0001;
			}
			
			var retPoint:ShpPoint = new ShpPoint();
			retPoint.x = minLong;
			retPoint.y = minLat;
			trace("Geom x,y: " + minLong + "," + minLat);
			return retPoint;
		}
		
		/**
		 * interpolateLatLong finds a point along an arc between two points
		 * that's closest to a third point.
		 * @param aPoint the point that the final result should be closest to
		 * @param aAdjacentPoints the two points that generate the line or arc
		 * 
		 * @return the optimal point
		 * 
		 * */
		public function interpolateLatLong2(pntIndex:Number):ShpPoint
		{
			var minLat:Number;
			var minLong:Number;
			
			var bSlope:Number;
			var smallerPointX:Number;
			var smallerPointY:Number;
			var largerPointX:Number;
			var largerPointY:Number;
			var point:Point;
			var forIndex:Number
			var tD:Number;
			
			var vertTrack:Boolean = false;
			
			// get the values from the correct coordinate pairs
			if (closestIsBefore)
			{
				minLat = this.routeCoords[pntIndex].Y;
				minLong = this.routeCoords[pntIndex].X;
				//if (this.routeCoords[pntIndex].X == this.routeCoords[pntIndex+1].X)
				//	bSlope = 90;
				//else
				//	bSlope = (this.routeCoords[pntIndex].Y - this.routeCoords[pntIndex+1].Y)/(this.routeCoords[pntIndex].X - this.routeCoords[pntIndex+1].X);
				smallerPointX = this.routeCoords[pntIndex].X;
				smallerPointY = this.routeCoords[pntIndex].Y;
				largerPointX = this.routeCoords[pntIndex+1].X;
				largerPointY - this.routeCoords[pntIndex+1].Y;	
			} else
			{
				minLat = this.routeCoords[pntIndex -1].Y;
				minLong = this.routeCoords[pntIndex -1].X;
				//bSlope = (minLat - this.routeCoords[pntIndex].Y)/(minLong - this.routeCoords[pntIndex].X);
				smallerPointX = this.routeCoords[pntIndex-1].X ;
				smallerPointY = this.routeCoords[pntIndex-1].Y;
				largerPointX =  this.routeCoords[pntIndex].X;
				largerPointY = this.routeCoords[pntIndex].Y;	
			}
			
			// Check the slope of the segment and determine what kind of tracking to use
			if (minLat == largerPointY)
			{
				vertTrack = true;
				bSlope = 0;
			} else if (minLong == largerPointX)
			{
				vertTrack = false;
				bSlope = 0;
			} else
			{
				
				if (Math.abs(bSlope) > 1)
				{
					bSlope = (minLong - largerPointX)/(minLat - largerPointY);
					vertTrack = true;
				}
				else
				{
					bSlope = (minLat - largerPointY)/(minLong - largerPointX);
					vertTrack = false;
				}
			}
			
			
			var minDistance:Number = Number.MAX_VALUE;

			var dFor:Number = 0;
			
			if (vertTrack)  // Calculate the path by moving the latitude values
			{
				for (forIndex = smallerPointY; forIndex < largerPointY; forIndex += 0.00002)
				{
					point = new Point();
					
					point.y = forIndex;
					point.x = smallerPointX + bSlope * dFor;
					tD = approxDistance_miles(mLatitude, mLongitude, point.y, point.x);
					if (tD < minDistance)
					{
						minDistance = tD;
						minLat = point.y;
						minLong = point.x;
					}
					dFor += 0.00002;
				}
			} else // Calculate the path by moving the longitude values
			{
				for (forIndex = smallerPointX; forIndex < largerPointX; forIndex += 0.00001)
				{
					point = new Point();
					
					point.x = forIndex;
					point.y = smallerPointY + bSlope * dFor;
					tD = approxDistance_miles(mLatitude, mLongitude, point.y, point.x);
					if (tD < minDistance)
					{
						minDistance = tD;
						minLat = point.y;
						minLong = point.x;
					}
					dFor += 0.00001;
				}
			}
			

			
			var retPoint:ShpPoint = new ShpPoint();
			retPoint.x = minLong;
			retPoint.y = minLat;
			trace("Geom x,y: " + minLong + "," + minLat);
			return retPoint;
		}
		
		public function projectPositionToFeature():ShpPoint
		{
			var nearestPoint:ShpPoint = this.findClosestPoint();
			var retVal:ShpPoint = interpolateLatLong(nearestPoint, getAdjacentPoints(nearestPoint));
			return retVal;
		}
		/**
		 * getAdjacentPoints returns the points surrounding a given point for a particular polygon
		 * @param aPoint the given point
		 * 
		 * @return the adjacent points
		 * */
		public function getAdjacentPoints(aPoint:ShpPoint):Vector.<ShpPoint>
		{
			var pointAfter:ShpPoint;
			var pointBefore:ShpPoint;
			var index:int = 0;
			var index0:int = 0;
			for each (var lFeature:ShpFeature in mFeatures)
			{
				var feat:PolygonFeature = null;
				if (lFeature is PolygonFeature)
				{
					feat = lFeature as PolygonFeature;
				}
				else
				{
					index0++;
					continue;
				}
				index = 0;
				for each (var lRing:Array in feat.geometry)
				{
					for each (var lPoint:ShpPoint in lRing)
					{
						if (lPoint == aPoint)
						{
							if (index == 0)
								pointBefore = lRing[lRing.length - 1];					
							else
								pointBefore = lRing[index - 1];
							
							if (index == lRing.length - 1)
								pointAfter = lRing[0];
							else
								pointAfter = lRing[index + 1];
						}
						index++;
					}
					index = 0;
				}
				index0++;
			}
			
			var retVec:Vector.<ShpPoint> = new Vector.<ShpPoint>();
			retVec.push(pointBefore);
			retVec.push(pointAfter);
			return retVec;
		}
		
		
		
		/**
		 * findClosestPoint finds the closest point in all the classes features that's closest to the 
		 * current GPS/provided position.
		 * 
		 * @return the point that is closest
		 * */
		public function findClosestPoint():ShpPoint
		{
			var min:Number = Number.MAX_VALUE;
			var curIndex0:int = 0;
			var curIndex1:int = 0;
			var curIndex2:int = 0;
			var minIndex0:int = 0;
			var minIndex1:int = 0;
			var minIndex2:int = 0;
			
			var currentRings:Array = new Array();
			//trace("Num of Feats:" + mFeatures.length);
			var fCnt:Number = 0;
			for each (var feat2:ShpFeature in mFeatures)
			{
				fCnt++;
				//trace("Feature # " + fCnt);
				curIndex1 = 0;
				var feat:PolygonFeature = null;
				if (feat2 is PolygonFeature)
				{
					feat = feat2 as PolygonFeature;
				}
				else
				{
					curIndex0++;
					continue;
				}
				currentRings = feat.geometry;
				//trace("Num of Rings:" + currentRings.length + " in feature " + fCnt);
				var rCnt:Number = 0;
				for each (var ring:Array in currentRings)
				{
					rCnt++;
					//trace("Ring # " + rCnt);
					curIndex2 = 0;
					for each (var point:ShpPoint in ring)
					{
						//trace("Ring point: " + point.x + "," + point.y);
						var d:Number = accurateDistance_miles(mLatitude, mLongitude, point.y, point.x);
						if (d < min)
						{
							min = d;
							minIndex1 = curIndex1;
							minIndex2 = curIndex2;
							minIndex0 = curIndex0;
						}
						curIndex2++;
					}
					curIndex1++;
				}
				curIndex0++;
			}
			
			var returnVal:PolygonFeature = mFeatures[minIndex0];
			return returnVal.geometry[minIndex1][minIndex2];
		}
		
		/**
		 * findClosestPoint finds the closest point in the coordinate array that's closest to the 
		 * current GPS/provided position.
		 * 
		 * @return the index to the point that is closest
		 * */
		public function findClosestPoint2():Number
		{
			var min:Number = Number.MAX_VALUE;
			var minIndex1:int = 0;
			
			for (var rcIndex:Number=0;rcIndex<routeCoords.length;rcIndex++)
			{
					var tmpX:Number = this.routeCoords[rcIndex].X;
					var tmpY:Number = this.routeCoords[rcIndex].Y;
					var d:Number = accurateDistance_miles(mLatitude, mLongitude, tmpY, tmpX);
					if (d < min)
					{
						min = d;
						minIndex1 = rcIndex; 
					}		
			}
			
			if (minIndex1 == 0)
				closestIsBefore = true;
			else if (minIndex1 == this.routeCoords.length - 1)
				closestIsBefore = false;
			else
			{
				var distToPrevPoint:Number = accurateDistance_miles(this.routeCoords[minIndex1-1].Y, this.routeCoords[minIndex1-1].X,this.routeCoords[minIndex1].Y, this.routeCoords[minIndex1].X);
				var distToNextPoint:Number = accurateDistance_miles(this.routeCoords[minIndex1].Y, this.routeCoords[minIndex1].X,this.routeCoords[minIndex1+1].Y, this.routeCoords[minIndex1+1].X);
				var distXYToPrevPoint:Number = accurateDistance_miles(this.routeCoords[minIndex1-1].Y, this.routeCoords[minIndex1-1].X,mLatitude,mLongitude) + min;
				var distXYToNextPoint:Number = accurateDistance_miles(this.routeCoords[minIndex1+1].Y, this.routeCoords[minIndex1+1].X,mLatitude,mLongitude) + min;
				if ((distToPrevPoint - distXYToPrevPoint) < (distToNextPoint - distXYToNextPoint))
					closestIsBefore = true;
				else
					closestIsBefore = false;	
			}
			
			
			
			return minIndex1;
		}
		
		/**
		 * calculateMilepoint calculates and returns the current milepoint the user is along the
		 * specified features in the class
		 * 
		 * @return the milepoint
		 * */
		public function calculateMilepoint():Number
		{
			var aggregateDistance:Number = 0;
			var curIndex0:int = 0;
			for each (var feature:ShpFeature in mFeatures)
			{
				var curIndex1:int = 0;
				var polygon:PolygonFeature = null;
				if (feature is PolygonFeature)
				{
					polygon = feature as PolygonFeature;
				}
				else
				{
					curIndex0++;
					continue;
				}
				
				var closest:ShpPoint = findClosestPoint();
				var optimal:ShpPoint = interpolateLatLong(closest, getAdjacentPoints(closest));
				var allPntArray:ArrayList = new ArrayList();
				// TODO: Find out how roads are constructed
				for each (var ring:Array in polygon.geometry)
				{	
					
					//mMap.addMarkerAt(ring[0].y - curIndex1 * 0.0, ring[0].x, 0x222222 * curIndex1);
					//mMap.addMarkerAt(ring[ring.length - 1].y - 0.1, ring[ring.length - 1].x, 0x222222 * curIndex1);
					for (var forIndex:int = 0; forIndex < ring.length-1; forIndex++)
					{
						
						allPntArray.addItem(ring[forIndex]);
						
						var tPoint:ShpPoint = ring[forIndex];
						var tPoint2:ShpPoint = ring[forIndex + 1];
						if (tPoint == closest)
						{
							var tDist0:Number = accurateDistance_miles(tPoint.y, tPoint.x, optimal.y, optimal.x);
							var tDist:Number = accurateDistance_miles(tPoint.y, tPoint.x, tPoint2.y, tPoint2.x);
							if (closestIsBefore)
								aggregateDistance = aggregateDistance - tDist0;
							else
								aggregateDistance += tDist0;
							
							//trace(aggregateDistance);
							return aggregateDistance;
						}
						
						var tDist3:Number = accurateDistance_miles(tPoint.y, tPoint.x, tPoint2.y, tPoint2.x);
						//trace(tPoint.y +","+ tPoint.x +","+ tPoint2.y +","+ tPoint2.x + " - Dist: " + tDist);
						aggregateDistance += tDist3;
						//trace(aggregateDistance);
					}
					
					curIndex1++;
					//trace("Run: " + curIndex1);
				}				
			}
			return aggregateDistance;
		}
		
		// The first two points correspond to the first line, the last two to the second line
		private function calculateAnglePrueba(valuePoint1:Point, valuePoint2:Point, valuePoint3:Point, valuePoint4:Point):Number
		{
			var vector1:Point = new Point(valuePoint2.x - valuePoint1.x, valuePoint2.y - valuePoint1.y);
			var vector2:Point = new Point(valuePoint4.x - valuePoint3.x, valuePoint4.y - valuePoint3.y);
			trace("Vector 1 = (" + vector1.x + ", " + vector1.y + ")");
			trace("Vector 2 = (" + vector2.x + ", " + vector2.y + ")");
			
			var vector1Magnitude:Number = Math.sqrt(Math.pow(vector1.x, 2) + Math.pow(vector1.y, 2));
			var vector2Magnitude:Number = Math.sqrt(Math.pow(vector2.x, 2) + Math.pow(vector2.y, 2));
			
			var dotProduct:Number = (vector1.x * vector2.x) + (vector1.y * vector2.y);
			
			var resultado:Number = (Math.acos(dotProduct / (vector1Magnitude * vector2Magnitude))) * (180/Math.PI);            
			
			return(resultado);
		}
		
		private function calculateSchumAngle(beg:Point, end1:Point, end2:Point):Number
		{
			var retAngle:Number;
			
			var begx:Number = Math.cos(Deg2Rad(beg.x)) * Math.cos(Deg2Rad(beg.y));
			var begy:Number = Math.sin(Deg2Rad(beg.x)) * Math.cos(Deg2Rad(beg.y));
			var end1x:Number = Math.cos(Deg2Rad(end1.x)) * Math.cos(Deg2Rad(end1.y));
			var end1y:Number = Math.sin(Deg2Rad(end1.x)) * Math.cos(Deg2Rad(end1.y));
			var end2x:Number = Math.cos(Deg2Rad(end2.x)) * Math.cos(Deg2Rad(end2.y));
			var end2y:Number = Math.sin(Deg2Rad(end2.x)) * Math.cos(Deg2Rad(end2.y));
			
			var deltax1:Number = begx - end1x;
			var deltax2:Number = begx - end2x;
			
			var deltay1:Number = begy - end1y;
			var deltay2:Number = begy - end2y;
			
			var angle1:Number =  Rad2Deg(Math.atan(Math.abs(deltay1 / deltax1)));
			var angle2:Number = Rad2Deg(Math.atan(Math.abs(deltay2 / deltax2)));
			
			retAngle = Math.abs(angle1 - angle2);
			
			return retAngle;
		}
		
		
		/**
		 * calculateMilepoint calculates and returns the current milepoint the user is along the
		 * specified features in the class
		 * 
		 * @return the milepoint
		 * */
		public function calculateMilepoint2():Number
		{
			var aggregateDistance:Number = 0;
			var curIndex0:int = 0;
			
				
				var closest:Number = findClosestPoint2();
				
				// Alternative method for calculating the mile point length
				var distFromPrev:Number;
				var segSlope:Number;
				var gpsSlope:Number
				var gpscosDiff:Number;
				var segcosDiff:Number;
				var calcAggMileage:Number;
				
				var theAngle:Number;
				
				var originPoint:Point;
				var segEndPoint:Point;
				var gpsEndPoint:Point;
				
				trace("Input xy: " + this.longitude + " , " + this.latitude);
				
				if (!routeCoords[0].hasOwnProperty("utmX"))
				{
					var pUTM:PolarToUTM = new PolarToUTM();
					routeCoords = pUTM.routeCoordsToUTM(routeCoords);
				}
				
				if (closestIsBefore)
				{
					
					originPoint = new Point(routeCoords[closest].utmX, routeCoords[closest].utmY);
					segEndPoint = new Point(routeCoords[closest + 1].utmX, routeCoords[closest+1].utmY);
					gpsEndPoint = new Point(this.utmX, this.utmY);
					
					theAngle = this.calculateAnglePrueba(originPoint, segEndPoint, originPoint, gpsEndPoint);
					distFromPrev = accurateDistance_miles(this.routeCoords[closest].Y, this.routeCoords[closest].X,this.mLatitude, this.mLongitude);
				
				} else
				{
					
					originPoint = new Point(routeCoords[closest-1].utmX, routeCoords[closest-1].utmY);
					segEndPoint = new Point(routeCoords[closest].utmX, routeCoords[closest].utmY);
					gpsEndPoint = new Point(this.utmX, this.utmY);
					
					
					theAngle = this.calculateAnglePrueba(originPoint, segEndPoint, originPoint, gpsEndPoint);
					distFromPrev = accurateDistance_miles(this.routeCoords[closest-1].Y, this.routeCoords[closest-1].X,this.mLatitude, this.mLongitude);
					
				}
				trace("From Point: " + originPoint.x + " , " + originPoint.y);
				trace("Input utm: " + this.utmX + " , " + this.utmY);
				trace("Seg End Point: " + segEndPoint.x + " , " + segEndPoint.y);
				trace("Angle: " + theAngle);
				trace("Segment Distance: " + distFromPrev);
				
				var additionalMileage:Number =Math.abs(Math.cos(Deg2Rad(theAngle)) * distFromPrev);
				trace("Additional Mileage: " + additionalMileage);
				if (closestIsBefore)
				{
					calcAggMileage = parseFloat(this.routeCoords[closest].M) + additionalMileage;
				} else
				{
					calcAggMileage = parseFloat(this.routeCoords[closest-1].M) + additionalMileage;
				}
				trace("Total Mileage: " + calcAggMileage);
				//return calcAggMileage;
				// End of alternative method
				
				
			/*	var optimal:ShpPoint = interpolateLatLong2(closest);
				if (closestIsBefore)
				{
					var mdist:Number = this.routeCoords[closest + 1].M - this.routeCoords[closest].M;
					var lldist:Number = accurateDistance_miles(this.routeCoords[closest].Y, this.routeCoords[closest].X, this.routeCoords[closest + 1].Y, this.routeCoords[closest + 1].X);
					var partialDist:Number = accurateDistance_miles(this.routeCoords[closest].Y, this.routeCoords[closest].X, optimal.y, optimal.x);
					var percDist:Number = partialDist / lldist;
					aggregateDistance = parseFloat(this.routeCoords[closest].M) + (mdist * percDist);
				} else
				{
					mdist = this.routeCoords[closest].M - this.routeCoords[closest - 1].M;
					lldist = accurateDistance_miles(this.routeCoords[closest - 1].Y, this.routeCoords[closest - 1].X, this.routeCoords[closest].Y, this.routeCoords[closest].X);
					partialDist = accurateDistance_miles(this.routeCoords[closest - 1].Y, this.routeCoords[closest - 1].X, optimal.y, optimal.x);
					percDist = partialDist / lldist;
					aggregateDistance = parseFloat(this.routeCoords[closest - 1].M) + (mdist * percDist);
				}
				trace("mp: " + aggregateDistance);*/
				
				
			return calcAggMileage;
			//return aggregateDistance;
		}
		
		/**
		 * getter for milepoint
		 * @return the milepoint
		 * */
		public function get milepoint():Number
		{
			return calculateMilepoint();
		}

		public function get latitude():Number
		{
			return mLatitude;
		}

		public function set latitude(value:Number):void
		{
			mLatitude = value;
		}

		public function get longitude():Number
		{
			return mLongitude;
		}

		public function set longitude(value:Number):void
		{
			mLongitude = value;
		}


	}
}