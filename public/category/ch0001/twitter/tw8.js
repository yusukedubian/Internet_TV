/**
 * クラス名: tw8.js
 * 
 * バージョン情報: 2009042401NO
 *
 * 日付け: 2009/04/24
 * 
 * 著作権: Vasdaq Japan,Ltd.
 * 
 * 備考: RSSを取得するための初期化
 * 
 */
google.load('feeds', '1');
url_tw8 = "http://search.twitter.com/search.atom?q=";
search_str = "ソフトウェア"
url = url_tw8 + search_str;
id_tw8  = "tw8";
num_tw8 = 50;


/**
 * メソッド名: tw8
 * 
 * 引数: 無し
 * 
 * 戻り値: 無し
 * 
 * 備考: 初期化処理
 */
function tw8() {
	var feed = new google.feeds.Feed(url);
	feed.setResultFormat(google.feeds.Feed.XML_FORMAT);
	feed.setNumEntries(num_tw8);
	feed.load(function(result){
		if (!result.error) {
			var items = result.xmlDocument.getElementsByTagName("entry");
			convert(items, id_tw8, num_tw8, search_str);
		}
	});	
}


google.setOnLoadCallback(tw8);
