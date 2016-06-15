package appManager.displayContent
{
	import appManager.displayContentElemets.LightImage;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	internal class SliderGalleryElements extends MovieClip
	{
		private var lightImage:LightImage ;
		
		private var myArea:Rectangle ;
		
		private var lastImage:SliderImageItem ;
		
		private var lastImageLoaded:String ;
		
		private var H:Number;
		
		private var myPreloader:MovieClip ;
		private var preLoaderShowerTimeOutId:uint;
		
		/**All light images will store here*/
		private var lightImageHistory:Vector.<LightImage>,
					lightImageLinks:Vector.<String> ;
					
		private var maxHistory:uint = 5 ;
		
		public function SliderGalleryElements(rect:Rectangle)
		{
			super();
			
			lightImageHistory = new Vector.<LightImage>();
			lightImageLinks = new Vector.<String>();
			
			myArea = rect.clone() ;
			lightImage = new LightImage();
			//lightImage.animated = false ;
			this.addChild(lightImage);
			//this.graphics.beginFill(0x000000,0.5);
			//this.graphics.drawRect(0,0,rect.width,rect.height);
			
			if(SliderGallery.preloaderClass!=null)
			{
				myPreloader = new SliderGallery.preloaderClass();
				this.addChild(myPreloader);
				myPreloader.x = myArea.width/2;
				myPreloader.y = myArea.height/2;
			}
			
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
			
			drawBackGround();
		}
		
		private function drawBackGround():void
		{
			if(SliderGallery.imageBackGroundColor!=-1)
			{
				this.graphics.clear();
				this.graphics.beginFill(SliderGallery.imageBackGroundColor,SliderGallery.imageBackAlpha);
				this.graphics.drawRect(0,0,myArea.width,myArea.height);
			}
		}
		
		protected function unLoad(e:Event):void
		{
			clearTimeout(preLoaderShowerTimeOutId);
		}
		
		override public function set height(value:Number):void
		{
			myArea.height = value ;
			if(myPreloader)
			{
				myPreloader.y = myArea.height/2;
			}
			Obj.remove(lightImage);
			lightImage = new LightImage();
			this.addChild(lightImage);
			drawBackGround();
			load();
		}
		
		override public function get height():Number
		{
			return myArea.height ;
		}
		
		public function load(image:SliderImageItem=null):void
		{
			clearTimeout(preLoaderShowerTimeOutId);
			if((image==null && lastImage!=null) || image!=lastImage)
			{
				if(image==null)
				{
					image = lastImage ;
				}
				
				lightImage.removeEventListener(Event.COMPLETE,imageLoaded);
				
				var imageWasLoadedBefor:Boolean = false ;
				
				if(false && image.image is String)
				{
					trace("Damaging");
					for(var i = 0 ; i<lightImageHistory.length ; i++)
					{
						if(lightImageLinks[i] == image.image )
						{
							lightImage.visible = false ;
							lightImage = lightImageHistory[i];
							lightImage.visible = true ;
							imageWasLoadedBefor = true ;
							break;
						}
					}
				}
				
				if(!imageWasLoadedBefor)
				{
					lightImage.addEventListener(Event.COMPLETE,imageLoaded);
					
					if(myPreloader)
					{
						preLoaderShowerTimeOutId = setTimeout(showPreLoader,5);
					}
					
					
					if(image.image is BitmapData)
					{
						lightImage.setUpBitmapData(image.image,false,myArea.width,myArea.height,0,0,true);
					}
					else if(image.image is ByteArray)
					{
						lightImage.setUpBytes(image.image,false,myArea.width,myArea.height,0,0,true);
					}
					else if(image.image is String)
					{
						lightImage.setUp(image.image,false,myArea.width,myArea.height,0,0,true);
					}
					
					if(image.image is String)
					{
						lightImageHistory.push(lightImage);
						lightImageLinks.push(image.image);
					}
				}
				
				lastImage = image ;
				
				
				if(lightImageHistory.length>maxHistory)
				{
					var lightOne:LightImage = lightImageHistory.shift();
					lightImageLinks.shift();
					Obj.remove(lightOne);
				}
			}
		}
		
		
		private function imageLoaded(e:Event):void
		{
			if(myPreloader)
			{
				myPreloader.visible = false ;
			}
			clearTimeout(preLoaderShowerTimeOutId);
		}
		
		
		private function showPreLoader():void
		{
			myPreloader.visible = true ;
			this.addChild(myPreloader);
		}
	}
}