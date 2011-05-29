/**
 * クラス名: tw9.js
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
url_tw9 = "http://search.twitter.com/search.atom?q=";
search_str = "セキュリティ"
url = url_tw9 + search_str;
id_tw9  = "tw9";
num_tw9 = 50;


/**
 * メソッド名: tw9
 * 
 * 引数: 無し
 * 
 * 戻り値: 無し
 * 
 * 備考: 初期化処理
 */
function tw9() {
	var feed = new google.feeds.Feed(url);
	feed.setResultFormat(google.feeds.Feed.XML_FORMAT);
	feed.setNumEntries(num_tw9);
	feed.load(function(result){
		if (!result.error) {
			var items = result.xmlDocument.getElementsByTagName("entry");
			convert(items, id_tw9, num_tw9, search_str);
		}
	});	
}


google.setOnLoadCallback(tw9);
