package skins
{
	/** An optional skin class for the Panel component  **/
	import spark.skins.spark.PanelSkin;

	public class HeaderlessPanelSkin extends PanelSkin
	{
		public function HeaderlessPanelSkin()
		{
			super();          
			topGroup.includeInLayout = false;	
			
		}
	}
}