/**
 * クラス名: ie.js
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
url_ie = "http://search.twitter.com/search.atom?q=";
search_str = "i phone"
url = url_ie + search_str;
id_ie  = "ie";
num_ie = 50;


/**
 * メソッド名: ie
 * 
 * 引数: 無し
 * 
 * 戻り値: 無し
 * 
 * 備考: 初期化処理
 */
function ie() {
	var feed = new google.feeds.Feed(url);
	feed.setResultFormat(google.feeds.Feed.XML_FORMAT);
	feed.setNumEntries(num_ie);
	feed.load(function(result){
		if (!result.error) {
			var items = result.xmlDocument.getElementsByTagName("entry");
			convert(items, id_ie, num_ie, search_str);
		}
	});	
}


google.setOnLoadCallback(ie);
