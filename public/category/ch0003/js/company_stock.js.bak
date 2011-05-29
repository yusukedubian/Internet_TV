<!--
	google.load("feeds", "1");
	
	function initialize() {
		var rss = "http://worris2.sakura.ne.jp/worris/stock/stockrss.cgi?code=7203%2C8053%2C8316%2C9433%2C7201%2C5411%2C8411%2C6502%2C8306%2C8604%2C6758%2C8058&market=t";
		var feed = new google.feeds.Feed(rss);
		feed.setNumEntries(15);
		
		feed.load(function(result) {
			if (!result.error) {
				var container = document.getElementById("feed");
				var useFeed = "";
				var arrTitle = new Array();
				var arrTr = new Array();
				for (var i = 0; i < result.feed.entries.length; i++) {
					var entry = result.feed.entries[i];
					var title = entry.title.substr(0, entry.title.indexOf("("));
					var touraku = entry.title.substr(entry.title.indexOf("("));
					var link = "<a href=" + entry.link + " target=_blank>[詳細]</a>";
					title = "<font size=3><b>" + title + "</b></font>";
					if (touraku.indexOf("+") != -1) {
						touraku = touraku.replace("(", "▲ (");
						touraku = "<font color=green>" + touraku + "</font> " + link;
					} else if (touraku.indexOf("-") != -1) {
						touraku = touraku.replace("(", "▼ (");
						touraku = "<font color=red>" + touraku + "</font> " + link;
					} else {
						touraku = touraku.replace("(", "&nbsp;- (");
						touraku = "<font color=#ffffff>" + touraku + "</font> " + link;
					}
					arrTitle[i] = title;
					arrTr[i] = touraku;
				}
				useFeed += "<table align=right width=725 border=0>";
				for (var n = 0; n < arrTitle.length; n+=2) {
					useFeed += "<tr>";
					useFeed += createTd(arrTitle[n], arrTr[n]);
					useFeed += createTd(arrTitle[n+1], arrTr[n+1]);
					useFeed += "</tr>";
				}
				useFeed += "</table>";
				container.innerHTML = '<font color=#ffffff size=2>' + useFeed + '</font>';
			}
		});
	}
	google.setOnLoadCallback(initialize);
	
	function createTd(title, tr) {
		var r = "<td>" + title + "<br>" + tr + "</td>";
		return r;
	}
	
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
		var date = MM + "月" + DD + "日("  + day + ") " + hour + ":" + min + ":" + sec;
		return date;
	}
//-->