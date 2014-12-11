package com.transcendss.mavric.db
{
	import com.transcendss.mavric.managers.AssetManager;
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	import com.transcendss.transcore.sld.models.components.Culvert;
	import com.transcendss.transcore.sld.models.components.GeoTag;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLSchemaResult;
	import flash.data.SQLStatement;
	import flash.data.SQLTableSchema;
	import flash.errors.SQLError;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.utils.StringUtil;

	public class MAVRICDBManager
	{
		private static var instanceList:Vector.<MAVRICDBManager> = new Vector.<MAVRICDBManager>();
		private static var creationBool:Boolean = false;
		private var sConn:SQLConnection;
		private var sStat:SQLStatement = new SQLStatement();
		private var templates:Object;
		private var primaryKey:String;
		private var invCols:Array;
		private var inspCols:Array;
		
		public function MAVRICDBManager()
		{
			if (!creationBool)
				FlexGlobals.topLevelApplication.TSSAlert("Create not the DBManager from dost constructor, but from thy factory method.");
			
			sConn = new SQLConnection();
			sConn.open(File.applicationStorageDirectory.resolvePath("mavric99.db"));
			setupTables();
			createDdotTables();
			//clearInspectorTable();
			//inspectorDummies(); // PLaceholder for now. To be Removed.
		}
		
		public static function newInstance():MAVRICDBManager
		{
			creationBool = true;
			var mdbm:MAVRICDBManager = new MAVRICDBManager();
			instanceList.push(mdbm);
			creationBool = false;
			return mdbm;
		}
		
		public static function deleteDatabaseFile():void
		{
			try
			{
				for each (var db:MAVRICDBManager in instanceList)
					db.sConn.close();
				var dbFile:File = File.applicationStorageDirectory.resolvePath("mavric99.db");
				dbFile.deleteFile();
				
				for each (var db2:MAVRICDBManager in instanceList)
				{
					db2.sConn = new SQLConnection();
					db2.sConn.open(File.applicationStorageDirectory.resolvePath("mavric99.db"));
					db2.sStat.sqlConnection = db2.sConn;
				}
				
				instanceList[0].setupTables();
				instanceList[0].createDdotTables();
//				instanceList[0].inspectorDummies();
				var assetMan:AssetManager = new AssetManager(); 
			} catch (err:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert(err.message);
			}
		}
		
		// Open the local database and initialize all tables
		private function setupTables():void
		{
			sStat.sqlConnection = sConn;
			
			// Create the schema if it does not already exist
			sStat.text = "CREATE TABLE IF NOT EXISTS CACHED_ROUTES ( id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"route_id TEXT, " + 
				"begin_mile REAL, " +
				"end_mile REAL, " + 
				"content TEXT, " +
				"path TEXT, " +
				"bbox TEXT,"+
				"boundary TEXT);";
			sStat.execute();
			
			sStat.text = "CREATE TABLE IF NOT EXISTS CATEGORIES ( id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"description TEXT, " + 
				"type INTEGER, " +
				"diagram_location INTEGER, " + 
				"cached_route_id INTEGER, " + 
				"data_type INTEGER);";
			sStat.execute();
			
			sStat.text = "CREATE TABLE IF NOT EXISTS TYPES ( id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"category_id INTEGER, " + 
				"value INTEGER, " +
				"description TEXT);";
			sStat.execute();
			
			sStat.text = "CREATE TABLE IF NOT EXISTS EVENTS ( id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"type_id TEXT, " + 
				"begin_milepoint REAL, " +
				"end_milepoint REAL, " + 
				"creation_date DATE);";
			sStat.execute();
			
//			sStat.text = "DROP TABLE GEOTAGS;";
//			sStat.execute();
			
			sStat.text = "CREATE TABLE IF NOT EXISTS GEOTAGS ( id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"asset_type TEXT," +
				"asset_base_id TEXT, "+
				"local_asset_id TEXT, "+
				"is_insp_tag INTEGER, "+
				"cached_route_id TEXT, " + 
				"begin_mile REAL, " +
				"end_mile REAL, " + 
				"image_filename TEXT, " + 
				"video_filename TEXT, " + 
				"voice_filename TEXT, " + 
				"text_memo TEXT," +
				"is_cached integer);";
			sStat.execute();
			
			sStat.text = "CREATE TABLE IF NOT EXISTS DATA_EDITS ( id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"category_id INTEGER, " + 
				"record_id integer, " +
				"text_value TEXT, " + 
				"numeric_value REAL, " + 
				"creation_date DATE);";
			sStat.execute();
			
			sStat.text = "CREATE TABLE IF NOT EXISTS ELEMENTS ( id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"cached_route_id INTEGER, " +
				"diagram_type INTEGER, " +
				"description TEXT, " + 
				"content TEXT);";
			sStat.execute();
			
			sStat.text = "CREATE TABLE IF NOT EXISTS INSPECTORS ( id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"USER_NAME TEXT, BOUNDRY TEXT);";
			sStat.execute();	
			
			//IOWA MAVRIC Tables
			sStat.text = "CREATE TABLE IF NOT EXISTS ACCESS_INV ( ACCESS_INV_ID INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"asset_base_id INTEGER, " +
				"create_dt DATE, " +
				"modify_dt DATE, " + 
				"retire_dt DATE);";
			sStat.execute();	
				
			sStat.text = "CREATE TABLE IF NOT EXISTS CULVERT_DOMAIN ( ACCESS_INV_ID INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"d_id INTEGER, " +
				"d_description TEXT, " +
				"d_type TEXT);";
			sStat.execute();
			
			sStat.text = "CREATE TABLE IF NOT EXISTS ASSET_DOMAIN ( ACCESS_INV_ID INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"d_id TEXT, " +
				"d_description TEXT, " +
				"d_type TEXT," +
				"filter_column_data TEXT);";
			sStat.execute();
			
			
			sStat.text = "CREATE TABLE IF NOT EXISTS MAP_IMAGES ( id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"ROUTE_FULL_NAME TEXT,"+ 
				"BEGIN_MILE REAL, " +
				"END_MILE REAL, " + 
				"MINX REAL, " +
				"MINY REAL, " + 
				"MAXX REAL, " + 
				"MAXY REAL, " +
				"FILE_PREFIX TEXT);";
			sStat.execute();
			
			sStat.text = "CREATE TABLE IF NOT EXISTS DEFAULT_SETTINGS ( " +
				"KEY TEXT," +
				"VALUE TEXT);";
			sStat.execute();
			
			sStat.text = "CREATE TABLE IF NOT EXISTS CACHED_BOUNDARIES ( id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"BOUNDARY_NAME TEXT);";
			sStat.execute();
		}
		
		public function getKeys():ArrayCollection
		{
			sStat.text = "SELECT KEY FROM DEFAULT_SETTINGS";
			sStat.execute();
			var arr:Array = sStat.getResult().data;
			return new ArrayCollection(arr);
		}
		
		public function insertSetting(key:String, value:String):void
		{
			sStat.text = "INSERT INTO DEFAULT_SETTINGS (KEY, VALUE) VALUES('" + key + "', '" + value + "');"
			sStat.execute();
		}
		
		public function updateSetting(key:String, value:String):void
		{
			sStat.text = "UPDATE DEFAULT_SETTINGS SET VALUE='" + value + "' WHERE KEY='" + key + "';";
			sStat.execute();
		}
		
		public function getSettingByKey(key:String):Array
		{
			sStat.text = "SELECT * FROM DEFAULT_SETTINGS WHERE KEY = '" + key + "'";
			sStat.execute();
			
			return sStat.getResult().data;
		}
		
		public function inspectorDummies():void
		{
			sStat.text = "SELECT * from INSPECTORS";
			sStat.execute();
			
			if (sStat.getResult().data == null)
			{
				sStat.text = "INSERT INTO INSPECTORS (USER_NAME) VALUES('MHaubrich');"
				sStat.execute();	
				
				sStat.text = "INSERT INTO INSPECTORS (USER_NAME) VALUES('BRust');"
				sStat.execute();	
			}
		}
