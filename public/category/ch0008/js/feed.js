google.load("feeds", "1");
google.setOnLoadCallback(main);

function main() {
	var fdList = new Array("bestseller", "gift", "new1", "new2", "new3");
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
		'bestseller' : "http://www.amazon.co.jp/rss/bestsellers/music/569170/ref=pd_ts_rss_link",
		'gift' : "http://www.amazon.co.jp/rss/bestsellers/music/ref=pd_ts_rss_link",
		'new1' : "http://www.amazon.co.jp/rss/bestsellers/music/562060/ref=pd_ts_rss_link",
		'new2' : "http://www.amazon.co.jp/rss/bestsellers/music/569290/ref=pd_ts_rss_link",
		'new3' : "http://www.amazon.co.jp/rss/bestsellers/music/569174/ref=pd_ts_rss_link"
	}
	
	this.setNumList = {
		'bestseller' : 10,
		'gift' : 10,
		'new1' : 10,
		'new2' : 10,
		'new3' : 10
	}
	
	this.fItemsList = {
		'bestseller' : Array(),
		'gift' : Array(),
		'new1' : Array(),
		'new2' : Array(),
		'new3' : Array()
	}
	
	this.eItemsList = {
		'bestseller' : Array('title', 'content'),
		'gift' : Array('title', 'content'),
		'new1' : Array('title', 'content'),
		'new2' : Array('title', 'content'),
		'new3' : Array('title', 'content')
	}
	
	this.eContentsList = {
		'bestseller' : Array('published', 'star'),
		'gift' : Array('image', 'author', 'published', 'price', 'ranking'),
		'new1' : Array('image', 'author', 'published', 'price'),
		'new2' : Array('image', 'author', 'published', 'price'),
		'new3' : Array('image', 'author', 'published', 'price')
	}

	this.format = {
		'bestseller' : '',
		'gift' : '',
		'new1' : '',
		'new2' : '',
		'new3' : ''
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
					cnt.innerHtml = '<p class="' + "feed_" + fItem + '">' + eval('result.feed.' + fItem) + '</p>';
				}
			}

			var eItemsLen = this.eItems.length;
			var entryLen = result.feed.entries.length;
			var eContentsLen = this.eContents.length;
			var reg = new Regexies();
			var htmlStr = "";
	
			for (i = 0; i < entryLen; i++) {
				cnt = document.getElementById("entry_" + this.container + "_" + (i + 1));
				if (cnt) {
					htmlStr = '<div class="entry">\n';
					for (j = 0; j < eItemsLen; j++) {
						tmp = eval("result.feed.entries[i]." + this.eItems[j]);
						if (this.container == "new1"||this.container == "new2"||this.container == "new3"){
							htmlStr += ' <div class="' + this.container + '_entry_' + this.eItems[j] + '" style="width:160px; height:53px; overflow:hidden; color:#FFFFFF;">\n';
						}
						else{htmlStr += ' <div class="' + this.container + '_entry_' + this.eItems[j] + '">\n';}
						if (this.eItems[j] == 'content') {
							for (k = 0; k < eContentsLen; k++) {
								//正規表現入力
								data = reg.match(this.eContents[k], tmp);
								if (data) {
									if (this.eContents[k] == 'image') {
										var imgStr = ' <div class="' + this.container + '_entry_image">\n  <p class="' + this.container + '_contents_' + this.eContents[k] + '">' + reg.prefix[this.eContents[k]] + data + '</p>\n </div>';
									} else { 
										htmlStr += '  <p class="' + this.container + '_contents_' + this.eContents[k] + '">' + reg.prefix[this.eContents[k]] + data + '</p>\n';
									}
								} else {
									if (this.eContents[k] == 'image') {
										var imgStr = ' <div class="' + this.container + '_entry_image">\n  <p class="' + this.container + '_contents_' + this.eContents[k] + '">' + reg.isnull[this.eContents[k]] + '</p>\n </div>';
									} else {
										htmlStr += '  <p class="' + this.container + '_contents_' + this.eContents[k] + '">' + reg.isnull[this.eContents[k]] + '</p>\n';
									}
								}
							}
						} else {
							htmlStr += '  ' + tmp + '\n';
						}
						htmlStr += " </div>\n";
					}
					if (imgStr) {
						var ptn = ' <div class="' + this.container + '_entry_content">';
						var rg = RegExp(ptn);
						if (rg.exec(htmlStr) != null) {
							htmlStr = htmlStr.replace(ptn, imgStr + '\n' + ptn);
						} else {
							htmlStr += imgStr;
						}
					}
					htmlStr += '</div>\n';
					//alert(htmlStr);
					cnt.innerHTML = htmlStr;
				}
			}
		} else {
			this.error(result.error);
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
