package com.transcendss.mavric.views.baseViews
{
	import com.transcendss.transcore.events.CameraEvent;
	import com.transcendss.transcore.events.TextMemoEvent;
	import com.transcendss.transcore.events.VoiceEvent;
	import com.transcendss.transcore.events.videoEvent;
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	
	import flash.events.Event;

	public interface IAssetView
	{

	    function removeGeoTag(tssmedia:Object):void;
		function setBaseAsset(legacyValues:BaseAsset):void;
		function handlePicture(event:CameraEvent):void;
		function handleVideo(event:videoEvent):void;
		function handleVoiceMemo(event:VoiceEvent):void;
		function handleTextMemo(event:TextMemoEvent):void;
		function handleCloseEvent(event:Event = null):void;
	}
}