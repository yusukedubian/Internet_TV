google.load("feeds", "1");
google.setOnLoadCallback(main);

function main() {

	// 世界のこぼれ話
	world_news();
	// 占い
	fortune();
	// 絵本ランキング
	ranking();
	// エコグッズ
	eco();
	// 気になるピックアップ
	pickup();
	// みんなのペットギャラリー
	pet();
	// クイズコーナー
	quiz();
	// 全国スポットニュース
	spot();
	// 天気予報
	weather();

}

/***************************************************************************************
 * 世界のこぼれ話
 ***************************************************************************************/
function world_news() {
	var feed = new google.feeds.Feed("http://feeds.reuters.com/reuters/JPOddlyEnoughNews");
  feed.setNumEntries(10);
	feed.load(function(result) {
		if (!result.error) {
			var container = document.getElementById("kids_message");
			var html = "";
			for (var i = 0; i < result.feed.entries.length; i++) {
				var entry = result.feed.entries[i];
				html += "<div style='font-size:12px;margin-bottom:5px;border-bottom:1px dotted #333333;padding:3px;'>";
				html += "<img src='./img/icon_news.png' width='16' height='16' />&nbsp;" + entry.title + "";
				html += "</div>";
				html += "<div style='font-size:12px;margin-bottom:5px;padding:3px;'>";
				html += entry.contentSnippet;
				html += "</div>";
			}
			container.innerHTML = html;
		}
	});
}

/***************************************************************************************
 * 絵本ランキング
 ***************************************************************************************/
function ranking() {
		
	var html = "";
		
	// 絵本ランキング
	var feed = new google.feeds.Feed("http://www.amazon.co.jp/rss/bestsellers/books/492378/ref=pd_ts_rss_link");
	feed.load(function(result) {
		if (!result.error) {
			html += "<div align='center'> - 絵本ベストセラー - </div><br />";
			for (var i = 0; i < 3; i++) {
				var entry = result.feed.entries[i];
				var reg = new Regexies();
				var title = reg.match("title", entry.content);
				var author = reg.match("author", entry.content);
				var ranking = reg.match("ranking", entry.content);
				var published = reg.match("published", entry.content);
				var star = reg.match("star", entry.content);
				var link = reg.match("link", entry.content);
				var price = reg.match("price", entry.content);
				var remarks = reg.match("remarks", entry.content);
				
				html += "<div style='font-size:12px;margin-bottom:5px;border-bottom:1px dotted #333333;padding:3px;'>";
				html += "<img src='./img/icon_news.png' width='16' height='16' />&nbsp;" + entry.title.replace("#","No.") + "";
				html += "</div>";
				html += "<div style='font-size:12px;margin-bottom:5px;padding:3px;'>";
				html += "作家名:" + author + "<br />";
				html += "出版日:" + published + "<br />";
				html += "価格:" + price + "<br />";
				html += "</div>";
			}
		}
	});

　// こどもランキング
	feed = new google.feeds.Feed("http://www.amazon.co.jp/rss/bestsellers/books/466306/ref=pd_ts_rss_link");
	feed.load(function(result) {
		if (!result.error) {
			html += "<br />";
			html += "<div align='center'> - こどもベストセラー - </div><br />";
			var container = document.getElementById("question_message");
			for (var i = 0; i < 3; i++) {
				var entry = result.feed.entries[i];
				var reg = new Regexies();
				var title = reg.match("title", entry.content);
				var author = reg.match("author", entry.content);
				var ranking = reg.match("ranking", entry.content);
				var published = reg.match("published", entry.content);
				var star = reg.match("star", entry.content);
				var link = reg.match("link", entry.content);
				var price = reg.match("price", entry.content);
				var remarks = reg.match("remarks", entry.content);
				
				html += "<div style='font-size:12px;margin-bottom:5px;border-bottom:1px dotted #333333;padding:3px;'>";
				html += "<img src='./img/icon_news.png' width='16' height='16' />&nbsp;" + entry.title.replace("#","No.") + "";
				html += "</div>";
				html += "<div style='font-size:12px;margin-bottom:5px;padding:3px;'>";
				html += "作家名:" + author + "<br />";
				html += "出版日:" + published + "<br />";
				html += "価格:" + price + "<br />";
				html += "</div>";
			}
			container.innerHTML = html;	
		}
	});
}

