package skins
{
	/** An optional skin class for the TitleWindow component  **/
	import spark.skins.spark.TitleWindowSkin;
	public class HeaderlessTitleWindow extends TitleWindowSkin
	{
		public function HeaderlessTitleWindow()
		{
			super();
			topGroup.includeInLayout = false;


		}
	}
}
