package com.transcendss.mavric.extended.models
{
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.mavric.data.GPSData;
	import com.transcendss.mavric.events.AccessPointEvent;
	import com.transcendss.mavric.events.DataEventEvent;
	import com.transcendss.mavric.events.GPSEvent;
	import com.transcendss.mavric.events.GestureControlEvent;
	import com.transcendss.mavric.events.SignInvEvent;
	import com.transcendss.mavric.extended.models.Components.AccessPoint;
	import com.transcendss.mavric.views.InventoryMenu;
	import com.transcendss.transcore.events.ExternalFileEvent;
	import com.transcendss.transcore.events.InventoryMenuEvent;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.sensors.Geolocation;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.core.*;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import skins.*;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.Panel;
	import spark.components.RadioButton;
	import spark.components.Scroller;
	import spark.components.SkinnablePopUpContainer;
	import spark.components.TextInput;
	import spark.components.TitleWindow;
	import spark.components.VGroup;
	import spark.events.IndexChangeEvent;
	import spark.layouts.VerticalLayout;
	import spark.primitives.BitmapImage;
	import spark.primitives.Rect;
	import spark.skins.spark.DefaultComplexItemRenderer;

	
	
	public class SignInvCaptureBar extends UIComponent
	{
		[Bindable]
		[Embed(source="../../../../../images/signs/png/7-8P.png")] protected var sgn7_8P:Class
		[Embed(source="../../../../../images/signs/png/R1-1.png")] protected var sgnR1_1:Class
		[Embed(source="../../../../../images/signs/png/R1-10P.png")] protected var sgnR1_10P:Class
		[Embed(source="../../../../../images/signs/png/R1-2.png")] protected var sgnR1_2:Class
		[Embed(source="../../../../../images/signs/png/R1-2aP.png")] protected var sgnR1_2aP:Class
		[Embed(source="../../../../../images/signs/png/R1-3P.png")] protected var sgnR1_3P:Class
		[Embed(source="../../../../../images/signs/png/R1-5.png")] protected var sgnR1_5:Class
		[Embed(source="../../../../../images/signs/png/R1-5a.png")] protected var sgnR1_5a:Class
		[Embed(source="../../../../../images/signs/png/R1-5b.png")] protected var sgnR1_5b:Class
		[Embed(source="../../../../../images/signs/png/R1-5c.png")] protected var sgnR1_5c:Class
		[Embed(source="../../../../../images/signs/png/R1-6.png")] protected var sgnR1_6:Class
		[Embed(source="../../../../../images/signs/png/R1-6a.png")] protected var sgnR1_6a:Class
		[Embed(source="../../../../../images/signs/png/R1-9.png")] protected var sgnR1_9:Class
		[Embed(source="../../../../../images/signs/png/R1-9a.png")] protected var sgnR1_9a:Class
		[Embed(source="../../../../../images/signs/png/R10-1.png")] protected var sgnR10_1:Class
		[Embed(source="../../../../../images/signs/png/R10-10.png")] protected var sgnR10_10:Class
		[Embed(source="../../../../../images/signs/png/R10-11.png")] protected var sgnR10_11:Class
		[Embed(source="../../../../../images/signs/png/R10-11a.png")] protected var sgnR10_11a:Class
		[Embed(source="../../../../../images/signs/png/R10-11b.png")] protected var sgnR10_11b:Class
		[Embed(source="../../../../../images/signs/png/R10-11c.png")] protected var sgnR10_11c:Class
		[Embed(source="../../../../../images/signs/png/R10-11d.png")] protected var sgnR10_11d:Class
		[Embed(source="../../../../../images/signs/png/R10-12.png")] protected var sgnR10_12:Class
		[Embed(source="../../../../../images/signs/png/R10-13.png")] protected var sgnR10_13:Class
		[Embed(source="../../../../../images/signs/png/R10-14.png")] protected var sgnR10_14:Class
		[Embed(source="../../../../../images/signs/png/R10-14a.png")] protected var sgnR10_14a:Class
		[Embed(source="../../../../../images/signs/png/R10-15.png")] protected var sgnR10_15:Class
		[Embed(source="../../../../../images/signs/png/R10-16.png")] protected var sgnR10_16:Class
		[Embed(source="../../../../../images/signs/png/R10-17a.png")] protected var sgnR10_17a:Class
		[Embed(source="../../../../../images/signs/png/R10-18.png")] protected var sgnR10_18:Class
		[Embed(source="../../../../../images/signs/png/R10-19aP.png")] protected var sgnR10_19aP:Class
		[Embed(source="../../../../../images/signs/png/R10-19P.png")] protected var sgnR10_19P:Class
		[Embed(source="../../../../../images/signs/png/R10-2.png")] protected var sgnR10_2:Class
		[Embed(source="../../../../../images/signs/png/R10-20aP.png")] protected var sgnR10_20aP:Class
		[Embed(source="../../../../../images/signs/png/R10-23.png")] protected var sgnR10_23:Class
		[Embed(source="../../../../../images/signs/png/R10-25.png")] protected var sgnR10_25:Class
		[Embed(source="../../../../../images/signs/png/R10-27.png")] protected var sgnR10_27:Class
		[Embed(source="../../../../../images/signs/png/R10-28.png")] protected var sgnR10_28:Class
		[Embed(source="../../../../../images/signs/png/R10-29.png")] protected var sgnR10_29:Class
		[Embed(source="../../../../../images/signs/png/R10-3.png")] protected var sgnR10_3:Class
		[Embed(source="../../../../../images/signs/png/R10-30.png")] protected var sgnR10_30:Class
		[Embed(source="../../../../../images/signs/png/R10-31P.png")] protected var sgnR10_31P:Class
		[Embed(source="../../../../../images/signs/png/R10-32P.png")] protected var sgnR10_32P:Class
		[Embed(source="../../../../../images/signs/png/R10-3a.png")] protected var sgnR10_3a:Class
		[Embed(source="../../../../../images/signs/png/R10-3b.png")] protected var sgnR10_3b:Class
		[Embed(source="../../../../../images/signs/png/R10-3c.png")] protected var sgnR10_3c:Class
		[Embed(source="../../../../../images/signs/png/R10-3d.png")] protected var sgnR10_3d:Class
		[Embed(source="../../../../../images/signs/png/R10-3e.png")] protected var sgnR10_3e:Class
		[Embed(source="../../../../../images/signs/png/R10-3f.png")] protected var sgnR10_3f:Class
		[Embed(source="../../../../../images/signs/png/R10-3g.png")] protected var sgnR10_3g:Class
		[Embed(source="../../../../../images/signs/png/R10-3h.png")] protected var sgnR10_3h:Class
		[Embed(source="../../../../../images/signs/png/R10-3i.png")] protected var sgnR10_3i:Class
		[Embed(source="../../../../../images/signs/png/R10-4.png")] protected var sgnR10_4:Class
		[Embed(source="../../../../../images/signs/png/R10-4a.png")] protected var sgnR10_4a:Class
		[Embed(source="../../../../../images/signs/png/R10-5.png")] protected var sgnR10_5:Class
		[Embed(source="../../../../../images/signs/png/R10-6.png")] protected var sgnR10_6:Class
		[Embed(source="../../../../../images/signs/png/R10-6a.png")] protected var sgnR10_6a:Class
		[Embed(source="../../../../../images/signs/png/R10-7.png")] protected var sgnR10_7:Class
		[Embed(source="../../../../../images/signs/png/R10-8.png")] protected var sgnR10_8:Class
		[Embed(source="../../../../../images/signs/png/R11-1.png")] protected var sgnR11_1:Class
		[Embed(source="../../../../../images/signs/png/R11-2.png")] protected var sgnR11_2:Class
		[Embed(source="../../../../../images/signs/png/R11-3a.png")] protected var sgnR11_3a:Class
		[Embed(source="../../../../../images/signs/png/R11-3b.png")] protected var sgnR11_3b:Class
		[Embed(source="../../../../../images/signs/png/R11-4.png")] protected var sgnR11_4:Class
		[Embed(source="../../../../../images/signs/png/R12-1.png")] protected var sgnR12_1:Class
		[Embed(source="../../../../../images/signs/png/R12-2.png")] protected var sgnR12_2:Class
		[Embed(source="../../../../../images/signs/png/R12-3.png")] protected var sgnR12_3:Class
		[Embed(source="../../../../../images/signs/png/R12-4.png")] protected var sgnR12_4:Class
		[Embed(source="../../../../../images/signs/png/R12-5.png")] protected var sgnR12_5:Class
		[Embed(source="../../../../../images/signs/png/R13-1.png")] protected var sgnR13_1:Class
		[Embed(source="../../../../../images/signs/png/R14-1.png")] protected var sgnR14_1:Class
		[Embed(source="../../../../../images/signs/png/R14-2.png")] protected var sgnR14_2:Class
		[Embed(source="../../../../../images/signs/png/R14-3.png")] protected var sgnR14_3:Class
		[Embed(source="../../../../../images/signs/png/R14-4.png")] protected var sgnR14_4:Class
		[Embed(source="../../../../../images/signs/png/R14-5.png")] protected var sgnR14_5:Class
		[Embed(source="../../../../../images/signs/png/R16-10.png")] protected var sgnR16_10:Class
		[Embed(source="../../../../../images/signs/png/R16-11.png")] protected var sgnR16_11:Class
		[Embed(source="../../../../../images/signs/png/R16-4.png")] protected var sgnR16_4:Class
		[Embed(source="../../../../../images/signs/png/R16-5.png")] protected var sgnR16_5:Class
		[Embed(source="../../../../../images/signs/png/R16-6.png")] protected var sgnR16_6:Class
		[Embed(source="../../../../../images/signs/png/R16-7.png")] protected var sgnR16_7:Class
		[Embed(source="../../../../../images/signs/png/R16-8.png")] protected var sgnR16_8:Class
		[Embed(source="../../../../../images/signs/png/R16-9.png")] protected var sgnR16_9:Class
		[Embed(source="../../../../../images/signs/png/R2-1.png")] protected var sgnR2_1:Class
		[Embed(source="../../../../../images/signs/png/R2-10.png")] protected var sgnR2_10:Class
		[Embed(source="../../../../../images/signs/png/R2-11.png")] protected var sgnR2_11:Class
		[Embed(source="../../../../../images/signs/png/R2-2P.png")] protected var sgnR2_2P:Class
		[Embed(source="../../../../../images/signs/png/R2-3P.png")] protected var sgnR2_3P:Class
		[Embed(source="../../../../../images/signs/png/R2-4a.png")] protected var sgnR2_4a:Class
		[Embed(source="../../../../../images/signs/png/R2-4P.png")] protected var sgnR2_4P:Class
		[Embed(source="../../../../../images/signs/png/R2-5aP.png")] protected var sgnR2_5aP:Class
		[Embed(source="../../../../../images/signs/png/R2-5bP.png")] protected var sgnR2_5bP:Class
		[Embed(source="../../../../../images/signs/png/R2-5cP.png")] protected var sgnR2_5cP:Class
		[Embed(source="../../../../../images/signs/png/R2-5P.png")] protected var sgnR2_5P:Class
		[Embed(source="../../../../../images/signs/png/R2-6aP.png")] protected var sgnR2_6aP:Class
		[Embed(source="../../../../../images/signs/png/R2-6bP.png")] protected var sgnR2_6bP:Class
		[Embed(source="../../../../../images/signs/png/R2-6P.png")] protected var sgnR2_6P:Class
		[Embed(source="../../../../../images/signs/png/R3-1.png")] protected var sgnR3_1:Class
		[Embed(source="../../../../../images/signs/png/R3-18.png")] protected var sgnR3_18:Class
		[Embed(source="../../../../../images/signs/png/R3-2.png")] protected var sgnR3_2:Class
		[Embed(source="../../../../../images/signs/png/R3-20L.png")] protected var sgnR3_20L:Class
		[Embed(source="../../../../../images/signs/png/R3-20R.png")] protected var sgnR3_20R:Class
		[Embed(source="../../../../../images/signs/png/R3-23.png")] protected var sgnR3_23:Class
		[Embed(source="../../../../../images/signs/png/R3-23a.png")] protected var sgnR3_23a:Class
		[Embed(source="../../../../../images/signs/png/R3-24.png")] protected var sgnR3_24:Class
		[Embed(source="../../../../../images/signs/png/R3-24a.png")] protected var sgnR3_24a:Class
		[Embed(source="../../../../../images/signs/png/R3-24b.png")] protected var sgnR3_24b:Class
		[Embed(source="../../../../../images/signs/png/R3-25.png")] protected var sgnR3_25:Class
		[Embed(source="../../../../../images/signs/png/R3-25a.png")] protected var sgnR3_25a:Class
		[Embed(source="../../../../../images/signs/png/R3-25b.png")] protected var sgnR3_25b:Class
		[Embed(source="../../../../../images/signs/png/R3-26.png")] protected var sgnR3_26:Class
		[Embed(source="../../../../../images/signs/png/R3-26a.png")] protected var sgnR3_26a:Class
		[Embed(source="../../../../../images/signs/png/R3-27.png")] protected var sgnR3_27:Class
		[Embed(source="../../../../../images/signs/png/R3-3.png")] protected var sgnR3_3:Class
		[Embed(source="../../../../../images/signs/png/R3-33.png")] protected var sgnR3_33:Class
		[Embed(source="../../../../../images/signs/png/R3-4.png")] protected var sgnR3_4:Class
		[Embed(source="../../../../../images/signs/png/R3-5.png")] protected var sgnR3_5:Class
		[Embed(source="../../../../../images/signs/png/R3-5a.png")] protected var sgnR3_5a:Class
		[Embed(source="../../../../../images/signs/png/R3-5bP.png")] protected var sgnR3_5bP:Class
		[Embed(source="../../../../../images/signs/png/R3-5cP.png")] protected var sgnR3_5cP:Class
		[Embed(source="../../../../../images/signs/png/R3-5dP.png")] protected var sgnR3_5dP:Class
		[Embed(source="../../../../../images/signs/png/R3-5eP.png")] protected var sgnR3_5eP:Class
		[Embed(source="../../../../../images/signs/png/R3-5fP.png")] protected var sgnR3_5fP:Class
		[Embed(source="../../../../../images/signs/png/R3-5gP.png")] protected var sgnR3_5gP:Class
		[Embed(source="../../../../../images/signs/png/R3-6.png")] protected var sgnR3_6:Class
		[Embed(source="../../../../../images/signs/png/R3-7.png")] protected var sgnR3_7:Class
		[Embed(source="../../../../../images/signs/png/R3-8.png")] protected var sgnR3_8:Class
		[Embed(source="../../../../../images/signs/png/R3-8a.png")] protected var sgnR3_8a:Class
		[Embed(source="../../../../../images/signs/png/R3-8b.png")] protected var sgnR3_8b:Class
		[Embed(source="../../../../../images/signs/png/R3-9a.png")] protected var sgnR3_9a:Class
		[Embed(source="../../../../../images/signs/png/R3-9b.png")] protected var sgnR3_9b:Class
		[Embed(source="../../../../../images/signs/png/R3-9cP.png")] protected var sgnR3_9cP:Class
		[Embed(source="../../../../../images/signs/png/R3-9dP.png")] protected var sgnR3_9dP:Class
		[Embed(source="../../../../../images/signs/png/R3-9e.png")] protected var sgnR3_9e:Class
		[Embed(source="../../../../../images/signs/png/R3-9f.png")] protected var sgnR3_9f:Class
		[Embed(source="../../../../../images/signs/png/R3-9g.png")] protected var sgnR3_9g:Class
		[Embed(source="../../../../../images/signs/png/R3-9h.png")] protected var sgnR3_9h:Class
		[Embed(source="../../../../../images/signs/png/R3-9i.png")] protected var sgnR3_9i:Class
		[Embed(source="../../../../../images/signs/png/R4-1.png")] protected var sgnR4_1:Class
		[Embed(source="../../../../../images/signs/png/R4-10.png")] protected var sgnR4_10:Class
		[Embed(source="../../../../../images/signs/png/R4-12.png")] protected var sgnR4_12:Class
		[Embed(source="../../../../../images/signs/png/R4-13.png")] protected var sgnR4_13:Class
		[Embed(source="../../../../../images/signs/png/R4-14.png")] protected var sgnR4_14:Class
		[Embed(source="../../../../../images/signs/png/R4-16.png")] protected var sgnR4_16:Class
		[Embed(source="../../../../../images/signs/png/R4-17.png")] protected var sgnR4_17:Class
		[Embed(source="../../../../../images/signs/png/R4-18.png")] protected var sgnR4_18:Class
		[Embed(source="../../../../../images/signs/png/R4-2.png")] protected var sgnR4_2:Class
		[Embed(source="../../../../../images/signs/png/R4-3.png")] protected var sgnR4_3:Class
		[Embed(source="../../../../../images/signs/png/R4-5.png")] protected var sgnR4_5:Class
		[Embed(source="../../../../../images/signs/png/R4-7.png")] protected var sgnR4_7:Class
		[Embed(source="../../../../../images/signs/png/R4-7a.png")] protected var sgnR4_7a:Class
		[Embed(source="../../../../../images/signs/png/R4-7b.png")] protected var sgnR4_7b:Class
		[Embed(source="../../../../../images/signs/png/R4-7c.png")] protected var sgnR4_7c:Class
		[Embed(source="../../../../../images/signs/png/R4-8.png")] protected var sgnR4_8:Class
		[Embed(source="../../../../../images/signs/png/R4-8a.png")] protected var sgnR4_8a:Class
		[Embed(source="../../../../../images/signs/png/R4-8b.png")] protected var sgnR4_8b:Class
		[Embed(source="../../../../../images/signs/png/R4-8c.png")] protected var sgnR4_8c:Class
		[Embed(source="../../../../../images/signs/png/R4-9.png")] protected var sgnR4_9:Class
		[Embed(source="../../../../../images/signs/png/R5-1.png")] protected var sgnR5_1:Class
		[Embed(source="../../../../../images/signs/png/R5-10a.png")] protected var sgnR5_10a:Class
		[Embed(source="../../../../../images/signs/png/R5-10b.png")] protected var sgnR5_10b:Class
		[Embed(source="../../../../../images/signs/png/R5-10c.png")] protected var sgnR5_10c:Class
		[Embed(source="../../../../../images/signs/png/R5-11.png")] protected var sgnR5_11:Class
		[Embed(source="../../../../../images/signs/png/R5-1a.png")] protected var sgnR5_1a:Class
		[Embed(source="../../../../../images/signs/png/R5-2.png")] protected var sgnR5_2:Class
		[Embed(source="../../../../../images/signs/png/R5-3.png")] protected var sgnR5_3:Class
		[Embed(source="../../../../../images/signs/png/R5-4.png")] protected var sgnR5_4:Class
		[Embed(source="../../../../../images/signs/png/R5-5.png")] protected var sgnR5_5:Class
		[Embed(source="../../../../../images/signs/png/R5-6.png")] protected var sgnR5_6:Class
		[Embed(source="../../../../../images/signs/png/R5-7.png")] protected var sgnR5_7:Class
		[Embed(source="../../../../../images/signs/png/R5-8.png")] protected var sgnR5_8:Class
		[Embed(source="../../../../../images/signs/png/R6-1.png")] protected var sgnR6_1:Class
		[Embed(source="../../../../../images/signs/png/R6-2.png")] protected var sgnR6_2:Class
		[Embed(source="../../../../../images/signs/png/R6-3.png")] protected var sgnR6_3:Class
		[Embed(source="../../../../../images/signs/png/R6-3a.png")] protected var sgnR6_3a:Class
		[Embed(source="../../../../../images/signs/png/R6-4.png")] protected var sgnR6_4:Class
		[Embed(source="../../../../../images/signs/png/R6-4a.png")] protected var sgnR6_4a:Class
		[Embed(source="../../../../../images/signs/png/R6-4b.png")] protected var sgnR6_4b:Class
		[Embed(source="../../../../../images/signs/png/R6-5p.png")] protected var sgnR6_5p:Class
		[Embed(source="../../../../../images/signs/png/R6-6.png")] protected var sgnR6_6:Class
		[Embed(source="../../../../../images/signs/png/R6-7.png")] protected var sgnR6_7:Class
		[Embed(source="../../../../../images/signs/png/R7-1.png")] protected var sgnR7_1:Class
		[Embed(source="../../../../../images/signs/png/R7-107.png")] protected var sgnR7_107:Class
		[Embed(source="../../../../../images/signs/png/R7-107a.png")] protected var sgnR7_107a:Class
		[Embed(source="../../../../../images/signs/png/R7-108.png")] protected var sgnR7_108:Class
		[Embed(source="../../../../../images/signs/png/R7-2.png")] protected var sgnR7_2:Class
		[Embed(source="../../../../../images/signs/png/R7-20.png")] protected var sgnR7_20:Class
		[Embed(source="../../../../../images/signs/png/R7-200.png")] protected var sgnR7_200:Class
		[Embed(source="../../../../../images/signs/png/R7-200a.png")] protected var sgnR7_200a:Class
		[Embed(source="../../../../../images/signs/png/R7-201aP.png")] protected var sgnR7_201aP:Class
		[Embed(source="../../../../../images/signs/png/R7-201P.png")] protected var sgnR7_201P:Class
		[Embed(source="../../../../../images/signs/png/R7-202P.png")] protected var sgnR7_202P:Class
		[Embed(source="../../../../../images/signs/png/R7-203.png")] protected var sgnR7_203:Class
		[Embed(source="../../../../../images/signs/png/R7-21.png")] protected var sgnR7_21:Class
		[Embed(source="../../../../../images/signs/png/R7-21a.png")] protected var sgnR7_21a:Class
		[Embed(source="../../../../../images/signs/png/R7-22.png")] protected var sgnR7_22:Class
		[Embed(source="../../../../../images/signs/png/R7-23.png")] protected var sgnR7_23:Class
		[Embed(source="../../../../../images/signs/png/R7-23a.png")] protected var sgnR7_23a:Class
		[Embed(source="../../../../../images/signs/png/R7-2a.png")] protected var sgnR7_2a:Class
		[Embed(source="../../../../../images/signs/png/R7-3.png")] protected var sgnR7_3:Class
		[Embed(source="../../../../../images/signs/png/R7-4.png")] protected var sgnR7_4:Class
		[Embed(source="../../../../../images/signs/png/R7-5.png")] protected var sgnR7_5:Class
		[Embed(source="../../../../../images/signs/png/R7-6.png")] protected var sgnR7_6:Class
		[Embed(source="../../../../../images/signs/png/R7-7.png")] protected var sgnR7_7:Class
		[Embed(source="../../../../../images/signs/png/R7-8.png")] protected var sgnR7_8:Class
		[Embed(source="../../../../../images/signs/png/R8-1.png")] protected var sgnR8_1:Class
		[Embed(source="../../../../../images/signs/png/R8-2.png")] protected var sgnR8_2:Class
		[Embed(source="../../../../../images/signs/png/R8-3.png")] protected var sgnR8_3:Class
		[Embed(source="../../../../../images/signs/png/R8-3a.png")] protected var sgnR8_3a:Class
		[Embed(source="../../../../../images/signs/png/R8-3bP.png")] protected var sgnR8_3bP:Class
		[Embed(source="../../../../../images/signs/png/R8-3cP.png")] protected var sgnR8_3cP:Class
		[Embed(source="../../../../../images/signs/png/R8-3dP.png")] protected var sgnR8_3dP:Class
		[Embed(source="../../../../../images/signs/png/R8-3eP.png")] protected var sgnR8_3eP:Class
		[Embed(source="../../../../../images/signs/png/R8-3fP.png")] protected var sgnR8_3fP:Class
		[Embed(source="../../../../../images/signs/png/R8-3gP.png")] protected var sgnR8_3gP:Class
		[Embed(source="../../../../../images/signs/png/R8-3hP.png")] protected var sgnR8_3hP:Class
		[Embed(source="../../../../../images/signs/png/R8-4.png")] protected var sgnR8_4:Class
		[Embed(source="../../../../../images/signs/png/R8-5.png")] protected var sgnR8_5:Class
		[Embed(source="../../../../../images/signs/png/R8-6.png")] protected var sgnR8_6:Class
		[Embed(source="../../../../../images/signs/png/R8-7.png")] protected var sgnR8_7:Class
		[Embed(source="../../../../../images/signs/png/R9-1.png")] protected var sgnR9_1:Class
		[Embed(source="../../../../../images/signs/png/R9-13.png")] protected var sgnR9_13:Class
		[Embed(source="../../../../../images/signs/png/R9-14.png")] protected var sgnR9_14:Class
		[Embed(source="../../../../../images/signs/png/R9-2.png")] protected var sgnR9_2:Class
		[Embed(source="../../../../../images/signs/png/R9-3.png")] protected var sgnR9_3:Class
		[Embed(source="../../../../../images/signs/png/R9-3a.png")] protected var sgnR9_3a:Class
		[Embed(source="../../../../../images/signs/png/R9-3bP.png")] protected var sgnR9_3bP:Class
		[Embed(source="../../../../../images/signs/png/R9-4.png")] protected var sgnR9_4:Class
		[Embed(source="../../../../../images/signs/png/R9-4a.png")] protected var sgnR9_4a:Class
		[Embed(source="../../../../../images/signs/png/W1-1.png")] protected var sgnW1_1:Class
		[Embed(source="../../../../../images/signs/png/W1-10.png")] protected var sgnW1_10:Class
		[Embed(source="../../../../../images/signs/png/W1-10a.png")] protected var sgnW1_10a:Class
		[Embed(source="../../../../../images/signs/png/W1-10b.png")] protected var sgnW1_10b:Class
		[Embed(source="../../../../../images/signs/png/W1-10c.png")] protected var sgnW1_10c:Class
		[Embed(source="../../../../../images/signs/png/W1-10d.png")] protected var sgnW1_10d:Class
		[Embed(source="../../../../../images/signs/png/W1-10e.png")] protected var sgnW1_10e:Class
		[Embed(source="../../../../../images/signs/png/W1-11.png")] protected var sgnW1_11:Class
		[Embed(source="../../../../../images/signs/png/W1-13.png")] protected var sgnW1_13:Class
		[Embed(source="../../../../../images/signs/png/W1-15.png")] protected var sgnW1_15:Class
		[Embed(source="../../../../../images/signs/png/W1-1a.png")] protected var sgnW1_1a:Class
		[Embed(source="../../../../../images/signs/png/W1-2.png")] protected var sgnW1_2:Class
		[Embed(source="../../../../../images/signs/png/W1-2a.png")] protected var sgnW1_2a:Class
		[Embed(source="../../../../../images/signs/png/W1-3.png")] protected var sgnW1_3:Class
		[Embed(source="../../../../../images/signs/png/W1-4.png")] protected var sgnW1_4:Class
		[Embed(source="../../../../../images/signs/png/W1-5.png")] protected var sgnW1_5:Class
		[Embed(source="../../../../../images/signs/png/W1-6.png")] protected var sgnW1_6:Class
		[Embed(source="../../../../../images/signs/png/W1-7.png")] protected var sgnW1_7:Class
		[Embed(source="../../../../../images/signs/png/W1-8.png")] protected var sgnW1_8:Class
		[Embed(source="../../../../../images/signs/png/W11-1.png")] protected var sgnW11_1:Class
		[Embed(source="../../../../../images/signs/png/W11-10.png")] protected var sgnW11_10:Class
		[Embed(source="../../../../../images/signs/png/W11-11.png")] protected var sgnW11_11:Class
		[Embed(source="../../../../../images/signs/png/W11-12P.png")] protected var sgnW11_12P:Class
		[Embed(source="../../../../../images/signs/png/W11-14.png")] protected var sgnW11_14:Class
		[Embed(source="../../../../../images/signs/png/W11-15.png")] protected var sgnW11_15:Class
		[Embed(source="../../../../../images/signs/png/W11-15a.png")] protected var sgnW11_15a:Class
		[Embed(source="../../../../../images/signs/png/W11-15P.png")] protected var sgnW11_15P:Class
		[Embed(source="../../../../../images/signs/png/W11-16.png")] protected var sgnW11_16:Class
		[Embed(source="../../../../../images/signs/png/W11-17.png")] protected var sgnW11_17:Class
		[Embed(source="../../../../../images/signs/png/W11-18.png")] protected var sgnW11_18:Class
		[Embed(source="../../../../../images/signs/png/W11-19.png")] protected var sgnW11_19:Class
		[Embed(source="../../../../../images/signs/png/W11-2.png")] protected var sgnW11_2:Class
		[Embed(source="../../../../../images/signs/png/W11-20.png")] protected var sgnW11_20:Class
		[Embed(source="../../../../../images/signs/png/W11-21.png")] protected var sgnW11_21:Class
		[Embed(source="../../../../../images/signs/png/W11-22.png")] protected var sgnW11_22:Class
		[Embed(source="../../../../../images/signs/png/W11-3.png")] protected var sgnW11_3:Class
		[Embed(source="../../../../../images/signs/png/W11-4.png")] protected var sgnW11_4:Class
		[Embed(source="../../../../../images/signs/png/W11-5.png")] protected var sgnW11_5:Class
		[Embed(source="../../../../../images/signs/png/W11-5a.png")] protected var sgnW11_5a:Class
		[Embed(source="../../../../../images/signs/png/W11-6.png")] protected var sgnW11_6:Class
		[Embed(source="../../../../../images/signs/png/W11-7.png")] protected var sgnW11_7:Class
		[Embed(source="../../../../../images/signs/png/W11-8.png")] protected var sgnW11_8:Class
		[Embed(source="../../../../../images/signs/png/W11-9.png")] protected var sgnW11_9:Class
		[Embed(source="../../../../../images/signs/png/W12-1.png")] protected var sgnW12_1:Class
		[Embed(source="../../../../../images/signs/png/W12-2.png")] protected var sgnW12_2:Class
		[Embed(source="../../../../../images/signs/png/W12-2a.png")] protected var sgnW12_2a:Class
		[Embed(source="../../../../../images/signs/png/W13-1P.png")] protected var sgnW13_1P:Class
		[Embed(source="../../../../../images/signs/png/W13-2.png")] protected var sgnW13_2:Class
		[Embed(source="../../../../../images/signs/png/W13-3.png")] protected var sgnW13_3:Class
		[Embed(source="../../../../../images/signs/png/W13-6.png")] protected var sgnW13_6:Class
		[Embed(source="../../../../../images/signs/png/W13-7.png")] protected var sgnW13_7:Class
		[Embed(source="../../../../../images/signs/png/W14-1.png")] protected var sgnW14_1:Class
		[Embed(source="../../../../../images/signs/png/W14-1a.png")] protected var sgnW14_1a:Class
		[Embed(source="../../../../../images/signs/png/W14-2.png")] protected var sgnW14_2:Class
		[Embed(source="../../../../../images/signs/png/W14-2a.png")] protected var sgnW14_2a:Class
		[Embed(source="../../../../../images/signs/png/W14-3.png")] protected var sgnW14_3:Class
		[Embed(source="../../../../../images/signs/png/W15-1.png")] protected var sgnW15_1:Class
		[Embed(source="../../../../../images/signs/png/W16-10aP.png")] protected var sgnW16_10aP:Class
		[Embed(source="../../../../../images/signs/png/W16-10P.png")] protected var sgnW16_10P:Class
		[Embed(source="../../../../../images/signs/png/W16-12P.png")] protected var sgnW16_12P:Class
		[Embed(source="../../../../../images/signs/png/W16-13P.png")] protected var sgnW16_13P:Class
		[Embed(source="../../../../../images/signs/png/W16-15P.png")] protected var sgnW16_15P:Class
		[Embed(source="../../../../../images/signs/png/W16-17P.png")] protected var sgnW16_17P:Class
		[Embed(source="../../../../../images/signs/png/W16-18P.png")] protected var sgnW16_18P:Class
		[Embed(source="../../../../../images/signs/png/W16-1P.png")] protected var sgnW16_1P:Class
		[Embed(source="../../../../../images/signs/png/W16-2aP.png")] protected var sgnW16_2aP:Class
		[Embed(source="../../../../../images/signs/png/W16-2P.png")] protected var sgnW16_2P:Class
		[Embed(source="../../../../../images/signs/png/W16-3aP.png")] protected var sgnW16_3aP:Class
		[Embed(source="../../../../../images/signs/png/W16-3P.png")] protected var sgnW16_3P:Class
		[Embed(source="../../../../../images/signs/png/W16-4P.png")] protected var sgnW16_4P:Class
		[Embed(source="../../../../../images/signs/png/W16-5P.png")] protected var sgnW16_5P:Class
		[Embed(source="../../../../../images/signs/png/W16-6P.png")] protected var sgnW16_6P:Class
		[Embed(source="../../../../../images/signs/png/W16-7P.png")] protected var sgnW16_7P:Class
		[Embed(source="../../../../../images/signs/png/W16-8aP.png")] protected var sgnW16_8aP:Class
		[Embed(source="../../../../../images/signs/png/W16-8P.png")] protected var sgnW16_8P:Class
		[Embed(source="../../../../../images/signs/png/W16-9P.png")] protected var sgnW16_9P:Class
		[Embed(source="../../../../../images/signs/png/W17-1.png")] protected var sgnW17_1:Class
		[Embed(source="../../../../../images/signs/png/W19-1.png")] protected var sgnW19_1:Class
		[Embed(source="../../../../../images/signs/png/W19-2.png")] protected var sgnW19_2:Class
		[Embed(source="../../../../../images/signs/png/W19-3.png")] protected var sgnW19_3:Class
		[Embed(source="../../../../../images/signs/png/W19-4.png")] protected var sgnW19_4:Class
		[Embed(source="../../../../../images/signs/png/W19-5.png")] protected var sgnW19_5:Class
		[Embed(source="../../../../../images/signs/png/W2-1.png")] protected var sgnW2_1:Class
		[Embed(source="../../../../../images/signs/png/W2-2.png")] protected var sgnW2_2:Class
		[Embed(source="../../../../../images/signs/png/W2-3.png")] protected var sgnW2_3:Class
		[Embed(source="../../../../../images/signs/png/W2-4.png")] protected var sgnW2_4:Class
		[Embed(source="../../../../../images/signs/png/W2-5.png")] protected var sgnW2_5:Class
		[Embed(source="../../../../../images/signs/png/W2-6.png")] protected var sgnW2_6:Class
		[Embed(source="../../../../../images/signs/png/W2-7L.png")] protected var sgnW2_7L:Class
		[Embed(source="../../../../../images/signs/png/W2-7R.png")] protected var sgnW2_7R:Class
		[Embed(source="../../../../../images/signs/png/W2-8.png")] protected var sgnW2_8:Class
		[Embed(source="../../../../../images/signs/png/W23-2.png")] protected var sgnW23_2:Class
		[Embed(source="../../../../../images/signs/png/W25-1.png")] protected var sgnW25_1:Class
		[Embed(source="../../../../../images/signs/png/W25-2.png")] protected var sgnW25_2:Class
		[Embed(source="../../../../../images/signs/png/W3-1.png")] protected var sgnW3_1:Class
		[Embed(source="../../../../../images/signs/png/W3-2.png")] protected var sgnW3_2:Class
		[Embed(source="../../../../../images/signs/png/W3-3.png")] protected var sgnW3_3:Class
		[Embed(source="../../../../../images/signs/png/W3-4.png")] protected var sgnW3_4:Class
		[Embed(source="../../../../../images/signs/png/W3-5.png")] protected var sgnW3_5:Class
		[Embed(source="../../../../../images/signs/png/W3-5a.png")] protected var sgnW3_5a:Class
		[Embed(source="../../../../../images/signs/png/W3-6.png")] protected var sgnW3_6:Class
		[Embed(source="../../../../../images/signs/png/W3-7.png")] protected var sgnW3_7:Class
		[Embed(source="../../../../../images/signs/png/W3-8.png")] protected var sgnW3_8:Class
		[Embed(source="../../../../../images/signs/png/W4-1.png")] protected var sgnW4_1:Class
		[Embed(source="../../../../../images/signs/png/W4-2.png")] protected var sgnW4_2:Class
		[Embed(source="../../../../../images/signs/png/W4-3.png")] protected var sgnW4_3:Class
		[Embed(source="../../../../../images/signs/png/W4-4aP.png")] protected var sgnW4_4aP:Class
		[Embed(source="../../../../../images/signs/png/W4-4bP.png")] protected var sgnW4_4bP:Class
		[Embed(source="../../../../../images/signs/png/W4-4P.png")] protected var sgnW4_4P:Class
		[Embed(source="../../../../../images/signs/png/W4-5.png")] protected var sgnW4_5:Class
		[Embed(source="../../../../../images/signs/png/W4-5P.png")] protected var sgnW4_5P:Class
		[Embed(source="../../../../../images/signs/png/W4-6.png")] protected var sgnW4_6:Class
		[Embed(source="../../../../../images/signs/png/W5-1.png")] protected var sgnW5_1:Class
		[Embed(source="../../../../../images/signs/png/W5-2.png")] protected var sgnW5_2:Class
		[Embed(source="../../../../../images/signs/png/W5-3.png")] protected var sgnW5_3:Class
		[Embed(source="../../../../../images/signs/png/W6-1.png")] protected var sgnW6_1:Class
		[Embed(source="../../../../../images/signs/png/W6-2.png")] protected var sgnW6_2:Class
		[Embed(source="../../../../../images/signs/png/W6-3.png")] protected var sgnW6_3:Class
		[Embed(source="../../../../../images/signs/png/W7-1.png")] protected var sgnW7_1:Class
		[Embed(source="../../../../../images/signs/png/W7-1a.png")] protected var sgnW7_1a:Class
		[Embed(source="../../../../../images/signs/png/W7-2bP.png")] protected var sgnW7_2bP:Class
		[Embed(source="../../../../../images/signs/png/W7-2P.png")] protected var sgnW7_2P:Class
		[Embed(source="../../../../../images/signs/png/W7-3aP.png")] protected var sgnW7_3aP:Class
		[Embed(source="../../../../../images/signs/png/W7-3bP.png")] protected var sgnW7_3bP:Class
		[Embed(source="../../../../../images/signs/png/W7-3P.png")] protected var sgnW7_3P:Class
		[Embed(source="../../../../../images/signs/png/W7-4.png")] protected var sgnW7_4:Class
		[Embed(source="../../../../../images/signs/png/W7-4b.png")] protected var sgnW7_4b:Class
		[Embed(source="../../../../../images/signs/png/W7-4c.png")] protected var sgnW7_4c:Class
		[Embed(source="../../../../../images/signs/png/W7-4dP.png")] protected var sgnW7_4dP:Class
		[Embed(source="../../../../../images/signs/png/W7-4eP.png")] protected var sgnW7_4eP:Class
		[Embed(source="../../../../../images/signs/png/W7-4fP.png")] protected var sgnW7_4fP:Class
		[Embed(source="../../../../../images/signs/png/W7-6.png")] protected var sgnW7_6:Class
		[Embed(source="../../../../../images/signs/png/W8-1.png")] protected var sgnW8_1:Class
		[Embed(source="../../../../../images/signs/png/W8-11.png")] protected var sgnW8_11:Class
		[Embed(source="../../../../../images/signs/png/W8-12.png")] protected var sgnW8_12:Class
		[Embed(source="../../../../../images/signs/png/W8-13.png")] protected var sgnW8_13:Class
		[Embed(source="../../../../../images/signs/png/W8-14.png")] protected var sgnW8_14:Class
		[Embed(source="../../../../../images/signs/png/W8-15.png")] protected var sgnW8_15:Class
		[Embed(source="../../../../../images/signs/png/W8-15P.png")] protected var sgnW8_15P:Class
		[Embed(source="../../../../../images/signs/png/W8-16.png")] protected var sgnW8_16:Class
		[Embed(source="../../../../../images/signs/png/W8-17.png")] protected var sgnW8_17:Class
		[Embed(source="../../../../../images/signs/png/W8-17P.png")] protected var sgnW8_17P:Class
		[Embed(source="../../../../../images/signs/png/W8-18.png")] protected var sgnW8_18:Class
		[Embed(source="../../../../../images/signs/png/W8-19.png")] protected var sgnW8_19:Class
		[Embed(source="../../../../../images/signs/png/W8-2.png")] protected var sgnW8_2:Class
		[Embed(source="../../../../../images/signs/png/W8-21.png")] protected var sgnW8_21:Class
		[Embed(source="../../../../../images/signs/png/W8-22.png")] protected var sgnW8_22:Class
		[Embed(source="../../../../../images/signs/png/W8-23.png")] protected var sgnW8_23:Class
		[Embed(source="../../../../../images/signs/png/W8-25.png")] protected var sgnW8_25:Class
		[Embed(source="../../../../../images/signs/png/W8-3.png")] protected var sgnW8_3:Class
		[Embed(source="../../../../../images/signs/png/W8-4.png")] protected var sgnW8_4:Class
		[Embed(source="../../../../../images/signs/png/W8-5.png")] protected var sgnW8_5:Class
		[Embed(source="../../../../../images/signs/png/W8-5aP.png")] protected var sgnW8_5aP:Class
		[Embed(source="../../../../../images/signs/png/W8-5bP.png")] protected var sgnW8_5bP:Class
		[Embed(source="../../../../../images/signs/png/W8-5cP.png")] protected var sgnW8_5cP:Class
		[Embed(source="../../../../../images/signs/png/W8-5P.png")] protected var sgnW8_5P:Class
		[Embed(source="../../../../../images/signs/png/W8-6.png")] protected var sgnW8_6:Class
		[Embed(source="../../../../../images/signs/png/W8-7.png")] protected var sgnW8_7:Class
		[Embed(source="../../../../../images/signs/png/W8-8.png")] protected var sgnW8_8:Class
		[Embed(source="../../../../../images/signs/png/W8-9.png")] protected var sgnW8_9:Class
		[Embed(source="../../../../../images/signs/png/W9-1.png")] protected var sgnW9_1:Class
		[Embed(source="../../../../../images/signs/png/W9-2.png")] protected var sgnW9_2:Class
		[Embed(source="../../../../../images/signs/png/W9-7.png")] protected var sgnW9_7:Class
		
		
		private var button:Button;
		private var mateDispatcher:Dispatcher = new Dispatcher();
		private var stickGroup:Group = new Group();
		private var gpsGroup:Group = new Group();
		private var invGroup:Group= new Group();
		private var vGroup:VGroup = new VGroup();
		private var signDrpDown:DropDownList;
		private var drpDown: List;
		private var BtnList:ArrayCollection;
		private var cbMP:Number;
		private var cbType:String;
		private var txtBoxOpen:Boolean;
		private var openTextBox:TextInput;
		private var cbScroller:Scroller;
		private var sgnArray:ArrayList = new ArrayList();
		private var popUp:SkinnablePopUpContainer=new SkinnablePopUpContainer();
		private var dispatcher:IEventDispatcher;
		private var valX:Label = new Label();
		private var valY:Label = new Label();
		private var valPrecision:Label = new Label();
		
		
		
		public function SignInvCaptureBar()
		{
			clearContainer();
			super();
			//			this.width = 200;
			//			this.height = 700;
			this.percentHeight = 100;
			this.percentWidth = 100;
			vGroup.percentHeight = 100;
			vGroup.percentWidth = 100;
			
			var sVL:VerticalLayout = new VerticalLayout();
			sVL.horizontalAlign = "center";
			stickGroup.layout = sVL;
			stickGroup.percentHeight = 34;
			stickGroup.percentWidth = 100;
			
			var iVL:VerticalLayout = new VerticalLayout();
			iVL.horizontalAlign = "center";
			invGroup.layout = iVL;
			invGroup.percentHeight = 33;
			invGroup.percentWidth = 100;
			
			var gVL:VerticalLayout = new VerticalLayout();
			gVL.horizontalAlign = "center";
			gpsGroup.layout = gVL;
			gpsGroup.percentHeight = 33;
			gpsGroup.percentWidth = 100;
			
			
			sgnArray.addItem(getBMI(sgnR1_1 as Image));
			sgnArray.addItem(getBMI(sgnR1_10P));
			sgnArray.addItem(getBMI(sgnR1_2));
			sgnArray.addItem(getBMI(sgnR1_2aP));
			sgnArray.addItem(getBMI(sgnR1_3P));
			sgnArray.addItem(getBMI(sgnR1_5));
			sgnArray.addItem(getBMI(sgnR1_5a));
			sgnArray.addItem(getBMI(sgnR1_5b));
			sgnArray.addItem(getBMI(sgnR1_5c));
			sgnArray.addItem(getBMI(sgnR1_6));
			sgnArray.addItem(getBMI(sgnR1_6a));
			sgnArray.addItem(getBMI(sgnR1_9));
			sgnArray.addItem(getBMI(sgnR1_9a));
			sgnArray.addItem(getBMI(sgnR10_1));
			sgnArray.addItem(getBMI(sgnR10_10));
			sgnArray.addItem(getBMI(sgnR10_11));
			sgnArray.addItem(getBMI(sgnR10_11a));
			sgnArray.addItem(getBMI(sgnR10_11b));
			sgnArray.addItem(getBMI(sgnR10_11c));
			sgnArray.addItem(getBMI(sgnR10_11d));
			sgnArray.addItem(getBMI(sgnR10_12));
			sgnArray.addItem(getBMI(sgnR10_13));
			sgnArray.addItem(getBMI(sgnR10_14));
			sgnArray.addItem(getBMI(sgnR10_14a));
			sgnArray.addItem(getBMI(sgnR10_15));
			sgnArray.addItem(getBMI(sgnR10_16));
			sgnArray.addItem(getBMI(sgnR10_17a));
			sgnArray.addItem(getBMI(sgnR10_18));
			sgnArray.addItem(getBMI(sgnR10_19aP));
			sgnArray.addItem(getBMI(sgnR10_19P));
			sgnArray.addItem(getBMI(sgnR10_2));
			sgnArray.addItem(getBMI(sgnR10_20aP));
			sgnArray.addItem(getBMI(sgnR10_23));
			sgnArray.addItem(getBMI(sgnR10_25));
			sgnArray.addItem(getBMI(sgnR10_27));
			sgnArray.addItem(getBMI(sgnR10_28));
			sgnArray.addItem(getBMI(sgnR10_29));
			sgnArray.addItem(getBMI(sgnR10_3));
			sgnArray.addItem(getBMI(sgnR10_30));
			sgnArray.addItem(getBMI(sgnR10_31P));
			sgnArray.addItem(getBMI(sgnR10_32P));
			sgnArray.addItem(getBMI(sgnR10_3a));
			sgnArray.addItem(getBMI(sgnR10_3b));
			sgnArray.addItem(getBMI(sgnR10_3c));
			sgnArray.addItem(getBMI(sgnR10_3d));
			sgnArray.addItem(getBMI(sgnR10_3e));
			sgnArray.addItem(getBMI(sgnR10_3f));
			sgnArray.addItem(getBMI(sgnR10_3g));
			sgnArray.addItem(getBMI(sgnR10_3h));
			sgnArray.addItem(getBMI(sgnR10_3i));
			sgnArray.addItem(getBMI(sgnR10_4));
			sgnArray.addItem(getBMI(sgnR10_4a));
			sgnArray.addItem(getBMI(sgnR10_5));
			sgnArray.addItem(getBMI(sgnR10_6));
			sgnArray.addItem(getBMI(sgnR10_6a));
			sgnArray.addItem(getBMI(sgnR10_7));
			sgnArray.addItem(getBMI(sgnR10_8));
			sgnArray.addItem(getBMI(sgnR11_1));
			sgnArray.addItem(getBMI(sgnR11_2));
			sgnArray.addItem(getBMI(sgnR11_3a));
			sgnArray.addItem(getBMI(sgnR11_3b));
			sgnArray.addItem(getBMI(sgnR11_4));
			sgnArray.addItem(getBMI(sgnR12_1));
			sgnArray.addItem(getBMI(sgnR12_2));
			sgnArray.addItem(getBMI(sgnR12_3));
			sgnArray.addItem(getBMI(sgnR12_4));
			sgnArray.addItem(getBMI(sgnR12_5));
			sgnArray.addItem(getBMI(sgnR13_1));
			sgnArray.addItem(getBMI(sgnR14_1));
			sgnArray.addItem(getBMI(sgnR14_2));
			sgnArray.addItem(getBMI(sgnR14_3));
			sgnArray.addItem(getBMI(sgnR14_4));
			sgnArray.addItem(getBMI(sgnR14_5));
			sgnArray.addItem(getBMI(sgnR16_10));
			sgnArray.addItem(getBMI(sgnR16_11));
			sgnArray.addItem(getBMI(sgnR16_4));
			sgnArray.addItem(getBMI(sgnR16_5));
			sgnArray.addItem(getBMI(sgnR16_6));
			sgnArray.addItem(getBMI(sgnR16_7));
			sgnArray.addItem(getBMI(sgnR16_8));
			sgnArray.addItem(getBMI(sgnR16_9));
			sgnArray.addItem(getBMI(sgnR2_1));
			sgnArray.addItem(getBMI(sgnR2_10));
			sgnArray.addItem(getBMI(sgnR2_11));
			sgnArray.addItem(getBMI(sgnR2_2P));
			sgnArray.addItem(getBMI(sgnR2_3P));
			sgnArray.addItem(getBMI(sgnR2_4a));
			sgnArray.addItem(getBMI(sgnR2_4P));
			sgnArray.addItem(getBMI(sgnR2_5aP));
			sgnArray.addItem(getBMI(sgnR2_5bP));
			sgnArray.addItem(getBMI(sgnR2_5cP));
			sgnArray.addItem(getBMI(sgnR2_5P));
			sgnArray.addItem(getBMI(sgnR2_6aP));
			sgnArray.addItem(getBMI(sgnR2_6bP));
			sgnArray.addItem(getBMI(sgnR2_6P));
			sgnArray.addItem(getBMI(sgnR3_1));
			sgnArray.addItem(getBMI(sgnR3_18));
			sgnArray.addItem(getBMI(sgnR3_2));
			sgnArray.addItem(getBMI(sgnR3_20L));
			sgnArray.addItem(getBMI(sgnR3_20R));
			sgnArray.addItem(getBMI(sgnR3_23));
			sgnArray.addItem(getBMI(sgnR3_23a));
			sgnArray.addItem(getBMI(sgnR3_24));
			sgnArray.addItem(getBMI(sgnR3_24a));
			sgnArray.addItem(getBMI(sgnR3_24b));
			sgnArray.addItem(getBMI(sgnR3_25));
			sgnArray.addItem(getBMI(sgnR3_25a));
			sgnArray.addItem(getBMI(sgnR3_25b));
			sgnArray.addItem(getBMI(sgnR3_26));
			sgnArray.addItem(getBMI(sgnR3_26a));
			sgnArray.addItem(getBMI(sgnR3_27));
			sgnArray.addItem(getBMI(sgnR3_3));
			sgnArray.addItem(getBMI(sgnR3_33));
			sgnArray.addItem(getBMI(sgnR3_4));
			sgnArray.addItem(getBMI(sgnR3_5));
			sgnArray.addItem(getBMI(sgnR3_5a));
			sgnArray.addItem(getBMI(sgnR3_5bP));
			sgnArray.addItem(getBMI(sgnR3_5cP));
			sgnArray.addItem(getBMI(sgnR3_5dP));
			sgnArray.addItem(getBMI(sgnR3_5eP));
			sgnArray.addItem(getBMI(sgnR3_5fP));
			sgnArray.addItem(getBMI(sgnR3_5gP));
			sgnArray.addItem(getBMI(sgnR3_6));
			sgnArray.addItem(getBMI(sgnR3_7));
			sgnArray.addItem(getBMI(sgnR3_8));
			sgnArray.addItem(getBMI(sgnR3_8a));
			sgnArray.addItem(getBMI(sgnR3_8b));
			sgnArray.addItem(getBMI(sgnR3_9a));
			sgnArray.addItem(getBMI(sgnR3_9b));
			sgnArray.addItem(getBMI(sgnR3_9cP));
			sgnArray.addItem(getBMI(sgnR3_9dP));
			sgnArray.addItem(getBMI(sgnR3_9e));
			sgnArray.addItem(getBMI(sgnR3_9f));
			sgnArray.addItem(getBMI(sgnR3_9g));
			sgnArray.addItem(getBMI(sgnR3_9h));
			sgnArray.addItem(getBMI(sgnR3_9i));
			sgnArray.addItem(getBMI(sgnR4_1));
			sgnArray.addItem(getBMI(sgnR4_10));
			sgnArray.addItem(getBMI(sgnR4_12));
			sgnArray.addItem(getBMI(sgnR4_13));
			sgnArray.addItem(getBMI(sgnR4_14));
			sgnArray.addItem(getBMI(sgnR4_16));
			sgnArray.addItem(getBMI(sgnR4_17));
			sgnArray.addItem(getBMI(sgnR4_18));
			sgnArray.addItem(getBMI(sgnR4_2));
			sgnArray.addItem(getBMI(sgnR4_3));
			sgnArray.addItem(getBMI(sgnR4_5));
			sgnArray.addItem(getBMI(sgnR4_7));
			sgnArray.addItem(getBMI(sgnR4_7a));
			sgnArray.addItem(getBMI(sgnR4_7b));
			sgnArray.addItem(getBMI(sgnR4_7c));
			sgnArray.addItem(getBMI(sgnR4_8));
			sgnArray.addItem(getBMI(sgnR4_8a));
			sgnArray.addItem(getBMI(sgnR4_8b));
			sgnArray.addItem(getBMI(sgnR4_8c));
			sgnArray.addItem(getBMI(sgnR4_9));
			sgnArray.addItem(getBMI(sgnR5_1));
			sgnArray.addItem(getBMI(sgnR5_10a));
			sgnArray.addItem(getBMI(sgnR5_10b));
			sgnArray.addItem(getBMI(sgnR5_10c));
			sgnArray.addItem(getBMI(sgnR5_11));
			sgnArray.addItem(getBMI(sgnR5_1a));
			sgnArray.addItem(getBMI(sgnR5_2));
			sgnArray.addItem(getBMI(sgnR5_3));
			sgnArray.addItem(getBMI(sgnR5_4));
			sgnArray.addItem(getBMI(sgnR5_5));
			sgnArray.addItem(getBMI(sgnR5_6));
			sgnArray.addItem(getBMI(sgnR5_7));
			sgnArray.addItem(getBMI(sgnR5_8));
			sgnArray.addItem(getBMI(sgnR6_1));
			sgnArray.addItem(getBMI(sgnR6_2));
			sgnArray.addItem(getBMI(sgnR6_3));
			sgnArray.addItem(getBMI(sgnR6_3a));
			sgnArray.addItem(getBMI(sgnR6_4));
			sgnArray.addItem(getBMI(sgnR6_4a));
			sgnArray.addItem(getBMI(sgnR6_4b));
			sgnArray.addItem(getBMI(sgnR6_5p));
			sgnArray.addItem(getBMI(sgnR6_6));
			sgnArray.addItem(getBMI(sgnR6_7));
			sgnArray.addItem(getBMI(sgnR7_1));
			sgnArray.addItem(getBMI(sgnR7_107));
			sgnArray.addItem(getBMI(sgnR7_107a));
			sgnArray.addItem(getBMI(sgnR7_108));
			sgnArray.addItem(getBMI(sgnR7_2));
			sgnArray.addItem(getBMI(sgnR7_20));
			sgnArray.addItem(getBMI(sgnR7_200));
			sgnArray.addItem(getBMI(sgnR7_200a));
			sgnArray.addItem(getBMI(sgnR7_201aP));
			sgnArray.addItem(getBMI(sgnR7_201P));
			sgnArray.addItem(getBMI(sgnR7_202P));
			sgnArray.addItem(getBMI(sgnR7_203));
			sgnArray.addItem(getBMI(sgnR7_21));
			sgnArray.addItem(getBMI(sgnR7_21a));
			sgnArray.addItem(getBMI(sgnR7_22));
			sgnArray.addItem(getBMI(sgnR7_23));
			sgnArray.addItem(getBMI(sgnR7_23a));
			sgnArray.addItem(getBMI(sgnR7_2a));
			sgnArray.addItem(getBMI(sgnR7_3));
			sgnArray.addItem(getBMI(sgnR7_4));
			sgnArray.addItem(getBMI(sgnR7_5));
			sgnArray.addItem(getBMI(sgnR7_6));
			sgnArray.addItem(getBMI(sgnR7_7));
			sgnArray.addItem(getBMI(sgnR7_8));
			sgnArray.addItem(getBMI(sgnR8_1));
			sgnArray.addItem(getBMI(sgnR8_2));
			sgnArray.addItem(getBMI(sgnR8_3));
			sgnArray.addItem(getBMI(sgnR8_3a));
			sgnArray.addItem(getBMI(sgnR8_3bP));
			sgnArray.addItem(getBMI(sgnR8_3cP));
			sgnArray.addItem(getBMI(sgnR8_3dP));
			sgnArray.addItem(getBMI(sgnR8_3eP));
			sgnArray.addItem(getBMI(sgnR8_3fP));
			sgnArray.addItem(getBMI(sgnR8_3gP));
			sgnArray.addItem(getBMI(sgnR8_3hP));
			sgnArray.addItem(getBMI(sgnR8_4));
			sgnArray.addItem(getBMI(sgnR8_5));
			sgnArray.addItem(getBMI(sgnR8_6));
			sgnArray.addItem(getBMI(sgnR8_7));
			sgnArray.addItem(getBMI(sgnR9_1));
			sgnArray.addItem(getBMI(sgnR9_13));
			sgnArray.addItem(getBMI(sgnR9_14));
			sgnArray.addItem(getBMI(sgnR9_2));
			sgnArray.addItem(getBMI(sgnR9_3));
			sgnArray.addItem(getBMI(sgnR9_3a));
			sgnArray.addItem(getBMI(sgnR9_3bP));
			sgnArray.addItem(getBMI(sgnR9_4));
			sgnArray.addItem(getBMI(sgnR9_4a));
			sgnArray.addItem(getBMI(sgnW1_1));
			sgnArray.addItem(getBMI(sgnW1_10));
			sgnArray.addItem(getBMI(sgnW1_10a));
			sgnArray.addItem(getBMI(sgnW1_10b));
			sgnArray.addItem(getBMI(sgnW1_10c));
			sgnArray.addItem(getBMI(sgnW1_10d));
			sgnArray.addItem(getBMI(sgnW1_10e));
			sgnArray.addItem(getBMI(sgnW1_11));
			sgnArray.addItem(getBMI(sgnW1_13));
			sgnArray.addItem(getBMI(sgnW1_15));
			sgnArray.addItem(getBMI(sgnW1_1a));
			sgnArray.addItem(getBMI(sgnW1_2));
			sgnArray.addItem(getBMI(sgnW1_2a));
			sgnArray.addItem(getBMI(sgnW1_3));
			sgnArray.addItem(getBMI(sgnW1_4));
			sgnArray.addItem(getBMI(sgnW1_5));
			sgnArray.addItem(getBMI(sgnW1_6));
			sgnArray.addItem(getBMI(sgnW1_7));
			sgnArray.addItem(getBMI(sgnW1_8));
			sgnArray.addItem(getBMI(sgnW11_1));
			sgnArray.addItem(getBMI(sgnW11_10));
			sgnArray.addItem(getBMI(sgnW11_11));
			sgnArray.addItem(getBMI(sgnW11_12P));
			sgnArray.addItem(getBMI(sgnW11_14));
			sgnArray.addItem(getBMI(sgnW11_15));
			sgnArray.addItem(getBMI(sgnW11_15a));
			sgnArray.addItem(getBMI(sgnW11_15P));
			sgnArray.addItem(getBMI(sgnW11_16));
			sgnArray.addItem(getBMI(sgnW11_17));
			sgnArray.addItem(getBMI(sgnW11_18));
			sgnArray.addItem(getBMI(sgnW11_19));
			sgnArray.addItem(getBMI(sgnW11_2));
			sgnArray.addItem(getBMI(sgnW11_20));
			sgnArray.addItem(getBMI(sgnW11_21));
			sgnArray.addItem(getBMI(sgnW11_22));
			sgnArray.addItem(getBMI(sgnW11_3));
			sgnArray.addItem(getBMI(sgnW11_4));
			sgnArray.addItem(getBMI(sgnW11_5));
			sgnArray.addItem(getBMI(sgnW11_5a));
			sgnArray.addItem(getBMI(sgnW11_6));
			sgnArray.addItem(getBMI(sgnW11_7));
			sgnArray.addItem(getBMI(sgnW11_8));
			sgnArray.addItem(getBMI(sgnW11_9));
			sgnArray.addItem(getBMI(sgnW12_1));
			sgnArray.addItem(getBMI(sgnW12_2));
			sgnArray.addItem(getBMI(sgnW12_2a));
			sgnArray.addItem(getBMI(sgnW13_1P));
			sgnArray.addItem(getBMI(sgnW13_2));
			sgnArray.addItem(getBMI(sgnW13_3));
			sgnArray.addItem(getBMI(sgnW13_6));
			sgnArray.addItem(getBMI(sgnW13_7));
			sgnArray.addItem(getBMI(sgnW14_1));
			sgnArray.addItem(getBMI(sgnW14_1a));
			sgnArray.addItem(getBMI(sgnW14_2));
			sgnArray.addItem(getBMI(sgnW14_2a));
			sgnArray.addItem(getBMI(sgnW14_3));
			sgnArray.addItem(getBMI(sgnW15_1));
			sgnArray.addItem(getBMI(sgnW16_10aP));
			sgnArray.addItem(getBMI(sgnW16_10P));
			sgnArray.addItem(getBMI(sgnW16_12P));
			sgnArray.addItem(getBMI(sgnW16_13P));
			sgnArray.addItem(getBMI(sgnW16_15P));
			sgnArray.addItem(getBMI(sgnW16_17P));
			sgnArray.addItem(getBMI(sgnW16_18P));
			sgnArray.addItem(getBMI(sgnW16_1P));
			sgnArray.addItem(getBMI(sgnW16_2aP));
			sgnArray.addItem(getBMI(sgnW16_2P));
			sgnArray.addItem(getBMI(sgnW16_3aP));
			sgnArray.addItem(getBMI(sgnW16_3P));
			sgnArray.addItem(getBMI(sgnW16_4P));
			sgnArray.addItem(getBMI(sgnW16_5P));
			sgnArray.addItem(getBMI(sgnW16_6P));
			sgnArray.addItem(getBMI(sgnW16_7P));
			sgnArray.addItem(getBMI(sgnW16_8aP));
			sgnArray.addItem(getBMI(sgnW16_8P));
			sgnArray.addItem(getBMI(sgnW16_9P));
			sgnArray.addItem(getBMI(sgnW17_1));
			sgnArray.addItem(getBMI(sgnW19_1));
			sgnArray.addItem(getBMI(sgnW19_2));
			sgnArray.addItem(getBMI(sgnW19_3));
			sgnArray.addItem(getBMI(sgnW19_4));
			sgnArray.addItem(getBMI(sgnW19_5));
			sgnArray.addItem(getBMI(sgnW2_1));
			sgnArray.addItem(getBMI(sgnW2_2));
			sgnArray.addItem(getBMI(sgnW2_3));
			sgnArray.addItem(getBMI(sgnW2_4));
			sgnArray.addItem(getBMI(sgnW2_5));
			sgnArray.addItem(getBMI(sgnW2_6));
			sgnArray.addItem(getBMI(sgnW2_7L));
			sgnArray.addItem(getBMI(sgnW2_7R));
			sgnArray.addItem(getBMI(sgnW2_8));
			sgnArray.addItem(getBMI(sgnW23_2));
			sgnArray.addItem(getBMI(sgnW25_1));
			sgnArray.addItem(getBMI(sgnW25_2));
			sgnArray.addItem(getBMI(sgnW3_1));
			sgnArray.addItem(getBMI(sgnW3_2));
			sgnArray.addItem(getBMI(sgnW3_3));
			sgnArray.addItem(getBMI(sgnW3_4));
			sgnArray.addItem(getBMI(sgnW3_5));
			sgnArray.addItem(getBMI(sgnW3_5a));
			sgnArray.addItem(getBMI(sgnW3_6));
			sgnArray.addItem(getBMI(sgnW3_7));
			sgnArray.addItem(getBMI(sgnW3_8));
			sgnArray.addItem(getBMI(sgnW4_1));
			sgnArray.addItem(getBMI(sgnW4_2));
			sgnArray.addItem(getBMI(sgnW4_3));
			sgnArray.addItem(getBMI(sgnW4_4aP));
			sgnArray.addItem(getBMI(sgnW4_4bP));
			sgnArray.addItem(getBMI(sgnW4_4P));
			sgnArray.addItem(getBMI(sgnW4_5));
			sgnArray.addItem(getBMI(sgnW4_5P));
			sgnArray.addItem(getBMI(sgnW4_6));
			sgnArray.addItem(getBMI(sgnW5_1));
			sgnArray.addItem(getBMI(sgnW5_2));
			sgnArray.addItem(getBMI(sgnW5_3));
			sgnArray.addItem(getBMI(sgnW6_1));
			sgnArray.addItem(getBMI(sgnW6_2));
			sgnArray.addItem(getBMI(sgnW6_3));
			sgnArray.addItem(getBMI(sgnW7_1));
			sgnArray.addItem(getBMI(sgnW7_1a));
			sgnArray.addItem(getBMI(sgnW7_2bP));
			sgnArray.addItem(getBMI(sgnW7_2P));
			sgnArray.addItem(getBMI(sgnW7_3aP));
			sgnArray.addItem(getBMI(sgnW7_3bP));
			sgnArray.addItem(getBMI(sgnW7_3P));
			sgnArray.addItem(getBMI(sgnW7_4));
			sgnArray.addItem(getBMI(sgnW7_4b));
			sgnArray.addItem(getBMI(sgnW7_4c));
			sgnArray.addItem(getBMI(sgnW7_4dP));
			sgnArray.addItem(getBMI(sgnW7_4eP));
			sgnArray.addItem(getBMI(sgnW7_4fP));
			sgnArray.addItem(getBMI(sgnW7_6));
			sgnArray.addItem(getBMI(sgnW8_1));
			sgnArray.addItem(getBMI(sgnW8_11));
			sgnArray.addItem(getBMI(sgnW8_12));
			sgnArray.addItem(getBMI(sgnW8_13));
			sgnArray.addItem(getBMI(sgnW8_14));
			sgnArray.addItem(getBMI(sgnW8_15));
			sgnArray.addItem(getBMI(sgnW8_15P));
			sgnArray.addItem(getBMI(sgnW8_16));
			sgnArray.addItem(getBMI(sgnW8_17));
			sgnArray.addItem(getBMI(sgnW8_17P));
			sgnArray.addItem(getBMI(sgnW8_18));
			sgnArray.addItem(getBMI(sgnW8_19));
			sgnArray.addItem(getBMI(sgnW8_2));
			sgnArray.addItem(getBMI(sgnW8_21));
			sgnArray.addItem(getBMI(sgnW8_22));
			sgnArray.addItem(getBMI(sgnW8_23));
			sgnArray.addItem(getBMI(sgnW8_25));
			sgnArray.addItem(getBMI(sgnW8_3));
			sgnArray.addItem(getBMI(sgnW8_4));
			sgnArray.addItem(getBMI(sgnW8_5));
			sgnArray.addItem(getBMI(sgnW8_5aP));
			sgnArray.addItem(getBMI(sgnW8_5bP));
			sgnArray.addItem(getBMI(sgnW8_5cP));
			sgnArray.addItem(getBMI(sgnW8_5P));
			sgnArray.addItem(getBMI(sgnW8_6));
			sgnArray.addItem(getBMI(sgnW8_7));
			sgnArray.addItem(getBMI(sgnW8_8));
			sgnArray.addItem(getBMI(sgnW8_9));
			sgnArray.addItem(getBMI(sgnW9_1));
			sgnArray.addItem(getBMI(sgnW9_2));
			sgnArray.addItem(getBMI(sgnW9_7));
			
		}
		
		private function getBMI(img:Object):BitmapImage
		{
			var tmpBMI:BitmapImage = new BitmapImage();
			tmpBMI.source = img;
			return tmpBMI;
		}
		
		//once settings file is loaded and config manager is populated, add buttons and dropdown lists for each capture items found in the button list
		public function draw(btnClickHandler:Function):void{
			clearContainer();
			this.addChild(vGroup);
			vGroup.addElement(stickGroup);
			vGroup.addElement(invGroup);
			vGroup.addElement(gpsGroup);
			
			
			BtnList =new ArrayCollection(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.CaptureBarBtnList);
			for(var i:int; i< BtnList.length; i++)
			{
				button = new Button();
				button.buttonMode = true;
				button.useHandCursor = true;
				button.addEventListener(MouseEvent.CLICK, btnClickHandler);
				button.width = 150;
				button.height = 30;
				button.x = 20;
				
				button.label = BtnList.getItemAt(i).button;
				//var aList:ArrayList = getDP(BtnList.getItemAt(i).button);
				//var aList:ArrayList = getDP(BtnList.getItemAt(i).dataarray);
				var aList:ArrayList = sgnArray;
				
			
				
				if (aList != null)
				{
					drpDown = new List();
					drpDown.width = 150;
					drpDown.height = 30;
					drpDown.x = button.x;
					
					drpDown.buttonMode = true;
					drpDown.useHandCursor = true;
					drpDown.requireSelection=true;
					drpDown.labelField="label";
					//drpDown.setStyle("skinClass", SignImageDropDownListSkin);
					drpDown.itemRenderer = new ClassFactory(DefaultComplexItemRenderer);
					drpDown.name = "DRP_DOWN_" + String(BtnList.getItemAt(i).button).toUpperCase().replace(" ","");
					drpDown.dataProvider = aList;
					drpDown.addEventListener(MouseEvent.CLICK,drpDownChangeHandler);
				}
				
				if(BtnList.getItemAt(i).section == "stick" && aList != null)
				{
					button.y =  (button.height +15 )*i;
					drpDown.y =  button.y;
					button.addEventListener(MouseEvent.CLICK,captureStickBtnClickHandler);
					stickGroup.addElement(drpDown);
					stickGroup.addElement(button);
				}
				else if (BtnList.getItemAt(i).section == "inv" && aList != null)
				{
					button.y =  (button.height +27 )*i +45;
					drpDown.y =  button.y;
					button.addEventListener(MouseEvent.CLICK,captureInvBtnClickHandler);
					invGroup.addElement(drpDown);
					invGroup.addElement(button);
				}
				else if (BtnList.getItemAt(i).section == "stick" && aList == null)
				{
					button.y =  (button.height +15 )*i;
					//					drpDown.y =  button.y;
					button.addEventListener(MouseEvent.CLICK,captureStickBtnClickHandler);
					//					parentApplication.addElement(textInp);
					stickGroup.addElement(button);
				}
				else if (BtnList.getItemAt(i).section == "inv" && aList == null)
				{
					button.y =  (button.height +27 )*i +45;
					//					drpDown.y =  button.y;
					button.addEventListener(MouseEvent.CLICK,captureInvBtnClickHandler);
					//					parentApplication.addElement(textInp);
					invGroup.addElement(button);
				}
			}
			
			
			// Add GPS display elements
			//var gpsGroup:VGroup = new VGroup();
			//stickGroup.addElement(gpsGroup);
			
			/*var gpsBorder:Rect = new Rect();
			gpsBorder.visible = true;
			gpsBorder.x = 5;
			gpsBorder.y = 330;
			gpsBorder.width = 160;
			gpsBorder.height = 150;*/
			
			/*gpsBorder.setStyle("borderColor",0xffff00);
			gpsBorder.setStyle("backgroundAlpha",0);
			gpsBorder.setStyle("contentBackgroundAlpha",0);
			gpsBorder.setStyle("borderVisible",false);*/
			//gpsGroup.addElement(gpsBorder);
			
			
			
			this.graphics.beginFill(0xcccccc,1);
			this.graphics.drawRoundRect(5,325,185,140,20,20);
			this.graphics.endFill();
			
			
			var lblX:Label = new Label();
			lblX.text = "Longitude Dude : ";
			lblX.visible = true;
			lblX.height = 30;
			lblX.width = 85;
			lblX.x = 10;
			lblX.y = 350;
			
			valX.id = "longVal";
			valX.text = "";
			valX.width = 75;
			valX.height = 30;
			valX.visible = true;
			valX.x = 115;
			valX.y = 350;
			
			gpsGroup.addElement(lblX);
			gpsGroup.addElement(valX);
			
			
			
			var lblY:Label = new Label();
			lblY.text = "Latitude : ";
			lblY.visible = true;
			lblY.width = 75;
			lblY.height = 30;
			lblY.x = 10;
			lblY.y = 385;
			
			valY.id = "latVal";
			valY.text = "";
			valY.visible = true;
			valY.width = 75;
			valY.height = 30;
			valY.x = 115;
			valY.y = 385
				
			
			gpsGroup.addElement(lblY);
			gpsGroup.addElement(valY);
			
			var lblPrecision:Label = new Label();
			if (FlexGlobals.topLevelApplication.useInternalGPS)
				lblPrecision.text = "Precision(M) : ";
			else
				lblPrecision.text = "PDOP : ";
			lblPrecision.visible = true;
			lblPrecision.width = 100;
			lblPrecision.height = 30;
			lblPrecision.x = 10;
			lblPrecision.y = 420;
			
			valPrecision.id = "precVal";
			valPrecision.text = "";
			valPrecision.visible = true;
			valPrecision.width = 75;
			valPrecision.height = 30;
			valPrecision.x = 115;
			valPrecision.y = 420
			
			
			gpsGroup.addElement(lblPrecision);
			gpsGroup.addElement(valPrecision);
			
			
		}
	
		
		private function getDP(dataarray:String):ArrayList{
			//name = name.toLowerCase().replace(/\s+/g,"");
			
			var obj:Object = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.settingsAC.getItemAt(0);
			var retVal:ArrayList = null;
			for (var prop:String in obj)
			{
				//Alert.show(prop.toString() + " : " + obj[prop]);
				if (prop == dataarray)
					retVal = new ArrayList(obj[prop]);
			}
			
			
			return retVal;
		}
		
		private function captureStickBtnClickHandler(event:MouseEvent):void{
			if(txtBoxOpen)
			{
				parentApplication.removeElement(openTextBox);
				txtBoxOpen = false;
				openTextBox = null;
			}
			var drpDwn:List;
			var lbl:String = String(event.target.label).toUpperCase().replace(" ","");
			
			drpDwn = stickGroup.getChildByName("DRP_DOWN_"+lbl) as List;
			popUp.setStyle("skinClass",TSSSkinnablePopUpContainerSkin);
			
			if (lbl=="CULVERT")
			{
				var gbLoc:Number = FlexGlobals.topLevelApplication.GlobalComponents.stkDiagram.currentMPoint();
				var inForm:InventoryMenu=InventoryMenu(PopUpManager.createPopUp(this,InventoryMenu,true));
				inForm.x=100;
				inForm.y=5;
				
				//PopUpManager.centerPopUp(inForm);
			}
			else if(lbl=="ACCESSPOINT"){
				popUp = new SkinnablePopUpContainer();
				popUp.setStyle("skinClass",TSSSkinnablePopUpContainerSkin);
				popUp.width=100;
				popUp.height=150;
				popUp.name="ACCESS POINT Types";
				var type1301:RadioButton=new RadioButton;
				var layout:VerticalLayout=new VerticalLayout();
				popUp.layout=layout;
				type1301.label="Type one";
				var type1302:RadioButton=new RadioButton;
				type1302.label="Type two";
				popUp.addElement(type1301);
				popUp.addElement(type1302);
				var button:Button=new Button();
				button.label="OK";
				button.addEventListener(MouseEvent.CLICK,handleAccessPoint);
				popUp.addElement(button);
				popUp.open(this,false);
				PopUpManager.centerPopUp(popUp);
				
				
				
				
				
				
			}
			
			
			else if (drpDwn)
			{
				/*var gcEvent:GestureControlEvent = new GestureControlEvent(GestureControlEvent.CHANGED);
				gcEvent.gestures = false;
				dispatchEvent(gcEvent);*/
				//				drpDwn.width = 250;
				//drpDwn.openDropDown();
				popUp = new SkinnablePopUpContainer();
				popUp.setStyle("skinClass",TSSSkinnablePopUpContainerSkin);
				popUp.name=lbl;
				popUp.width=350;
				popUp.height=550;
				drpDwn.width=300;
				drpDwn.height=500;
				popUp.addElement(drpDwn);
				PopUpManager.centerPopUp(popUp);
				popUp.open(this,false);
			
				txtBoxOpen = false;
				openTextBox = null;
			}
			else
			{
				var	txtInp:TextInput = new TextInput();
				txtInp.width = 100;
				txtInp.height = 30;
				txtInp.y =  event.target.y+71;
				txtInp.x = event.target.x + event.target.width + 10;
				txtInp.name = "TXT_INP_" + lbl;
				
				txtInp.addEventListener(FlexEvent.ENTER,textInputHandler);
				txtBoxOpen = true;
				openTextBox = txtInp;
				parentApplication.addElement(txtInp);
			}
		}
		//************ACCESS POINT EVENT***************
		private function handleAccessPoint(event:MouseEvent):void{
			
			var button:Button=event.target as Button;
			trace(button.label);
			var type:Number;
			var a:RadioButton=popUp.getElementAt(0) as RadioButton;
			var b:RadioButton=popUp.getElementAt(1) as RadioButton;
			if(a.selected){
				type=1301;
				
			}
			else if(b.selected){
				type=1300;
				
			}
			if(type){
				var apEvent:AccessPointEvent=new AccessPointEvent(AccessPointEvent.NEWACCESSPOINT,true,true);
				apEvent.apType=type;
				dispatchEvent(apEvent);
			}
			popUp.close(false,null);
			popUp.removeAllElements();
			
		}
		
		private function captureInvBtnClickHandler(event:MouseEvent):void{
		
			if(txtBoxOpen)
			{
				parentApplication.removeElement(openTextBox);
				txtBoxOpen = false;
				openTextBox = null;
			}
			var drpDwn:List;
			var lbl:String = String(event.target.label).toUpperCase().replace(" ","");
			
			drpDwn=  invGroup.getChildByName("DRP_DOWN_"+lbl) as List;
			if (drpDwn)
			{
				/*var gcEvent:GestureControlEvent = new GestureControlEvent(GestureControlEvent.CHANGED);
				gcEvent.gestures = false;
				dispatchEvent(gcEvent);*/
				popUp.width=300;
				popUp.height=500;
				drpDwn.width=300;
				drpDwn.height=500;
				popUp.addElement(drpDwn);
				
				PopUpManager.centerPopUp(popUp);
				popUp.open(this,false);
				txtBoxOpen = false;
				openTextBox = null;
			}
			else
			{
				var	txtInp:TextInput = new TextInput();
				txtInp.width = 100;
				txtInp.height = 30;
				txtInp.y =   event.target.y+71;
				txtInp.x = event.target.x + event.target.width+10;
				txtInp.name = "TXT_INP_" + lbl;
				
				txtInp.addEventListener(FlexEvent.ENTER,textInputHandler);
				txtBoxOpen = true;
				openTextBox = txtInp;
				parentApplication.addElement(txtInp);
			}
		}
		
		/*	private function handleListSelection(event:IndexChangedEvent):void
		{
		var tmpEvent:DataEventEvent = new DataEventEvent(DataEventEvent.NEWPOINTEVENT, true, true);
		tmpEvent.datatype = 1;
		dispatchEvent(tmpEvent);
		}*/
		
		public function hideTooltip(e:MouseEvent):void
		{
			
		}
		
		
		
		//When the capture bar dropdown value changes
		//save the record in local and draw new element on the diagram
		private function drpDownChangeHandler(event:MouseEvent):void{
			
			
			var tmpEvent:SignInvEvent;
			var list:List=popUp.getElementAt(0) as List;
			tmpEvent = new SignInvEvent(SignInvEvent.NEWSIGNEVENT, true, true);
			tmpEvent.img = list.selectedItem;
			tmpEvent.mutcd = list.selectedItem.id;
			dispatchEvent(tmpEvent);
			list.selectedIndex = 0;
			popUp.close(true,null);
			
			//type from currentCaptureType
			//milepoint from currentCaptureMP
			//event.stopPropagation();
			/*var gcEvent:GestureControlEvent = new GestureControlEvent(GestureControlEvent.CHANGED);
			gcEvent.gestures = true;
			dispatchEvent(gcEvent);*/
		}
		
		//will be called when FlexEvent.ENTER occurs in the textbox
		//TODO: how will the enter event be captured in Xoom
		private function textInputHandler(event:FlexEvent):void{
			
			var txtInput:TextInput = event.target as TextInput;
			var text:String=txtInput.text;
			trace(text);
			//type from currentCaptureType
			//milepoint from currentCaptureMP
		}
		
		public function triangulateMouseUp(event:MouseEvent):void{
			if(txtBoxOpen && event.target != openTextBox)
			{
				parentApplication.removeElement(openTextBox);
				txtBoxOpen = false;
				openTextBox = null;
			}
		}
		public function set currentCaptureMP(mp:Number):void{
			cbMP=mp;
		}
		public function get currentCaptureMP():Number{
			return cbMP;
		}
		public function set currentCaptureType(typ:String):void{
			cbType=typ;
		}
		public function get currentCaptureType():String{
			return cbType;
		}
		
		public function clearContainer():void{
			stickGroup.removeAllElements();
			invGroup.removeAllElements();
			// clear all children of container
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
		
		public function handleGPSChange(evt:GPSEvent):void
		{
			valX.text = evt.x.toString().substr(0,9);
			valY.text = evt.y.toString().substr(0,8);
			valPrecision.text = evt.precision.toString();
		}
		

			
	}
}