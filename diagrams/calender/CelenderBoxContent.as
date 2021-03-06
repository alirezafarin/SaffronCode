﻿package diagrams.calender
{
	import flash.display.MovieClip;
	import flash.text.TextFormatAlign;
	
	internal class CelenderBoxContent extends MovieClip
	{
		public function CelenderBoxContent(W:Number,H:Number,cashedContents:CalenderContents )
		{
			super();
			
			
			var maxH:Number = H/cashedContents.contents.length ;
			var l:uint = cashedContents.contents.length ;
			var currentContent:CalenderContent ;
			var lastY:Number = 0 ;
			for(var i = 0 ; i<l ; i++)
			{
				currentContent = cashedContents.contents[i];
				this.graphics.beginFill(chaneColor(currentContent.color,i));
				this.graphics.drawRect(0,lastY,W,maxH);
				
				var newTitle:CalenderText = new CalenderText(CalenderConstants.Color_content_text,
					CalenderConstants.Font_size_contents,
					CalenderConstants.Font_contents_name,
					TextFormatAlign.CENTER,
					CalenderConstants.LineSpacing_content_box
				);
				newTitle.width = W ;
				newTitle.height = maxH;
				newTitle.y = lastY ;
				
				UnicodeStatic.fastUnicodeOnLines(newTitle,currentContent.title,false);
				this.addChild(newTitle);
				
				lastY+=maxH ;
			}
		}
		
		private function chaneColor(color:uint, i:int):uint
		{
			if(i%2==0)
			{
				return color ;
			}
			else
			{
				var red:uint = 0xff0000&color;
				var green:uint = 0x00ff00&color;
				var blue:uint = 0x0000ff&color;
				
				red = Math.floor(red*0.9);
				red = red&0xff0000;
				green = Math.floor(green*0.9);
				green = green&0x00ff00;
				blue = Math.floor(blue*0.9);
				blue = blue&0x0000ff;
				
				var color2 = red+green+blue ;
				
				return color2;
			}
		}
	}
}