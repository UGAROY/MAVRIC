package com.transcendss.mavric.extended.models
{
	import com.asfusion.mate.core.GlobalDispatcher;
	import com.cartogrammar.shp.PolygonFeature;
	import com.cartogrammar.shp.ShpMap;
	import com.transcendss.mavric.db.CachedElement;
	import com.transcendss.mavric.db.CachedRoute;
	import com.transcendss.mavric.db.MAVRICDBManager;
	import com.transcendss.mavric.events.AccessPointEvent;
	import com.transcendss.mavric.events.AssetEvent;
	import com.transcendss.mavric.events.DataEventEvent;
	import com.transcendss.mavric.events.GPSEvent;
	import com.transcendss.mavric.events.LocalRouteEvent;
	import com.transcendss.mavric.events.SignInvEvent;
	import com.transcendss.mavric.events.ddot.DdotRecordEvent;
	import com.transcendss.mavric.extended.models.Components.AccessPoint;
	import com.transcendss.mavric.managers.AssetManager;
	import com.transcendss.mavric.managers.CSVExportManager;
	import com.transcendss.mavric.managers.FeatureSetManager;
	import com.transcendss.mavric.managers.MavricConfiguredSyncManager;
	import com.transcendss.mavric.managers.RandHSyncManager;
	import com.transcendss.mavric.managers.ddot.DdotRandHSyncManager;
	import com.transcendss.mavric.util.FileUtility;
	import com.transcendss.mavric.util.TSSRectangle;
	import com.transcendss.mavric.views.InventoryMenu;
	import com.transcendss.mavric.views.OverviewMap;
	import com.transcendss.mavric.views.SettingsMenu;
	import com.transcendss.transcore.events.AttributeEvent;
	import com.transcendss.transcore.events.CameraEvent;
	import com.transcendss.transcore.events.ElementEditEvent;
	import com.transcendss.transcore.events.ElementEvent;
	import com.transcendss.transcore.events.MenuBarEvent;
	import com.transcendss.transcore.events.NavControlEvent;
	import com.transcendss.transcore.events.TSSMapEvent;
	import com.transcendss.transcore.events.TextMemoEvent;
	import com.transcendss.transcore.events.VoiceEvent;
	import com.transcendss.transcore.events.videoEvent;
	import com.transcendss.transcore.sld.models.AssetDiagram;
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	import com.transcendss.transcore.sld.models.components.GeoTag;
	import com.transcendss.transcore.sld.models.components.NearestBaseAsset;
	import com.transcendss.transcore.sld.models.components.Route;
	import com.transcendss.transcore.sld.models.managers.GeotagsManager;
	import com.transcendss.transcore.sld.models.managers.LRMManager;
	import com.transcendss.transcore.util.Converter;
	import com.transcendss.transcore.util.PolarToUTM;
	import com.transcendss.transcore.util.TSSAudio;
	import com.transcendss.transcore.util.TSSMemo;
	import com.transcendss.transcore.util.TSSPicture;
	import com.transcendss.transcore.util.TSSVideo;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.effects.EffectInstance;
	import mx.events.EffectEvent;
	import mx.events.PropertyChangeEvent;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import spark.components.BorderContainer;
	import spark.components.Callout;
	import spark.components.Group;
	import spark.components.HScrollBar;
	import spark.components.Image;
	import spark.components.Scroller;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	import spark.effects.easing.Power;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	
	
	
	public class MAVRICDiagram extends AssetDiagram
	{
		private var dbManager:MAVRICDBManager;
		private var gtManager:GeotagsManager = new GeotagsManager();
		
		private var exportManager:CSVExportManager;
		private var RHSyncMgr:DdotRandHSyncManager;
		private var mavicConfiguredSyncMgr:MavricConfiguredSyncManager;
		private var fileUtility:FileUtility;
		private var addingMarkers:ArrayList;
		private var calloutDisp:Callout = new Callout();
		private var cbBorder:BorderContainer;
		private var cbScroller:Scroller;
		private var cbGroup:Group;
		
		public var captureBar:CaptureBar;
		
		private var timer:Timer = new Timer(1000);
		private var runInterval:int = 16;
		private var scrollForward:Boolean = true;
//		public var running:Boolean = false;
		private var fsm:FeatureSetManager;
		private var shapeMap:ShpMap;
		private var _routeCoords:ArrayCollection;
		private var lrmManager:LRMManager= new LRMManager();
		// gesture/animation vars
		private var prevX:Number;
		private var prevY:Number;
		private var velocity:Number = 0;
		private var AniStick:Animate;
		private var AniStickInv:Animate;
		private var smp:SimpleMotionPath;
		private var smpInv:SimpleMotionPath;
		private var leftCulvertStart:Number = 0;
		private var rightCulvertStart:Number = 0;
		private var savingRoutetoLocalDB:Boolean = false;
		private var continueMoveToXYFlag:Boolean = false;
		private var iconLocations:ArrayCollection = new ArrayCollection();
		private var calloutExitBtnImg:Image = new Image();
		
		private var testgpscnter:int = 0;
		private var testCoordX:Array = new Array();
		private var testCoordY:Array = new Array();
		
		//This is used to prevent opening two Callout popups at once. There is a bad graphics bug caused when that is done.
		private var calloutOpen:Boolean = false;
		
		
		//private var dispatcher:Dispatcher = new Dispatcher();
		public var dispatcher:GlobalDispatcher = new GlobalDispatcher();
		
		[Embed(source="/images/sld/adding.png")] protected var adding:Class;	
		[Embed(source="/images/util/popupexit.png")] protected var exit:Class;
		
		
		//static public var milepostData:ArrayCollection;
		private var gpsEvt:GPSEvent = null;
		
		static private var currMP:Number;
		static private var currMPost:Number;
		/**
		 *  Initializes MAVRIC diagram and adds capture bar container/components to left panel group
		 * @param route
		 * @param scale
		 * 
		 */
		public function MAVRICDiagram(routep:Route=null, scale:Number=.10)
		{
			
			super(routep, scale);
			
			
			
			dbManager = MAVRICDBManager.newInstance();
		
			RHSyncMgr = new DdotRandHSyncManager();
			exportManager = new CSVExportManager();
			fileUtility = new FileUtility();
			addingMarkers = new ArrayList();
			this.mavicConfiguredSyncMgr = new MavricConfiguredSyncManager();
			initCaptureBar();
			//addGestureSupport();
		}
		
		/**
		 * 
		 * @param nRoute
		 * @param nScale
		 * @param view
		 * 
		 */
		public override function updateRoute(nRoute:Route, nScale:Number, fromStorage:Boolean=false, view:Number=0):void
		{
			//BA:this.stickDrawing.culvert.clearContainer();
			
			if (!captureBar)
			{
				initCBGroup();
				
				captureBar = new CaptureBar();
				cbGroup.addElement(captureBar);
				
				cbBorder.addElement(cbGroup);
				cbScroller.viewport = cbGroup;
				cbBorder.addElement(cbScroller);
				
				this.leftPanel.addElement(cbBorder);
				//this.leftPanel.width = cbBorder.width;
			}
			
			
		    iconLocations = new ArrayCollection();
			savingRoutetoLocalDB = false;
			invPanelContent = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.invPanelContent;
			initInvPanelContent(getPanelContent(invPanelContent,nRoute));
			
			if(fromStorage)//if from storage reuse the original selected mileposts as the orig miles
			{
				nRoute.beginMi = nRoute.beginMilepost;
				nRoute.endMi = nRoute.endMilepost;
			}

			var resp:Responder = new Responder(milepostReqResponse,  function ():void{
				FlexGlobals.topLevelApplication.setBusyStatus(false);
				FlexGlobals.topLevelApplication.TSSAlert("Error in obtaining milemarker data");
			});
			
			if(!fromStorage)
				FlexGlobals.topLevelApplication.GlobalComponents.assetManager.requestMilePosts(resp,{fromStorage:fromStorage, nRoute:nRoute, nview:view,nscale:nScale} );
			else//use the same markers
				milepostReqResponse({dataProviderAC:FlexGlobals.topLevelApplication.GlobalComponents.assetManager.origMileMarkers,nRouteObj: {fromStorage:fromStorage, nRoute:nRoute, nview:view,nscale:nScale}});
			
		}
		
		
		public function milepostReqResponse(result:Object):void
		{
			//var nRouteObj:Object = signEvent.nrouteObj;
			var fromStorage:Boolean = result.nRouteObj.fromStorage;
			var nRoute:Route = result.nRouteObj.nRoute as Route;
			
			var nScale:Number = new Number(result.nRouteObj.nscale);
			var view:Number = new Number(result.nRouteObj.nview);
			
//			if(isNaN(nRoute.beginMilepost) || isNaN(nRoute.endMilepost))
//			{
				nRoute.beginMilepost =nRoute.beginMi;
				nRoute.endMilepost = nRoute.endMi;
				FlexGlobals.topLevelApplication.GlobalComponents.assetManager.route = nRoute;
				//this will set the filtered markers as well; which includes only valid milemarkers for LRM transformations
				if(!fromStorage)
					FlexGlobals.topLevelApplication.GlobalComponents.assetManager.origMileMarkers= result.dataProviderAC;
				
				var milepostData:ArrayCollection = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.filteredMileMarkers;
				if(nRoute!=null && milepostData !=null)
				{
					var nba:NearestBaseAsset = lrmManager.milepostToMilepointPlusOffset(nRoute.beginMi,"MILEMARKER",milepostData);
					//			//use milepost data to LRM transform.
					
					
					nRoute.beginMi =nba.milepoint + nba.offsetMiles;
					
					nba = lrmManager.milepostToMilepointPlusOffset(nRoute.endMi,"MILEMARKER",milepostData);
					
					
					nRoute.endMi =nba.milepoint + nba.offsetMiles;
					
				}
				else
				{
					nRoute.beginMilepost = nRoute.beginMi;
					nRoute.endMilepost = nRoute.endMi;
				}
//			}
			// call parent function
			updateRouteBase(nRoute, nScale, fromStorage,view, "middle", false, false);
			 
			stickScroller.viewport.addEventListener(MouseEvent.MOUSE_UP, scrollMouseup);
			stickScroller.viewport.addEventListener(MouseEvent.MOUSE_DOWN, scrollMouseDown);
			
			stickScroller.viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, linkScrollers);
			stickScroller.horizontalScrollBar = new HScrollBar();
			stickScroller.horizontalScrollBar.alpha =0;
			stickScroller.viewport.addEventListener(EffectEvent.EFFECT_END, scrollFinished);
			stickScroller.viewport.addEventListener(EffectEvent.EFFECT_START, scrollBegin);
			stickScroller.viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, hideCallout);
			loadRouteShape(nRoute.routeName);
			stickDrawing.moveHUD(stickScroller.viewport.horizontalScrollPosition+((stickScroller.viewport.width - 50)/2));
			updateStickGuideMile();
			updateCallOutVals();
			//this.viewMile = view;
		}
		
		/**
		 *Switches the view in the bottom panel. 
		 * 
		 */
		public function toggleInvPanelView():void
		{
			var cont:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.invPanelContent;
			toggleInvPanelContent(getPanelContent(cont,_route), "middle",false,false);
			
			
			if (cont == "bars")
			{
				if(!inventoryDrawing) // for a bug: loading a cached route after wifi suddenly turns off.
					return;
				
				inventoryDrawing.guideBar.moveGuideBar(stickScroller.viewport.horizontalScrollPosition);
				invScroller.viewport.horizontalScrollPosition = stickScroller.viewport.horizontalScrollPosition;
				inventoryDrawing.labels.forEach(moveLabels);
				dispatcher.dispatchEvent(new ElementEvent (ElementEvent.ELEMENT_LOAD_COMPLETED));
			}
			stickScroller.viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, linkScrollers);	
		}
		
		public override function clearRoute():void
		{
			super.clearRoute();
			this.captureBar = null;
			cbGroup.removeAllElements();
			cbBorder.removeAllElements();
			//leftPanel.removeAllElements();
		}
		
		/**
		 * Builds and Returns the content for the bottom panel
		 * @return 
		 * 
		 */
		private function getPanelContent(cont:String, route:Route=null):IVisualElement
		{
			if(invPanelContent!=cont)
				invPanelContent = cont;
			//var cont:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.invPanelContent;
			switch(cont)
			{
				case "bars":
					if (_invScroller != null)
						_invScroller.setStyle("verticalScrollPolicy", "on");
					
					return null;
				case "settings":
					if (_invScroller != null)
						_invScroller.setStyle("verticalScrollPolicy", "off");
					var settings:SettingsMenu = new SettingsMenu();
					settings.currentState="appSettings"
					settings.height = 600;
					settings.width = 800;
					return settings;
				case "form":
					if (_invScroller != null)
						_invScroller.setStyle("verticalScrollPolicy", "on");
					var invForm:InventoryMenu = new InventoryMenu();
					invForm.height = 800;
					invForm.width = 1000;
					
					return invForm;
				case "map":
					if (_invScroller != null)
						_invScroller.setStyle("verticalScrollPolicy", "off");
					var ovMap:OverviewMap = FlexGlobals.topLevelApplication.overViewMap;
					//this is done to repeatedly calling lat/long call unless it is a new route
					//also the check stickDrawing.route.routeName!="no_rte"  is to avoid calling lat long call twice if the default view is map
					if(ovMap  && (route == null || ovMap.isNewRoute(route.routeName, route.beginMi, route.endMi)))//redraw only if new route
						FlexGlobals.topLevelApplication.redrawMaps(route);
					ovMap.height = 600;
					ovMap.width = 1000;
					return ovMap;
			}
			return null;
		}
		
		
		/**
		 * Method used to enable mobile events in the MAVRIC Diagram.  Works with Air and Air-mobile environments 
		 * 
		 */
		public function addGestureSupport():void
		{
			smp = new SimpleMotionPath("horizontalScrollPosition");
			
			var MVect:Vector.<MotionPath> = new Vector.<MotionPath>;
			MVect.push(smp);
			
			AniStick = new Animate(stickGroup);
			
			AniStick.motionPaths = MVect;
			var ePower:Power = new Power(0.5,4);
			AniStick.easer = ePower;
			
			smpInv = new SimpleMotionPath("verticalScrollPosition");
			var MVectInv:Vector.<MotionPath> = new Vector.<MotionPath>;
			MVectInv.push(smp);
			AniStickInv = new Animate(inventoryGroup);
			AniStickInv.motionPaths = MVectInv;
			var ePowerInv:Power = new Power(0.5,4);
			AniStickInv.easer = ePowerInv;
			
			if (Multitouch.supportsTouchEvents)
			{
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;

				// add for stick diagram
				stickBorder.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
				stickBorder.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
				stickBorder.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
				
				// add for Inventory diagram
				inventoryBorder.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBeginY);
				inventoryBorder.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMoveY);
				inventoryBorder.addEventListener(TouchEvent.TOUCH_END, onTouchEndY);				
			}
		}
		
		public function removeGestureSupport():void
		{
			stickBorder.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			stickBorder.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			stickBorder.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			
			inventoryBorder.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBeginY);
			inventoryBorder.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMoveY);
			inventoryBorder.removeEventListener(TouchEvent.TOUCH_END, onTouchEndY);
			
		}
	
		
		/**
		 *	Begin drag event/reset values 
		 * @param event
		 * 
		 */
		protected function onTouchBegin(event:TouchEvent):void
		{
			velocity = 0;
			if (AniStick.isPlaying)
			{
				AniStick.stop();
			}			
			prevX = event.stageX;
			
		}
		
		/**
		 * movement action as user drags finger across screen 
		 * @param event
		 * 
		 */
		protected function onTouchMove(event:TouchEvent):void
		{
			var deltaX:Number = Math.round((prevX - event.stageX));
			
			// average the current velocity with the new velocity
			velocity = (deltaX + velocity) / 2;
			var desiredX:Number = stickGroup.horizontalScrollPosition + deltaX;
			scrollTo(desiredX);
			prevX = event.stageX;
			
			event.preventDefault();
			event.stopImmediatePropagation();
			event.stopPropagation();
			
		}
		
		/**
		 * End Touch event
		 * @param event
		 * 
		 */
		protected function onTouchEnd(event:TouchEvent):void
		{
			var scrollDistance:Number = (velocity * 6);
			// calc distance
			smp.valueFrom = stickGroup.horizontalScrollPosition;
			if (stickGroup.horizontalScrollPosition + scrollDistance < 0)
			{
				smp.valueTo = 0;
			}
			else if (stickGroup.horizontalScrollPosition + scrollDistance > stickGroup.contentWidth)
			{
				smp.valueTo = stickGroup.contentWidth;
			}
			else
			{
				smp.valueTo = stickGroup.horizontalScrollPosition + scrollDistance;
			}
			AniStick.play();
			var p:PropertyChangeEvent = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
			
			p.property = "horizontalScrollPosition";
			p.newValue = smp.valueTo;
			linkScrollers(p);
		}
		
		
		/**
		 *	Begin drag event/reset values 
		 * @param event
		 * 
		 */
		protected function onTouchBeginY(event:TouchEvent):void
		{
			velocity = 0;
			if (AniStickInv.isPlaying)
			{
				AniStickInv.stop();
			}			
			prevY = event.stageY;
			
		}
		
		/**
		 * movement action as user drags finger across screen 
		 * @param event
		 * 
		 */
		protected function onTouchMoveY(event:TouchEvent):void
		{
			var deltaY:Number = Math.round((prevY - event.stageY));
			
			// average the current velocity with the new velocity
			velocity = (deltaY + velocity) / 2;
			var desiredY:Number = inventoryGroup.verticalScrollPosition + deltaY;
			scrollTo(desiredY);
			prevY = event.stageY;
			
			event.preventDefault();
			event.stopImmediatePropagation();
			event.stopPropagation();
			
		}
		
		/**
		 * End Touch event
		 * @param event
		 * 
		 */
		protected function onTouchEndY(event:TouchEvent):void
		{
			var scrollDistance:Number = (velocity * 6);
			// calc distance
			smpInv.valueFrom = inventoryGroup.verticalScrollPosition;
			if (inventoryGroup.verticalScrollPosition + scrollDistance < 0)
			{
				smpInv.valueTo = 0;
			}
			else if (inventoryGroup.verticalScrollPosition + scrollDistance > inventoryGroup.contentHeight)
			{
				smpInv.valueTo = inventoryGroup.contentHeight;
			}
			else
			{
				smpInv.valueTo = inventoryGroup.verticalScrollPosition + scrollDistance;
			}
			
			AniStickInv.play();
		}
		
		
		/**
		 *  draws ruler on stick diagrams
		 * 
		 */
		public function turnMeasureBarOn():void
		{
			stickDrawing.drawMeasureBar();
			
		}
		
		/**
		 * removes ruler from stick diagrams
		 * 
		 */
		public function turnMeasureBarOff():void
		{
			stickDrawing.removeMeasureBar();
			
		}
		
		/**
		 * changes measure bar unit
		 * 
		 */
		public function changeMeasureBarUnit(newUnit:Number):void
		{
			stickDrawing.changeMeasureBarUnit(newUnit);
			
		}
		
		
		
		
	public function toggleAssetsOnStick(switchObj:Object):void
	{
		var assetDef:Object = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.assetDefs;
		for each (var def:Object in assetDef) 
		{
			if(switchObj[def.DESCRIPTION])
				stickDrawing.drawAsset(def.DESCRIPTION);
			else
				stickDrawing.hideAsset(def.DESCRIPTION);
		}
		
		
	}
		
		
		
		/**
		 * Calculates and scrolls to position with animation 
		 * @param x
		 * 
		 */
		protected function scrollTo(x:Number):void
		{
			if (x < 0)
			{
				x = 0;
				
				velocity = 0;
			}
			else if (x > stickGroup.contentWidth)
			{
				x = stickGroup.contentWidth;
				
				velocity = 0;
			}
			stickGroup.horizontalScrollPosition = x;
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		public function addattDropDown(event:AttributeEvent):void
		{
			inventoryDrawing.displayElementDrop(event,this.scale)
		}

		/**
		 * 
		 * @param event
		 * 
		 */
		public function addAttInput(event:ElementEditEvent, isSplit:Boolean=false):void
		{
			inventoryDrawing.displayAttrInput(event, this.scale, isSplit)
		}

		/**
		 * Initializes the Capture Bar Group container and adds it to the left panel group
		 * 
		 */
		private function initCaptureBar():void
		{
			initCBContainer();
			initCBScroller();
			initCBGroup();
			
			captureBar = new CaptureBar();
			cbGroup.addElement(captureBar);
			
			cbBorder.addElement(cbGroup);
			cbScroller.viewport = cbGroup;
			cbBorder.addElement(cbScroller);
			
			this.leftPanel.addElement(cbBorder);
			this.leftPanel.width = cbBorder.width;
		}
		
		/**
		 * Initializes the Capture Bar UR border container
		 * 
		 */
		private function initCBContainer():void
		{
			cbBorder = new BorderContainer();	
			cbBorder.id = "cbBorder";
			cbBorder.percentHeight = 100;
			cbBorder.width = 200;
			cbBorder.setStyle("cornerRadius", 3);
			cbBorder.setStyle("borderWeight", 1);
			cbBorder.setStyle("borderColor", 0x444444);
			cbBorder.setStyle("dropShadowVisible", true);
			cbBorder.setStyle("backgroundColor", 0xffffcc);	
		}
		
		/**
		 * Initializes the Capture Bar scroller object
		 * 
		 */
		private function initCBScroller():void
		{		
			cbScroller = new Scroller();
			cbScroller.id = "cbScroller";
			cbScroller.percentWidth = 100;
			cbScroller.percentHeight = 100;
			cbScroller.setStyle("horizontalScrollPolicy", "off");
			cbScroller.setStyle("verticalScrollPolicy", "off");
			// add event listeners
			cbScroller.addEventListener(MouseEvent.MOUSE_DOWN,setScrollDown);
		}	
		
		/**
		 * Initializes the Capture Bar Group container
		 * 
		 */
		private function initCBGroup():void
		{
			cbGroup = new Group();
			cbGroup.id = "cbGroup";
			cbGroup.clipAndEnableScrolling = true;
			cbGroup.verticalScrollPosition = 0;
			cbGroup.percentWidth = 100;
			cbGroup.percentHeight = 100;
			
			var cbVL:VerticalLayout = new VerticalLayout();
			cbVL.horizontalAlign = "center"
			cbVL.paddingTop = 20;
			cbVL.paddingBottom = 20;
			
			// add horizontal layout
			cbGroup.layout = cbVL;
		}	
		
		//*******************  Add events **************************
		
//		public function handleNewSign(event:SignInvEvent):void
//		{
//			var tmpImage:TSSPicture = event.tsspicture;
//			tmpImage.x = Converter.scaleMileToPixel(this.stickDiagram.currentMPost()-this.stickDiagram.route.beginMilepost,scale)-20;//current location- width of the image
//			tmpImage.y = this.stickDiagram.getIconY("sign");
//			tmpImage.width = 40;
//			tmpImage.height = 40;
//			tmpImage.id = iconLocations.length.toString();
//			
//			iconLocations.addItem({index:iconLocations.length,X:tmpImage.x, Y:tmpImage.y, type:"sign",obj:tmpImage.clone()});
//			stickDrawing.addChild(tmpImage);
//			tmpImage.addEventListener(TouchEvent.TOUCH_BEGIN,showMultipleIconsIfExists);
//			tmpImage.addEventListener(MouseEvent.ROLL_OVER,showMultipleIconsIfExists);
//			/*tmpImage.addEventListener(MouseEvent.ROLL_OUT, hideCallout);
//			tmpImage.addEventListener(TouchEvent.TOUCH_OUT, hideCallout);*/
//		}
		
		public function handleNewSign(event:SignInvEvent):void
		{
			var signArrayC:ArrayCollection = event.signs;
			var gtags:ArrayCollection;
			for(var i:int=0; i< signArrayC.length; i++)
			{
				var sign:BaseAsset= signArrayC[i] as BaseAsset;
				FlexGlobals.topLevelApplication.GlobalComponents.assetManager.saveAsset(sign);
				if(sign.invProperties["ASSET_BASE_ID"])
					saveAssetGTs(sign.geotagsArray,sign.id ,sign.invProperties["ASSET_BASE_ID"].value);
				else
					saveAssetGTs(sign.geotagsArray,sign.id ,sign.invProperties[sign.primaryKey].value);//use primary key if no asset_base id TODO:How to completely work without asset_base_id for GTs
				stickDrawing.applyAssetToDiagram(sign.description, sign, true,(signArrayC.length>1));
			}
			
			
			
			
			
				
				
			
		}
		
		private function saveAssetGTs(gtColl:ArrayCollection, assetID:int, asset_base_id:String):void
		{
			if(gtColl != null && gtColl.length >0)
			{
				for(var i:int =0; i<gtColl.length;i++)
				{
					var gt:GeoTag = gtColl[i] as GeoTag;
					gt.local_asset_id = "" + assetID;
					gt.asset_base_id=asset_base_id;
					if(gt.id == 0)	// to avoid adding duplicates
						dbManager.addGeoTag(gt,false);
				}
			}
		}
		public function handlePicture(event:CameraEvent):void
		{
			event.stopPropagation();
			if(FlexGlobals.topLevelApplication.GlobalComponents.capturEventSource == "ControlBar")
			{
			var bmp:Bitmap = event.bitmap;
			var tmpImage:TSSPicture = new TSSPicture();
			//tmpImage.source = gtManager.camera;
			tmpImage.source = bmp;
			tmpImage.bitmap = bmp;
			tmpImage.x = Converter.scaleMileToPixel(getCurrentMP()-stickDrawing.route.beginMi,diagramScale) + offsetValue-20;//current location- width of the image
			tmpImage.y =this.stickDiagram.getIconY("image");
			tmpImage.width = 40;
			tmpImage.height = 40;
			tmpImage.id = iconLocations.length.toString();
			
			tmpImage.addEventListener(TouchEvent.TOUCH_BEGIN,showMultipleIconsIfExists);
			tmpImage.addEventListener(MouseEvent.ROLL_OVER,showMultipleIconsIfExists);
			/*tmpImage.addEventListener(MouseEvent.ROLL_OUT, hideCallout);
			tmpImage.addEventListener(TouchEvent.TOUCH_OUT, hideCallout);*/
			stickDrawing.addChild(tmpImage);
			
			iconLocations.addItem({index:iconLocations.length,X:tmpImage.x, Y:tmpImage.y, type:"image", obj:tmpImage.clone()});
			var fileName:String = new Date().time + ".png";
			var tmpGT:GeoTag = new GeoTag();
			tmpGT.cached_route_id = stickDrawing.route.routeName;
			tmpGT.begin_mile_point = getCurrentMP();
			tmpGT.end_mile_point = 0;
			tmpGT.image_file_name = fileName;
			tmpGT.text_memo = event.memo;
			tmpGT.is_insp = -1;
			tmpGT.asset_ty_id = "0";
			tmpImage.geoLocalId = ""+dbManager.addGeoTag(tmpGT,false);
			tmpImage.geoTag = tmpGT;
			
			try
			{
				FlexGlobals.topLevelApplication.setBusyStatus(true);
				fileUtility.WritePicture(fileName, bmp);
				FlexGlobals.topLevelApplication.setBusyStatus(false);
			} catch (er:Error)
			{
				FlexGlobals.topLevelApplication.setBusyStatus(false);
				FlexGlobals.topLevelApplication.TSSAlert(er.message);
			}
			}
			
		}
		
		//function to handle VideoEvent
		public function handleVideo(event:videoEvent):void{
			event.stopPropagation();
			try
			{
			if(FlexGlobals.topLevelApplication.GlobalComponents.capturEventSource == "ControlBar")
			{
			var vid:TSSVideo=new TSSVideo();
			vid.source=gtManager.video;
			vid.video=event.video;
			vid.x=Converter.scaleMileToPixel(getCurrentMP()-stickDrawing.route.beginMi,diagramScale) + offsetValue-20;//current location- width of the image
			vid.y=this.stickDiagram.getIconY("video");
			vid.width=40;
			vid.height=40;
			
			FlexGlobals.topLevelApplication.setBusyStatus(true);
			var fileName:String=new Date().time +".3gp";
			fileUtility.WriteVideo(vid.video, fileName, event.path);
			vid.filePath=fileName;
			vid.id = iconLocations.length.toString();
			FlexGlobals.topLevelApplication.setBusyStatus(false);
			
			vid.addEventListener(TouchEvent.TOUCH_BEGIN,showMultipleIconsIfExists);
			vid.addEventListener(MouseEvent.ROLL_OVER,showMultipleIconsIfExists);
			/*vid.addEventListener(MouseEvent.ROLL_OUT, hideCallout);
			vid.addEventListener(TouchEvent.TOUCH_OUT, hideCallout);*/
			stickDrawing.addChild(vid);
			iconLocations.addItem({index:iconLocations.length,X:vid.x, Y:vid.y, type:"video", obj:vid.clone()});
			
			var tmpGT:GeoTag=new GeoTag();
			tmpGT.cached_route_id= stickDrawing.route.routeName;
			tmpGT.begin_mile_point=getCurrentMP();
			tmpGT.end_mile_point=0;
			tmpGT.video_file_name = fileName;
			tmpGT.text_memo = event.memo;
			tmpGT.asset_ty_id = "0";
			tmpGT.is_insp = -1;
			vid.geoLocalId = ""+ dbManager.addGeoTag(tmpGT,false);
			vid.geoTag = tmpGT;
			
			//fileUtility.WriteVideo(vid.video,fileName);
			}
		} catch (er:Error)
		{
			FlexGlobals.topLevelApplication.setBusyStatus(false);
			FlexGlobals.topLevelApplication.TSSAlert(er.message);
		}
		
			
		}
		
	
		
		
		public function handleVoiceMemo(event:VoiceEvent):void
		{
			event.stopPropagation();
			if(FlexGlobals.topLevelApplication.GlobalComponents.capturEventSource == "ControlBar")
			{
			
			var soundBytes:ByteArray=event.byteArray;
			var tmpImage:TSSAudio = new TSSAudio();
			tmpImage.source = gtManager.voice;
			tmpImage.soundBytes = event.byteArray;
			tmpImage.x =Converter.scaleMileToPixel(getCurrentMP()-stickDrawing.route.beginMi,diagramScale) + offsetValue-20;
			
			tmpImage.y =  this.stickDiagram.getIconY("voice");
			tmpImage.width = 40;
			tmpImage.height = 40;
			var fileName:String = new Date().time +".wav";
			//saving the sound file
		
//			var fTemp:File = new File("/sdcard/VoiceMemos/" + fileName);
//			var writer:WAVWriter = new WAVWriter();
//			writer.numOfChannels=2;
//			writer.sampleBitRate=16;
//			writer.samplingRate=44100;
//			soundBytes.position=0;
//			var stream:FileStream=new FileStream();
//			stream.open(fTemp,FileMode.WRITE);
//			writer.processSamples(stream, soundBytes, 44100,2);
//		
//			stream.close();
			//
			//tmpImage.addEventListener(TouchEvent.TOUCH_BEGIN,showMultipleIconsIfExists);
			tmpImage.addEventListener(MouseEvent.ROLL_OVER,showMultipleIconsIfExists);
			/*tmpImage.addEventListener(MouseEvent.ROLL_OUT, hideCallout);*/
			//tmpImage.addEventListener(TouchEvent.TOUCH_OUT, hideCallout);
			tmpImage.id = iconLocations.length.toString();
			stickDrawing.addChild(tmpImage);
			
			iconLocations.addItem({index:iconLocations.length,X:tmpImage.x, Y:tmpImage.y, type:"voice", obj:tmpImage.clone()});
		
			var tmpGT:GeoTag = new GeoTag();
			tmpGT.cached_route_id = stickDrawing.route.routeName;
			tmpGT.begin_mile_point = getCurrentMP();
			tmpGT.end_mile_point = 0;
			tmpGT.voice_file_name = fileName;
			tmpGT.text_memo = "";
			tmpGT.is_insp = -1;
			tmpGT.asset_ty_id = "0";
			tmpImage.geoLocalId = ""+dbManager.addGeoTag(tmpGT,false);
			tmpImage.geoTag = tmpGT;
			try{
				FlexGlobals.topLevelApplication.setBusyStatus(true);
				fileUtility.saveToWAV(event.byteArray, fileName);
				FlexGlobals.topLevelApplication.setBusyStatus(false);
			}
			catch(e:Error){
				FlexGlobals.topLevelApplication.setBusyStatus(false);
				FlexGlobals.topLevelApplication.TSSAlert(e.message);
			}
			
			}
		}

		public function handleTextMemo(event:TextMemoEvent):void
		{
			event.stopPropagation();
			if(FlexGlobals.topLevelApplication.GlobalComponents.capturEventSource == "ControlBar")
			{
				var tmpMemo:TSSMemo = new TSSMemo();
			
				tmpMemo.source = gtManager.memo;
				tmpMemo.memo=event.memo;
				tmpMemo.label = event.memo;
				tmpMemo.x =Converter.scaleMileToPixel(getCurrentMP()-stickDrawing.route.beginMi,diagramScale) + offsetValue-20;//current location- width of the image
				tmpMemo.y = this.stickDiagram.getIconY("text");
				
				//tmpMemo.addEventListener(TouchEvent.TOUCH_BEGIN,showMultipleIconsIfExists);
				tmpMemo.addEventListener(MouseEvent.ROLL_OVER,showMultipleIconsIfExists);
				/*tmpMemo.addEventListener(MouseEvent.ROLL_OUT, hideCallout);*/
				//tmpMemo.addEventListener(TouchEvent.TOUCH_OUT, hideCallout);
				
				tmpMemo.width = 40;
				tmpMemo.height = 40;
				tmpMemo.id = iconLocations.length.toString();
				stickDrawing.addChild(tmpMemo);
				
				iconLocations.addItem({index:iconLocations.length,X:tmpMemo.x, Y:tmpMemo.y, type:"text", obj: tmpMemo.clone() });
				var tmpGT:GeoTag = new GeoTag();
				tmpGT.cached_route_id = stickDrawing.route.routeName;
				tmpGT.begin_mile_point = getCurrentMP();
				tmpGT.end_mile_point = 0;
				tmpGT.image_file_name = "";
				tmpGT.asset_ty_id = "0";
				tmpGT.text_memo = event.memo;
				tmpGT.is_insp = -1;
				tmpMemo.geoLocalId = ""+ dbManager.addGeoTag(tmpGT,false);
				tmpMemo.geoTag = tmpGT;
			}
		}
		
		
		
		private function showMultipleIconsIfExists(event:MouseEvent):void
		{
			if (calloutOpen)
				return;
			
			var id:Number = Number(event.target.id);
			
			var i:Number=0;
			//var l:LayoutBase
			calloutDisp = new Callout();
			calloutDisp.layout = new HorizontalLayout();

			
			for each (var icon:Object in iconLocations)
			{
				if(icon.type==iconLocations[id].type && icon.X==iconLocations[id].X)
				{
					
					calloutDisp.addElement(icon.obj);
					i++;
				}
			}
			calloutExitBtnImg.source = exit;
			calloutExitBtnImg.addEventListener(MouseEvent.CLICK, hideCallout); 
			calloutDisp.addElement(calloutExitBtnImg);
			
			if(i>1)
			{
			calloutDisp.visible = true;
			//calloutDisp.addEventListener(MouseEvent.ROLL_OUT, hideCallout);
			calloutDisp.open(event.target as UIComponent);
			
			calloutOpen = true;
			}
			
		}
		
		private function hideCallout(e:Event):void
		{
			if (!calloutOpen)
				return;
			
			calloutExitBtnImg.removeEventListener(MouseEvent.CLICK, hideCallout);
			calloutDisp.removeAllElements();
			calloutDisp.close();
			calloutDisp.visible = false;
			
			calloutOpen = false;
		}
		public function handlePointEvent(event:DataEventEvent):void
		{
			var xval:Number = stickGroup.horizontalScrollPosition + (stickGroup.width / 2) - 20;
			if (event.datatype < 1100)//speed limit
			{
				var tmpImage:TSSPicture = new TSSPicture();
				tmpImage.source = event.getTypeIcon();
				
				tmpImage.x = xval;
				tmpImage.y = 40;
				tmpImage.width = 40;
				tmpImage.height = 40;
				stickDrawing.addChild(tmpImage);
			}
			else if(event.datatype > 1300)//Access Points
			{
				var accessP:AccessPoint = new AccessPoint(event.datatype,xval,stickGroup.height);
				stickDrawing.addChild(accessP);
			}
		}

		
		public function drawRoadwayLanes(event:ElementEvent):void
		{
			stickDrawing.drawRoadwayLanes(event.featureAC, event.scale);
		}

		public function handleNewAP(event:AccessPointEvent):void{
			
			var xval:Number=stickGroup.horizontalScrollPosition + (stickGroup.width / 2) - 20;
			var yval:Number=stickGroup.height/2;
			if(event.apType != 1301){
				yval=yval+120;
			}
			stickDrawing.addChild(new AccessPoint(event.apType,xval,yval));
			
		}
		public function handleNewCulvert(event:AssetEvent):void{
			
				var isNewAsset:Boolean =false;
				var cul:BaseAsset = (BaseAsset)(event.culvert);
				if(cul.id==-1)
					isNewAsset = true;
				var gtags:ArrayCollection = event.geoTags;
				//cul.invProperties["MILEPOST"] = getCurrentMP();
				
				if(!event.saveCulvert && event.culvert !=null)
					event.culvert.symbol.deselectAsset();	
				else
				{
					FlexGlobals.topLevelApplication.GlobalComponents.assetManager.saveAsset(cul);
					stickDrawing.applyAssetToDiagram(cul.description, cul, true);	
					if(isNewAsset)
						stickDrawing.spriteLists[cul.description].addItem(cul);
						
					if(gtags != null && gtags.length >0)
					{
						for(var i:int =0; i<gtags.length;i++)
						{
							var gt:GeoTag = gtags[i] as GeoTag;
							//gt.local_asset_id = "" + cul.id;
							//if(cul.invProperties.hasOwnProperty("ASSET_BASE_ID"))	
							//	gt.asset_base_id=cul.invProperties["ASSET_BASE_ID"].value;
							if(gt.id == 0)	// to avoid adding duplicates
								dbManager.addGeoTag(gt,false);
						}
					}
					
					var culSavedEvent:DdotRecordEvent = new DdotRecordEvent(DdotRecordEvent.SUPPORT_SAVED , true, true);
					culSavedEvent.support = cul;
					dispatchEvent(culSavedEvent);
				}
					
				//} else
				//{
				//	FlexGlobals.topLevelApplication.TSSAlert("Error Inserting Culvert to Local Database");
				//}

		}
	
		public function handleLineEventStart(event:DataEventEvent):void
		{
			var tmpImage:TSSPicture;
			
			if (event.endtype > -1)
			{
				tmpImage = new TSSPicture();
				tmpImage.source = event.getEndTypeIcon();
				tmpImage.x = stickGroup.horizontalScrollPosition + (stickGroup.width / 2) - 20;
				if (event.endtype < 13)
				{
					tmpImage.y = 65;
				}
				else if (event.endtype > 20 && event.endtype < 40)
				{
					tmpImage.y = 135;
				}
				else if (event.endtype > 40 && event.endtype < 50)
				{
					tmpImage.y = 205;
				}
				else if (event.endtype > 60 && event.endtype < 70)
				{
					tmpImage.y = 275;
				}
				tmpImage.width = 40;
				tmpImage.height = 40;
				
				inventoryDrawing.addChild(tmpImage);
				inventoryDrawing.removeChild(inventoryDrawing.getChildByName(event.endtype.toString()));
			}
			tmpImage = new TSSPicture();
			tmpImage.source = event.getTypeIcon();
			tmpImage.x = stickGroup.horizontalScrollPosition + (stickGroup.width / 2) - 20;
			if (event.datatype < 13)
			{
				tmpImage.y = 65;
			}
			else if (event.datatype > 20 && event.datatype < 40)
			{
				tmpImage.y = 135;
			}
			else if (event.datatype > 40 && event.datatype < 50)
			{
				tmpImage.y = 205;
			}
			else if (event.datatype > 60 && event.datatype < 70)
			{
				tmpImage.y = 275;
			}
			tmpImage.width = 40;
			tmpImage.height = 40;
			
			inventoryDrawing.addChild(tmpImage);
			
			var tmpAddingImage:Image = new Image();
			tmpAddingImage.source = adding;
			tmpAddingImage.x = stickGroup.horizontalScrollPosition + (stickGroup.width / 2) - 20;
			
			if (event.datatype < 13)
			{
				tmpAddingImage.y = 65;
			}
			else if (event.datatype > 20 && event.datatype < 40)
			{
				tmpAddingImage.y = 135;
			}
			else if (event.datatype > 40 && event.datatype < 50)
			{
				tmpAddingImage.y = 205;
			}
			else if (event.datatype > 60 && event.datatype < 70)
			{
				tmpAddingImage.y = 275			}
			
			tmpAddingImage.width = 40;
			tmpAddingImage.height = 40;
			tmpAddingImage.name = event.datatype.toString();
			inventoryDrawing.addChild(tmpAddingImage);
			addingMarkers.addItem(tmpAddingImage);

			
		}	
		

		public function getCurrentMP():Number
		{
			//trace(this.stickDiagram.currentMPoint());
			//trace("currMP " +currMP);
			if(stickScroller.viewport.width == 0)// for position tracking point bug, the viewport width very strangely become zero when toggle to Overview map panel
			{
				return currMP;
			}
			else
			{
				var percent:Number = (stickGroup.horizontalScrollPosition )/ stickDrawing.width;
				//var percent:Number = (stickGroup.horizontalScrollPosition - offsetValue + (stickGroup.width /2))/ stickDrawing.width;
				var miDist:Number = stickDrawing.route.endMi - stickDrawing.route.beginMi;
				currMP = stickDrawing.route.beginMi + (miDist * percent);
			}
			//currMP =  Converter.scalePixelToMile(stickScroller.viewport.horizontalScrollPosition+((stickScroller.viewport.width)/2) - offsetValue,this.scale) + 
			//	this.stickDrawing.route.beginMi;
			//trace("stick width"  + stickScroller.viewport.width)
			//trace(this.stickDiagram.currentMPoint())
			//trace(currMP + "cp");
			//return currMP;
			//return Converter.scalePixelToMile(stickScroller.viewport.horizontalScrollPosition+(stickScroller.viewport.width/2),this.scale) + 
			//	this.stickDrawing.route.beginMi;
			return this.stickDiagram.currentMPoint();		
			//return Converter.scalePixelToMile(stickDrawing.guideBar.x,this.scale);
			
		}
		
		public function getCurrentMPost():Number
		{
			if(stickScroller.viewport.width == 0)// for position tracking point bug, the viewport width very strangely become zero when toggle to Overview map panel
			{
				return currMPost;
			}
			else
			{
				currMPost = lrmManager.milepointToMilepostPlusOffset(currMP,"MILEMARKER",FlexGlobals.topLevelApplication.GlobalComponents.assetManager.filteredMileMarkers)
			}
			return currMPost;
		}

		public function moveAddingMarkers():void
		{
			for (var i:Number=0;i<addingMarkers.length;i++)
			{
				var tmpImg:Image = addingMarkers.getItemAt(i) as Image;
				tmpImg.x = stickGroup.horizontalScrollPosition + (stickGroup.width / 2) - 20;
			}
			
		}
		

		public function handleLineEventEnd(event:DataEventEvent):void
		{
			var tmpImage:TSSPicture = new TSSPicture();
			tmpImage.source = event.getTypeIcon();
			tmpImage.x = stickGroup.horizontalScrollPosition + (stickGroup.width / 2) - 20;
			if (event.datatype < 13)
			{
				tmpImage.y = 65;
			}
			else if (event.datatype > 20 && event.datatype < 40)
			{
				tmpImage.y = 135;
			}
			else if (event.datatype > 40 && event.datatype < 50)
			{
				tmpImage.y = 205;
			}
			else if (event.datatype > 60 && event.datatype < 70)
			{
				tmpImage.y = 275;
			}
			tmpImage.width = 40;
			tmpImage.height = 40;
			
			inventoryDrawing.addChild(tmpImage);
			inventoryDrawing.removeChild(inventoryDrawing.getChildByName(event.datatype.toString()));
		}
		
		/**
		 *  this function triangulates to ensure the mouse up command fires to refresh 
		 if the user has activate the scrollbar but has moved of the scrollbar element
		 or if the user has activated the guidebar drag but moved of the guidebar before mouse up
		 * @param event
		 * 
		 */
		public override function triangulateMouseUp(event:MouseEvent):void
		{
			if (scrollOn == true)
			{
				getScrollUpdates(event);
			}
			if (captureBar)
				captureBar.triangulateMouseUp(event);
		}
		
		/**
		 * Synchronizes the scrollers, updates the guide mile, gudie bar poistion and left and rigth view miles
		 * @param e
		 * 
		 */
		protected override function linkScrollers(e:PropertyChangeEvent):void
		{
			if (e.source == e.target && e.property == "horizontalScrollPosition") 
			{
				var newX:Number = Math.round(new Number(e.newValue)); 
				if (InvPanelContent=="bars")
				{
					//invScroller.viewport.horizontalScrollPosition = stickScroller.viewport.horizontalScrollPosition;
					inventoryDrawing.guideBar.moveGuideBar(stickScroller.viewport.horizontalScrollPosition);
					invScroller.viewport.horizontalScrollPosition = stickScroller.viewport.horizontalScrollPosition;
					inventoryDrawing.labels.forEach(moveLabels);
				}
				stickDrawing.moveHUD(Math.round(stickScroller.viewport.horizontalScrollPosition) +  ((stickScroller.viewport.width - 50) / 2));
				
				stickDrawing.updateCallOutXs(newX+10);
				stickDrawing.updateMeasureBarX(newX);
				this.updateCallOutVals();
				stickDrawing.displayAssetsInRange();
				
				//var xForGuideB:Number =  
				stickDrawing.guideBar.moveGuideBar(newX);
				
				
				
			}
			fireXYChange();
		}

		/**
		 * Called once the config file is read and button list array is ready
		 * Initiates the buttons on the capture bar
		 * Sets button Data providers and handlers for buttons, dropdowns and input 
		 */
		public function setCBButtonDPs():void
		{
			captureBar.draw(cbBtnHandler, leftPanel.width, leftPanel.height);
		}
		
		
		/**
		 * Captures the milepoint as soon as any button on the capture bar is clicked
		 * also capture what type of button for ex:"Sign"
		 * @param event
		 * 
		 */
		public function cbBtnHandler(event:Event):void
		{
			var currentMP:Number= getCurrentMP();
			captureBar.currentCaptureMP = currentMP + Converter.scalePixelToMile(screenWidth/2, scale);
			captureBar.currentCaptureType = event.target.label;
		}
		/**
		 * Returns the JSON string for current route 
		 * @return 
		 * 
		 */
		public function getJSONRoute():String
		{
			var curRte:Route = stickDrawing.route;
			var JSONStr:String = "{\"route\": { \"routeName\": \"" + curRte.routeName + "\", \"beginMi\" : \"" + curRte.beginMi + "\", \"endMi\" : \"" + curRte.endMi + "\", \"routeNumber\" : \"" + curRte.routeNumber + "\"}}"; 
			return JSONStr;
		}
		
		/**
		 * Sets the route from json string  
		 * @param jsonRteStr
		 * 
		 */
		public function setRouteByJSON(jsonRteStr:String, begin:Number = -1, end:Number = -1):Route
		{
			
			FlexGlobals.topLevelApplication.GlobalComponents.assetManager.origMileMarkers= stickDrawing.getCachedAssetByType("MILEMARKER");
			var tempObj:Object = JSON.parse(jsonRteStr);
			var rteObj:Object = tempObj.route;
			
			if (begin < 0)
				begin = rteObj.beginMi;
			if (end < 0)
				end = rteObj.endMi;
			
			var newRte:Route = new Route(rteObj.routeName, begin, end, rteObj.routeNumber);
			
//			if(milepostData !=null && milepostData.length>0)
//			{
//				var ac:Array= FlexGlobals.topLevelApplication.GlobalComponents.assetManager.mapAssetColl(milepostData,"MILEMARKER");
//				milepostData = new ArrayCollection(ac);
//				
//			}
//			else
//				FlexGlobals.topLevelApplication.TSSAlert("Milepost data not available. Using milepoint");
			
			var milepostData:ArrayCollection = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.filteredMileMarkers;
			if(newRte!=null && milepostData !=null && milepostData.length>0)
			{
				newRte.beginMilepost = newRte.beginMi;
				newRte.endMilepost = newRte.endMi;
				
				
				var nba:NearestBaseAsset = lrmManager.milepostToMilepointPlusOffset(newRte.beginMi,"MILEMARKER",milepostData);
				//			//use milepost data to LRM transform.
				
				newRte.beginMi =nba.milepoint + nba.offsetMiles;
				
				
				nba = lrmManager.milepostToMilepointPlusOffset(newRte.endMi,"MILEMARKER",milepostData);
				
				newRte.endMi =nba.milepoint + nba.offsetMiles;
				
			}
			else
			{
				newRte.beginMilepost = newRte.beginMi;
				newRte.endMilepost = newRte.endMi;
			}
			return newRte;
			
			//stickDrawing.route = newRte; //sets stick route
		}
		
		/**
		 * 
		 * 
		 */
		public function startRun():void
		{
			scrollerRunning = true;
			timer.addEventListener(TimerEvent.TIMER, run);
			timer.start();
		}
		
		/**
		 * Begins scrolling movement down route diagram
		 * @param obj
		 * 
		 */
		private function run(obj:Object):void
		{
			
			if (scrollForward)
			{
				advanceScroller(null);
			}else
			{
				retreatScroller(null);
			}
		}
		
		/**
		 * Stops scrolling movement
		 * 
		 */
		public function stopRun():void
		{
			scrollerRunning = false;
			timer.stop();
		}
		
		public function goTo(milepoint:Number,milepost:Number):void{
			
			stickScroller.viewport.horizontalScrollPosition = Converter.scaleMileToPixel(milepoint-this.stickDiagram.route.beginMi, this.scale)-(stickScroller.viewport.width-50)/2 + this.offsetValue;
			this.updateCallOutVals();
			stickDrawing.displayAssetsInRange();
			this.moveAddingMarkers();
			
			var xForGuideB:Number =  new Number(stickScroller.viewport.horizontalScrollPosition);
			
			stickDrawing.guideBar.x=0;
			//trace(xForGuideB);
			
			//trace("Guidebar x: "+stickDrawing.guideBar.x);
			stickDrawing.moveHUD(stickScroller.viewport.horizontalScrollPosition+((stickScroller.viewport.width-50)/2));
			//stickDrawing.routeHUD.updateGuideMile(Converter.scalePixelToMile((xForGuideB +  stickScroller.viewport.width/2), this.scale)+ this.stickDiagram.route.beginMi);

			updateStickGuideMile(milepost);
			//var maxRightX:Number =  new Number(xForGuideB) +  stickScroller.viewport.width-40;
			stickDrawing.updateCallOutXs(new Number(xForGuideB));
			fireXYChange();
			
			
		}
		
		/**
		 * 
		 * @param obj
		 * 
		 */
		public function advanceScroller(obj:Object):void
		{
			stickGroup.horizontalScrollPosition = stickGroup.horizontalScrollPosition + runInterval;
			
			//trace(Converter.scalePixelToMile(stickGroup.horizontalScrollPosition, this.scale));
			//trace(Converter.scalePixelToMile(runInterval, this.scale));
			this.updateCallOutVals();
			stickDrawing.displayAssetsInRange();
			//FlexGlobals.topLevelApplication.GlobalComponents.stkDiagram.displayAssetsInRange();
			this.moveAddingMarkers();
			if (guideBarOn)
			{
				var xForGuideB:Number =  new Number(stickGroup.horizontalScrollPosition) ;
				
				stickDrawing.guideBar.x=0;
				trace(xForGuideB);
		
				//inventoryDrawing.guideBar.moveGuideBar(xForGuideB);
				//trace("inv guidebar x:"+inventoryDrawing.guideBar.x);
				trace("Guidebar x: "+stickDrawing.guideBar.x);
				stickDrawing.moveHUD(stickScroller.viewport.horizontalScrollPosition+((stickScroller.viewport.width - 50)/2));

				updateStickGuideMile();
				updateCallOutVals();
				//var maxRightX:Number =  new Number(xForGuideB) +  stickScroller.viewport.width-40;
				stickDrawing.updateCallOutXs(new Number(xForGuideB));
			}
			fireXYChange();
		}
		
		/**
		 * 
		 * @param obj
		 * 
		 */
		public function retreatScroller(obj:Object):void
		{
			stickGroup.horizontalScrollPosition = stickGroup.horizontalScrollPosition - runInterval;
			fireXYChange();
		}
		
		/**
		 * Scrolls to the beginning of the diagram
		 * @param obj
		 * 
		 */
		public function scrollToBeginning(obj:Object):void
		{
			stickGroup.horizontalScrollPosition = 0;
			fireXYChange();
		}
		
		/**
		 * Scrolls to the end of the diagram
		 * @param obj
		 * 
		 */
		public function scrollToEnd(obj:Object):void
		{
			stickGroup.horizontalScrollPosition = stickDrawing.width-1;
			fireXYChange();
		}
		
		/**
		 * Scrolls backward on u-turn
		 * @param obj
		 * 
		 */
		public function uturn(obj:Object):void
		{
			if (scrollForward)
			{
				scrollForward = false;		
			} 
			else
			{
				scrollForward = true;
			}
		}
		
		/**
		 * Increases or decreases the speed
		 * @param event
		 * 
		 */
		public function changeSpeed(event:NavControlEvent):void
		{
			var speed:Number = event.sliderValue;
			if (scrollerRunning)
			{
				stopRun();
				timer = new Timer(speed);
				startRun();
			} 
			else
			{
				timer = new Timer(speed);
			}
		}
		
		/**
		 * Increases or decreases the step size
		 * @param event
		 * 
		 */
		public function changeStep(event:NavControlEvent):void
		{
			runInterval = event.sliderValue;
		}
		
		/**
		 * Dispatches  X, Y value change event
		 */
		protected function fireXYChange():void
		{
			try 
			{		
				var runEvent:NavControlEvent = new NavControlEvent(NavControlEvent.XY_CHANGE, true, true);
				runEvent.mp = getCurrentMP();
				
				this.dispatcher.dispatchEvent(runEvent);
			}
			catch(error:TypeError)
			{
				trace("CAUGHT!");
				//catch the occassional type error obtained when clicked on the menu container outside the item
			}
		}
		
		/**
		 * call firexychange for map
		 */
		public function fireXYChange_FT(event:TSSMapEvent):void
		{
			fireXYChange();
		}
		
		/**
		 * Returns the cached route id 
		 * @return 
		 * 
		 */
		protected function getCurrentCachedRouteID():Number
		{
			var cRoute:CachedRoute = dbManager.getCachedRouteByRtID(stickDrawing.route.routeName);
			return cRoute.id;
		}
		
		public function setFormWidth(width:Number):void
		{
			//inventoryGroup.width = width;
			inventoryForm.width = width;
		}
		
		
		public function setFormHeight(height:Number):void
		{
			//inventoryGroup.height = height;
			inventoryForm.height = height;
			
		}
		
		
		
		
		/**
		 * Retrieves JSON representative strings for the current route, crossing features and inventory data elements 
		 * Stores generated JSON to local database (SQL lite db)
		 * 
		 */
		public function saveLocalDiagram():void
		{
			if(stickDrawing.route.routeName=="no_rte")
			{
				FlexGlobals.topLevelApplication.TSSAlert("No route loaded. Please load a route to save");
				return;
			}
			if(dbManager.isRouteAlreadyCached(stickDrawing.route.routeName,stickDrawing.route.beginMi, stickDrawing.route.endMi))
			{
				FlexGlobals.topLevelApplication.TSSAlert("Route already cached with same extents");
				return;
			}	
			FlexGlobals.topLevelApplication.setBusyStatus(true);
			if(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.invPanelContent != "bars")
			{
				savingRoutetoLocalDB = true;
				FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.invPanelContent="bars";
			}
			else
				continueSaveLocalDiagram();
		}
		
		public function invDrawingCompleted():void
		{
			if(savingRoutetoLocalDB == true)
			{
				continueSaveLocalDiagram();
				savingRoutetoLocalDB = false;
			}
			else
			{
				
				if(FlexGlobals.topLevelApplication.savedEditMP>-1)
				{
					//viewMile = FlexGlobals.topLevelApplication.savedEditMP;
					FlexGlobals.topLevelApplication.savedEditMP=-1;//reset it
					inventoryDrawing.guideBar.moveGuideBar(stickScroller.viewport.horizontalScrollPosition);
					invScroller.viewport.horizontalScrollPosition = stickScroller.viewport.horizontalScrollPosition;
				}
				
			}
		}
		
		private function continueSaveLocalDiagram():void
		{
			try
			{
				if(_routeCoords==null)
				{	
					savingRoutetoLocalDB = true;
					FlexGlobals.topLevelApplication.redrawMaps(stickDrawing.route);
				}
				else
					continueSaveLocalDiagramStep2();
				
			}
			catch (e:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert("Error saving route to local database :" + String(e.message));
			}
		}
		
		
		private function continueSaveLocalDiagramStep2():void
		{
			savingRoutetoLocalDB = false;
			var stickElements:String = stickDrawing.xingFeaturesToJSON();
			if(inventoryDrawing != null)
				var invElements:String = inventoryDrawing.invElementsToJSON();
			var diagramRoute:String = getJSONRoute();
			var cRoute:CachedRoute = new CachedRoute();
			cRoute.routeid = stickDrawing.route.routeName;
			cRoute.beginmile = stickDrawing.route.beginMi;
			cRoute.endmile = stickDrawing.route.endMi;
			
			cRoute.content = diagramRoute;
			cRoute.path = JSON.stringify(_routeCoords.toArray());
			var bbox:TSSRectangle = getBoundingBox(_routeCoords);
			cRoute.bbox = JSON.stringify(bbox);
			
			var cStickElement:CachedElement = new CachedElement();
			cStickElement.type = 1;
			cStickElement.description = "stick elements";
			cStickElement.content = stickElements;
			
			var cInvElement:CachedElement = new CachedElement();
			cInvElement.type = 2;
			cInvElement.description = "inventory elements";
			cInvElement.content = invElements;
			
			// store route data
			var sID:Number = dbManager.addCachedRoute(cRoute);
			// store stick and inv data
			dbManager.addElement(sID,cStickElement);
			dbManager.addElement(sID,cInvElement);
			
			//store geotags
			storeGeotags();
		}
		
		
		/**
		 * Save the all (attached and unattached geotags on current route )
		 * 
		 */
		private function storeGeotags():void
		{
			try
			{
				var httpService:HTTPService = new HTTPService();
				httpService.url = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL + ConfigUtility.get("all_asset_geotags")  + this._route.routeName + "/" + this._route.beginMi + "/" + this._route.endMi; 
				httpService.resultFormat = "text";
				httpService.addEventListener(FaultEvent.FAULT, allGeotagsonFail);
				httpService.addEventListener(ResultEvent.RESULT, allGeotagsResponse);
				httpService.send();
			}
			catch (e:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert("Error saving attachments to local database :" + String(e.message));
			}
		}
		
		private function allGeotagsonFail(ev:FaultEvent):void
		{
			FlexGlobals.topLevelApplication.TSSAlert("Error saving attachments to local database :" + String(ev.message.toString() ));
		}
		
		protected function allGeotagsResponse(ev:ResultEvent):void{
			
			var gtArr:Array  = new Array();
			gtArr = JSON.parse(ev.message.body as String) as Array;
			
			FlexGlobals.topLevelApplication.GlobalComponents.assetManager.cacheGeotags(gtArr,true);
			
			//alert displayed and busy set to false after downloading all geotags in asset manager
		}
		
		/**
		 * returns the tightest-fitting, angled box around a route path
		 * @param path the geometry of the path in the format that the getRouteCoords service returns
		 * @return the angled rectangle 
		 */
		public static function getBoundingBox(path:ArrayCollection):TSSRectangle
		{
			var mapSR:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.baseMapSR;
//			var mapSR:String = BaseConfigUtility.get("basemapSR");
			var baseX:Number;
			var baseY:Number;
			
			var endX:Number;
			var endY:Number;
			
			// Also, vector for change. Used for projection.
			var dx:Number;
			var dy:Number;
			
			if (mapSR == "4623" || mapSR == "4327")
			{
				baseX = parseFloat(path[0].X);
				baseY = parseFloat(path[0].Y);
				
				endX = parseFloat(path[path.length - 1].X);
				endY = parseFloat(path[path.length - 1].Y);
				
				// Also, vector for change. Used for projection.
				dx = parseFloat(path[path.length - 1].X) - baseX;
				dy = parseFloat(path[path.length - 1].Y) - baseY;
			} else
			{
				baseX = parseFloat(path[0].utmX);
				baseY = parseFloat(path[0].utmY);
				
				endX = parseFloat(path[path.length - 1].utmX);
				endY = parseFloat(path[path.length - 1].utmY);
				
				// Also, vector for change. Used for projection.
				dx = parseFloat(path[path.length - 1].utmX) - baseX;
				dy = parseFloat(path[path.length - 1].utmY) - baseY;
			}
			
			
			var max1:Number = 0;
			var max2:Number = 0;
			var max1Point:Point;
			var max2Point:Point;
			
			var thresh:Number = ConfigUtility.getNumber("route_tolerance");
			
			for (var i:int = 1; i < path.length - 1; i++)
			{
				var x:Number;
				var y:Number;
				if (mapSR == "4623")
				{
					x = parseFloat(path[i].X) - baseX;
					y = parseFloat(path[i].Y) - baseY;
				} else
				{
					x = parseFloat(path[i].utmX) - baseX;
					y = parseFloat(path[i].utmY) - baseY;
				}
				
				var comp:Number = (((x * dx) + (y * dy)) / (dx * dx + dy * dy));
				
				var projX:Number = comp * dx;
				var projY:Number = comp * dy;
				
				var orthX:Number = x - projX;
				var orthY:Number = y - projY;
				
				var nDX:Number = roundToPlace(dx / Math.sqrt((dx * dx) + (dy * dy)), 6);
				var nDY:Number = roundToPlace(dy / Math.sqrt((dx * dx) + (dy * dy)), 6);
				
				var nOrthX:Number = roundToPlace(orthX / Math.sqrt((orthX * orthX) + (orthY * orthY)), 6);
				var nOrthY:Number = roundToPlace(orthY / Math.sqrt((orthX * orthX) + (orthY * orthY)), 6);
				
				//trace("Dot Val: " + dot(nOrthX, nDX, nOrthY, nDY));
				
				if (nOrthX != nDX)
				{
					var val:Number = Math.sqrt(Math.pow(orthX, 2) + Math.pow(orthY, 2));
					if (val > max1) {
						max1 = val;
						max1Point = new Point(x + nOrthX * thresh, y + nOrthY * thresh);
					}
				}
				else if (nOrthY != nDY)
				{
					var val2:Number = Math.sqrt(Math.pow(projX - x, 2) + Math.pow(projX - x, 2));
					if (val2 > max2)
						max2 = val2;
						max2Point = new Point(x + nOrthX * thresh, y + nOrthY * thresh);
				}
				
			}
			
			if (max1Point == null)
				max1Point = new Point(0, 0);
			
			if (max2Point == null)
				max2Point = new Point(0, 0);
			
			if (max1Point.x > max2Point.y)
			{
				var tPoint:Point = max2Point;
				max2Point = max1Point;
				max1Point = tPoint;
			}
			
			var tRect:TSSRectangle = new TSSRectangle(baseX + max1Point.x, baseY + max1Point.y, endX + max1Point.x, endY + max1Point.y,
													  baseX + max2Point.x, baseY + max2Point.y, endX + max2Point.x, endY + max2Point.y);
			return tRect;	
		}
		
		/**
		 * round a number to a specified decimal place. 
		 * WARNING: can be slightly inaccurate
		 * @param num the number to round
		 * @param places the number of decimal places to round to
		 * @return the rounded-off number
		 * */
		public static function roundToPlace(num:Number, places:int):Number
		{
			var multiplicand:int = Math.pow(10, places) as int;
			var multiplug:int = int(num * multiplicand);
			return (multiplug * 1.0) / multiplicand;
		}
		
		/**
		 * dot product of two 2D vectors 
		 */
		public static function dot(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			return (x1 * x2) + (y1 * y2);
		}
		
		public function exportChanges():void
		{
			exportManager.syncChanges();
		}

		public function mavricConfiguredSync():void
		{
			//syncManager.syncCulverts(this.stickDrawing.route.routeName);
			//syncManager.syncInitiate();
			mavicConfiguredSyncMgr.syncInitiate();
		}
		public function RHSync():void
		{
			RHSyncMgr.syncChanges();
		}
		
		
		/**
		 * Loads stored route information by storage id from local DB
		 * @param rtePkId
		 * 
		 */
		public function loadLocalDiagram(rtePkId:Number, begin:Number = -1, end:Number = -1):void
		{
			var routeEve:LocalRouteEvent = new LocalRouteEvent(LocalRouteEvent.LOAD_1);
			routeEve.routePkId = rtePkId;
			routeEve.begin = begin;
			routeEve.end = end;
			dispatcher.dispatchEvent(routeEve);
		}
		
		
		/**
		 *Loads  unattached geotags from local DB
		 * 
		 */
		public function loadLocalUnattachedGeotags():void
		{
			var gtA:Array = dbManager.getLocalUnattachedGeoTags(this._route.routeName, this._route.beginMi, this._route.endMi);
			this.stickDiagram.geotagRequestCallBack(new ArrayCollection(gtA), "local");
		}
		
		/*
			BEGIN BLOCK: The following methods are used to break up the task of loading a cached route, to
						 implement a form of pseudo-threading. The Event model will first be used.
						 otherwise, a Timer-based model should suffice.
		*/
		private var tTimer:Timer;
		public function loadPhase1(rtePkId:Number, begin:Number, end:Number):void
		{
			// pull data from local device
			var cRoute:CachedRoute = dbManager.getCachedRoute(rtePkId);
			var cStickElement:CachedElement = dbManager.getElement(rtePkId,1);
			var cInvElement:CachedElement = dbManager.getElement(rtePkId,2);
			
			fsm = new FeatureSetManager(null);
			var rtArray:Array = JSON.parse(cRoute.path) as Array;
			
			var pUTM:PolarToUTM = new PolarToUTM();
			fsm.routeCoords = pUTM.routeCoordsToUTM(new ArrayCollection(rtArray));
			
			//fsm.routeCoords = new ArrayCollection(rtArray);
			FlexGlobals.topLevelApplication.routeCoords = fsm.routeCoords;
			
			var routeEve:LocalRouteEvent = new LocalRouteEvent(LocalRouteEvent.LOAD_2);
			routeEve.cachedRoute = cRoute;
			routeEve.stickElement = cStickElement;
			routeEve.invElement = cInvElement;
			routeEve.begin = begin;
			routeEve.end = end;
			
			tTimer = new Timer(100);
			tTimer.start();
			tTimer.repeatCount = 1;
			tTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void 
			{
				dispatcher.dispatchEvent(routeEve); 
			}); 
			
			//dispatcher.dispatchEvent(routeEve); 
		}
		
		public function loadPhase2(cRoute:CachedRoute, cStickElement:CachedElement, cInvElement:CachedElement, begin:Number, end:Number):void
		{
			var mileMarkerArrC:ArrayCollection = stickDrawing.JSONToMileMarkers(cStickElement.content, begin, end);
			
			var rte:Route = new Route(cRoute.routeid, cRoute.beginmile, cRoute.endmile);
			FlexGlobals.topLevelApplication.GlobalComponents.assetManager.route = rte;
			if (mileMarkerArrC.length==0)
				mileMarkerArrC = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getAssetsByRoute("MILEMARKER", rte);
			//set this here, so it gets filtered and fake milepoints get added to the list if list is empty
			//use filtered markers from here on
			FlexGlobals.topLevelApplication.GlobalComponents.assetManager.origMileMarkers = mileMarkerArrC;
			var tempBeg:Number = -1;
			var tempEnd:Number = -1;
			if (FlexGlobals.topLevelApplication.GlobalComponents.assetManager.filteredMileMarkers.length>0)
			{
				var coreAssetManager:AssetManager = new AssetManager();
				var lrm:LRMManager = new LRMManager();
				var milemarker1:NearestBaseAsset = lrm.milepostToMilepointPlusOffset(begin, "MILEMARKER",FlexGlobals.topLevelApplication.GlobalComponents.assetManager.filteredMileMarkers);
				tempBeg = milemarker1.milepoint + milemarker1.offsetMiles;

				var milemarker2:NearestBaseAsset = lrm.milepostToMilepointPlusOffset(end, "MILEMARKER",FlexGlobals.topLevelApplication.GlobalComponents.assetManager.filteredMileMarkers);
				tempEnd = milemarker2.milepoint + milemarker2.offsetMiles;
			}
			if(tempBeg==-1)
				tempBeg = begin;
			if(tempEnd == -1)
				tempEnd = end;
			stickDrawing.JSONToXingFeatures(cStickElement.content, tempBeg, tempEnd);
			
			var routeEve:LocalRouteEvent = new LocalRouteEvent(LocalRouteEvent.LOAD_3);
			routeEve.cachedRoute = cRoute;
			routeEve.stickElement = cStickElement;
			routeEve.invElement = cInvElement;
			routeEve.begin = begin;
			routeEve.end = end;
			
			tTimer = new Timer(100);
			tTimer.start();
			tTimer.repeatCount = 1;
			tTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void 
			{
				dispatcher.dispatchEvent(routeEve); 
			});
		}
		
		public function loadPhase3(cRoute:CachedRoute, cStickElement:CachedElement, cInvElement:CachedElement, begin:Number, end:Number):void
		{
			
			
			
			// Bad form, but necessary:
			FlexGlobals.topLevelApplication.currentRouteName = cRoute.routeid
			FlexGlobals.topLevelApplication.currentBeginMile = begin;
			FlexGlobals.topLevelApplication.currentEndMile = end;
			FlexGlobals.topLevelApplication.GlobalComponents.stkDiagram = stickDrawing;
			
			// call to push JSON into app storage 
			var tempRoute:Route = setRouteByJSON(cRoute.content, begin, end);
			
			var routeEve:LocalRouteEvent = new LocalRouteEvent(LocalRouteEvent.LOAD_4);
			routeEve.cachedRoute = cRoute;
			routeEve.stickElement = cStickElement;
			routeEve.invElement = cInvElement;
			routeEve.begin = tempRoute.beginMi;
			routeEve.end = tempRoute.endMi;
			routeEve.evtRoute  = tempRoute;
			tTimer = new Timer(100);
			tTimer.start();
			tTimer.repeatCount = 1;
			tTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void 
			{
				dispatcher.dispatchEvent(routeEve); 
			});
			
			
		}
		
		public function loadPhase4(cRoute:CachedRoute, cStickElement:CachedElement, cInvElement:CachedElement, evtRoute:Route):void
		{
			stickDrawing.includeLocalAssets(evtRoute);
			FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.invPanelContent = "bars";
			
			initInvPanelContent(getPanelContent("bars"));
			
			var routeEve:LocalRouteEvent = new LocalRouteEvent(LocalRouteEvent.LOAD_5);
			routeEve.cachedRoute = cRoute;
			routeEve.stickElement = cStickElement;
			routeEve.invElement = cInvElement;
			routeEve.evtRoute  = evtRoute;
			//dispatcher.dispatchEvent(routeEve);
			
			tTimer = new Timer(100);
			tTimer.start();
			tTimer.repeatCount = 1;
			tTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void 
			{
				dispatcher.dispatchEvent(routeEve); 
			});
			
			//dispatcher.dispatchEvent(routeEve); 
		}
		
		public function loadPhase5(cInvElement:CachedElement, evtRoute:Route):void
		{
			// call parent function
			updateRouteBase(evtRoute, scale, true, 0, "middle", false, false);
			stickScroller.viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, linkScrollers);
			stickScroller.horizontalScrollBar = new HScrollBar();
			stickScroller.horizontalScrollBar.alpha = 0;
			
			var routeEve:LocalRouteEvent = new LocalRouteEvent(LocalRouteEvent.LOAD_6);
			routeEve.invElement = cInvElement;
			//dispatcher.dispatchEvent(routeEve);
			
			tTimer = new Timer(100);
			tTimer.start();
			tTimer.repeatCount = 1;
			tTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void 
			{
				dispatcher.dispatchEvent(routeEve);
			}); 
			 
		}
		
		public function loadPhase6(cInvElement:CachedElement):void
		{
			// position HUD Text after stick draw
			stickDiagram.moveHUD(stickScroller.viewport.horizontalScrollPosition+((stickScroller.viewport.width - 50)/2));
			guideBarSwitch = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.guideBarSwitch;
			
			inventoryDrawing.JSONtoInvElements(cInvElement.content, stickDrawing.route.beginMi,stickDrawing.route.endMi);
			
			var routeEve:LocalRouteEvent = new LocalRouteEvent(LocalRouteEvent.LOAD_7);
			routeEve.invElement = cInvElement;
			//dispatcher.dispatchEvent(routeEve);
			
			tTimer = new Timer(100);
			tTimer.start();
			tTimer.repeatCount = 1;
			tTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void 
			{
				dispatcher.dispatchEvent(routeEve);
			});
			//dispatcher.dispatchEvent(routeEve); 
		}
		
		public function loadPhase7():void
		{
			this.viewMile =0;
			this.screenWidth = stickScroller.viewport.width;
			stickScroller.viewport.horizontalScrollPosition = 0;
			inventoryDrawing.draw(this.scale,stickDrawing.route,true, (stickScroller.viewport.width - 50) /2);
			
			var routeEve:LocalRouteEvent = new LocalRouteEvent(LocalRouteEvent.LOAD_8);
			
			//dispatcher.dispatchEvent(routeEve);
			
			tTimer = new Timer(100);
			tTimer.start();
			tTimer.repeatCount = 1;
			tTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void 
			{
				dispatcher.dispatchEvent(routeEve);
				//tTimer.stop();
			});
			
			//dispatcher.dispatchEvent(routeEve); 
		}
		
		public function loadPhase8():void
		{
			//stickDrawing.draw(this.scale,stickDrawing.route,true,stickScroller.viewport.width, (stickScroller.viewport.width - 50)/2);
			stickDrawing.moveHUD(stickScroller.viewport.horizontalScrollPosition+((stickScroller.viewport.width - 50)/2));
			setCBButtonDPs();
			
			stickScroller.viewport.addEventListener(EffectEvent.EFFECT_END, scrollFinished);
			stickScroller.viewport.addEventListener(EffectEvent.EFFECT_START, scrollBegin);
			
			if (FlexGlobals.topLevelApplication.savedMPValue > -1)
			{
				var lrm:LRMManager = new LRMManager();
				var milemarker:NearestBaseAsset = lrm.milepostToMilepointPlusOffset(FlexGlobals.topLevelApplication.savedMPValue, "MILEMARKER",FlexGlobals.topLevelApplication.GlobalComponents.assetManager.filteredMileMarkers);
				var milepostLoc:Number = milemarker.milepoint + milemarker.offsetMiles;
				this.goTo(milepostLoc,milemarker.milepost);
				FlexGlobals.topLevelApplication.savedMPValue = -1;
			} 
			
			FlexGlobals.topLevelApplication.setBusyStatus(false);

		}
		
		private function loadRouteShape(rtName:String):void
		{
			try
			{
				var myPattern:RegExp = / /g; 
				var rtID:String = rtName.replace(myPattern, "_");
				
				var fl:File = new File("app:/InnerFiles/shape/IOWA_TRANS_DISTRICTS.shp");
				if (fl.exists)
				{
					//shapeMap = new ShpMap("file:C:/Projects/IDOT/route_shp/" + rtID + ".shp","file:C:/Projects/IDOT/route_shp/" + rtID + ".dbf");
					shapeMap = new ShpMap("app:/InnerFiles/shape/IOWA_TRANS_DISTRICTS.shp","app:/InnerFiles/shape/IOWA_TRANS_DISTRICTS.dbf");
					shapeMap.addEventListener("attributes loaded", shapesLoaded);
				}
			}
			catch(e:Error)
			{
				trace(e.message);
			}
		}
		
		protected function shapesLoaded(e:Event):void
		{
			fsm = new FeatureSetManager(shapeMap.features);
			//moveToXY(-96.0346, 41.5513);
			//moveToXY(-90.2401, 41.8156, new GPSEvent(GPSEvent.UPDATE));
		}
		
		public function setRouteCoords(routeCoords:ArrayCollection):void
		{
			this._routeCoords = routeCoords;
			if (fsm == null)
				fsm = new FeatureSetManager(null);
			if (fsm != null)
				fsm.routeCoords = routeCoords;
			
			if (FlexGlobals.topLevelApplication.savedMPValue > -1)
			{
				var coreAssetManager:AssetManager = new AssetManager();
				var lrm:LRMManager = new LRMManager();
				var milemarker:NearestBaseAsset = lrm.milepostToMilepointPlusOffset(FlexGlobals.topLevelApplication.savedMPValue, "MILEMARKER",FlexGlobals.topLevelApplication.GlobalComponents.assetManager.filteredMileMarkers );
				var milepostLoc:Number = milemarker.milepoint + milemarker.offsetMiles;
				this.goTo(milepostLoc,milemarker.milepost);
				FlexGlobals.topLevelApplication.savedMPValue = -1;
			}
			if (savingRoutetoLocalDB)//if redraw map was called by save current route
				continueSaveLocalDiagramStep2();
			if(continueMoveToXYFlag)//if redraw map was called by gps event
				continueMoveToXY();
		}
		
		private var currCoordNdx: int = 0;
		
		public function moveToXY(x:Number, y:Number, evt:GPSEvent):void
		{	
			gpsEvt = evt;
			
			if (fsm == null)
				return;
			
			var pUTM:PolarToUTM = new PolarToUTM();
			var utmObj:Object = pUTM.latlongToUTM(y, x);
			fsm.latitude = y;
			fsm.longitude = x;
			fsm.utmY = utmObj.y;
			fsm.utmX = utmObj.x;
			
			//Debug code for tracing a route using GPS.
			/*fsm.latitude = fsm.routeCoords.getItemAt(currCoordNdx).Y;
			fsm.longitude = fsm.routeCoords.getItemAt(currCoordNdx).X;
			currCoordNdx += 10;*/
			
			var vec:Vector.<PolygonFeature> = fsm.findIntersectingPolygon();
			if(vec.length > 0)
			{
				var mbe:MenuBarEvent = new MenuBarEvent(MenuBarEvent.DISTRICT_CHANGED);
				mbe.dist = vec[0] ? parseInt(vec[0].values["DISTRICT_N"]).toString() : "";
				this.dispatcher.dispatchEvent(mbe);
				
			}
			
			
			if (fsm.routeCoords == null && FlexGlobals.topLevelApplication.routeCoords !=null) {
				
				fsm.routeCoords = FlexGlobals.topLevelApplication.routeCoords;
				
				continueMoveToXY();
			}
			else if(fsm.routeCoords == null && FlexGlobals.topLevelApplication.routeCoords ==null)
			{
				continueMoveToXYFlag= true;
				FlexGlobals.topLevelApplication.redrawMaps(_route);
				
			}
			else
			{
				
				continueMoveToXY();
			}
			
			
		}
			
		public function continueMoveToXY():void
		{
			continueMoveToXYFlag= false;
			try{
				trace("newb3");
				stickGroup.horizontalScrollPosition = Converter.scaleMileToPixel(fsm.calculateMilepoint2() - this.stickDrawing.route.beginMi, this.scale);
				trace("newb4");
				
				trace("Hi5");
				if (guideBarOn)
				{
					var xForGuideB:Number =  new Number(stickGroup.horizontalScrollPosition) ;
					trace("Hi6");
					stickDrawing.guideBar.x=0;
					trace("Hi7");
					trace(xForGuideB);
					
					//inventoryDrawing.guideBar.moveGuideBar(xForGuideB);
					//trace("inv guidebar x:"+inventoryDrawing.guideBar.x);
					//trace("Guidebar x: "+stickDrawing.guideBar.x);
					stickDrawing.moveHUD(stickScroller.viewport.horizontalScrollPosition+((stickScroller.viewport.width - 50)/2));
					//stickDrawing.routeHUD.updateGuideMile(Converter.scalePixelToMile((xForGuideB+  stickScroller.viewport.width/2), this.scale)+ this.stickDiagram.route.beginMi);

					updateStickGuideMile();
					//					var maxRightX:Number =  new Number(xForGuideB) +  stickScroller.viewport.width-40;
					stickDrawing.updateCallOutXs(new Number(xForGuideB));
					trace("hi8");
					
				}
				//stickDrawing.updateMileRange(getLeftMilepoint(),getRightMilepoint());
				this.updateCallOutVals();
				trace("hi9");
				stickDrawing.displayAssetsInRange();
				this.captureBar.handleGPSChange(this.gpsEvt); // For updating labels
				trace("hi10");
				this.fireXYChange();
				trace("fin");
			}catch(err:Error)
			{
				trace("Big Trouble in Little China: " + err.message);
			}
		}
	
		public function scrollBegin(event:EffectEvent):void
		{
			_invScroller.setStyle("verticalScrollPolicy", "off");
			var uii:UIComponent = _invScroller.viewport as UIComponent;
			for each (var eff:EffectInstance in uii.activeEffects)
				eff.stop();
			stickDrawing.routeHUD.hideGuideMile();
			stickDrawing.hideUpdateCallOutVals();
		}
		
		public function scrollFinished(event:Event):void
		{
			
			
			
			if (invPanelContent != null && invPanelContent != "map")
				_invScroller.setStyle("verticalScrollPolicy", "on");
			
			updateStickGuideMile();
			if(inventoryDrawing)
			inventoryDrawing.labels.forEach(moveLabels);
			updateCallOutVals();
			stickDrawing.displayAssetsInRange();
		}
		
		public function scrollMouseup(event:Event):void
		{
			updateStickGuideMile();
			updateCallOutVals();
			stickDrawing.displayAssetsInRange();
		}
		
		
		public function scrollMouseDown(event:Event):void
		{
			stickDrawing.routeHUD.hideGuideMile();
			stickDrawing.hideUpdateCallOutVals();
		}
		
		public function updateStickGuideMile(milepost:Number = -100):void
		{
			var milepostData:ArrayCollection = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.filteredMileMarkers;
			if(milepost ==-100)
			{
				// offsetValue
				var curMP:Number = new Number((Converter.scalePixelToMile(stickScroller.viewport.horizontalScrollPosition +  ((stickScroller.viewport.width - 50) / 2) - offsetValue, diagramScale)+  this.stickDiagram.route.beginMi).toFixed(3));
				trace("update" + curMP);
				if(milepostData != null && milepostData.length>0) //GUIDE MP will mostly get the milepost data
					stickDrawing.routeHUD.updateGuideMile(lrmManager.milepointToMilepostPlusOffset(curMP,"MILEMARKER",milepostData ));
				else
					stickDrawing.routeHUD.updateGuideMile(curMP);
			
			}
			else
				stickDrawing.routeHUD.updateGuideMile(milepost);
		}
		
		public function updateCallOutVals():void
		{
			
			
			var leftMilepoint:Number =getLeftMilepoint();
			var rightMilepoint:Number = getRightMilepoint();
			var leftMilepost:Number ;
			var rightMilepost:Number;
			var milepostData:ArrayCollection = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.filteredMileMarkers;
			if(milepostData != null && milepostData.length>0)
			{
				leftMilepost= lrmManager.milepointToMilepostPlusOffset(leftMilepoint,"MILEMARKER",milepostData);
				rightMilepost= lrmManager.milepointToMilepostPlusOffset(rightMilepoint,"MILEMARKER",milepostData );
				stickDrawing.updateCallOutVals(leftMilepost, rightMilepost);
			}
			else
				stickDrawing.updateCallOutVals(leftMilepoint, rightMilepoint);
			
			stickDrawing.updateMileRange(leftMilepoint,rightMilepoint);
		}
		
		private function getLeftMilepoint():Number
		{
			var leftX:Number = stickScroller.viewport.horizontalScrollPosition;
			return  Converter.scalePixelToMile(leftX - offsetValue,  diagramScale)+  this.stickDiagram.route.beginMi;
		}
		private function getRightMilepoint():Number
		{
			var rightX:Number =  stickScroller.viewport.horizontalScrollPosition +  stickScroller.viewport.width-50;
			return  Converter.scalePixelToMile(rightX - offsetValue,  diagramScale)+  this.stickDiagram.route.beginMi;
		}
		
		public function getMilePostData():ArrayCollection
		{
			return FlexGlobals.topLevelApplication.GlobalComponents.assetManager.filteredMileMarkers;;
		}
		
		public function get currentRoute():Route
		{
			return _route;
		}
	}
}