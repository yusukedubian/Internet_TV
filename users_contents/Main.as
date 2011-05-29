package 
{
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.geom.Matrix;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	import flash.display.Sprite;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.*;


	/**
     * 電光掲示板
     */
    [SWF(width="545", height="545", backgroundColor="0x000000")]
    public class Main extends Sprite 
    {
		
        /**
         * 文字列のピクセルを入れるビットマップデータ
         */
        private var data:BitmapData;
        /**
         * 1 フレーム経過するごとに一定量ずつ値を足す
         * スクロール値に使用
         */
        private var frameCount:Number;
        
        /**
         * 電光掲示板に表示する内容が入ったテキストフィールド
         */
        private var textField:TextField;
        
        /**
         * テキストフィールドのピクセルを取得する時に使うスプライト
         */
        private var sourceSprite:Sprite;
		private var sprite1:Sprite;
		private var sprite2:Sprite;
        //追加分(RSSを読み込むためのオブジェクト群)
		private var rssXML:XML;
		private var rssObj:URLLoader;
		private var changed:Boolean;
		//x初期化
		private var x1:int = 100;
		//y初期化
		private var y1:int = 100;
		//スクロール方向
		private var scrollDirection:String;
		//色
		private var txtcolors:Array;
		//xml
		private var xml:XML = new XML();
		//図分割に使用
		private var txtbmp:Array = new Array();
		//図分割幅に使用
		private var txtwidthI:int;
		private var txtwidthA:Array = new Array();
		//図分割高に使用
		private var txtheightI:int;
		private var txtheightA:Array = new Array();

        /**
         * コンストラクタ
         */
        public function Main():void 
        {
			if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
		/**
         * 初期化イベント
         * @param    e
         */
        private function init(e:Event = null):void 
        {
			var loader:URLLoader = new URLLoader();
            configureListeners(loader);

            var request:URLRequest = new URLRequest("index.xml");
            try {
                loader.load(request);
            } catch (error:Error) {
                trace("Unable to load requested document.");
            }
        }

        
        /**
         * フレーム開始イベント
         * @param    event
         */
        private function onEnterFrame(event:Event):void 
		{
			var x:int = 0;
			var y:int = 0;
			var i:int;
			var j:int;
			var fcount:int;
			var pixel:uint;

            // フレーム数のカウント
            frameCount++;

			// 文字列サイズを超えたら初期値にする
			if (frameCount > txtheightI && scrollDirection == "up") {
				frameCount = -y1;

			}
			if (frameCount > txtwidthI && scrollDirection == "Left") {
				frameCount = -x1;
			}

			// 画面に描かれた内容をいったんクリア
			sprite2.graphics.clear();

			if (scrollDirection == "up") {
				for (y = 0; y < y1; y++)
				{
					for ( x = 0; x < x1; x++)
					{
						if (frameCount+y > txtheightI || frameCount+y < 0) {
							j = 0;
						} else {
							for (i = 0; i<txtheightA.length; i++ ) {
								if (frameCount+y < txtheightA[i]) {
									break;
								}
							}
							j = i-1;
						}
						fcount = (frameCount+y) - (txtheightA[j]);

						// 表示範囲を超えていたら強制的に OFF
						if (fcount < 0)
							pixel = 0;
						else
							pixel = txtbmp[j].getPixel(x, fcount);

						if (pixel != 0)
							drawDot(0 + x * 5.5, 0 + y * 5.5, 2.5, txtcolors[0], txtcolors[1], sprite2); 
					}
				}
			} else {
				for (y = 0; y < y1; y++)
				{
					for (x = 0; x < x1; x++)
					{
						if (frameCount+x > txtwidthI || frameCount+x < 0) {
							j = 0;
						} else {
							for (i = 0; i<txtwidthA.length; i++ ) {
								if (frameCount+x < txtwidthA[i]) {
									break;
								}
							}
							j = i-1;
						}
						fcount = (frameCount+x) - (txtwidthA[j]);
						
						// 表示範囲を超えていたら強制的に OFF 
						if (fcount < 0) 
							pixel = 0;
						else 
							pixel = txtbmp[j].getPixel(fcount, y);
							
						if (pixel != 0) 
							drawDot(0 + x * 5.5, 0 + y * 5.5, 2.5, txtcolors[0], txtcolors[1], sprite2);             
					}
				}
			}
        }


        /**
         * 点を描く
         * @param    x            点の中心の X 座標
         * @param    y            点の中心の Y 座標
         * @param    size        点の大きさ
         * @param    colorLight    明るい場所の色
         * @param    colorDark    暗い場所の色
         */
        private function drawDot(x:Number, y:Number, size:Number, colorLight:uint, colorDark:uint, sp:Sprite):void
        {
            var colors:Array = [colorLight, colorDark];
            var alphas:Array = [1.0, 1.0];
            var ratios:Array = [0, 255];
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(size * 2, 
                                     size * 2, 
                                     0,
                                     x - size,
                                     y - size);
            
            sp.graphics.lineStyle();
            sp.graphics.beginGradientFill(GradientType.RADIAL, 
                                          colors,
                                          alphas,
                                          ratios,
                                          matrix);
            sp.graphics.drawCircle(x, y, size);
            sp.graphics.endFill();    
        }
		
		
        /**
         * configureListeners
         */
		private function configureListeners(dispatcher:IEventDispatcher):void
		{
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
        }
        /**
         * completeHandler
         */
		private function completeHandler(event:Event):void
		{
            var loader:URLLoader = URLLoader(event.target);
            xml = new XML(loader.data);

			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			if (xml.text_type == "rss") {
				//RSS読み込み開始
				rssObj = new URLLoader(new URLRequest(xml.rss_url));
				rssObj.addEventListener(Event.COMPLETE , onComplete);
			} else {
				// フレーム開始イベントの登録
				pageSet(xml,"");
			}
		}

        /**
         * onComplete
         */
		private function onComplete(e:Event):void
		{
			//読み込んだデータをXMLに変換後、最初の記事のタイトルをtextfieldに入れる
			pageSet(xml,e.target.data);
		}
		 /**
         * pageSet
         */
		private function pageSet(xml:Object, str:String):void
		{
			//フォント色
			var fontColor:int;

			scrollDirection = xml.scroll_direction;
			fontColor = parseInt(xml.font_color);
            //速度
			stage.frameRate = xml.scroll_speed;

			//比例
			stage.scaleMode = StageScaleMode.NO_BORDER;
			stage.align = StageAlign.TOP_LEFT;

            // スプライトの初期化
            sourceSprite = new Sprite();

            textField = new TextField();
            textField.autoSize = TextFieldAutoSize.LEFT;

            textField.background = true;
            textField.backgroundColor = 0x000000;
			var format:TextFormat = new TextFormat();
			
			var textTemp:String;
			textTemp = xml.text_content;
			textTemp = textTemp.replace(/\n/g,"");

			if (scrollDirection == "Left") {

				if (xml.text_type == "rss") {
					str = str.replace(/\r/g,"");
					textField.text = str;
					textTemp = str;
				} else {
					textField.text = textTemp;
				}
			} else {
				if (xml.text_type == "rss") {
					textField.text = str;
					textTemp = str;
				} else {
					textField.text = textTemp;
				}
					textField.multiline = true;
					textField.wordWrap = true;
			}

			// スプライトにテキストフィールドを登録
			format.color = 0x0000FF;
			format.size = xml.font_size;
			format.font = "ＭＳ ゴシック";

			// 文字の隙間
			format.letterSpacing = 1;
			textField.setTextFormat(format);

			//赤
			if (fontColor == 0xFF0000) {
				txtcolors = [0xFF0000, 0x800000, 0x600000, 0x400000];
			//緑
			} else if (fontColor == 0x00FF00) {
				txtcolors = [0x00FF00, 0x008000, 0x006000, 0x004000];
			//青
			} else if (fontColor == 0x0000FF) {
				txtcolors = [0x0000FF, 0x000080, 0x000060, 0x000040];
			//黄
			} else if (fontColor == 0xFFFF00) {
				txtcolors = [0xFFFF00, 0x808000, 0x606000, 0x404000];
			//ピンク
			} else if (fontColor == 0xFFEEFF) {
				txtcolors = [0xFFEEFF, 0xFF00CC, 0xCC3399, 0x400040];
			//水色
			} else if (fontColor == 0x00FFFF) {
				txtcolors = [0x00FFFF, 0x008080, 0x006060, 0x004040];
			//灰
			} else if (fontColor == 0xFFFFFF) {
				txtcolors = [0xFFFFFF, 0x808080, 0x606060, 0x404040];
			//オレンジ色
			} else if (fontColor == 0xFFCC33) {
				txtcolors = [0xFFCC33, 0x802000, 0x606000, 0x402000];
			//紫
			} else if (fontColor == 0x9900FF) {
				txtcolors = [0x9900FF, 0x800080, 0x600060, 0x400040];
			}
			//図数
			var bmpcount:int;
			var txtcount:int;

			if (scrollDirection == "Left") {
				
				var x:int = 0;
				bmpcount = Math.ceil(textField.width/7500);
				txtcount = Math.ceil(textField.length/bmpcount);

				for (x = 0; x < bmpcount; x++) {

					var textFieldL:TextField = new TextField();

					textFieldL.autoSize = TextFieldAutoSize.LEFT;
					textFieldL.background = true;
					textFieldL.backgroundColor = 0x000000;
					
					textFieldL.text = textTemp.substring(x*txtcount, txtcount*(x+1));
					textFieldL.setTextFormat(format);

					sourceSprite.addChild(textFieldL);

					data = new BitmapData(textFieldL.width, textFieldL.height, true, 0);
            		data.draw(sourceSprite);
					txtbmp.push(data);
					txtwidthI += textFieldL.width;
					
					if (x == 0) {
						txtwidthA[x] = 0;
					} else {
						txtwidthA[x] = txtwidthA[x-1] + txtbmp[x-1].width;
					}
				}
			} else {

				var y:int = 0;
				bmpcount = Math.ceil(textField.height/7500);
				txtcount = Math.ceil(textField.length/bmpcount);
				
				for (y = 0; y < bmpcount; y++) {
					
					var textFieldH:TextField = new TextField();
					textFieldH.width = 100;
					textFieldH.autoSize = TextFieldAutoSize.LEFT;
					textFieldH.background = true;
					textFieldH.backgroundColor = 0x000000;

					textFieldH.text = textTemp.substring(y*txtcount, txtcount*(y+1));
					textFieldH.multiline = true;
					textFieldH.wordWrap = true;
					textFieldH.setTextFormat(format);

					sourceSprite.addChild(textFieldH);

					data = new BitmapData(textFieldH.width, textFieldH.height, true, 0);
            		data.draw(sourceSprite);

					txtbmp.push(data);	
					txtheightI += textFieldH.height;

					if (y == 0) {
						txtheightA[y] = 0;
					} else {
						txtheightA[y] = txtheightA[y-1] + txtbmp[y-1].height;
					}
				}
			}

			var w:int = parseInt(xml.text_width);
			var h:int = parseInt(xml.text_height);

			if (w > h) {
				y1 = y1 * Math.ceil(h / w);
			} else {
				x1 = x1 * Math.ceil(w / h);
			}

			// 初期スクロール値を設定
			if (scrollDirection == "Left") {
				frameCount = -x1;
			} else {
				frameCount = -y1;
			}
			
			sprite1 = new Sprite();
			sprite2 = new Sprite();
			for (y = 0; y < y1; y++) {
				
				for (x = 0; x < x1; x++) {
					drawDot(0 + x * 5.5, 0 + y * 5.5, 2.5, txtcolors[2], txtcolors[3], sprite1);
				}
				
			}
			x=0;
			y=0;
			addChild(sprite1);
			sprite1.cacheAsBitmap = true;
			addChild(sprite2);

			// フレーム開始イベントの登録
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
		}
	}
}