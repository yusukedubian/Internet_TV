/**
 * クラス名: tw12.js
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
url_tw12 = "http://search.twitter.com/search.atom?q=";
search_str = "運用"
url = url_tw12 + search_str;
id_tw12  = "tw12";
num_tw12 = 50;


/**
 * メソッド名: tw12
 * 
 * 引数: 無し
 * 
 * 戻り値: 無し
 * 
 * 備考: 初期化処理
 */
function tw12() {
	var feed = new google.feeds.Feed(url);
	feed.setResultFormat(google.feeds.Feed.XML_FORMAT);
	feed.setNumEntries(num_tw12);
	feed.load(function(result){
		if (!result.error) {
			var items = result.xmlDocument.getElementsByTagName("entry");
			convert(items, id_tw12, num_tw12, search_str);
		}
	});	
}


google.setOnLoadCallback(tw12);