//		
		
		public function getInspectors():ArrayCollection
		{
			sStat.text = "SELECT * from INSPECTORS order by USER_NAME";
			sStat.execute();
			
			return new ArrayCollection(sStat.getResult().data);
		}
		
		public function getInspectorsByBoundry(boundry:String):ArrayCollection
		{
			sStat.text = "SELECT * from INSPECTORS where BOUNDRY ='"+boundry+"' or BOUNDRY ='All Divisions' order by USER_NAME";
			sStat.execute();
			
			return new ArrayCollection(sStat.getResult().data);
		}
		
		// Check to see if culvert domain table is populated
		public function isCulvertDomainAvailable():Boolean
		{
			var retVal:Boolean = false;
			sStat.text = "SELECT * from CULVERT_DOMAIN";
			sStat.execute();
			var data:Array = sStat.getResult().data;
			if (data == null)
			{
				return false;
			} else if (data.length > 0)
			{
				retVal = true;
			}
			return retVal;
		}
		
		// Check to see if culvert domain table is populated
		public function isAssetDomainAvailable(dString:String):Boolean
		{
			var retVal:Boolean = false;
			sStat.text = "SELECT * from ASSET_DOMAIN where d_type ='"+dString +"'";
			sStat.execute();
			var data:Array = sStat.getResult().data;
			if (data == null)
			{
				return false;
			} else if (data.length > 0)
			{
				retVal = true;
			}
			return retVal;
		}
		
		// Check to see if guardrail domain table is populated
		public function isGuardrailDomainAvailable():Boolean
		{
			var retVal:Boolean = false;
			sStat.text = "SELECT * from GUARDRAIL_DOMAIN";
			sStat.execute();
			var data:Array = sStat.getResult().data;
			if (data == null)
			{
				return false;
			} else if (data.length > 0)
			{
				retVal = true;
			}
			return retVal;
		}

		// Check to see if inspector table is populated
		public function isUserDomainAvailable():Boolean
		{
			var retVal:Boolean = false;
			sStat.text = "SELECT * from INSPECTORS";
			sStat.execute();
			var data:Array = sStat.getResult().data;
			if (data == null)
			{
				return false;
			} else if (data.length > 0)
			{
				retVal = true;
			}
			return retVal;
		}
		
		public function insertUser(name:String,district:String):void
		{
			sStat.text = "INSERT INTO INSPECTORS (USER_NAME, BOUNDRY) VALUES('"+name+"','"+district+"');"
			sStat.execute();	
			
		}
			
		
		// Populate local domain DB table
		public function insertMapImageRecord(routeName:String, beginMile:Number, endMile:Number, minx:Number, miny:Number, maxx:Number, maxy:Number, filePrefix:String):void
		{
			try
			{
				sStat.text = "INSERT INTO MAP_IMAGES (ROUTE_FULL_NAME, BEGIN_MILE, END_MILE, MINX, MINY, MAXX, MAXY, FILE_PREFIX) " +
					" VALUES('" + routeName + "'," + beginMile + "," + endMile + "," + minx + "," + miny + "," + maxx + "," + maxy + ",'" + filePrefix + "');";
				sStat.execute();
				
			} catch (err:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert(err.message);
			}
			
		}
		
		// Retrieve map image from local DB
		public function getMapImageRecord(routeName:String, beginMile:Number, endMile:Number):Array
		{
			var coords:Array = null;
			try
			{
				sStat.text = "SELECT * from MAP_IMAGES where ROUTE_FULL_NAME = '" + routeName + "' and BEGIN_MILE <= " + beginMile + " and END_MILE >= " + endMile + "";
				sStat.execute();
				var data:Array = sStat.getResult().data;
				
				
				if (data != null && data.length >0)
				{
					coords = new Array();
					coords[0] =	data[0].MINX;
					coords[1] =	data[0].MINY;
					coords[2] =	data[0].MAXX;
					coords[3] =	data[0].MAXY;
					coords[4] = data[0].ROUTE_FULL_NAME;
					coords[5] = data[0].BEGIN_MILE;
					coords[6] = data[0].END_MILE;
					
				}
				
			} catch (err:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert(err.message);
			}
			return coords;
		}
		
		
		
		// Populate local domain DB table
		public function insertDomain(dm:ArrayCollection, dtype:String):void
		{
			try
			{
				for (var i:Number=0;i<dm.length;i++)
				{
					var domainInst:Object = dm.getItemAt(i);
					sStat.text = "INSERT INTO CULVERT_DOMAIN (d_id, d_description, d_type) " +
						" VALUES(" + domainInst.ID + ",'" + domainInst.DESCRIPTION + "','" + dtype + "');";
					sStat.execute();
				}
			} catch (err:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert(err.message);
			}
			
		}
		
		// Populate local domain DB table
		public function insertAssetDomain(dm:ArrayCollection, dtype:String, filterColName:String=""):void
		{
			try
			{
				for (var i:Number=0;i<dm.length;i++)
				{
					
					var domainInst:Object = dm.getItemAt(i);
					
					sStat.text = "select count(*) from asset_domain where d_id = '"+domainInst.ID +"' and d_description ='"+StringUtil.trim(domainInst.DESCRIPTION)+"' and d_type = '"+dtype+"'" ;
					if(filterColName !="")
						sStat.text += " and filter_column_data = '"+domainInst[filterColName]+"';";
					else
						sStat.text += ";";
					sStat.execute();
					var arr:Array = sStat.getResult().data;
					if(arr !=null && arr.length>0)
					{
						var rownum:int = arr[0]["count(*)"];
						if(rownum<1)
						{
							sStat.text = "INSERT INTO ASSET_DOMAIN (d_id, d_description, d_type" ;
							if(filterColName !="")
								sStat.text += ",filter_column_data";
							sStat.text +=	") VALUES('" + domainInst.ID + "','" +StringUtil.trim(domainInst.DESCRIPTION) + "','" + dtype + "'" ;
							if(filterColName !="")
								sStat.text += ",'"+domainInst[filterColName]+"'";
							sStat.text +=	");";
							sStat.execute();
						}
					}
				}
			} catch (err:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert(err.message);
			}
			
		}
		
		
//		// Retrieve domain from local DB
//		public function getDomain(dtype:String):ArrayCollection
//		{
//			var domainReturn:ArrayCollection = new ArrayCollection();
//			try
//			{
//				sStat.text = "SELECT * from CULVERT_DOMAIN where d_type = '" + dtype + "' order by d_description";
//				sStat.execute();
//				var data:Array = sStat.getResult().data;
//				
//				if(data!=null)
//				{
//					for (var i:Number=0;i<data.length;i++)
//					{
//						var dmObj:Object = new Object();
//						dmObj.ID = data[i].d_id;
//						dmObj.DESCRIPTION = data[i].d_description;
//						domainReturn.addItem(dmObj);
//					}
//				}
//			} catch (err:Error)
//			{
//				FlexGlobals.topLevelApplication.TSSAlert(err.message);
//			}
//			return domainReturn;
//		}
//		
//		public function getAssetDomain(dtype:String):ArrayCollection
//		{
//			var domainReturn:ArrayCollection = new ArrayCollection();
//			try
//			{
//				sStat.text = "SELECT * from ASSET_DOMAIN where d_type = '" + dtype + "'" + " order by d_description";
//				sStat.execute();
//				var data:Array = sStat.getResult().data;
//				
//				if(data!=null)
//				{
//					for (var i:Number=0;i<data.length;i++)
//					{
//						var dmObj:Object = new Object();
//						dmObj.ID = data[i].d_id;
//						dmObj.DESCRIPTION = data[i].d_description;
//						dmObj.FILTER_COLUMN_DATA = data[i].filter_column_data;
//						domainReturn.addItem(dmObj);
//					}
//				}
//				
//			} catch (err:Error)
//			{
//				FlexGlobals.topLevelApplication.TSSAlert(err.message);
//			}
//
//			return domainReturn;
//		}
		
