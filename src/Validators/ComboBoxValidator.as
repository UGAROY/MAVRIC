package Validators
{
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	public class ComboBoxValidator extends Validator
	{
		public var error:String;
		public var prompt:String;
		
		public function ComboBoxValidator()
		{
			super();
		}
		override protected function doValidation(value:Object):Array
		{
			var resultArray:Array = [];
			if(value as String == prompt || value == null)
			{
				var res:ValidationResult = new ValidationResult(true, "", "",error);
				resultArray.push(res);
			}
			return resultArray;
		}
		
	}
}