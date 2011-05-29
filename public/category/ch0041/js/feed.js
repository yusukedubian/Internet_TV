function getFeed() {
	google.load("feeds", "1");
	google.setOnLoadCallback(main);
}

function main() {
	var fd = new Feed('http://bokasachi.natsu.gs/blog_part/newmoviedata.xml', 'news1', 'news', 13, 250);
	var fd = new Feed('http://feeds.feedburner.com/vocaloidblog', 'news2', 'news', 13, 250);
}

var Feed = function(url, container, cls, num, omit, items, entries, contents, format) {
	this.url = url;
	this.num = num || 10;
	this.container = container;
	this.cls = cls || this.container;
	this.omit = omit || 100;
	this.items = items || Array();
	this.entries = entries || Array('title', 'content');
	this.contents = contents || Array('all');
	this.format = format || '';

	this.error = function(err) {
		alert(err.code + ":" + err.message);
	}

	this.getHtml = function(result) {
		if (!result.error) {
			var iLen = this.items.length;

			for (var i=0; i<iLen; i++) {
				var cnt = document.getElementById(this.container + "_" + this.items[i]);
				if (cnt) {
					var html = eval('result.feed.' + this.items[i]);
					cnt.innerHTML = html;
				}
			}

			var eCnt = result.feed.entries.length;
			var eLen = this.entries.length;
			var cLen = this.contents.length;
			var reg = new Regexies();

			for (var i=0; i<eCnt; i++) {
				var cnt = document.getElementById(this.container + "_entry_" + (i + 1));
				if (cnt) {
					cnt.className = this.cls + "_entry";
					for (var j=0; j<eLen; j++) {
						var html = eval("result.feed.entries[i]." + this.entries[j]);
						var eTag = document.createElement('div');
						eTag.className = this.cls + "_entry_" + this.entries[j];

						if (this.entries[j] == "content") {
							for (var k=0; k<cLen; k++) {
								if (this.contents[k] == "all") {
									eTag.innerHTML = omitStr(html, this.omit);
								} else {
									var mat = reg.match(this.contents[k], html);
									var cTag = document.createElement('div');
									cTag.className = this.cls + "_contents_" + this.contents[k];
									cTag.innerHTML = omitStr(html, this.omit);
									eTag.appendChild(cTag);
									eTag.innerHTML = omitStr(html, this.omit);
								}
							}
						} else {
							eTag.innerHTML = omitStr(html, this.omit);
						}
						cnt.appendChild(eTag);
					}
				}
			}
		} else {
			this.error(result.error);
		}
	}

	var tmp = new google.feeds.Feed(this.url);
	tmp.setNumEntries(this.num);
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
		var regex = this.pattern[target];
		var cap = regex.exec(text);
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
		text = text.substr(1, len) + "...";
	}
	return text;
}