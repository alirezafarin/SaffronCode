﻿package dataManager
{
	import com.mteamapp.Encrypt;
	import com.mteamapp.JSONParser;
	
	import flash.net.SharedObject;

	public class GlobalStorage
	{
		private static var storage:SharedObject ; 
		private static var bigDataStorage:SharedObject ;
		
		/**Do not encrypt strings with length of more than this*/
		private static const maxLengthForEncryptableStrings:uint = 200 ;
		
		private static function setUp():void
		{
			if(storage==null)
			{
				storage = SharedObject.getLocal("MyGlobalStorage2",'/');
				bigDataStorage = SharedObject.getLocal("MyGlobalStoragebigData",'/');
			}
		}
		
		/**Boolean, Number, String supported*/
		public static function load(id:String):*
		{
			setUp();
			id = Encrypt.encrypt(id,DevicePrefrence.DeviceUniqueId()) ;
			var loadedString:* = storage.data[id] ; 
			if( loadedString == undefined)
			{
				loadedString = bigDataStorage.data[id] ;
				if(loadedString == undefined)
				{
					return null ;
				}
				return loadedString ;
			}
			else
			{
				if(loadedString != null)
				{
					return Encrypt.decrypt(loadedString,DevicePrefrence.DeviceUniqueId()) ;
				}
				else
				{
					loadedString = bigDataStorage.data[id] ;
					return loadedString ;
				}
			}
		}
		
		/**Boolean, Number, Stirng is supported*/
		public static function save(id:String,value:*,flush:Boolean=true):void
		{
			setUp();
			id = Encrypt.encrypt(id,DevicePrefrence.DeviceUniqueId());
			if(value is String && value.length>maxLengthForEncryptableStrings)
			{
				bigDataStorage.data[id] = value ;
				if(storage.data[id]!=undefined)
				{
					storage.data[id] = undefined ;
					storage.flush();
				}
				if(flush)
				{
					bigDataStorage.flush();
				}
			}
			else
			{
				storage.data[id] = Encrypt.encrypt(value,DevicePrefrence.DeviceUniqueId()) ;
				if(flush)
				{
					storage.flush();
				}
			}
		}
		
		
		public static function loadObject(id:String,catcherObject:*):*
		{
			var jsonObject:String = load(id);
			if(jsonObject==null)
			{
				return null ;
			}
			//trace("jsonObject : "+jsonObject);
			return JSONParser.parse(jsonObject,catcherObject);
		}
		public static function loadObject2(id:String):Vector.<uint>
		{
			var jsonObject:String = load(id);
			if(jsonObject==null)
			{
				return null ;
			}
			//trace('jsonObject :',jsonObject)
			var obj:Object = JSON.parse(jsonObject);
			var _list:Vector.<uint> = new Vector.<uint>
			for each(var value:uint in obj)
			{
				_list.push(value)
			}
			return _list
		}

		public static function saveObject(id:String,saverObject:*,flush:Boolean=true):void
		{
			var jsonString:String = JSONParser.stringify(saverObject);
			save(id,jsonString,flush);
		}
		public static function Delete(id:String):void
		{
				setUp();
				delete storage.data[id];
		}
		
		public function Clear(id:String):void
		{
			setUp();
			storage.data[id] = null ;
			storage.flush();
		}
	}
}