/**
 * クラス名: tw4.js
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
url_tw4 = "http://search.twitter.com/search.atom?q=";
search_str = "Java　開発"
url = url_tw4 + search_str;
id_tw4  = "tw4";
num_tw4 = 80;


/**
 * メソッド名: tw4
 * 
 * 引数: 無し
 * 
 * 戻り値: 無し
 * 
 * 備考: 初期化処理
 */
function tw4() {
	var feed = new google.feeds.Feed(url);
	feed.setResultFormat(google.feeds.Feed.XML_FORMAT);
	feed.setNumEntries(num_tw4);
	feed.load(function(result){
		if (!result.error) {
			var items = result.xmlDocument.getElementsByTagName("entry");
			convert(items, id_tw4, num_tw4, search_str);
		}
	});	
}


google.setOnLoadCallback(tw4);
