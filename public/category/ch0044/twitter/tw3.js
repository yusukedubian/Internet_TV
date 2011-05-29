/**
 * クラス名: tw3.js
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
url_tw3 = "http://search.twitter.com/search.atom?q=";
search_str = "無線LAN"
url = url_tw3 + search_str;
id_tw3  = "tw3";
num_tw3 = 50;


/**
 * メソッド名: tw3
 * 
 * 引数: 無し
 * 
 * 戻り値: 無し
 * 
 * 備考: 初期化処理
 */
function tw3() {
	var feed = new google.feeds.Feed(url);
	feed.setResultFormat(google.feeds.Feed.XML_FORMAT);
	feed.setNumEntries(num_tw3);
	feed.load(function(result){
		if (!result.error) {
			var items = result.xmlDocument.getElementsByTagName("entry");
			convert(items, id_tw3, num_tw3, search_str);
		}
	});	
}


google.setOnLoadCallback(tw3);