//		public function getAssetDomainRecordDescByID(dtype:String, ID:String):String
//		{
//			
//			try
//			{
//				sStat.text = "SELECT * from ASSET_DOMAIN where d_type = '" + dtype + "'" + " and d_id = '"+ID+"' ORDER BY d_description";
//				sStat.execute();
//				var data:Array = sStat.getResult().data;
//				
//				if(data!=null && data.length>0)
//				{
//					return data[0].d_description;
//				}
//				
//			} catch (err:Error)
//			{
//				FlexGlobals.topLevelApplication.TSSAlert(err.message);
//			}
//			
//			return "";
//		}
		
		
		// Clear domain table
		public function deleteDomains(): void
		{
			sStat.text = "DELETE from CULVERT_DOMAIN";
			sStat.execute();
			sStat.text = "DELETE from ASSET_DOMAIN";
			sStat.execute();
			clearInspectorTable();
		}
		
		// Drop the Culverts Table
		public function dropCulvertsTable(): void
		{
			sStat.text = "DROP TABLE CACHED_CULVERTS;";
			sStat.execute();
			sStat.text = "CREATE TABLE IF NOT EXISTS CACHED_CULVERTS( " +
				"CULVERT_INV_ID INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"asset_base_id TEXT, " +
				"ROUTE_FULL_NAME TEXT,"+ 
				"CROSS_ST_NM	TEXT,"+ 
				"CROSS_ST_NUM	TEXT,"+ 
				"CULV_LENGTH_FLG	INTEGER,"+ 
				"CULV_LENGTH_FT	TEXT,"+ 
				"D_ORIG_DATA_SOURCE_ID	TEXT,"+ 
				"D_BEAM_MAT_ID	TEXT,"+ 
				"D_ABUTMENT_MAT_ID	TEXT,"+ 
				"D_CULV_MAT_ID	TEXT,"+ 
				"D_CULV_MAT_ID_2	TEXT,"+ 
				"D_CULV_SHAPE_ID	TEXT,"+ 
				"D_JOINT_SEP_LOC_ID	TEXT,"+ 
				"D_CULV_PLACEMENT_TY_ID	TEXT,"+ 
				"REFPT	REAL,"+ 
				"LOCATION_CMT	TEXT,"+ 
				"NUM_BARRELS	INTEGER,"+ 
				"STATION	TEXT,"+ 
				"D_GARAGE_ID	TEXT,"+ 
				"CULV_SIZE_VERT_INCH	TEXT,"+ 
				"CULV_SIZE_HORIZ_INCH	TEXT,"+ 
				"CULV_SIZE3	TEXT,"+ 
				"SKEW_FLG	INTEGER,"+ 
				"INV_CMT	TEXT,"+ 
				"PROJECT_ID	INTEGER,"+ 
				"INSP_CMT	TEXT,"+ 
				"D_JOINT_COND_ID	TEXT,"+
				"D_CHNL_COND_ID	TEXT,"+
				"D_BARL_COND_ID	TEXT,"+
				"D_ENDS_COND_ID	TEXT,"+
				"D_FLOW_COND_ID	TEXT,"+
				"D_JOINT_RMK_ID	TEXT,"+
				"D_CHNL_RMK_ID	TEXT,"+
				"D_BARL_RMK_ID	TEXT,"+
				"D_ENDS_RMK_ID	TEXT,"+
				"D_FLOW_RMK_ID	TEXT,"+
				"D_REFER_TO_ID	TEXT,"+
				"CREATE_DT	DATE,"+ 
				"MODIFY_DT	DATE,"+ 
				"D_USER_ID	TEXT,"+ 
				"RETIRE_DT	DATE);";
			
			
			sStat.execute();	
		}
		
		// Drop the Geotags table
		public function dropGeotagsTable(): void
		{
			sStat.text = "DROP TABLE GEOTAGS;";
			sStat.execute();
			
			sStat.text = "CREATE TABLE IF NOT EXISTS GEOTAGS ( id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"asset_type TEXT," +
				"asset_base_id TEXT, "+
				"local_asset_id TEXT, "+
				"cached_route_id TEXT, " + 
				"is_insp_tag INTEGER, "+
				"begin_mile REAL, " +
				"end_mile REAL, " + 
				"image_filename TEXT, " + 
				"video_filename TEXT, " + 
				"voice_filename TEXT, " + 
				"text_memo TEXT," +
				"is_cached INTEGER);";
			sStat.execute();
		}
		
		// deletes all local geotags
		public function clearGeotagsTable(): void
		{
			sStat.text = "DELETE FROM GEOTAGS where is_cached <> 1;";
			sStat.execute();
			
		}
		// deletes all data the Geotags table
		public function clearCachedGeotagsTable(): void
		{
			sStat.text = "DELETE FROM GEOTAGS where is_cached = 1;";
			sStat.execute();
			
		}
		public function clearIncidentTable(): void
		{
			sStat.text = "DELETE FROM INCIDENT_INV;";
			sStat.execute();
			
		}
		
		
		public function clearMapImageTable():void
		{
			sStat.text = "DELETE FROM MAP_IMAGES";
			sStat.execute();	
		}
		
		public function clearInspectorTable():void
		{
			sStat.text = "DELETE FROM INSPECTORS";
			sStat.execute();	
		}
		
		
		
		
		// deletes all data the Geotags table
		public function deleteFromGeotagsTable(idType:String, str:String): void
		{
			if(idType =="local")
				sStat.text = "DELETE FROM GEOTAGS where local_asset_id not in (" +str+")";
			else 
				sStat.text = "DELETE FROM GEOTAGS where asset_base_id not in (" +str+")";
			sStat.execute();
			
		}
		
		
		
		// deletes data from table; will be replaced by the following function
		public function deleteFromAssetTable(assetType:String , idType:String,str:String): void
		{
			var id:String ="ID";
			
			if(assetType =="CULV")
				id  = 	"CULVERT_INV_ID";	
				
			if(assetHasInspTable(assetType))
			{
				if(idType =="local")
					sStat.text = "DELETE FROM "+assetType+"_INSP where "+id+" not in (" +str+")";
				else 
					sStat.text = "DELETE FROM "+assetType+"_INSP where "+id+" not in (select "+id+" from "+assetType+"_INV where asset_base_id not in (" +str+"))";
				sStat.execute();
			}
			
			if(idType =="local")
				sStat.text = "DELETE FROM "+assetType+"_INV where "+id+" not in (" +str+")";
			else 
				sStat.text = "DELETE FROM "+assetType+"_INV where asset_base_id not in (" +str+")";
			sStat.execute();
			
			
			
		}
		//replaces the prev func in new sync
		public function deleteLocalAsset(assetType:String ,idStr:String, idColName:String): void
		{
			
			
			
			
			if(assetHasInspTable(assetType))
			{
				sStat.text = "DELETE FROM "+assetType+"_INSP where "+idColName+"  in (" +idStr+")";
				sStat.execute();
			}
			
			sStat.text = "DELETE FROM "+assetType+"_INV where "+idColName+"  in (" +idStr+")";
			sStat.execute();
					
			
		}
		
		private function resultHandler(event:SQLEvent):void
		{
			var data:Array = sStat.getResult().data;
		}
		
		private function errorHandler(event:SQLEvent):void
		{
			
		}
		// Cached Inventory **********************************************
		
		public function dropAssetTables(assetTable:Object):void
		{
			var assetDesc:String = assetTable.ASSET_DATA_TEMPLATE.DESCRIPTION;
			var dropString:String = "DROP TABLE " + assetDesc.toUpperCase() + "_INV";
			sStat.text = dropString;
			sStat.execute();
				if(assetHasInspTable(assetDesc.toUpperCase() ))
				{
					dropString = "DROP TABLE " + assetDesc.toUpperCase() + "_INSP";
					sStat.text = dropString;
					sStat.execute();
						
				}
		}

		// MAVRICDBManager2 Code***********************************
		public function createAssetTables(assetTables:Object):void
		{
			for(var i : int = 0; i < assetTables.length; i++)
			{
				var assetDesc:String = assetTables[i].ASSET_DATA_TEMPLATE.DESCRIPTION;
				primaryKey = assetTables[i].ASSET_DATA_TEMPLATE.PRIMARY_KEY;
				invCols = assetTables[i].ASSET_DATA_TEMPLATE.INV_COLUMNS as Array;
				inspCols = assetTables[i].ASSET_DATA_TEMPLATE.INSP_COLUMNS as Array;
				//if(invCols.length > 0)
				{
					var invCreateString:String = "CREATE TABLE IF NOT EXISTS " + assetDesc.toUpperCase() + "_INV ( " + primaryKey.toUpperCase() +
						" INTEGER PRIMARY KEY AUTOINCREMENT, STATUS TEXT, ";
					
					for (var j:int = 0; j < invCols.length; j++)
					{
						
						
						if (primaryKey.toUpperCase() !== invCols[j].NAME) 
							invCreateString += invCols[j].NAME + " " + invCols[j].TYPE + ",";
					}
					
					invCreateString = invCreateString.substring(0, invCreateString.length - 1);
					invCreateString += ");";
					
					sStat.text = invCreateString;
					sStat.execute();
				}
				
				if(inspCols.length > 0)
				{
					var inspCreateString:String = "CREATE TABLE IF NOT EXISTS " + assetDesc.toUpperCase() + "_INSP ( " + primaryKey.toUpperCase() +
						" INTEGER PRIMARY KEY AUTOINCREMENT, ";
					
					for (var k:int = 0; k < inspCols.length; k++)
					{
						
						inspCreateString += inspCols[k].NAME + " " + inspCols[k].TYPE + ",";
					}
					
					while(inspCreateString.charAt(inspCreateString.length-1) == "," || inspCreateString.charAt(inspCreateString.length-1) == " ")
					{
						inspCreateString = inspCreateString.substring(0, inspCreateString.length - 1);
					}
					
					inspCreateString += ");";
					
					sStat.text = inspCreateString;
					sStat.execute();
				}
				
			}
			
		}

		public function dropBarElementTables(barElementTable:Object):void
		{
			var barElementDesc:String = barElementTable.BAR_ELEMENT_DATA_TEMPLATE.DESCRIPTION;
			var dropString:String = "DROP TABLE " + barElementDesc.toUpperCase() + "_INV";
			sStat.text = dropString;
			sStat.execute();
		}

		// MAVRICDBManager2 Code***********************************
		public function createBarElementTables(barElementTables:Object):void
		{
			for(var i : int = 0; i < barElementTables.length; i++)
			{
				var barElementDesc:String = barElementTables[i].BAR_ELEMENT_DATA_TEMPLATE.DESCRIPTION;
				primaryKey = barElementTables[i].BAR_ELEMENT_DATA_TEMPLATE.PRIMARY_KEY;
				invCols = barElementTables[i].BAR_ELEMENT_DATA_TEMPLATE.INV_COLUMNS as Array;

				var invCreateString:String = "CREATE TABLE IF NOT EXISTS " + barElementDesc.toUpperCase() + "_INV ( " + primaryKey.toUpperCase() +
					" INTEGER PRIMARY KEY AUTOINCREMENT, ";
					
				for (var j:int = 0; j < invCols.length; j++)
				{
					
					
					if (primaryKey.toUpperCase() !== invCols[j].NAME) 
						invCreateString += invCols[j].NAME + " " + invCols[j].TYPE + ",";
				}
				
				invCreateString = invCreateString.substring(0, invCreateString.length - 1);
				invCreateString += ");";
				
				sStat.text = invCreateString;
				sStat.execute();
			}
		}

		public function addBarElement(barElement:BaseAsset, isNew:Boolean=false, isRetired:Boolean=false):void
		{
			var colNames : String;
			var vals : String;
			
			if (barElement.id < 0)
				assignAssetId(barElement, barElement.description);
			var colObj:Object = buildColNames(primaryKey, "INV", barElement, isNew, isRetired);
			colNames = colObj.STRING; //--> String of column names
			vals = colObj.VALUES; //--> String of values
			sStat.text = "INSERT INTO " + barElement.description + "_INV (" + colNames + ")" + " VALUES(" + vals + ");";
			sStat.execute();
		}
		
		public function updateBarElement(barElement:BaseAsset):void
		{
			var colNames : String;
			var vals : String;
			var eqString:String;
			var colObj : Object = buildColNames(barElement.primaryKey, "INV", barElement); //--> String of column names
			
			vals = buildValuesString(barElement, colObj.ARRAY, "INV"); //--> String of values
			
			eqString = buildSETString(colObj.STRING, vals, barElement.invProperties, barElement.id); //--> String of "column_x = value_x"
			sStat.text = "UPDATE " + barElement.description + "_INV SET " + eqString + " WHERE " + barElement.primaryKey + " = " + barElement.id + ";";
			sStat.execute();
		}

		public function deleteBarElement(barElement:BaseAsset):void
		{
			sStat.text = "DELETE FROM " + barElement.description + "_INV WHERE " + barElement.primaryKey + " = " + barElement.id + ";";
			sStat.execute();
		}
		
