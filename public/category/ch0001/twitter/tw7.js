/**
 * クラス名: tw7.js
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
url_tw7 = "http://search.twitter.com/search.atom?q=";
search_str = "アーキテクチャ"
url = url_tw7 + search_str;
id_tw7  = "tw7";
num_tw7 = 80;


/**
 * メソッド名: tw7
 * 
 * 引数: 無し
 * 
 * 戻り値: 無し
 * 
 * 備考: 初期化処理
 */
function tw7() {
	var feed = new google.feeds.Feed(url);
	feed.setResultFormat(google.feeds.Feed.XML_FORMAT);
	feed.setNumEntries(num_tw7);
	feed.load(function(result){
		if (!result.error) {
			var items = result.xmlDocument.getElementsByTagName("entry");
			convert(items, id_tw7, num_tw7, search_str);
		}
	});	
}


google.setOnLoadCallback(tw7);
