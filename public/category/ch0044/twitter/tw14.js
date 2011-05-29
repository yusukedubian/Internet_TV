/**
 * クラス名: tw14.js
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
url_tw14 = "http://search.twitter.com/search.atom?q=";
search_str = "アプリ"
url = url_tw14 + search_str;
id_tw14  = "tw14";
num_tw14 = 50;


/**
 * メソッド名: tw14
 * 
 * 引数: 無し
 * 
 * 戻り値: 無し
 * 
 * 備考: 初期化処理
 */
function tw14() {
	var feed = new google.feeds.Feed(url);
	feed.setResultFormat(google.feeds.Feed.XML_FORMAT);
	feed.setNumEntries(num_tw14);
	feed.load(function(result){
		if (!result.error) {
			var items = result.xmlDocument.getElementsByTagName("entry");
			convert(items, id_tw14, num_tw14, search_str);
		}
	});	
}


google.setOnLoadCallback(tw14);
