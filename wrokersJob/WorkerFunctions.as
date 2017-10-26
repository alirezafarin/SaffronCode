package wrokersJob
{
	import contents.alert.Alert;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	public class WorkerFunctions
	{
		private static var currentWorker:uint = 0 ;
		private static var totalWorkers:uint ;
		private static var workers:Vector.<Worker> ;
		
		private static var receiverChallens:Vector.<MessageChannel> ;
		
		private static var isReady:Boolean = false ;
		
		
		private static var senderChannels:Vector.<MessageChannel> ;
		
		private static var  funcList:Vector.<Function>,
							idList:Vector.<uint>;
							
		private static var lastID:uint = 0 ;
		
		/**This variable uses when you are in debugging mode*/
		private static var bgEmulator:BgWorker ;
		
		public static function setUp(TotalWorkers:uint = 4):void
		{
			totalWorkers = TotalWorkers ;
			funcList = new Vector.<Function>() ;
			idList = new Vector.<uint>() ;
			
			var workerBytes:ByteArray = FileManager.loadFile(new File("D://Sepehr//gitHub/sepehrEngine/SaffronEngine/Data-sample/bgWork.swf"));
			
			if(!Capabilities.isDebugger)
			{
				workers = new Vector.<Worker>();
				senderChannels = new Vector.<MessageChannel>();
				receiverChallens = new Vector.<MessageChannel>();
				for(var i:int = 0 ; i<totalWorkers ; i++)
				{
					var worker:Worker = WorkerDomain.current.createWorker(workerBytes,true);
					worker.addEventListener(Event.WORKER_STATE, workerStateHandler);
					
					var senderChannel:MessageChannel = Worker.current.createMessageChannel(worker);
					worker.setSharedProperty("senderChannel_fromMainProject", senderChannel);
					
					var receiverChannel:MessageChannel = worker.createMessageChannel(Worker.current);
					receiverChannel.addEventListener(Event.CHANNEL_MESSAGE, handlecustomeChannel)
					worker.setSharedProperty("receiverChannel_fromMainProject", receiverChannel);
					worker.start();
					
					workers.push(worker);
					senderChannels.push(senderChannel);
					receiverChallens.push(receiverChannel);
				}
			}
			else
			{
				bgEmulator = new BgWorker(handlecustomeChannel);
			}
		}
		
		/**Select a sender channel*/
		private static function selectSenderTosend():MessageChannel
		{
			currentWorker++ ;
			//Alert.show("Selected Worker is : "+(currentWorker%totalWorkers));
			return senderChannels[currentWorker%totalWorkers] ;
		}
		
		/**Worker state*/
		private static function workerStateHandler(e:Event) {
			var worker:Worker = e.currentTarget as Worker ;
			trace("Worker State : "+worker.state);
			isReady = worker.state == WorkerState.RUNNING ;
		}
		
		
		/**The receiver function will receive array of byteOfBitmap,Width,Heigh or null to make a bitmapData with BitmapData.setPixels() function*/
		public static function createBitmapFromByte(byteOrURLString:*,receiver:Function,loadInThisArea:Boolean=false, imageW:Number=0, imageH:Number=0, keepRatio:Boolean=true):void
		{
			var currentId:uint = lastID++ ;
			
			funcList.push(receiver);
			idList.push(currentId);
			
			var toSendValue:Array = [BgWorker.id_byteToBitmap,currentId,[byteOrURLString,loadInThisArea,imageW,imageH,keepRatio]] ;
			
			
			if(!Capabilities.isDebugger)
			{
				//var tim:Number = getTimer();
				//It takes time to pass big bytes here
				selectSenderTosend().send(toSendValue);
				//Alert.show("Get timer : "+(getTimer()-tim));
			}
			else
			{
				bgEmulator.handleCommandMessage(toSendValue);
			}
		}
		
		
		/**You will recevie your objec on your receiver function on the first unit of an Array.*/
		public static function JSONPars(str:String,receiver:Function):void
		{
			var currentId:uint = lastID++ ;
			
			funcList.push(receiver);
			idList.push(currentId);
			
			trace("Function id list updated : "+idList+' vs currentId :'+currentId);
			
			var toSendValue:Array = [BgWorker.id_jsonParser,currentId,str] ;
			
			if(!Capabilities.isDebugger)
			{
				selectSenderTosend().send(toSendValue);
			}
			else
			{
				bgEmulator.handleCommandMessage(toSendValue);
			}
		}
		
		/**Received data from worker*/
		private static function handlecustomeChannel(eventOrDebugValue:*):void
		{
			trace('Receved event on worker caller ');
			var received:Array;
			if(eventOrDebugValue is Array)
			{
				received = eventOrDebugValue ;
			}
			else if(eventOrDebugValue is Event)
			{
				var receiverChannel:MessageChannel = eventOrDebugValue.currentTarget as MessageChannel ;
				received = receiverChannel.receive();
			}
			trace("Received data type is : "+getQualifiedClassName(received[1]));
			callFunction(received[0],received[1]);
		}
		
		/**Send this data to its recever*/
		private static function callFunction(callerId:uint,data:Object):void
		{
			//Alert.show(callerId+' function id receved '+((data.hasOwnProperty('length'))?"[data length is : "+data.length+"]":data)+' function ids are : '+idList);
			var I:int = idList.indexOf(callerId) ;
			trace("Function founded : "+I);
			if(I!=-1)
			{
				funcList[I](data);
				
				funcList.removeAt(I);
				idList.removeAt(I);
			}
		}
	}
}