//		private function buildINVColumnNamesArray(template : Object):Array
//		{
//			var arr : Array = new Array();
//			//arr.push(template.PRIMARY_KEY);
//			for each(var obj : Object in template.INV_COLUMNS)
//			{
//				arr.push(obj.NAME);
//			}
//			return arr;
//		}
		
//		private function buildINSPColumnNamesArray(template : Object):Array
//		{
//			var arr : Array = new Array();
//			//arr.push(template.PRIMARY_KEY);
//			for each(var obj : Object in template.INSP_COLUMNS)
//			{
//				arr.push(obj.NAME);
//			}
//			return arr;
//		}
		
		public function getAssetsByType(assetType:String, primaryKey:String):Array
		{
			if(assetType === "CULV")
				trace("getting culverts from local db");
			var resArray:Array = new Array();
			var array:Array;
		
			if(assetHasInspTable(assetType))
				sStat.text = "SELECT inv.*, insp.* FROM " + assetType + "_INV inv LEFT OUTER JOIN "+ assetType + "_INSP insp ON insp." + primaryKey + "  = inv." + primaryKey + "";
			else
				sStat.text = "SELECT * FROM " + assetType + "_INV";
			
			sStat.execute();
			var result:SQLResult = sStat.getResult();
			array = result.data;

			return array;

		}
		
		public function getAssetById(id:String, assetType:String, primaryKey:String):Object
		{
			if(assetHasInspTable(assetType))
				sStat.text = "SELECT inv.*,insp.* FROM " + assetType + "_INV inv LEFT OUTER JOIN "+ assetType + "_INSP insp ON insp." + primaryKey + " = inv." + primaryKey + " WHERE inv." + primaryKey + " = " + id;
			else
				sStat.text = "SELECT * FROM " + assetType + "_INV WHERE " + primaryKey + " = " + id;
			
			var ret:Object = null;
			try
			{
				sStat.execute();
				
				var result:SQLResult = sStat.getResult();
				//TODO: access SELECT statement's result data. Look up API
				ret = result && result.data ? result.data[0] : null;
			}
			catch (error:SQLError)
			{
				trace("Error message:", error.message);
				trace("Details:", error.details);
			}
			
			return ret;
		}	
		
		public function getAssetStatus(id:String, assetType:String, primaryKey:String):String
		{
			
			sStat.text = "SELECT STATUS FROM " + assetType + "_INV WHERE " + primaryKey + " = " + id;
			
			var ret:String = null;
			try
			{
				sStat.execute();
				
				var result:SQLResult = sStat.getResult();
				//TODO: access SELECT statement's result data. Look up API
				ret = result && result.data ? String(result.data) : null;
			}
			catch (error:SQLError)
			{
				trace("Error message:", error.message);
				trace("Details:", error.details);
			}
			
			return ret;
		}	
		
		
		public function addAsset(asset:BaseAsset):void
		{
			//assignAssetId(asset, table);
			var colNames : String;
			var vals : String;
			//invCols = asset.ASSET_DATA_TEMPLATE.INV_COLUMNS
			var isNew:Boolean= (asset.id < 0);
			if (isNew)
				assignAssetId(asset, asset.description);
			var colObj:Object = buildColNames(primaryKey, "INV", asset, isNew);
			colNames = colObj.STRING; //--> String of column names
			vals = colObj.VALUES; //--> String of values
			sStat.text = "INSERT INTO " + asset.description + "_INV (" + colNames + ")" + " VALUES(" + vals + ");";
			sStat.execute();
			
			var isEmpty:Boolean = true;
			for (var n:Object in asset.inspProperties) { isEmpty = false; break; }

			if(!isEmpty && assetHasInspTable(asset.description))
			{
				colObj = buildColNames(primaryKey, "INSP", asset);
				colNames = colObj.STRING;
				vals = colObj.VALUES;//buildValuesString(asset,colObj.ARRAY, "INSP");
				sStat.text = "INSERT INTO " + asset.description + "_INSP (" + colNames + ")" + " VALUES(" + vals + ");";
				sStat.execute();
			}
			//sStat.text = "INSERT INTO OFFSET_TABLE ("+asset.primaryKey+", OFFSET) VALUES(" + asset.id + ","+asset.offset + ");";
			//sStat.execute();
		}
		
		public function updateAsset(asset:BaseAsset):void
		{
			var colNames : String;
			var vals : String;
			var eqString:String;
			
			
			
			
			var colObj : Object = buildColNames(asset.primaryKey, "INV", asset); //--> String of column names
			
			vals = buildValuesString(asset, colObj.ARRAY, "INV"); //--> String of values
			
			eqString = buildSETString(colObj.STRING, vals, asset.invProperties, asset.id); //--> String of "column_x = value_x"
			sStat.text = "UPDATE " + asset.description + "_INV SET " + eqString + " WHERE " + asset.primaryKey + " = " + asset.id + ";";
			sStat.execute();
			if(assetHasInspTable(asset.description))
			{
				colObj = buildColNames(asset.primaryKey, "INSP", asset);
				colNames = colObj.STRING;
				vals = buildValuesString(asset,colObj.ARRAY, "INSP");
				
				eqString  = buildSETString(colObj.STRING,vals, asset.inspProperties, asset.id);
				sStat.text = "UPDATE " + asset.description + "_INSP SET " + eqString + " WHERE " + asset.primaryKey + " = " + asset.id + ";";
				sStat.execute();
			}
			//sStat.text = "UPDATE OFFSET_TABLE SET OFFSET=" + asset.offset + " WHERE " + asset.primaryKey + " = " + asset.id + ";";
			//sStat.execute();
		}
		
		private function assignAssetId(asset : BaseAsset, table:String):void
		{
			var rowid : int;
			sStat.text = "SELECT COUNT(" + asset.primaryKey + ") FROM " + table + "_INV";
			sStat.execute();
			
			var arr:Array = sStat.getResult().data;
			rowid = arr[0]["COUNT(" + asset.primaryKey + ")"];
			
			asset.id = rowid + 1;
		}
		
		public function assignSignAssemblyLocalID():int
		{
			var rowid : int;
			sStat.text = "SELECT COUNT(DISTINCT (ASSEMBLY_LOCAL_ID)) as countAssm FROM SIGN_INV where ASSEMBLY_LOCAL_ID is not null";
			sStat.execute();
			
			var arr:Array = sStat.getResult().data;
			rowid = arr[0]["countAssm"];
			
			return rowid + 1;
		}
		
		public function getAllSignsByAssemblyID(id:String,idColName:String, local:Boolean=true):ArrayCollection
		{
			var rowid : int;
			if(local)
				sStat.text = "SELECT inv.*,ins.* FROM SIGN_INV inv LEFT OUTER JOIN SIGN_INSP ins ON inv."+idColName+" = ins."+idColName+" where ASSEMBLY_LOCAL_ID =" + id;
			else
				sStat.text = "SELECT inv.*,ins.* FROM SIGN_INV inv LEFT OUTER JOIN SIGN_INSP ins ON inv."+idColName+" = ins."+idColName+" where ASSEMBLY_ID =" + id;
			sStat.execute();
			
			var arr:Array = sStat.getResult().data;
			
			
			return new ArrayCollection(arr);;
		}
		
		public function isSignMultiple(id:String, local:Boolean=true):Boolean
		{
			var rowid : int;
			if(local)
				sStat.text = "SELECT * FROM SIGN_INV where ASSEMBLY_LOCAL_ID =" + id;
			else
				sStat.text = "SELECT * FROM SIGN_INV where ASSEMBLY_ID =" + id;
			sStat.execute();
			
			var arr:Array = sStat.getResult().data;
			
			if(arr!=null && arr.length>0)
				return true;
			else
				return false;
			
		}
		
		private function assetHasInspTable(type:String):Boolean
		{
			if(FlexGlobals.topLevelApplication.GlobalComponents.assetManager.barElementNames != null && 
				FlexGlobals.topLevelApplication.GlobalComponents.assetManager.barElementNames.length > 0)
			{
				if(FlexGlobals.topLevelApplication.GlobalComponents.assetManager.barElementNames.indexOf(type) >= 0)
					return false;
			}
			
			sStat.sqlConnection.loadSchema(); 
			
			var result:SQLSchemaResult = sStat.sqlConnection.getSchemaResult();
			
			
			var arr:Array = result.tables;
			
			for each (var table:SQLTableSchema in result.tables)
			{
				if(table.name==type.toUpperCase()+"_INSP")
					return true;
			}
			return false;
		}
		
		
		private function buildValuesString(asset:BaseAsset, colArray:Array, type: String):String
		{
			var result: String = "";
			var status:String = getAssetStatus(String(asset.id),asset.description,asset.primaryKey);
			
			var propertiesObj : Object;
			if(type ==="INV")
			{
				propertiesObj = asset.invProperties;	
			}
			else if(type === "INSP")
			{
				propertiesObj = asset.inspProperties;
			}
			
			if(asset.id == -1)
			{
				result += "NULL,";
				if(type ==="INV")
					result += "'"+status+"',";
			}
			else
			{
				result += asset.id+",";
				if(type ==="INV")
					result += "'"+status+"',";
			}
			
			for(var i : int = 1; i < colArray.length; i++)
			{
				if(propertiesObj[colArray[i]].type === "TEXT")
				{
					result += stringOrNull(propertiesObj[colArray[i]].value, true);
				}else
				{
					result += stringOrNull(propertiesObj[colArray[i]].value, false);
				}
				if(i != colArray.length - 1)
				{
					result += ",";
				}
			}
			return result;
		}
		
		/**
		 * For the purpose of adding quotes to String values and replacing null or empty valuess with NULL.
		 */
		private function stringOrNull(str : String, isString : Boolean):String
		{
			var res : String;
			if(str === "" || str == null)
			{
				res = "NULL";
			}
			else
			{
				if(isString)
				{
					escapeChars(str);
						
					res = "'" + str + "'";
				}
				else
				{
					res = str;
				}
				
			}
			return res;
		}
		
		private function escapeChars(str:String):String
		{
			var i:int;
			while(str.indexOf("'") != -1)
			{
				i = str.indexOf("'");
				str = str.substring(0,i)+"'"+str.substring(i,str.length);
			}
			
			while(str.indexOf("\\") != -1)
			{
				i = str.indexOf("\\");
				str = str.substring(0,i)+"\\"+str.substring(i,str.length);
				
			}
			return str;
		}
		
		private function buildColNames(primaryKey:String, type:String, asset:BaseAsset, isNew:Boolean=false, isRetired:Boolean=false):Object
		{
			var resArray:Array = new Array();
			var resString :String = "";
			var valuesString:String = "";
			var statusVal:String = "EDITED";
			if(isNew)
				statusVal = "NEW";
			else if(isRetired)
				statusVal = "RETIRED";
			
			resString += asset.primaryKey+  ",";
			 
			var array : Object;
			if(type === "INV")
			{
				resString +=   "STATUS,";
				array = asset.invProperties;
				valuesString += array[asset.primaryKey].value+",'" + statusVal +"',";
			}
			else if(type === "INSP")
			{
				array = asset.inspProperties;
				valuesString += asset.invProperties[asset.primaryKey].value+",";
			}
			
			for each (var val:Object in array)
			{
				if(val.name != asset.primaryKey)
				{
					resString += val.name;
					resString += ",";
					resArray.push(val.name);
					if(val.type === "TEXT" )
					{
						valuesString += stringOrNull(val.value, true) + ",";
					}else if(val.type === "DATE" )
					{
						valuesString +=   (val.value? "strftime('%J','" + toSqlDate(val.value) +"')" :"null") + ",";
					}else
					{
						valuesString += stringOrNull(val.value, false)+",";
					}
				}
				
			}
			valuesString = valuesString.substring(0, valuesString.length - 1);
			resString = resString.substring(0, resString.length - 1);
			return {STRING:resString, ARRAY:resArray, VALUES:valuesString};
		}
		
		private function lpad(original:Object, length:int, pad:String):String
		{
			var padded:String = original == null ? "" : original.toString();
			while (padded.length < length) padded = pad + padded;
			return padded;
		}
		
		
		
		private function toSqlDate(dateStr:String):String
		{
			var dateVal:Date = new Date(Date.parse(dateStr));
			return dateVal == null ? null : dateVal.fullYear
				+ "-" + lpad(dateVal.month + 1,2,'0')  // month is zero-based
				+ "-" + lpad(dateVal.date,2,'0')
				+ " " + lpad(dateVal.hours,2,'0')
				+ ":" + lpad(dateVal.minutes,2,'0')
				+ ":" + lpad(dateVal.seconds,2,'0')
				;
		}
		
		/**
		 * Creates the assignment part of the SET SQL statement in the update and insert asset methods.
		 * @param id The id of the asset, necessary for assigning the values of the inspection properties. 
		 */
		private function buildSETString(colNames:String, vals:String, properties:Object, id:Number):String
		{
			var result :String = "";
			// TODO Auto Generated method stub
			var colArray : Array = colNames.split(",");
			var val:String;
			
			for(var i : int = 0; i < colArray.length; i++)
			{
				if(properties.hasOwnProperty(colArray[i]))
				{
					val = properties[colArray[i]].type === "TEXT" ? stringOrNull(properties[colArray[i]].value, true):stringOrNull(properties[colArray[i]].value, false);
					result += colArray[i] + " = " + val;//valArray[i];
					if(i < colArray.length -1)
					{
						result += ",";
					}		
				}
				else if(colArray[i] === "ID")
				{
					result += colArray[i] + " = " + id;//valArray[i];
					if(i < colArray.length -1)
					{
						result += ",";
					}		
				}
				
			}
			
			return result;
		}
		
		public function clearAssetTable(type:String):void
		{
			sStat.text = "DELETE FROM " + type + "_INV;";
			sStat.execute();
			if(assetHasInspTable(type))
			{
				sStat.text = "DELETE FROM " + type + "_INSP;";
				sStat.execute();
			}
			
		}

		public function clearBarElementTable(type:String):void
		{
			sStat.text = "DELETE FROM " + type + "_INV;";
			sStat.execute();
		}

		// ********************************************************
		
		
		public function exportAssets(assetType:String):Array
		{
			
			var data2:Array = new Array();
			try
			{
				if(assetHasInspTable(assetType))
				{
					var primaryKey:String =  FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getAssetPrimaryKeyColName(assetType);
					
					sStat.text = "SELECT i.*,inv.*  "
					+ "from " + assetType + "_INV inv LEFT OUTER JOIN "+ assetType+ "_INSP i ON i."+primaryKey+" = inv."+primaryKey;
				
				}
				else
					sStat.text = "SELECT *  from " + assetType + "_INV ";
				sStat.execute();
				data2 = sStat.getResult().data;
				return data2;
				
			}
			catch(e:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert( "Error in exportAssets:\n" + e.message );
				
			}
			return null;
		}
		
		public function exportCulverts():Array
		{
			var data:Array = new Array();
			var data2:Array = new Array();
			try
			{
				
				sStat.text = "SELECT i.*,inv.*  "
					+ "from " + Culvert.TYPE + "_INV inv LEFT OUTER JOIN "+ Culvert.TYPE + "_INSP i ON i.ID = inv.ID";
				
				
				sStat.execute();
				data2 = sStat.getResult().data;
				return data2;

			}
			catch(e:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert( "Error in exportCulverts:\n" + e.message );
				
			}
			return null;
		}
		
		
		
		public function exportGuardrails():Array
		{
			var data:Array = new Array();
			var data2:Array = new Array();
			try
			{
				
				sStat.text = "SELECT insp.*, inv.* "
					+ "from GUARDRAIL_INV inv LEFT OUTER JOIN GUARDRAIL_INSP insp ON  inv.id= insp.id ";
				
				sStat.execute();
				data= sStat.getResult().data;
				
				return data;

			}
			catch(e:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert( "Error in exportGuardrails :\n" + e.message );
				
			}
			return null;
		}
		
		public function exportSigns():Array
		{
			var data:Array = new Array();
			var data2:Array = new Array();
			try
			{
				
				sStat.text = "SELECT inv.*, insp.* from SIGN_INV inv LEFT OUTER JOIN SIGN_INSP insp ON  inv.id= insp.id ";
				
				sStat.execute();
				data= sStat.getResult().data;
				
				return data;
				
			}
			catch(e:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert( "Error in exportSigns :\n" + e.message );
				
			}
			return null;
		}
		
		public function exportIncidents():Array
		{
			var data:Array = new Array();
			var data2:Array = new Array();
			try
			{
								
				sStat.text = "SELECT *"
					+ " from " +   "INCIDENT_INV";
				
				sStat.execute();
				data= sStat.getResult().data;
				
			}
			catch(e:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert("Error in exportIncidents :\n" + e.message);
			}
			
			return data;
			
		}
		
		// Shamelessly Lifted from StackOverflow at:
		// http://stackoverflow.com/questions/5350907/merging-objects-in-as3
		public static function zip(objects:Array):Object
		{
			var r:Object = {};
			
			for each (var o:Object in objects)
			for (var k:String in o)
				r[k] = o[k];
			
			return r;
		}

		public function getGeoTagFileNames():Array
		{
			var data:Array = new Array();
			try
			{
				sStat.text = "SELECT image_filename,video_filename,voice_filename from GEOTAGS where is_cached = 0";
				
				sStat.execute();
				data= sStat.getResult().data;
			}
			catch(e:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert(e.message);
			}
			return data;
		}
		
		public function isCachedGeotag(filename:String):Boolean
		{
			sStat.text = "SELECT * from GEOTAGS where is_cached=1 and (image_filename = '"+filename+"' or video_filename = '"+filename+"' or voice_filename='"+filename+"')";
				
			sStat.execute();
			var res:SQLResult = sStat.getResult();
			if(res && (res.data == null || res.data.length ==0))
				return false;
			return true;
			
		}
		
		
		public function isNotCachedAndInDBGeotag(filename:String):Boolean
		{
			sStat.text = "SELECT * from GEOTAGS where  (image_filename = '"+filename+"' or video_filename = '"+filename+"' or voice_filename='"+filename+"')";
			
			sStat.execute();
			var arr:Array = sStat.getResult().data;
			if(arr ==null || arr.length==0)
				return false;
			var is_cach:int = arr[0]["is_cached"];
			if(is_cach==1)
				return false;
			else
				return true;
			//is_cached=1 and
		}
		
		
		public function exportGeotagData(assetType:String=""):Array
		{
			var data:Array = new Array();
			try
			{
				sStat.text = "SELECT * from GEOTAGS where is_cached = 0";
				
				sStat.execute();
				data= sStat.getResult().data;
			}
			catch(e:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert(e.message);
			}
			return data;
		}
		
		// Cached Routes **********************************************
		public function addCachedRoute(cr:CachedRoute):Number
		{		
			sStat.text = "INSERT INTO CACHED_ROUTES (route_id, begin_mile, end_mile, content, path, bbox, boundary) " +
				" VALUES('" + cr.routeid + "'," + cr.beginmile + "," + cr.endmile + ", '" + cr.content + "', '" 
				+ cr.path + "', '" + cr.bbox + "', '"+cr.boundary+"');";
			sStat.execute();
			var sr:SQLResult = sStat.getResult();
			// return row id (pk)
			return sr.lastInsertRowID;
		}
		
		public function deleteRoutesByBoundary(boundary:String):void{
			sStat.text = "DELETE FROM CACHED_ROUTES WHERE boundary = '" +boundary+"';";
			sStat.execute();
		}
		
		public function getCachedRoutes():Array
		{
			var crArray:Array = [];
			sStat.text = "SELECT * from CACHED_ROUTES";
			sStat.execute();
			var data:Array = sStat.getResult().data;
			if(data != null){
			for (var i:int=0;i<data.length;i++)
			{
				var tmpcr:CachedRoute = new CachedRoute();
				tmpcr.id = data[i].id;
				tmpcr.routeid = data[i].route_id;
				tmpcr.beginmile = data[i].begin_mile;
				tmpcr.endmile = data[i].end_mile;
				tmpcr.content = data[i].content;
				tmpcr.path = data[i].path;
				tmpcr.bbox = data[i].bbox;
				tmpcr.boundary = data[i].boundary;
				crArray[i] = tmpcr;
			}
			
			
		}
			
			return crArray;
		}
		
		public function getCachedRoute(crid:Number):CachedRoute
		{
			sStat.text = "SELECT * from CACHED_ROUTES where id = " + crid;
			sStat.execute();
			var data:Array = sStat.getResult().data;
			
			var tmpcr:CachedRoute = new CachedRoute();
			tmpcr.id = data[0].id;
			tmpcr.routeid = data[0].route_id;
			tmpcr.beginmile = data[0].begin_mile;
			tmpcr.endmile = data[0].end_mile;
			tmpcr.content = data[0].content;
			tmpcr.path = data[0].path;
			tmpcr.bbox = data[0].bbox;
			tmpcr.boundary = data[0].boundary;
			return tmpcr;
		}
		
		public function getCachedRouteByRtID(rid:String):CachedRoute
		{
			sStat.text = "SELECT * from CACHED_ROUTES where route_id = " + rid;
			sStat.execute();
			var data:Array = sStat.getResult().data;
			
			var tmpcr:CachedRoute = new CachedRoute();
			tmpcr.id = data[0].id;
			tmpcr.routeid = data[0].route_id;
			tmpcr.beginmile = data[0].begin_mile;
			tmpcr.endmile = data[0].end_mile;
			tmpcr.content = data[0].content;
			
			return tmpcr;
		}
		
		public function isRouteAlreadyCached(rid:String,begMile:Number,endMile:Number):Boolean
		{
			sStat.text = "SELECT * from CACHED_ROUTES where route_id = '" + rid + "' and begin_mile = "+begMile +" and end_mile = "+endMile;
			sStat.execute();
			var data:Array = sStat.getResult().data;
			if(data !=null && data.length>0)
				return true;
			else
				return false;
			
		}
		
		public function deleteCachedRoute(crid:Number): void
		{
			sStat.text = "DELETE from CACHED_ROUTES where id = " + crid;
			sStat.execute();
		}
		
		public function dropCachedRoutesTable():void
		{
			sStat.text = "DROP TABLE CACHED_ROUTES;";
			sStat.execute();
		}
		
		// Categories **********************************************
		public function addCategory(cat:Category):void
		{
			sStat.text = "INSERT INTO CATEGORIES (description, type, diagram_location, cached_route_id, data_type) " +
				" VALUES('" + cat.desription + "'," + cat.type + "," + cat.diagram_location + "," + cat.cached_route_id + "," + cat.data_type + ");";
			sStat.execute();
		}
		
		public function getCategories():Array
		{
			return null;
		}
		
		public function getCategory(cid:Number):Category
		{
			return null;
		}
		
		public function deleteCategory(cid:Number): void
		{
			
		}
		
		// Types **********************************************
		public function addType(type:Type):void
		{
			/*sqls.text = "INSERT INTO CACHED_ROUTES (route_id, begin_mile, end_mile, content) " +
			" VALUES('" + cr.routeid + "'," + cr.beginmile + "," + cr.endmile + ", '" + cr.content + "');";
			sqls.execute();*/
		}
		
		public function getTypes():Array
		{
			return null;
		}
		
		public function getType(tid:Number):Type
		{
			return null;
		}
		
		public function deleteType(tid:Number): void
		{
			
		}
		
		
		// Events **********************************************
		public function addEvent(evt:com.transcendss.mavric.db.DataEvent):void
		{
			/*sqls.text = "INSERT INTO CACHED_ROUTES (route_id, begin_mile, end_mile, content) " +
			" VALUES('" + cr.routeid + "'," + cr.beginmile + "," + cr.endmile + ", '" + cr.content + "');";
			sqls.execute();*/
		}
		
		public function getEvents():Array
		{
			return null;
		}
		
		public function getEvent(eid:Number):com.transcendss.mavric.db.DataEvent
		{
			return null;
		}
		
		public function deleteEvent(eid:Number): void
		{
			
		}
		
		// Data Edits **********************************************
		public function addDataEdit(dedit:DataEdit):void
		{
			/*sqls.text = "INSERT INTO CACHED_ROUTES (route_id, begin_mile, end_mile, content) " +
			" VALUES('" + cr.routeid + "'," + cr.beginmile + "," + cr.endmile + ", '" + cr.content + "');";
			sqls.execute();*/
		}
		
		public function getDataEdits():Array
		{
			return null;
		}
		
		public function getDataEdit(deid:Number):DataEdit
		{
			return null;
		}
		
		public function deleteDataEdit(deid:Number): void
		{
			
		}
		
		// Geotags **********************************************
		public function addGeoTag(tag:GeoTag, is_cached:Boolean):Number
		{
			var assetColName:String;
			var assetColVal:String;
			
			if(tag.asset_base_id =="" && tag.local_asset_id =="" || tag.asset_base_id ==null && tag.local_asset_id ==null)
			{
				assetColName = "local_asset_id,asset_base_id,";
				assetColVal="'','',";
			}
			else if(tag.asset_base_id =="" && tag.local_asset_id !="" || tag.asset_base_id ==null && tag.local_asset_id !=null)
			{
				assetColName = "local_asset_id,asset_base_id,";
				assetColVal = "'"+ tag.local_asset_id +"','',";
			}
			else
			{
				// Testing to see if changing the string to a number helps solve a bug
				assetColName = "local_asset_id,asset_base_id,";
				assetColVal = "'"+  tag.local_asset_id+"','"+  tag.asset_base_id+"',";
			}
			
			
			
			sStat.text = "INSERT INTO GEOTAGS (cached_route_id,asset_type,"+assetColName+ " is_insp_tag, begin_mile, end_mile, image_filename, video_filename, voice_filename, text_memo,is_cached) " +
				" VALUES('" + tag.cached_route_id + "','"+tag.asset_ty_id+"',"+assetColVal + tag.is_insp + "," + tag.begin_mile_point + "," + tag.end_mile_point + ", '" + tag.image_file_name +
				"' , '" + tag.video_file_name + "' , '" + tag.voice_file_name + "', '" + escapeChars(tag.text_memo) + "',"+(is_cached?"1":"0")+");";
			sStat.execute();
			
			return  sStat.sqlConnection.lastInsertRowID;
		}
		
		public function getGeoTags():Array
		{
			var gtArray:Array = [];
			sStat.text = "SELECT * from GEOTAGS";
			sStat.execute();
			var data:Array = sStat.getResult().data;
			
			for (var i:int=0;i<data.length;i++)
			{
				var tmpgt:GeoTag = new GeoTag();
				tmpgt.id = data[i].id;
				tmpgt.cached_route_id = data[i].cached_route_id;
				tmpgt.asset_base_id = data[i].asset_base_id;
				tmpgt.is_insp = data[i].is_insp_tag;
				tmpgt.begin_mile_point = data[i].begin_mile;
				tmpgt.end_mile_point = data[i].end_mile;
				tmpgt.image_file_name = data[i].image_filename;
				tmpgt.video_file_name = data[i].video_filename;
				tmpgt.voice_file_name = data[i].voice_filename;
				tmpgt.text_memo = data[i].text_memo;
				gtArray[i] = tmpgt;
			}
			
			return gtArray;
		}
		
		public function getLocalGeoTags(local_id:Number, atype:String):Array
		{
			var connected:Boolean =  FlexGlobals.topLevelApplication.connected;
			var gtArray:Array = [];
			sStat.text = "SELECT * from GEOTAGS where local_asset_id =" + local_id + " and asset_type = '"+atype + "'";
			if(connected)
				sStat.text += " and is_cached =0";
//			sStat.text = "SELECT * from GEOTAGS" ;
			sStat.execute();
			var data:Array = sStat.getResult().data;
			if (data != null)
			{
				for (var i:int=0;i<data.length;i++)
				{
					var tmpgt:GeoTag = new GeoTag();
					tmpgt.id = data[i].id;
					tmpgt.cached_route_id = data[i].cached_route_id;
					tmpgt.asset_base_id = data[i].asset_base_id;
					tmpgt.is_insp = data[i].is_insp_tag;
					tmpgt.begin_mile_point = data[i].begin_mile;
					tmpgt.end_mile_point = data[i].end_mile;
					tmpgt.image_file_name = data[i].image_filename;
					tmpgt.video_file_name = data[i].video_filename;
					tmpgt.voice_file_name = data[i].voice_filename;
					tmpgt.text_memo = data[i].text_memo;
					gtArray[i] = tmpgt;
				}
			}
			return gtArray;
		}
		
		public function getLocalUnattachedGeoTags(cached_route_id:String,bgMile:Number,endMile:Number):Array
		{
			var gtArray:Array = [];
			sStat.text = "SELECT * from GEOTAGS where local_asset_id ='' and asset_base_id ='' and cached_route_id='" + cached_route_id +"' and begin_mile between "+ bgMile +" and " +endMile;
			sStat.execute();
			var data:Array = sStat.getResult().data;
			if (data != null)
			{
				for (var i:int=0;i<data.length;i++)
				{
					var tmpgt:GeoTag = new GeoTag();
					tmpgt.id = data[i].id;
					tmpgt.cached_route_id = data[i].cached_route_id;
					tmpgt.asset_base_id = data[i].asset_base_id;
					tmpgt.is_insp = data[i].is_insp_tag;
					tmpgt.begin_mile_point = data[i].begin_mile;
					tmpgt.end_mile_point = data[i].end_mile;
					tmpgt.image_file_name = data[i].image_filename;
					tmpgt.video_file_name = data[i].video_filename;
					tmpgt.voice_file_name = data[i].voice_filename;
					tmpgt.text_memo = data[i].text_memo;
					gtArray[i] = tmpgt;
				}
			}
			return gtArray;
		}
		
		
		public function getGeoTag(gtid:Number):GeoTag
		{
			return null;
		}
		
		public function deleteGeoTag(gtid:Number): void
		{
			sStat.text = "DELETE FROM GEOTAGS WHERE id = " +gtid+";";
			sStat.execute();
		}
		
		// Elements *********************************************
		public function addElement(crid:Number, elem:CachedElement):void
		{
			elem.content = elem.content.replace(new RegExp("'", "g"), "''");
			sStat.text = "INSERT INTO ELEMENTS (cached_route_id, diagram_type, description, content) " + 
				" VALUES(" + crid + "," + elem.type + ",'" + elem.description + "','" + elem.content + "')";
			sStat.execute();
		}
		
		public function getElements():Array
		{
			return null;
		}
		
		public function getElement(crid:Number, elemtype:int):CachedElement
		{
			sStat.text = "SELECT * from ELEMENTS where cached_route_id = " + crid + " and diagram_type = " + elemtype;
			sStat.execute();
			var data:Array = sStat.getResult().data;
			
			var tmpce:CachedElement = new CachedElement();
			tmpce.id = data[0].id;
			tmpce.type = data[0].diagram_type;
			tmpce.description = data[0].description
			tmpce.content = data[0].content;
			
			return tmpce;
		}
		
		public function deleteElement(gtid:Number): void
		{
			
		}
		
		public function clearCachedRoutes():void
		{
			
			sStat.text = "DROP TABLE CACHED_ROUTES";
			sStat.execute();
			
			sStat.text = "DROP TABLE ELEMENTS";
			sStat.execute();
			
			sStat.text = "DROP TABLE CACHED_BOUNDARIES";
			sStat.execute();
			
			
			sStat.text = "CREATE TABLE IF NOT EXISTS CACHED_ROUTES ( id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"route_id TEXT, " + 
				"begin_mile REAL, " +
				"end_mile REAL, " + 
				"content TEXT, " +
				"path TEXT, " +
				"bbox TEXT," +
				"boundary TEXT);";
			sStat.execute();	
			
			
			sStat.text = "CREATE TABLE IF NOT EXISTS ELEMENTS ( id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"cached_route_id INTEGER, " +
				"diagram_type INTEGER, " +
				"description TEXT, " + 
				"content TEXT);";
			sStat.execute();
			
			sStat.text = "CREATE TABLE IF NOT EXISTS CACHED_BOUNDARIES ( id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"BOUNDARY_NAME TEXT);";
			sStat.execute();
		}
		
		/**
		 * Adds the boundary name to the BOUNDARY_NAME table for validation purposes in 
		 * the Get Routes By Boundaries function.
		 * @param bn the name of boundary to be added
		 * @result True if the table already contains the boundary, false otherwise (if the boundary was added without a hitch)
		 */
		public function addBoundary(bn:String):void
		{	
			sStat.text = "INSERT INTO CACHED_BOUNDARIES (BOUNDARY_NAME) VALUES('"+bn+"')";
			sStat.execute();
		}
		
		public function containsBoundary(b:String):Boolean
		{
			sStat.text = "SELECT * FROM CACHED_BOUNDARIES WHERE BOUNDARY_NAME = '" + b +"';";
			sStat.execute();
			var res:SQLResult = sStat.getResult();
			if(res && (res.data == null || res.data.length ==0))
				return false;
			return true;
		}
		private function executeForResult():SQLResult
		{
			sStat.execute();
			return sStat.getResult();
		}
		
		//New getMapImageRecord to fit both route-based cached map and district-based cached map
		public function getMapImageList(routeName:String, beginMile:Number, endMile:Number):ArrayCollection
		{
			
			try
			{
				//sStat.text = "SELECT * " + 
				//	"from MAP_IMAGES " + 
				//	"where (ROUTE_FULL_NAME = '" + routeName + "' and BEGIN_MILE <= " + beginMile + " and END_MILE >= " + endMile + ") " +
				//	"OR ROUTE_FULL_NAME LIKE 'district%'" + 
				//	"ORDER BY FILE_PREFIX";
				
				sStat.text = "SELECT * " + 
					"from MAP_IMAGES " + 
					"where (ROUTE_FULL_NAME = '" + routeName + "' and BEGIN_MILE <= " + beginMile + " and END_MILE >= " + endMile + ") " +
					"OR (BEGIN_MILE = 0 and END_MILE = 0) " + 
					"ORDER BY FILE_PREFIX";
				
				//sStat.text = "SELECT * from MAP_IMAGES where ROUTE_FULL_NAME = '" + routeName + "' and BEGIN_MILE <= " + beginMile + " and END_MILE >= " + endMile + "";
				
				sStat.execute();
				
				var data:Array = sStat.getResult().data;
				var mapList:ArrayCollection = new ArrayCollection(data);
			}
			catch(err:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert(err.message);
			}
					
			return mapList;
		}
		
		//New getMapImageRecord - based on the file Prefix, which could be "route name + begmile + endmile", or district name
		public function getMapImageRecordByPrefix(preName:String):Array
		{
			var coords:Array;
			try
			{
				sStat.text = "SELECT * from MAP_IMAGES where FILE_PREFIX = '" + preName + "'";
				
				sStat.execute();
				var data:Array = sStat.getResult().data;
				
				if (data != null && data.length >0)
				{
					coords = new Array();
					coords[0] =	data[0].MINX;
					coords[1] =	data[0].MINY;
					coords[2] =	data[0].MAXX;
					coords[3] =	data[0].MAXY;
					//coords[4] = data[0].ROUTE_FULL_NAME;
					//coords[5] = data[0].BEGIN_MILE;
					//coords[6] = data[0].END_MILE;
					
				}
				
			}
			catch(err:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert(err.message);	
			}
			
			return coords;
		}
		//newly added code
		public function deleteMapImageRecordByName(name:String):void
		{
			sStat.text = "DELETE FROM MAP_IMAGES WHERE ROUTE_FULL_NAME = '" + name +"';";
			sStat.execute();
		}
		
		// ----DDOT code----------------------------------------------------
		public function createDdotTables():void
		{
			// Signs Table
			sStat.text = "CREATE TABLE IF NOT EXISTS SIGNS ( ID INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"SIGNID INTEGER, " +
				"POLEID INTEGER, " + 
				"SIGNNAME TEXT, " +
				"DESCRIPTION TEXT, " + 
				"SIGNFACING INTEGER, " +
				"SIGNHEIGHT REAL, " +
				"SIGNSTATUS INTEGER,"+
				"ARROWDIRECTION TEXT," +
				"COMMENT TEXT);";
			sStat.execute();
			
			// Linked Sign Table
			sStat.text = "CREATE TABLE IF NOT EXISTS LinkedSign ( ID INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"SIGNID INTEGER, " +
				"LINKID TEXT, " +
				"ZONEID INTEGER);";
			sStat.execute();
			
			// Inspections Table
			sStat.text = "CREATE TABLE IF NOT EXISTS INSPECTIONS ( ID INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"INSPECTIONID INTEGER, " +
				"POLEID INTEGER, " + 
				"SIGNID INTEGER, " + 
				"INSPECTOR TEXT, " +
				"DATEINSPECTED REAL, " + 
				"TYPE INTEGER, " +
				"OVERALLCONDITION INTEGER, " +
				"ACTIONTAKEN INTEGER,"+
				"ADDITIONALACTIONNEEDED INTEGER," +
				"BENT INTEGER," +
				"TWISTED INTEGER," +
				"LOOSE INTEGER," +
				"RUSTED INTEGER," +
				"FADED INTEGER," +
				"PEELING INTEGER," +
				"OTHER INTEGER," +
				"COMMENT TEXT);";
			sStat.execute();
			
			// Time Restriction Table
			sStat.text = "CREATE TABLE IF NOT EXISTS TIMERESTRICTIONS ( ID INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"RESTRICTIONID INTEGER, " +
				"LINKID TEXT, " + 
				"STARTDAY INTEGER, " + 
				"ENDDAY INTEGER, " +
				"STARTTIME INTEGER, " + 
				"ENDTIME INTEGER, " +
				"HOURLIMIT REAL, " +
				"RESTRICTIONORDER INTEGER);";
			sStat.execute();
			
			// MS Utility Table
			sStat.text = "CREATE TABLE IF NOT EXISTS MSUTILITY ( MSUTILITY INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"MSSTARTDATE REAL, " + 
				"MSENDDATE REAL);";
			sStat.execute();

		}
		
		private function formatColumnValue(value:Object):String
		{
			// The AIR api for sqlite is extremely strict
			if (value is Number)
				return value.toString();
			else if (value is Date)
				return Date.parse(value).toString();
			else if (value is Boolean)
				return value == true? "1": "0";
			else
				return "'" + value + "'"; 
		}
		
		// Build the key string and value string for the insert sql statement
		private function buildDdotInsertKeyValueStr(record:Object, keys:Array):String
		{
			var keyStr:String = "";
			var valueStr:String = "";
			for each (var key:String in keys)
			{
				if (record[key] == null)
					continue;
				keyStr += key + ",";
				valueStr += formatColumnValue(record[key]) + ",";
			}	
			return StringUtil.substitute("({0}) VALUES ({1})", [keyStr.slice( 0, -1 ), valueStr.slice( 0, -1 )]);
		}
		
		// Build key = value string for the update sql statement
		private function buildDdotUpdateKeyValueStr(record:Object, keys:Array):String
		{
			var updateStr:String = "";
			for each (var key:String in keys)
			{
				if (record[key] == null)
					continue;
				updateStr += StringUtil.substitute("{0}={1},", [key, formatColumnValue(record[key])]);
			}
			return updateStr.slice( 0, -1 )
		}
		
		public function addDdotSign(sign:Object):void
		{
			var signColumns:Array = new Array("SIGNID", "POLEID", "SIGNNAME", "DESCRIPTION", "SIGNFACING", "SIGNHEIGHT", "SIGNSTATUS", "ARROWDIRECTION", "COMMENT")
			sStat.text = "INSERT INTO SIGNS " + buildDdotInsertKeyValueStr(sign, signColumns); 
			sStat.execute();
		}
		
		public function updateDdotSign(sign:Object):void
		{
			var signColumns:Array = new Array("SIGNID", "POLEID", "SIGNNAME", "DESCRIPTION", "SIGNFACING", "SIGNHEIGHT", "SIGNSTATUS", "ARROWDIRECTION", "COMMENT");
			sStat.text = StringUtil.substitute("UPDATE SIGNS SET {0} WHERE SIGNID={1}", [buildDdotUpdateKeyValueStr(sign, signColumns), sign['SIGNID'].toString()]);
			sStat.execute();
		}
		
		// Check to see if culvert domain table is populated
		public function isDdotSignExist(signID:Number):Boolean
		{
			sStat.text = "SELECT * from SIGNS where SIGNID =" + signID.toString();
			sStat.execute();
			var data:Array = sStat.getResult().data;
			if (data == null)
				return false;
			else if (data.length > 0)
				return true;
			else
				return false;
		}
		
		public function getDdotSignByPoleID(poleID:Number):ArrayCollection
		{
			var signs:ArrayCollection = new ArrayCollection();
			try
			{
				sStat.text = "SELECT * FROM SIGNS WHERE POLEID = " + poleID;
				sStat.execute();
				var data:Array = sStat.getResult().data;
				signs = new ArrayCollection(data);
			}
			catch(err:Error)
			{
				FlexGlobals.topLevelApplication.TSSAlert(err.message);
			}
			return signs;
		}
		
		public function addDdotInspection(inspection:Object):void
		{
			var inspectionColumns:Array = new Array("INSPECTIONID", "POLEID", "SIGNID", "INSPECTOR", "DATEINSPECTED", "TYPE", "OVERALLCONDITION", "ACTIONTAKEN", 
				"ADDITIONALACTIONNEEDED", "BENT", "TWISTED", "LOOSE", "RUSTED", "FADED", "PEELING", "OTHER");
			sStat.text = "INSERT INTO INSPECTIONS " + buildDdotInsertKeyValueStr(inspection, inspectionColumns); 
			sStat.execute();
		}
		
		public function updateDdotInspection(inspection:Object):void
		{
			var inspectionColumns:Array = new Array("INSPECTIONID", "POLEID", "SIGNID", "INSPECTOR", "DATEINSPECTED", "TYPE", "OVERALLCONDITION", "ACTIONTAKEN", 
				"ADDITIONALACTIONNEEDED", "BENT", "TWISTED", "LOOSE", "RUSTED", "FADED", "PEELING", "OTHER");
			sStat.text = StringUtil.substitute("UPDATE INSPECTIONS SET {0} WHERE INSPECTIONID={1}", [buildDdotUpdateKeyValueStr(inspection, inspectionColumns), inspection['INSPECTIONID'].toString()]);
			sStat.execute();
		}
		
		public function isDdotInspectionExist(inspectionID:Number):Boolean
		{
			sStat.text = "SELECT * from INSPECTIONS where INSPECTIONID =" + inspectionID.toString();
			sStat.execute();
			var data:Array = sStat.getResult().data;
			if (data == null)
				return false;
			else if (data.length > 0)
				return true;
			else
				return false;
		}
	}
}