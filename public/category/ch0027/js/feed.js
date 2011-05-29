function feeddesu() {
	google.load("feeds", "1");
	google.setOnLoadCallback(main);
}

function main() {
	var fdList = new Array("open", "rank", "news1", "news2", "news3");
	var fdLen = fdList.length;

	for(i = 0; i < fdLen; i++) {
		var fd = new Feed(fdList[i]);
	}
}

/**
 *Feedクラス
 *
 *@package vasdaq.js
 *@access public
 */
var Feed = function(flg) {
	this.urlList = {
		'rank' : "http://pia-eigaseikatsu.jp/rdf/ranking.rdf",
		'open' : "http://movie.goo.ne.jp/schedule/thisweek.rdf",
		'news1' : "http://feeds.cinematoday.jp/cinematoday_update?format=xml",
		'news2' : "http://pia-eigaseikatsu.jp/rdf/news.rdf",
		'news3' : "http://movie.goo.ne.jp/news/index.rdf"
	}
	
	this.setNumList = {
		'rank' : 20,
		'open' : 10,
		'news1' : 10,
		'news2' : 10,
		'news3' : 10
	}
	
	this.fItemsList = {
		'rank' : Array(),
		'open' : Array(),
		'news1' : Array(),
		'news2' : Array(),
		'news3' : Array()
	}
	
	this.eItemsList = {
		'rank' : Array('title', 'content'),
		'open' : Array('title'),
		'news1' : Array('title', 'content'),
		'news2' : Array('title', 'content'),
		'news3' : Array('title', 'content')
	}
	
	this.eContentsList = {
		'rank' : Array('all'),
		'open' : Array('all'),
		'news1' : Array('image', 'remarks'),
		'news2' : Array('all'),
		'news3' : Array('all')
	}

	this.format = {
		'rank' : '',
		'open' : '',
		'news1' : '',
		'news2' : '',
		'news3' : ''
	}

	this.url = this.urlList[flg];
	this.setNum = this.setNumList[flg];
	this.fItems = this.fItemsList[flg];
	this.eItems = this.eItemsList[flg];
	this.eContents = this.eContentsList[flg];
	this.container = flg;
	this.html = new Array();

	this.error = function(err) {
		alert(err.code + ":" + err.message);
	}

	this.getHtml = function(result) {
		var cnt;
		if (!result.error) {
			var fItemsLen = this.fItems.length;
			for (i = 0; i < fItemsLen; i++) {
				cnt = document.getElementById("feed_" + this.container + fItems[i]);
				if (cnt) {
					cnt.innerHTML = '<p class="' + "feed_" + fItem + '">' + eval('result.feed.' + fItem) + '</p>';
				}
			}

			var eItemsLen = this.eItems.length;
			var entryLen = result.feed.entries.length;
			var eContentsLen = this.eContents.length;
			var reg = new Regexies();

			for (var i=0; i<entryLen; i++) {
				var cntEntry = document.getElementById(this.container + "_entry_" + (i + 1));
				if (cntEntry) {
					for (var j=0; j<eItemsLen; j++) {
						var tmp = eval("result.feed.entries[i]." + this.eItems[j]);
						var cntItem = document.createElement('div');
						cntItem.className = this.container + '_entry_' + this.eItems[j];
						if (this.eItems[j] == "content") {
							for (var k=0; k<eContentsLen; k++) {
								if (this.eContents[k] == "all") {
									cntItem.innerHTML = omitStr(tmp, 250);
								} else {
									html = reg.match(this.eContents[k], tmp);
									var cntContent = document.createElement('div');
									cntContent.className = this.container + "_contents_" + this.eContents[k];
									cntContent.innerHTML = omitStr(html, 250);
									cntItem.appendChild(cntContent);
								}
							}
						} else {
							cntItem.innerHTML = omitStr(tmp, 250);
						}
						cntEntry.appendChild(cntItem);
					}
				}
			}
		} else {
			this.error(result.err);
		}
	}

	var tmp = new google.feeds.Feed(this.url);
	tmp.setNumEntries(this.setNum);
	switch (this.format) {
		case "XML":
			tmp.setResultFormat(tmp.XML_FORMAT);
			break;
		case "MIXED":
			tmp.setResultFormat(tmp.MIXED_FORMAT);
			break;
	}
	tmp.load($.scope(this, this.getHtml));
}

var Regexies = function() {
	this.pattern = {
		'image' : /<img.*jpg">/,
		'title' : /<span>(<a href=.*<\/a>)<\/span>/,
		'author' : /<span>([^<].+?)<\/span>/,
		'ranking' : /<\/strong>.*?<\/font>([^<]+)<br>/,
		'published' : /<em>([^<]+?\d+\/\d+\/\d+)<\/em>/,
		'star' : /<br> (<img src=".*)\(.*\)<br>/,
		'link' : /<a href="(http:\/\/.*?)">/,
		'price' : /<b>(￥.*?)<\/b>/,
		'remarks' : /(?:jpg|png|gif)">(.*)<img/
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


function omitStr(text, len) {
	if (text.length > len) {
		text = text.substr(1, len) + "…";
	}
	return text;
}