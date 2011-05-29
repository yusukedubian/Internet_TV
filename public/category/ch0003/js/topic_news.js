<!--
	google.load("feeds", "1");
	
	function initialize() {
		var rss = "http://news.livedoor.com/topics/rss.xml";
		var feed = new google.feeds.Feed(rss);
		feed.setNumEntries(10);
		
		feed.load(function(result) {
			if (!result.error) {
				var container = document.getElementById("feed");
				var useFeed = "";
				useFeed += '<marquee behavior="scroll" direction="left" scrollamount="5" onmouseover="this.stop();" onmouseout="this.start();">';
				for (var i = 0; i < result.feed.entries.length; i++) {
					var entry = result.feed.entries[i];
					useFeed += entry.title + '<font size=3><a href=' + entry.link + ' target=_blank>［全文］</a></font>&nbsp;&nbsp;';
					container.innerHTML = '<font color=#ffffff size=5>' + useFeed + '</font>';
				}
				useFeed += '</marquee>';
			}
		});
	}
	google.setOnLoadCallback(initialize);
//-->