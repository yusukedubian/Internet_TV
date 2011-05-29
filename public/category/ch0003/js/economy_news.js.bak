<!--
	google.load("feeds", "1");
	
	function initialize() {
		var rss = "http://sankei.jp.msn.com/rss/news/economy.xml";
		var feed = new google.feeds.Feed(rss);
		feed.setNumEntries(30);
		
		feed.load(function(result) {
			if (!result.error) {
				var container = document.getElementById("feed");
				var useFeed = "";
				var title = result.feed.title;
				title = title.substr(0, title.indexOf("-"));
				useFeed += "<b><font color=#c0c0c0><center>" + title + "</center></font></b><br>";
				useFeed += '<marquee behavior="scroll" direction="up" scrollamount="2" onmouseover="this.stop();" onmouseout="this.start();">';
				for (var i = 0; i < result.feed.entries.length; i++) {
					var entry = result.feed.entries[i];
					//useFeed += '<a href=" ' + entry.link + ' " target=_blank><b>' + entry.title + '</b></a><br>';
					useFeed += '<b>' + entry.title + ' </b><br>';
					useFeed += '<font size="2">' + dateForm(entry.publishedDate) + ' <a href=" ' + entry.link + ' " target=_blank>[全文]</a></font><br><br>';
					container.innerHTML = '<font color=#ffffff>' + useFeed + '</font>';
				}
				useFeed += "</marquee>";
			}
		});
	}
	google.setOnLoadCallback(initialize);
	
	function dateForm(str) {
		var myDate = new Date(str);
		var MM = myDate.getMonth() + 1;
		var DD = myDate.getDate();
		var day = myDate.getDay();
		switch (day) {
			case 0:
			day = "日";
			break;
			case 1:
			day = "月";
			break;
			case 2:
			day = "火";
			break;
			case 3:
			day = "水";
			break;
			case 4:
			day = "木";
			break;
			case 5:
			day = "金";
			break;
			case 6:
			day = "土";
			break;
		}
		var hour = myDate.getHours();
		var min = myDate.getMinutes();
		var sec = myDate.getSeconds();
		if (hour < 10) {
			hour = "0" + hour;
		}
		if (min < 10) {
			min = "0" + min;
		}
		if (sec < 10) {
			sec = "0" + sec;
		}
		var date = MM + "月" + DD + "日(" + day + ") " + hour + "：" + min + "：" + sec;
		return date;
	}
//-->