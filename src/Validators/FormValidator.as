package Validators
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.events.ValidationResultEvent;
	import mx.validators.Validator;

	
	
	public class FormValidator extends EventDispatcher
	{
		
		[Bindable]
		public var formIsValid:Boolean = false;
		
		public var validators:Array;
		private var focusedFormControl:DisplayObject;

		public function FormValidator(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function validateForm(event:Event):void
		{
			try{
				focusedFormControl = event.target as DisplayObject;
			
			formIsValid = true;
			
			for each( var validator:Validator in validators )
			validate(validator);
			}
			catch(e:Error){
				trace(e);
			}
			
		}
		
		private function validate(validator:Validator):Boolean
		{
			var validatorSource:DisplayObject = validator.source as DisplayObject;
			var supressEvents:Boolean = validatorSource != focusedFormControl;
			
			var event:ValidationResultEvent = validator.validate(null, supressEvents);
			
			var currentControlIsValid:Boolean = event.type == ValidationResultEvent.VALID;
			
			formIsValid = formIsValid && currentControlIsValid;
			return currentControlIsValid;
		}

	}
}