/***************************************************************************************
 * 気になる情報ピックアップ
 ***************************************************************************************/
function pickup() {
	var feed = new google.feeds.Feed("http://www.amazon.co.jp/rss/bestsellers/dvd/562026/ref=pd_ts_rss_link");
  feed.setNumEntries(10);
	feed.load(function(result) {
		if (!result.error) {
			
			for (var i = 0; i < result.feed.entries.length; i++) {
			
				var html = "";
				var entry = result.feed.entries[i];
			
				var pickup_image = document.getElementById("pickup_image" + (i + 1));
				var pickup_title = document.getElementById("pickup_title" + (i + 1));
				var pickup_message = document.getElementById("pickup_message" + (i + 1));
						
				var rex = new RegExp("<img.+?>", "i");
				var imgs = entry.content.match(rex);
				var img = "";
				if (imgs.length > 0) {
					img = imgs[0];
				}
	
				var reg = new Regexies();
				var title = reg.match("title", entry.content);
				var author = reg.match("author", entry.content);
				var ranking = reg.match("ranking", entry.content);
				var published = reg.match("published", entry.content);
				var star = reg.match("star", entry.content);
				var link = reg.match("link", entry.content);
				var price = reg.match("price", entry.content);
				var remarks = reg.match("remarks", entry.content);
	
				pickup_image.innerHTML = img;	
				pickup_title.innerHTML = "<font style='font-size:12px;'>" + entry.title.substr(0, 30) + "</font>";	
				
				var table = "<br />";
				table += "<table width='280'>";
				table += "<tr>";
				table += "<td style='width:140px;'>";
				table += "【発売日】<br />&nbsp;&nbsp;";
				table += published.replace(/発売日:/g,'') + "<br /><br />";
				table += "</td>";
				table += "<td style='width:140px;'>";
				table += "【ランキング】<br />&nbsp;&nbsp;";
				table += ranking + "<br /><br />";
				table += "</td>";
				table += "</tr>";
				table += "<tr>";
				table += "<td style='width:140px;'>";
				table += "【価格】<br />&nbsp;&nbsp;";
				table += price;
				table += "</td>";
				table += "<td style='width:140px;'>";
				table += "【評価】<br />&nbsp;&nbsp;";
				table += star;
				table += "</td>";
				table += "</tr>";
				table += "</table>";
				
				pickup_message.innerHTML = table;
				
			}
		}
	});
}

/***************************************************************************************
 * 占い
 ***************************************************************************************/
function fortune() {
	var feed = new google.feeds.Feed("http://fortune.jp.msn.com/rss.aspx?rsstype=12rank");
  feed.setNumEntries(12);
	feed.load(function(result) {
		if (!result.error) {
			var container = document.getElementById("fortune_message");
			var html = "";
			for (var i = 0; i < result.feed.entries.length; i++) {
				var entry = result.feed.entries[i];
				html += "<div style='font-size:12px;margin-bottom:5px;border-bottom:1px dotted #333333;padding:3px;'>";
				html += "<img src='./img/icon_news.png' width='16' height='16' />&nbsp;" + entry.title + "";
				html += "</div>";
				html += "<div style='font-size:12px;margin-bottom:5px;padding:3px;'>";
				html += entry.contentSnippet;
				html += "</div>";
			}
			container.innerHTML = html;
		}
	});
}

/***************************************************************************************
 * エコチャレンジ
 ***************************************************************************************/
