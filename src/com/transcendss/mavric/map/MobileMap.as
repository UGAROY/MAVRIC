package com.transcendss.mavric.map
{
	import com.transcendss.mavric.db.MAVRICDBManager;
	import com.transcendss.mavric.util.FileUtility;
	import com.transcendss.mavric.util.PopUpUtils;
	import com.transcendss.transcore.events.TSSMapEvent;
	import com.tss.mapcore.map.TSSMap;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Image;
	import spark.components.Scroller;
	import spark.core.SpriteVisualElement;
	
	public class MobileMap extends UIComponent
	{
		private var iMinx:Number;
		private var iMiny:Number;
		private var iMaxx:Number;
		private var iMaxy:Number;
		private var currMinx:Number;
		private var currMiny:Number;
		private var currMaxx:Number;
		private var currMaxy:Number;
		//private var mapServiceURL:String = "http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer";
		
		private var mapServiceURL:String =FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.baseMapUrl;
//		private var mapServiceURL:String = BaseConfigUtility.get("basemapLayer");
		private var imageList:ArrayList = new ArrayList();
		
		
		
		private var mapMinx:ArrayList = new ArrayList();
		private var mapMiny:ArrayList = new ArrayList();
		private var mapMaxx:ArrayList = new ArrayList();
		private var mapMaxy:ArrayList = new ArrayList();
		private var mapWidth:Number = 978;
		private var mapHeight:Number = 562;
		private var initialMapWidth:Number = 978;
		private var initialMapHeight:Number = 562;
		
		private var zoomState:Number = 0;
		private var liveZoomState:Number = 0;
		private var mapGroup:Group = new Group();
		private var imageGroup1:Group = new Group(); // For the top overviewMap
		
		//newly added code
		private var tempImageGroup:Group = new Group(); // use a temp instead
		private var lodList:ArrayList = new ArrayList(); // to store the each lod group
		private var mapImage:Image = new Image();
		private var tempMapImage:Image = new Image();
		private var tileList:ArrayList = new ArrayList(); 
		private var imageIndex:int = -1;
		private var EsriMap:TSSMap = new TSSMap();
		
		[Inspectable]
		public var numberOfLevel:int = 3;
		
		public var isDistrictCached:Boolean = false;
		
		private var PrefixName:String = "";
		
		private var loadMapType:String = ""; // "live" for lived map, "district" for districte-based cached map, "route" for route-based cached map
		
		//end of newly added code
		
		private var zinImage:Image = new Image();
		private var zoutImage:Image = new Image();
		private var canvas:BorderContainer = new BorderContainer();
		private var sve:SpriteVisualElement = new SpriteVisualElement();
		private var _routeCoords:ArrayCollection;
		private var positionSprite:Sprite = new Sprite();
		private var mapRetrievalCount:int = 0;
		private var tileRetrievalCount:int = 0;
		private var dbManager:MAVRICDBManager;
		private var fileUtility:FileUtility = new FileUtility();
		
		private var mapIsDrawing:Boolean = false;
		private var localCoords:Array = null;
		
		private var mapIsPanning:Boolean = false;
		private var mapMDownX:Number = 0;
		private var mapMDownY:Number = 0;
		
		private var currX:Number = -1;
		private var currY:Number = -1;
		
		private var mapScroller:Scroller;
		private var scrollGroup:Group = new Group;
		
		[Embed(source="../../../../images/sld/zoom-in.png")] protected var zoomin:Class
		[Embed(source="../../../../images/sld/zoom-out.png")] protected var zoomout:Class
		[Embed(source="../../../../images/arrow_up.png")] protected var panUp:Class
		[Embed(source="../../../../images/arrow_down.png")] protected var panDown:Class
		[Embed(source="../../../../images/arrow_left.png")] protected var panLeft:Class
		[Embed(source="../../../../images/arrow_right.png")] protected var panRight:Class
		
		//toggle base map layers
		public var toggleMapButton:spark.components.Button = new spark.components.Button();
		
		public function MobileMap()
		{
			trace("call function MobileMap (MobileMap.as)");
			
			try
			{	
				dbManager = MAVRICDBManager.newInstance();
				buildMapView();
			} catch (err:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert(err.message);
			}
		}
		
		private function buildMapView():void
		{
			
			mapImage.x = 0;
			mapImage.y = 0;
			imageGroup1.addElement(mapImage);
			
			// Set up the map group
			mapGroup.height = mapHeight;
			mapGroup.width = mapWidth;
			mapGroup.addElement(imageGroup1);
			
			lodList.addItemAt(imageGroup1,0);
			
			canvas.x=0;
			canvas.y=0;
			canvas.height=mapHeight;
			canvas.width=mapWidth;
			canvas.visible=true;
			canvas.setStyle("backgroundAlpha",0);
			canvas.setStyle("contentBackgroundAlpha",0);
			positionSprite.graphics.lineStyle(1,0x000000,1);
			positionSprite.graphics.beginFill(0xFF0000,1);
			positionSprite.graphics.drawCircle(5,5,8);
			positionSprite.graphics.endFill();
			positionSprite.visible = false;
			positionSprite.x=0;
			positionSprite.y=0;
			
			
			sve.addChild(positionSprite);
			sve.x=0;
			sve.y=0;
			sve.height=mapHeight;
			sve.width=mapWidth;
			canvas.addElement(sve);
			
			mapGroup.addElement(canvas);
			
			zinImage.source = zoomin;
			zinImage.x = 35;
			zinImage.y = 30;
			zinImage.width = 35;
			zinImage.height = 35;
			zinImage.addEventListener(MouseEvent.CLICK, zoomIn);
			
			
			zoutImage.source = zoomout;
			zoutImage.x = 35;
			zoutImage.y = 85;
			zoutImage.width = 35;
			zoutImage.height = 35;
			zoutImage.addEventListener(MouseEvent.CLICK, zoomOut);
			
			toggleMapButton.x = mapWidth - 100  ;
			toggleMapButton.y = 10;
			toggleMapButton.label = "Maps"; 
			toggleMapButton.width = 80;
			toggleMapButton.height = 30;
			toggleMapButton.addEventListener(MouseEvent.CLICK, toggleMapClick_Handler);
			
			zinImage.visible = false;
			zoutImage.visible = false;
			
			this.addChild(mapGroup);
			this.addChild(zoutImage);
			this.addChild(zinImage);
			this.addChild(toggleMapButton);
			
			mapScroller = new Scroller();
			mapScroller.percentHeight = 100;
			mapScroller.percentWidth = 100;
			mapScroller.viewport = mapGroup;
			this.addChildAt(mapScroller, 0);
			
			//added for the first zoom level
			mapGroup.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			mapGroup.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			mapGroup.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function scrollTo(x:Number, y:Number):void
		{
			mapGroup.horizontalScrollPosition = x;
			mapGroup.verticalScrollPosition = y;
		}
		
		private function toggleMapClick_Handler(evt:MouseEvent):void
		{
			//var toggleMapEvent:MapInitEvent = new MapInitEvent(MapInitEvent.MAP_ROUTE_INFO_READY);
			if(zoomState !=0)
			{
				zoomState =0 ;
				setZoomLevel(0); // added to avoid the tricky toggle map bug
			}
			var toggleMapEvent:TSSMapEvent = new TSSMapEvent(TSSMapEvent.TOGGLE_MAP);
			dispatchEvent(toggleMapEvent);
		}
		
		/*
		Set the initial map extent.  Esri only.
		*/
		
		public function get routeCoords():ArrayCollection
		{
			
			return _routeCoords;
		}
		
		public function set routeCoords(value:ArrayCollection):void
		{
			if (value.length > 1)
				_routeCoords = value;
		}
		
		
		public function setInitialMapExtent(minx:Number, miny:Number, maxx:Number, maxy:Number, preName:String):void
		{
			// Add a buffer around the route
			var xbuf:Number = Math.abs((maxx - minx)) *.1;
			var ybuf:Number = Math.abs((maxy - miny)) * .1;
			minx = minx - xbuf;
			miny = miny - ybuf;
			maxx = maxx + xbuf;
			maxy = maxy +  ybuf;
			
			this.PrefixName = preName;
		 	//EsriMap = new TSSMap();
			if(PrefixName == "Live Map")
			{
				loadMapType = "live";
				if (!this.contains(EsriMap))
					this.addChildAt(EsriMap,2);
				
				EsriMap.setBaseLayer(mapServiceURL);
				EsriMap.setInitialMapExtent(minx, miny, maxx, maxy);
				EsriMap.setSpatialReference(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.baseMapSR);
				EsriMap.height = this.parent.height;
				EsriMap.width = this.parent.width;
				EsriMap.setMaptype(0);
				addOverlay();
				if (currX != -1)
					positionTrackingPoint(currX, currY, 0, "current");
				else
				{
					var tmpXY:ArrayCollection = this.getXYfromMP(FlexGlobals.topLevelApplication.sldDiagram.sldDiagram.getCurrentMP());
					if (tmpXY != null)
					{
						positionTrackingPoint(tmpXY.getItemAt(0) as Number, tmpXY.getItemAt(1) as Number, 0, "current");
					}
				}
				zinImage.visible = false;
				zoutImage.visible = false;
				// remove map pan 
				mapGroup.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				mapGroup.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				mapGroup.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				return;
			}
			else if (PrefixName.indexOf("D_") != -1)
			{
				loadMapType = "district";
			}
			else
			{
//				var tmpRN:String = FlexGlobals.topLevelApplication.currentRouteName;
//				var tmpBM:Number = FlexGlobals.topLevelApplication.currentBeginMile;
//				var tmpEM:Number = FlexGlobals.topLevelApplication.currentEndMile;
//				PrefixName = tmpRN + "_" + tmpBM + "_" + tmpEM;
				if (dbManager.getMapImageRecordByPrefix(PrefixName) == null) 
				{
					loadMapType = "cache";	
				}
				else 
				{
					loadMapType = "load";
				}
			}
			
			if (this.getChildAt(2) == EsriMap)
				this.removeChildAt(2);

			FlexGlobals.topLevelApplication.setBusyStatus(true);
			if (!this.mapIsDrawing)
			{
				mapIsDrawing = true;
				iMinx=minx;
				iMiny=miny;
				iMaxx=maxx;
				iMaxy=maxy;
				mapRetrievalCount = 0;
				tileRetrievalCount = 0;
				retrieveMapImages();
			}
		}
		
		
		
		// Retrieve the three map scale images. Check locally first.
		private function retrieveMapImages():void
		{		
			try
			{	
				FlexGlobals.topLevelApplication.setBusyStatus(true);
				if (loadMapType == "cache" || isDistrictCached)
				{
					
					var bbox:String;
					var newWidth:int = Math.round(initialMapWidth * (1 + (liveZoomState * .25)));
					var newHeight:int = Math.round((initialMapHeight * (1 + (liveZoomState * .25))));
					
					var msize:String = newWidth + "," + newHeight;
					
					var extWidth:Number = iMaxx - iMinx;
					var extHeight:Number = iMaxy - iMiny;
					
					var tileNum:int = Math.pow(4, mapRetrievalCount)
					var deltaX:Number = extWidth / Math.sqrt(tileNum);
					var deltaY:Number = extHeight / Math.sqrt(tileNum);
					
					var n:int = tileRetrievalCount % Math.sqrt(tileNum);
					var m:int = tileRetrievalCount / Math.sqrt(tileNum);
					
					imageIndex++;
					
					bbox = (iMinx + deltaX * n) + ", " + (iMiny + deltaY * m) + ", " +(iMinx + deltaX * (n+1)) + "," + (iMiny + deltaY * (m+1));
					
					var mapRequestUrl:String = mapServiceURL+"/export?bbox=" + bbox + "&bboxSR=&layers=&layerdefs=&size=" + msize + "&imageSR=&format=png24&transparent=false&dpi=200&f=pjson";
					
					var urlReq:URLRequest = new URLRequest(mapRequestUrl);	
					var urlLdr:URLLoader = new URLLoader();
					urlLdr.addEventListener(Event.COMPLETE, handleMapString);
					urlLdr.addEventListener(IOErrorEvent.IO_ERROR, handleMapError);
					urlLdr.load(urlReq);
				} 
				else
				{
					var coords:Array = dbManager.getMapImageRecordByPrefix(PrefixName);
					currMinx = coords[0];
					currMiny = coords[1];
					currMaxx = coords[2];
					currMaxy = coords[3];
					iMinx = coords[0];
					iMiny = coords[1];
					iMaxx = coords[2];
					iMaxy = coords[3];
					localCoords = coords;
					getLocalMapImages();
				}
			} catch (err:Error)
			{
				handleIOError();
				FlexGlobals.topLevelApplication.TSSAlert(err.message + "retrieve map images");
			}
		}
		
		private function handleMapError(evt:Event):void
		{
			handleIOError();
			FlexGlobals.topLevelApplication.TSSAlert("Map Server Unavailable. Maps not retrieved.");
		}
		
		private function handleMapString(evt:Event):void 
		{
			evt.stopPropagation();
			try
			{
				var ldr:URLLoader = evt.currentTarget as URLLoader;
				var mapReturn:String = ldr.data;
				
				var syms:Object = (JSON.parse(mapReturn));
				if (mapRetrievalCount == 0)
				{
					//Adjust the extent based on the return result from esri (msize has to be specified in the url). fix the problem of linear feature.
					currMinx = syms.extent.xmin;
					currMiny = syms.extent.ymin;
					currMaxx = syms.extent.xmax;
					currMaxy = syms.extent.ymax;
					iMinx = syms.extent.xmin;
					iMiny = syms.extent.ymin;
					iMaxx = syms.extent.xmax;
					iMaxy = syms.extent.ymax;
					
				} 
				var mapRequestUrl:String = syms.href;
				
				var urlReq:URLRequest = new URLRequest(mapRequestUrl);	
				var urlLdr:Loader = new Loader();
				urlLdr.contentLoaderInfo.addEventListener(Event.COMPLETE, handleImageLoad);	
				urlLdr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleImageLoadFail);
				urlLdr.load(urlReq);	
			} catch (err:Error)
			{
				handleIOError();
				FlexGlobals.topLevelApplication.TSSAlert(err.message + "Handle Map String");
			}
		}
		
		//The ArcGIS server is sometimes too busy to correctly retrieve images.
		private function handleImageLoadFail(e:IOErrorEvent):void
		{
			handleIOError();
			FlexGlobals.topLevelApplication.TSSAlert("Retrieve images from ArcGIS server failed. Check your connection or wait till the server is not busy!");
		}
		
		private function handleImageLoad(evt:Event):void 
		{		
			evt.stopPropagation();
			try
			{
				var ldr:URLLoader = evt.currentTarget as URLLoader;
				var img:Bitmap = evt.target.content as Bitmap;
				//trace("mapRetrieval Count = " + mapRetrievalCount);
				if (mapRetrievalCount == 0)
				{
					
					mapImage.source = img;
					
					
					if(!isDistrictCached)// need to be modified later based on how to get local district-based map images
					{	
						addOverlay();
					}
					
					mapRetrievalCount++;
					
					if (FlexGlobals.topLevelApplication.cacheLocalMaps || isDistrictCached) // if cacheLocal Map is checked in the start window , or downloading district-based map
					{
						tileList.addItemAt(img, imageIndex);
						retrieveMapImages();
					}
				} 
				else
				{
					if (tileRetrievalCount == Math.pow(4,(numberOfLevel-1)) - 1 ) //End of the retrieval
					{
						tileList.addItemAt(img, imageIndex);
						
						writeLocalMapImages();
						
						if(!isDistrictCached) // Route-based map cached
						{
							loadImages();
							var coords:Array = dbManager.getMapImageRecordByPrefix(PrefixName);
							if(coords == null) // If there is an exact same route_based cached map existing, donot write map image record to the database
							{
								dbManager.insertMapImageRecord(FlexGlobals.topLevelApplication.currentRouteName, FlexGlobals.topLevelApplication.currentBeginMile, FlexGlobals.topLevelApplication.currentEndMile, 
									currMinx, currMiny, currMaxx, currMaxy,
									FlexGlobals.topLevelApplication.currentRouteName + "_" + FlexGlobals.topLevelApplication.currentBeginMile + "_" + FlexGlobals.topLevelApplication.currentEndMile);
							}
							FlexGlobals.topLevelApplication.TSSAlert("Map Loading Complete");
							if (currX != -1)
								positionTrackingPoint(currX, currY, 0, "current");
							else
							{
								var tmpXY:ArrayCollection = this.getXYfromMP(FlexGlobals.topLevelApplication.sldDiagram.sldDiagram.getCurrentMP());
								if (tmpXY != null)
								{
									positionTrackingPoint(tmpXY.getItemAt(0) as Number, tmpXY.getItemAt(1) as Number, 0, "current");
								}
							}
							
						}
							
						else // Cached map by district, no need to loadImages
						{
							//write codes for the cache map by district
							dbManager.insertMapImageRecord(PrefixName, 0 , 0, currMinx, currMiny, currMaxx, currMaxy, PrefixName);
							//set the busy skin to false
							FlexGlobals.topLevelApplication.setBusyStatus(false);
							
							//Loop through all the popup window to find the downloadRoutesform. the DLRFTipLabel property is defined to fake a identifier
							var tempAc:ArrayCollection = PopUpUtils.getAllPopups();
							var alertText:String = "Finished Map Cached By District";
							for(var i:int = 0; i< tempAc.length; i++)
							{
								if(tempAc.getItemAt(i).hasOwnProperty("DLRFTipLabel"))
								{
									tempAc.getItemAt(i).DLRFTipLabel = tempAc.getItemAt(i).txtBounds.text+" download complete";
									alertText = tempAc.getItemAt(i).DLRFTipLabel;
									break;
								}
							}
							
							
							//trace("Running events " + FlexGlobals.topLevelApplication.runningEvents);
							FlexGlobals.topLevelApplication.TSSAlert(alertText);
						}
						
						
						mapIsDrawing = false;
					}
					else if(tileRetrievalCount == Math.pow(4, mapRetrievalCount) - 1)
					{
						tileList.addItemAt(img, imageIndex);
						tileRetrievalCount = 0;
						mapRetrievalCount++;
						retrieveMapImages();
					}
					else
					{
						tileList.addItemAt(img, imageIndex);
						tileRetrievalCount++;
						retrieveMapImages();
					}
				}	
			}
			catch (err:Error)
			{
				handleIOError();
				FlexGlobals.topLevelApplication.TSSAlert(err.message + "Handle Image Load");
			}
		}
		
		
		private function writeLocalMapImages():void
		{
			var tmpMapImage:Bitmap;
			try
			{			
				var breakPoint:int = 1;
				var mapLevel:int = 1;
				
				for(var i:int = 0; i<= imageIndex ; i++)
				{
					if(i == 0)
					{
						tmpMapImage = tileList.getItemAt(0) as Bitmap; 
						//var tmpMapImage:Bitmap = tileList1.getItemAt(0) as Bitmap;
						fileUtility.WriteMapImage(PrefixName + ".png", tmpMapImage);
					}
					else
					{
						var bP:int = calculateBreakPoint(mapLevel);
						if(i >= calculateBreakPoint(mapLevel))
						{
							breakPoint = calculateBreakPoint(mapLevel);
							mapLevel++;
							
						}
						tmpMapImage = tileList.getItemAt(i) as Bitmap; 
						fileUtility.WriteMapImage(PrefixName + "_"+ (mapLevel-1) + "_"+ (i - breakPoint ) + ".png", tmpMapImage);
					}
				}
				
				imageIndex = -1; //Set the image index back to -1 after save the images to the local disk
			} catch (err:Error)
			{
				handleIOError();
				FlexGlobals.topLevelApplication.TSSAlert(err.message + "writeLocalImage");
			}
		}
		
		private function calculateBreakPoint(mLevel:int):int
		{
			var mapLevel:int = mLevel;
			var bP:int = 0;
			for( var i:int = 0; i < mapLevel; i++)
			{
				bP+= Math.pow(4, i);
				
			}
			return bP;
		}
		
		
		private function getLocalMapImages():void
		{
			trace("call function getLocalMapImages (MobileMap.as)");
			
			try
			{
				
				var tmpFile:File;
				var load:Loader
				
				if (mapRetrievalCount == 0)
				{
					var path:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.cachedMapUrl + PrefixName + ".png";
//					tmpFile = new File(BaseConfigUtility.get("cached_map_folder") + PrefixName + ".png");
					if (FlexGlobals.topLevelApplication.platform == "IOS") {
						tmpFile = File.applicationStorageDirectory.resolvePath(path);
					} else {
						tmpFile = new File(path);
					}
					//tmpFile = new File("/sdcard/mapimages/" + tmpRN + "_" + tmpBM + "_" + tmpEM + ".png");
				} 
				else
				{
					for (var n:int = 1 ; n < numberOfLevel; n++)
					{
						var path2:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.cachedMapUrl + PrefixName + "_" + n + "_" + tileRetrievalCount + ".png";
						if(mapRetrievalCount == n)
						{
							if (FlexGlobals.topLevelApplication.platform == "IOS") {
								tmpFile = File.applicationStorageDirectory.resolvePath(path2);
							} else {
								tmpFile = new File(path2);
							}
							//tmpFile = new File("/sdcard/mapimages/" + tmpRN + "_" + tmpBM + "_" + tmpEM + "_2_" + tileRetrievalCount + ".png");
							break;
						}
					}
				}
				
				imageIndex++;
				load = new Loader();
				var request:URLRequest = new URLRequest(tmpFile.url);
				load.load(request);
				load.contentLoaderInfo.addEventListener(Event.COMPLETE, mapImageLoadComplete);
			} catch (err:Error)
			{
				handleIOError();
				FlexGlobals.topLevelApplication.TSSAlert(err.message + "getlocal images");
			}
		}
		
		private function mapImageLoadComplete(evt:Event):void
		{
			
			evt.stopPropagation();
			try
			{
				var ldr:URLLoader = evt.currentTarget as URLLoader;
				var img:Bitmap = evt.target.content as Bitmap;
				if (mapRetrievalCount == 0)
				{
					//imageIndex = 0;
					mapImage.source = img;
					addOverlay();
					tileList.addItemAt(img,imageIndex);
					mapRetrievalCount++;
					getLocalMapImages();
				} 
				else  
				{
					if(tileRetrievalCount == Math.pow(4,(numberOfLevel-1)) - 1 )
					{
						tileList.addItemAt(img, imageIndex);
						
						loadImages(); // load the images to the map group
						imageIndex = -1; //set image index back to intial value
						FlexGlobals.topLevelApplication.TSSAlert("Map Loading Complete");
						if (currX != -1)
							positionTrackingPoint(currX, currY, 0, "current");
						else
						{
							var tmpXY:ArrayCollection = this.getXYfromMP(FlexGlobals.topLevelApplication.sldDiagram.sldDiagram.getCurrentMP());
							if (tmpXY != null)
							{
								positionTrackingPoint(tmpXY.getItemAt(0) as Number, tmpXY.getItemAt(1) as Number, 0, "current");
							}
						}
						
						//FlexGlobals.topLevelApplication.setBusyStatus(false);
						
						mapIsDrawing = false;
					}
						
					else if( tileRetrievalCount == Math.pow(4, mapRetrievalCount) - 1) //End of each lOD
					{
						tileList.addItemAt(img, imageIndex);
						tileRetrievalCount = 0; 
						mapRetrievalCount++;
						//imageIndex = 0;
						getLocalMapImages();
					}
					else
					{
						tileList.addItemAt(img, imageIndex);
						tileRetrievalCount ++;
						getLocalMapImages();
					}
				}	
			}
			catch (err:Error)
			{
				handleIOError();
				FlexGlobals.topLevelApplication.TSSAlert(err.message + "load_complete");
			}
		}
		
		private function loadImages():void
		{
			tileList.removeItemAt(0); // remove the first , top level
			for(var i:int = 1; i < numberOfLevel; i++)
			{	
				var tempImageGroup:Group = new Group();
				
				//carefully calculate the group height and width
				tempImageGroup.height = mapHeight * Math.pow(2, i );
				tempImageGroup.width = mapWidth * Math.pow(2,i);
				//tempImageGroup.x = ((tempImageGroup.width - mapWidth) / 2 ) * -1;
				//tempImageGroup.y = ((tempImageGroup.height - mapHeight) / 2 ) * -1;
				var colrow:int =  Math.sqrt(Math.pow(4, i));
				for (var j:int = 0; j < Math.pow(4, i); j++)
				{
					var tempMapImage:Image = new Image();
					tempMapImage.source = tileList.getItemAt(0) as Bitmap;
					
					tempMapImage.x = (j % colrow) * mapWidth;
					tempMapImage.y = tempImageGroup.height - int( j / colrow) * mapHeight - mapHeight; //
					tempImageGroup.addElement(tempMapImage);
					tileList.removeItemAt(0);
				}
				lodList.addItemAt(tempImageGroup, i);
			}
			
			// Make it visible the map has been successfully loaded
			zinImage.visible = true;
			zoutImage.visible = true;
			trace("Running events " + FlexGlobals.topLevelApplication.runningEvents);
			FlexGlobals.topLevelApplication.setBusyStatus(false);
		}
		
		private function zoomIn(evt:MouseEvent):void
		{
			if (loadMapType == "live" || isDistrictCached)
			{
				liveZoomState++;
				var newWidth:int = Math.round(initialMapWidth * (1 + (liveZoomState * .25)));
				var newHeight:int = Math.round((initialMapHeight * (1 + (liveZoomState * .25))));
				if (newWidth > 2048  || newHeight > 2048)
				{
					liveZoomState = liveZoomState -1;
					FlexGlobals.topLevelApplication.TSSAlert("Maximum Zoom Level Reached");
					return;
				}
				
				setInitialMapExtent(iMinx, iMiny, iMaxx, iMaxy, "Live Map");
			} else
			{
				if (zoomState < numberOfLevel - 1 )
				{
					zoomState++;
					setZoomLevel(zoomState);
				}
			}
		}
		
		private function zoomOut(evt:MouseEvent):void
		{
			if (loadMapType == "live" || isDistrictCached)
			{
				liveZoomState = liveZoomState - 1;
				setInitialMapExtent(iMinx, iMiny, iMaxx, iMaxy, "Live Map");
			} else
			{
				if (zoomState > 0)
				{
					zoomState = zoomState -1;
					setZoomLevel(zoomState);
				}
			}
		}
		
		// Retrieve the image for the live zoomed map
		
		public function setLiveZoomLevel(zLevel:int):void
		{
			trace("in livezoomlevel");
			
			mapWidth = mapImage.source.bitmapData.width;
			canvas.width = mapImage.source.bitmapData.width;
			sve.width = mapImage.source.bitmapData.width;
			mapHeight = mapImage.source.bitmapData.height;
			canvas.height = mapImage.source.bitmapData.height;
			canvas.x = mapImage.x;
			canvas.y = mapImage.y;
			sve.height = mapImage.source.bitmapData.height;
		}
		
		// Set the image for the appropriate zoom level
		
		public function setZoomLevel(zLevel:int):void
		{
			trace("call function setZoomLevel (MobileMap.as)");
			
			try
			{
				if ( zLevel > -1 && zLevel < numberOfLevel)
				{
					mapGroup.removeAllElements();
					
					mapGroup.addElement(canvas);
					if(zLevel == 0)
					{
						mapGroup.addElementAt(imageGroup1, 0);
						mapWidth = imageGroup1.width;
						canvas.width = imageGroup1.width;
						sve.width = imageGroup1.width;
						mapHeight = imageGroup1.height;
						canvas.height = imageGroup1.height;
						canvas.x = imageGroup1.x;
						canvas.y = imageGroup1.y;
						sve.height = imageGroup1.height;
						
						//add map pan to zoomlevel 1
						mapGroup.horizontalScrollPosition = 0;
						mapGroup.verticalScrollPosition = 0;
						mapGroup.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
						mapGroup.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
						mapGroup.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					}
					else
					{
						
						//tempImageGroup.removeAllElements();
						var tempImageGroup:Group = new Group();
						tempImageGroup = lodList.getItemAt(zLevel) as Group;
						
						tempImageGroup.x = 0;
						tempImageGroup.y = 0;
						
						mapGroup.addElementAt(tempImageGroup,0);
						mapWidth = tempImageGroup.width;
						canvas.width = tempImageGroup.width;
						sve.width = tempImageGroup.width;
						mapHeight = tempImageGroup.height;
						canvas.height = tempImageGroup.height;
						canvas.x = tempImageGroup.x;
						canvas.y = tempImageGroup.y;
						sve.height = tempImageGroup.height;
						
						// remove map pan 
						mapGroup.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
						mapGroup.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
						mapGroup.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					}
					this.addOverlay();
					if (currX != -1)
						this.positionTrackingPoint(currX, currY, 0, "current");
					else
					{
						var tmpXY:ArrayCollection = this.getXYfromMP(FlexGlobals.topLevelApplication.sldDiagram.sldDiagram.getCurrentMP());
						if (tmpXY != null)
						{
							positionTrackingPoint(tmpXY.getItemAt(0) as Number, tmpXY.getItemAt(1) as Number, 0, "current");
						}
					}
				}
			} catch (err:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert(err.message +  "set Zoom Level");
			}
		}
		
		/*
		Add a linear feature passing in an ordered array of coordinate pairs
		ToDo: Add support for the optimized arrays for Google.
		*/
		public function addOverlay():void
		{
			if(loadMapType == "live")
			{
				EsriMap.addOverlay(this.routeCoords);
			} else
			{

				var mapSR:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.baseMapSR;
				canvas.graphics.clear();
				canvas.graphics.lineStyle(8,0x0000FF,.4);
				if (mapSR == "4623")
					canvas.graphics.moveTo(longToMapX(this.routeCoords[0].X), latToMapY(this.routeCoords[0].Y));
				else
					canvas.graphics.moveTo(longToMapX(this.routeCoords[0].utmX), latToMapY(this.routeCoords[0].utmY));
				for (var i:int=1;i<this.routeCoords.length;i++)
				{
					//				trace(this.routeCoords[i].X + "," + this.routeCoords[i].Y + "," + this.routeCoords[i].M);
					var tmpX:Number;
					var tmpY:Number;
					if (mapSR == "4623")
					{
						tmpX = longToMapX(this.routeCoords[i].X);
						tmpY = latToMapY(this.routeCoords[i].Y);
					} else
					{
						tmpX = longToMapX(this.routeCoords[i].utmX);
						tmpY = latToMapY(this.routeCoords[i].utmY);
					}
					if (tmpX > -1 && tmpY > -1)
					{
						canvas.graphics.lineTo(tmpX, tmpY);
					}
					
					//trace(this.routeCoords[i].X + "," + this.routeCoords[i].Y +"," + this.routeCoords[i].M );
					
					//trace(tmpX + "," + tmpY);
				}
			//var posTPEvent:TSSMapEvent = new TSSMapEvent(TSSMapEvent.TRACKING_POINT);
			//dispatchEvent(posTPEvent);
			}
		}
			
		
		/*
		Add a polygon feature passing in an ordered array of coordinate pairs
		ToDo: Add support for the optimized arrays for Google.
		*/
		public function addPolygon(polyCoords:ArrayCollection, boundarywidth:Number, boundarycolor:Number, fillcolor:Number, opacity:Number):void
		{
			trace("call function set addPolygon (MobileMap.as)");
			
			canvas.graphics.lineStyle(boundarywidth,boundarycolor,opacity);
			canvas.graphics.beginFill(fillcolor, opacity);
			canvas.graphics.moveTo(longToMapX(polyCoords[0].X), latToMapY(polyCoords[0].Y));
			for (var i:int=1;i<polyCoords.length;i++)
			{
				canvas.graphics.lineTo(longToMapX(polyCoords[i].X), latToMapY(polyCoords[i].Y));
			}
			canvas.graphics.lineTo(longToMapX(polyCoords[0].X), latToMapY(polyCoords[0].Y));
			canvas.graphics.endFill();
		}
		
		/*
		Clear all dynamic lines and points
		*/
		public function clearOverlays():void
		{
			canvas.graphics.clear();
		}
		
		
		
		/*
		Move the dynamic point of the specified name
		*/
		
		public function positionTrackingPoint(x:Number, y:Number, angle:Number, name:String):void
		{
			if(loadMapType == "live")
			{
				EsriMap.positionTrackingPoint(x,y,angle, name);
			} else
			{
				currX = x;
				currY = y;
				positionSprite.x = longToMapX(x) - (positionSprite.width/2);
				positionSprite.y = latToMapY(y) - (positionSprite.height/2);
				positionSprite.visible = true;
				
				var transformX:Number = positionSprite.x;
				var transformY:Number = positionSprite.y;
				
				//if(transformX < 0 || transformX > this.width || transformY < 0 || transformY > this.height)
				//{
				//	trace(transformX+ " -----" + transformY);
					scrollTo(transformX- this.width/2, transformY - this.height /2);
				//}
					//scrollTo(longToMapX(x)- mapGroup.width/2, latToMapY(y) - mapGroup.height/2);
			}
		}
		
		/*
		Clear a specific dynamic point
		*/
		public function clearTrackingPoint(name:String):void
		{
			trace("call function clearTrackingPoint (MobileMap.as)");
			
			positionSprite.visible = false;
		}
		
		// Calculate x value in pixels from a longitude value
		private function longToMapX(long:Number):Number
		{
			//trace("call function longToMapX (MobileMap.as)");
			
			if (long <= currMinx)
				return 0;
			if (long >= currMaxx)
				return mapWidth;
			if (long <= currMaxx && long >= currMinx)
			{
				var tmpDif:Number = long - currMinx;
				var tmpPerc:Number = tmpDif / (currMaxx - currMinx);
				return mapWidth * tmpPerc;
			} 
			
			return -1;
		}
		
		// Calculate y value in pixels from a latitude value
		private function latToMapY(lat:Number):Number
		{
			//trace("call function latToMapY (MobileMap.as)");
			
			if (lat >= currMaxy)
				return 0;
			if (lat <= currMiny)
				return mapHeight;
			if (lat <=currMaxy && lat >= currMiny)
			{
				var tmpDif:Number = currMaxy - lat;
				var tmpPerc:Number = tmpDif / (currMaxy - currMiny);
				return mapHeight * tmpPerc;
			}
			return -1;
		}
		
		
		private function handleIOError():void
		{
			mapIsDrawing = false;
			imageIndex = -1;
			FlexGlobals.topLevelApplication.setBusyStatus(false);
			//Loop through all the popup window to find the downloadRoutesform. the DLRFTipLabel property is defined to fake a identifier
			var tempAc:ArrayCollection = PopUpUtils.getAllPopups();
			var alertText:String = "Finished Map Cached By District";
			for(var i:int = 0; i< tempAc.length; i++)
			{
				if(tempAc.getItemAt(i).hasOwnProperty("DLRFTipLabel"))
				{
					tempAc.getItemAt(i).DLRFTipLabel = "Download Map Error";
					alertText = tempAc.getItemAt(i).DLRFTipLabel;
					break;
				}
			}
		}
		
		//map Pan of level 1
		private function onMouseDown(evt:MouseEvent):void
		{
			mapIsPanning = true;
			mapMDownX = evt.stageX;
			mapMDownY = evt.stageY;
		}
		private function onMouseMove(evt:MouseEvent):void
		{
			if(mapIsPanning)
			{
				mapGroup.horizontalScrollPosition = mapGroup.horizontalScrollPosition - (evt.stageX - mapMDownX);
				mapGroup.verticalScrollPosition = mapGroup.verticalScrollPosition - (evt.stageY - mapMDownY);
				mapMDownX = evt.stageX;
				mapMDownY = evt.stageY;
			}
		}
		private function onMouseUp(evt:MouseEvent):void
		{
			mapIsPanning = false;
		}
		
		private function getXYfromMP(currMP:Number):ArrayCollection
		{
			var cnter:int = 0;
			var retVal:ArrayCollection = null;
			if (this.routeCoords != null)
			{
				for (cnter=0;cnter<this.routeCoords.length;cnter++)
				{
					//position the tracking point propotionally between two points
					
					if (currMP >= this.routeCoords[cnter].M && currMP <= this.routeCoords[cnter + 1].M)
					{
						var lowX:Number;
						var lowY:Number;
						var highX:Number;
						var highY:Number;
						
						if (FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.baseMapSR == "4623")
						{
							lowX = this.routeCoords[cnter].X;
							lowY = this.routeCoords[cnter].Y;
							highX = this.routeCoords[cnter + 1].X;
							highY = this.routeCoords[cnter + 1].Y;
						} else
						{
							lowX = this.routeCoords[cnter].utmX;
							lowY = this.routeCoords[cnter].utmY;
							highX = this.routeCoords[cnter + 1].utmX;
							highY = this.routeCoords[cnter + 1].utmY;
						}
						
						var lowMP:Number = this.routeCoords[cnter].M;
						var highMP:Number = this.routeCoords[cnter + 1].M;
						var percMP:Number = (currMP - lowMP) / (highMP - lowMP);
						var currX:Number = lowX + ((highX - lowX) * percMP);
						var currY:Number = lowY + ((highY - lowY) * percMP);
						
						retVal = new ArrayCollection();
						retVal.addItem(currX);
						retVal.addItem(currY);
						break;
					}
				}
			}
			return retVal;
		}
		
		
	}
}