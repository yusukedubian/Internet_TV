<!--
	google.load("feeds", "1");

	function initialize() {
		var rss = "http://rss.news.yahoo.com/rss/business";
		var feed = new google.feeds.Feed(rss);
		feed.setNumEntries(20);
		
		feed.load(function(result) {
			if (!result.error) {
				var container = document.getElementById("feed");
				var useFeed = "";
				var date = new Date(result.feed.entries[0].publishedDate);
				date = date.toGMTString();
				useFeed += "<font color=#ffffff>last updated: " + date + "</font><br>";
				useFeed += '<marquee behavior="scroll" direction="left" scrollamount="3" onmouseover="this.stop();" onmouseout="this.start();">';
				for (var i = 0; i < result.feed.entries.length; i++) {
					var entry = result.feed.entries[i];
					useFeed += "<a href=" + entry.link + " target=_blank><b>" + entry.title + "</b></a>";
					useFeed += "&nbsp;&nbsp;&nbsp;";
					container.innerHTML = "<font size=2>" + useFeed + "</font>";
				}
				useFeed += "</marquee>";
			}
		});
	}
	google.setOnLoadCallback(initialize);
//-->