function eco() {
	var feed = new google.feeds.Feed("http://allabout.co.jp/gs/ecogoods/rss/index.xml");
  feed.setNumEntries(10);
	feed.load(function(result) {
		if (!result.error) {
			var container = document.getElementById("eco_message");
			var html = "";
			for (var i = 0; i < result.feed.entries.length; i++) {
				var entry = result.feed.entries[i];
				
				var rex = new RegExp("<img.+?>", "i");
				var imgs = entry.content.match(rex);
				var img = "";
				if (imgs.length > 0) {
					img = imgs[0];
				}
				
				html += "<div style='font-size:12px;margin-bottom:5px;border-bottom:1px dotted #333333;padding:3px;'>";
				html += "<img src='./img/icon_news.png' width='16' height='16' />&nbsp;" + entry.title + "";
				html += "</div>";
				if (img != "") {
				html += "<div style='margin-bottom:5px;padding:3px;text-align:center;'>";
				html += img;
				html += "</div>";
				html += "<div style='clear:both;' />";
				}
				html += "<div style='font-size:12px;margin-bottom:5px;padding:3px;'>";
				html += entry.contentSnippet;
				html += "</div>";
			}
			container.innerHTML = html;
		}
	});
}

/***************************************************************************************
 * クイズコーナー
 ***************************************************************************************/
function quiz() {
	var feed = new google.feeds.Feed("http://polls.dailynews.yahoo.co.jp/quiz/rss.xml");
  feed.setNumEntries(10);
	feed.load(function(result) {
		if (!result.error) {
			var container = document.getElementById("quiz_message");
			var html = "";
			for (var i = 0; i < result.feed.entries.length; i++) {
				var entry = result.feed.entries[i];
				html += "<div style='font-size:12px;margin-bottom:2px;border-bottom:1px dotted #333333;padding:3px;text-align:left;'>";
				html += "<img src='./img/icon_news.png' width='16' height='16' />&nbsp;" + entry.title + "";
				html += "</div>";
				html += "<div style='font-size:12px;margin-bottom:5px;padding:1px 3px;text-align:left;'>";
				html += entry.contentSnippet;
				html += "</div>";
			}
			container.innerHTML = html;
		}
	});
}

/***************************************************************************************
 * 全国スポットニュース
 ***************************************************************************************/
function spot() {	
	var feed = new google.feeds.Feed("http://feeds2.feedburner.com/walkerplus-odekake");
  feed.setNumEntries(10);
	feed.load(function(result) {
		if (!result.error) {
			var container = document.getElementById("spot_message");
			var html = "";
			for (var i = 0; i < result.feed.entries.length; i++) {
				var entry = result.feed.entries[i];
				html += "<div style='font-size:12px;margin-bottom:2px;border-bottom:1px dotted #333333;padding:3px;text-align:left;'>";
				html += "<img src='./img/icon_news.png' width='16' height='16' />&nbsp;" + entry.title + "";
				html += "</div>";
				html += "<div style='font-size:12px;margin-bottom:5px;padding:1px 3px;text-align:left;'>";
				html += entry.contentSnippet.substr(0, ( entry.contentSnippet.lastIndexOf("。") + 1 )　);
				html += "</div>";
			}
			container.innerHTML = html;
		}
	});
}

/***************************************************************************************
 * みんなのペットギャラリー
 ***************************************************************************************/
