package com.transcendss.mavric.extended.models
{
	import com.transcendss.mavric.events.AccessPointEvent;
	
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.controls.Spacer;
	import mx.core.FlexGlobals;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.RadioButton;
	import spark.components.SkinnablePopUpContainer;
	import spark.components.TextInput;
	import spark.components.VGroup;
	import spark.formatters.NumberFormatter;
	
	public class AccessPointPopup extends SkinnablePopUpContainer
	{
		private var radioButtons: Vector.<RadioButton> = new Vector.<RadioButton>(); 
		private var formatter:NumberFormatter;
		private var leftBtn : RadioButton;
		private var rightBtn : RadioButton;
		
		public function AccessPointPopup()
		{
			super();
			formatter = new NumberFormatter();
			formatter.fractionalDigits = 2;
			
			parseDataTemplate();
		}
		
		private function parseDataTemplate():void
		{
			var meFile:File = File.applicationDirectory.resolvePath(ConfigUtility.get("access_point_popup_template"));
			
			var fs:FileStream = new FileStream();
			fs.open(meFile, FileMode.READ);
			
			var jsonString : String = fs.readUTFBytes(fs.bytesAvailable);
			var jsonObj:Object = JSON.parse(jsonString);
			
			height = jsonObj.DATA_ENTRY_TEMPLATE.HEIGHT;
			width = jsonObj.DATA_ENTRY_TEMPLATE.WIDTH;
			
			var groups : Array;
			var group:Group;
			var tabs : Array = jsonObj.DATA_ENTRY_TEMPLATE.TABS as Array;
			
			//For every Group within the viewStack
			for(var ti : int = 0; ti < tabs.length; ti++)
			{
				// the var groups does NOT represent the array of panels
				groups = tabs[ti].GROUPS as Array;
				group = new Group();
				
				var vg:VGroup;
				//For every VGroup within a Group
				for(var i : int = 0; i < groups.length; i++)
				{
					var groupObj : Object = groups[i];
					
					// Defining each VGroup
					vg = new VGroup();
					
					var hg:HGroup; 
					var controls : Array = groupObj.CONTROLS as Array; 
					
					//For every control (HGroup) within a VGroup
					for(var j : int = 0; j < controls.length; j++)
					{
						hg = new HGroup();
						hg.verticalAlign = "middle";
						var label :Label = new Label();
						label.text = controls[j].LABEL + ":";
						label.setStyle("fontWeight", "bold");
						

						
						hg.addElement(label);
						//This series of conditionals determines what type of input component to create
						if(controls[j].TYPE === "TextInput")
						{
							var txtInp:TextInput = new TextInput();
							txtInp.id = controls[j].ID;
							if(controls[j].TIWidth != null)
							{
								txtInp.widthInChars = controls[j].TIWidth;
								txtInp.percentWidth = 45;
							}
							if(controls[j].EDITABLE != null)
							{
								txtInp.editable = controls[j].EDITABLE;
							}
							if(controls[j].ID === "ROUTE_ID")
							{
								txtInp.text = FlexGlobals.topLevelApplication.GlobalComponents.stkDiagram.route.routeName;
							}else if(controls[j].ID === "MILEPOST")
							{
								txtInp.text = formatter.format(FlexGlobals.topLevelApplication.GlobalComponents.stkDiagram.currentMPoint());
							}
							hg.addElement(txtInp);
						}
						else if(controls[j].TYPE === "RADIO")
						{
							var radioTemp :RadioButton;
							var radioLabel:Label;
							var radioGroup:VGroup = new VGroup();
							var spacer:Spacer = new Spacer();
							spacer.height = 55;
							spacer.percentWidth = 50;
							radioGroup.addElement(spacer);
							var radioH : HGroup = new HGroup();
							var groupLabel : Label = new Label();
							groupLabel.text = controls[j].LABEL;
							for(var k : int = 0; k < controls[j].RADIO_OPTS.length; k++)
							{
								radioTemp = new RadioButton();
								radioLabel = new Label();
								
								radioLabel.text = controls[j].RADIO_OPTS[k];
								radioTemp.name = radioLabel.text;
								radioH.addElement(radioLabel);
								radioH.addElement(radioTemp);
								radioGroup.addElement(radioH);
								
								radioButtons.push(radioTemp);
								
								if(radioLabel.text === "Left")
								{
									leftBtn = radioTemp;
								}else
								{
									rightBtn = radioTemp;
								}
							}
							
							hg.addElement(radioGroup);
						}
						else if(controls[j].TYPE === "BUTTON")
						{
							var buttonTemp :Button= new Button();
							buttonTemp.name = controls[j].ID;
							buttonTemp.content = controls[j].LABEL;
							buttonTemp.addEventListener(MouseEvent.CLICK,handleAccessPoint);
							hg.addElement(buttonTemp);
							label.text = "";
							hg.horizontalAlign = "center";
						}
						
						
						//Set properties and add elements of the VGroup
						setVGroup(vg, hg, groupObj);
						
					}
					
					group.addElement(vg);
				}
				addElement(group);
			}
			
		}
		private function setVGroup(vg : VGroup, hg:HGroup, groupObj:Object):void
		{
			
			if(vg.numChildren == 0)
			{
				var space : Label = new Label();
				var vgtitle : Label = new Label();
				vgtitle.text = groupObj.TITLE;
				vg.addElement(vgtitle);
				vg.addElement(space);
			}
			
			vg.addElement(hg);
			vg.x = groupObj.X;
			vg.y = groupObj.Y;
			vg.height = groupObj.HEIGHT;
			vg.width = groupObj.WIDTH;
		}
		
		private function handleAccessPoint(event:MouseEvent):void{
			
			//var button:Button=event.target as Button;
			//trace(button.label);
			var type:int = 1300;
			var typeSelected:Boolean = false;
			
//			for(var i :int ; i < radioButtons.length && !typeSelected; i++)
//			{
//				if(radioButtons[i].selected)
//				{
//					typeSelected = true;
//					type += i;
//				}
//			}
			if(leftBtn.selected || rightBtn.selected){
				if(leftBtn.selected)
					type = 1301;
				else
					type = 1302;
				var apEvent:AccessPointEvent=new AccessPointEvent(AccessPointEvent.NEWACCESSPOINT,true,true);
				apEvent.apType=type;
				dispatchEvent(apEvent);
			}
			close(false,null);
			removeAllElements();
			
		}
	}
}