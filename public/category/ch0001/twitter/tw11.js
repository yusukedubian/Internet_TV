/**
 * クラス名: tw11.js
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
url_tw11 = "http://search.twitter.com/search.atom?q=";
search_str = "プロジェクト"
url = url_tw11 + search_str;
id_tw11  = "tw11";
num_tw11 = 50;


/**
 * メソッド名: tw11
 * 
 * 引数: 無し
 * 
 * 戻り値: 無し
 * 
 * 備考: 初期化処理
 */
function tw11() {
	var feed = new google.feeds.Feed(url);
	feed.setResultFormat(google.feeds.Feed.XML_FORMAT);
	feed.setNumEntries(num_tw11);
	feed.load(function(result){
		if (!result.error) {
			var items = result.xmlDocument.getElementsByTagName("entry");
			convert(items, id_tw11, num_tw11, search_str);
		}
	});	
}


google.setOnLoadCallback(tw11);
