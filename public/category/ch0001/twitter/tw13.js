/**
 * クラス名: tw13.js
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
url_tw13 = "http://search.twitter.com/search.atom?q=";
search_str = "クラウド"
url = url_tw13 + search_str;
id_tw13  = "tw13";
num_tw13 = 80;


/**
 * メソッド名: tw13
 * 
 * 引数: 無し
 * 
 * 戻り値: 無し
 * 
 * 備考: 初期化処理
 */
function tw13() {
	var feed = new google.feeds.Feed(url);
	feed.setResultFormat(google.feeds.Feed.XML_FORMAT);
	feed.setNumEntries(num_tw13);
	feed.load(function(result){
		if (!result.error) {
			var items = result.xmlDocument.getElementsByTagName("entry");
			convert(items, id_tw13, num_tw13, search_str);
		}
	});	
}


google.setOnLoadCallback(tw13);
