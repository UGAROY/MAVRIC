package
{
	import mx.resources.ResourceManager;

	[ResourceBundle("settings")]
	[ResourceBundle("mdot")]
	[ResourceBundle("vdot_arcgis")]
	[ResourceBundle("vdot")]
	[ResourceBundle("okdot")]
	[ResourceBundle("iowa")]
	[ResourceBundle("ddot")]
	public class ConfigUtility
	{
		public static function getResourceName():String
		{
			return ResourceManager.getInstance().getString("settings", "version_name");
		}
		public static function get(param:String):String
		{
			var str:String = ResourceManager.getInstance().getString(getResourceName(), param);
			return str ? str : "";
		}
		
		public static function getInt(param:String):int
		{
			var val:int = parseInt(ResourceManager.getInstance().getString(getResourceName(), param));
			return val;
		}
		
		public static function getNumber(param:String):Number
		{
			var val:Number = parseFloat(ResourceManager.getInstance().getString(getResourceName(), param));
			return val;
		}
		
		public static function getBool(param:String):Boolean
		{
			var val:Boolean = ResourceManager.getInstance().getString(getResourceName(), param) == "true" ? true : false;
			return val;
		}
	}
}