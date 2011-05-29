/**
 * クラス名: tw5.js
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
url_tw5 = "http://search.twitter.com/search.atom?q=";
search_str = "プログラマ"
url = url_tw5 + search_str;
id_tw5  = "tw5";
num_tw5 = 50;


/**
 * メソッド名: tw5
 * 
 * 引数: 無し
 * 
 * 戻り値: 無し
 * 
 * 備考: 初期化処理
 */
function tw5() {
	var feed = new google.feeds.Feed(url);
	feed.setResultFormat(google.feeds.Feed.XML_FORMAT);
	feed.setNumEntries(num_tw5);
	feed.load(function(result){
		if (!result.error) {
			var items = result.xmlDocument.getElementsByTagName("entry");
			convert(items, id_tw5, num_tw5, search_str);
		}
	});	
}


google.setOnLoadCallback(tw5);
