package
{
	import mx.resources.ResourceManager;

	[ResourceBundle("settings")]
	public class ConfigUtility
	{
		public static function get(param:String):String
		{
			var str:String = ResourceManager.getInstance().getString("settings", param);
			return str ? str : "";
		}
		
		public static function getInt(param:String):int
		{
			var val:int = parseInt(ResourceManager.getInstance().getString("settings", param));
			return val;
		}
		
		public static function getNumber(param:String):Number
		{
			var val:Number = parseFloat(ResourceManager.getInstance().getString("settings", param));
			return val;
		}
		
		public static function getBool(param:String):Boolean
		{
			var val:Boolean = ResourceManager.getInstance().getString("settings", param) == "true" ? true : false;
			return val;
		}
	}
}