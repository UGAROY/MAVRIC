package com.transcendss.mavric.util
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;

	public class ArrayColUtil
	{
		public function ArrayColUtil()
		{
			
			
		}
		
		/**
		 *Compares two arraycollections. Returns true or false 
		 * @param arrayCol1
		 * @param arrayCol2
		 * @return 
		 * 
		 */
		public static function compare(arrayCol1:ArrayCollection, arrayCol2:ArrayCollection):Boolean
		{
			if(arrayCol1 == null || arrayCol2 == null)
				return false;
			if(arrayCol1.length != arrayCol2.length)
				return false;
			for (var i:uint = 0; i < arrayCol1.length ; i++)
			{
				if (ObjectUtil.compare(arrayCol1[i], arrayCol2[i]) != 0)
					return false;
			}
			return true;
		}
		
		
		/**
		 *Source: http://kuttikumar.wordpress.com/2009/06/07/flex-removing-duplicates-from-an-arraycollection-filter-function/
		 * .Filters out the duplicates preserving order.
		 * @param ArrColl:ArrayCollection
		 * 
		 */
		public function filterCollection(ArrColl:ArrayCollection):void {
			// assign the filter function
			ArrColl.filterFunction = removeDuplicates;
			//refresh the collection
			ArrColl.refresh();
		}
		
		/**
		 * Source: http://kuttikumar.wordpress.com/2009/06/07/flex-removing-duplicates-from-an-arraycollection-filter-function/
		 * .Filter function for filterCollection. Filters out the duplicates preserving order.
		 * @param item
		 * @return 
		 * 
		 */
		private function removeDuplicates(item:Object):Boolean {
			// the return value
			var retVal:Boolean = false;
			var tempObj:Object = {};
			
			// check the items in the itemObj Ojbect to see if it contains the value being tested
			if (!tempObj.hasOwnProperty(item.label)) {
				// if not found add the item to the object
				tempObj[item.label] = item;
				retVal = true;
			}
			return retVal;
		}
		
		
		/**
		 *Source: Internet
		 * takes an AC and the filters out all duplicate entries, but no order preservation
		 * @param collection
		 * @return 
		 * 
		 */
		public function getUniqueValues (collection : ArrayCollection) : ArrayCollection {
			
			var length : Number = collection.length;
			var dic :Dictionary = new Dictionary();
			
			//this should be whatever type of object you have inside your AC
			var value : Object;
			for(var i : Number = 0; i < length; i++){
				value = collection.getItemAt(i).DESCRIPTION;
				dic[value] = collection.getItemAt(i);
			}
			
			//this bit goes through the dictionary and puts data into a new AC
			var unique:ArrayCollection = new ArrayCollection();
			for(var prop :String in dic){
				unique.addItem(dic[prop]);
			}
			return unique;
		}
	}
}