function pet() {
	var feed = new google.feeds.Feed("http://webryalbum.biglobe.ne.jp/theme/theme13.rdf");
  feed.setNumEntries(15);
	feed.load(function(result) {
		if (!result.error) {
			var container = document.getElementById("pet_message");
			var html = "";
			for (var i = 0; i < 5; i++) {
				var entry1 = result.feed.entries[i*3];
				var entry2 = result.feed.entries[i*3+1];
				var entry3 = result.feed.entries[i*3+2];
				
				var rex = new RegExp("<img.+?>", "i");
				var img1 = "";
				var img2 = "";
				var img3 = "";
				var imgs = entry1.content.match(rex);
				if (imgs.length > 0) {img1 = imgs[0];}
				var imgs = entry2.content.match(rex);
				if (imgs.length > 0) {img2 = imgs[0];}
				var imgs = entry3.content.match(rex);
				if (imgs.length > 0) {img3 = imgs[0];}

				html += "<div style='margin-bottom:5px;'>";
				html += "<table width='278'>";
				html += "<tr>";
				html += "<td valign='top' align='center' width='92'>" + img1 + "</td>";
				html += "<td valign='top' align='center' width='92'>" + img2 + "</td>";
				html += "<td valign='top' align='center' width='92'>" + img3 + "</td>";
				html += "</tr>";
				html += "</table>";
				html += "</div>";
				
			}
			container.innerHTML = html;
		}
	});
	
}

/***************************************************************************************
 * 天気予報
 ***************************************************************************************/
function weather() {	
	var feed = new google.feeds.Feed("http://weather.livedoor.com/forecast/rss/index.xml");
  feed.setNumEntries(14);
	feed.load(function(result) {
		if (!result.error) {
			var container = document.getElementById("weather_message");
			var html = "";
			html += "<table width='278'>";
			for (var i = 0; i < result.feed.entries.length; i++) {
				if (i > 0) {
					var entry = result.feed.entries[i];
					var tmp = entry.title.replace(" ", "").split("-");
					var date = document.getElementById("weather_date");
					date.innerHTML = "&nbsp;&nbsp;<font style='font-size:14px;'>" + tmp[3] + "</font>";
					var tmp2 = tmp[0].split("]");
					
					html += "<tr>";
					html += "<td width='120'>";
					html += "<div style='margin:0 auto 3px auto;width:100px;padding:5px;background-color:#eeeeee;border:1px solid #333333;text-align:center;'><font style='font-size:20px;font-weight:bold;letter-spacing:3px;'>" + tmp2[1] + "</font></div>";
					html += "</td>";
					html += "<td width='150'>";
					html += "<div align='center' style='margin-bottom:5px;'>";
					html += tmp[1] + "<br />";
					html += tmp[2] + "<br />";
					html += "</div>";
					html += "</td>";
					html += "<tr>";
				}
			}
			html += "</table>";
			container.innerHTML = html;
		}
	});
	
}

/***************************************************************************************
 * 正規表現クラス
 ***************************************************************************************/
var Regexies = function() {
	this.pattern = {
		'image' : /<div style="float:left">.*<\/a><\/div>/,
		'title' : /<span>(<a href=.*<\/a>)<\/span>/,
		'author' : /<span>([^<].+?)<\/span>/,
		'ranking' : /<\/strong>.*?<\/font>([^<]+)<br>/,
		'published' : /<em>([^<]+?\d+\/\d+\/\d+)<\/em>/,
		'star' : /<br> (<img src=".*)\(.*\)<br>/,
		'link' : /<a href="(http:\/\/.*?)">/,
		'price' : /<b>(￥.*?)<\/b>/,
		'remarks' : /<br>(\(.*?\))/
	}
	
	this.isnull = {
		'image' : "",
		'current' : "",
		'title' : "",
		'author' : "",
		'ranking' : "",
		'published' : "出版日: -",
		'star' : "評価: -",
		'link' : "",
		'price' : "",
		'remarks' : ""
	}
	
	this.prefix = {
		'image' : "",
		'current' : "",
		'title' : "",
		'author' : "",
		'ranking' : "",
		'published' : "",
		'star' : "評価:",
		'link' : "",
		'price' : "",
		'remarks' : ""		
	}

	//トリムがないので定義
	this.trim = function(text) {
	    return text.replace(/^[\s　]+|[\s　]+$/g, '');
	}
	
	this.match = function(target, text) {
		res = "";
		regex = this.pattern[target];
		cap = regex.exec(text);
		if (cap) {
			if (cap[1]) {
				res = this.trim(cap[1]);
			} else {
				res = cap;
			}
		}
		return res;
	}
}