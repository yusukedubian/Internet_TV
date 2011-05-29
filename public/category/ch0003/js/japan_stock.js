<!--
	google.load("feeds", "1");
	
	function initialize() {
		var rss = "http://worris2.sakura.ne.jp/worris/stock/stockrss.cgi?code=&market=t&NIKKEI=on&TOPIX=on&JASDAQ=on";
		var feed = new google.feeds.Feed(rss);
		feed.setNumEntries(10);
		
		feed.load(function(result) {
			if (!result.error) {
				var container = document.getElementById("feed");
				var useFeed = "";
				useFeed += '<b><font color=#c0c0c0><center>日本' + result.feed.title + '</center></font></b><br>';
				var date = result.feed.entries[0].publishedDate;
				//useFeed += '<font size=2>' + dateForm(date) + ' 更新</font><br><br>';
				
				useFeed += '<marquee behavior="scroll" direction="up" scrollamount="2">';
				for (var i = 0; i < result.feed.entries.length; i++) {
					var entry = result.feed.entries[i];
					var title1 = entry.title.substr(0, entry.title.indexOf("("));
					var title2 = entry.title.substr(entry.title.indexOf("("));
					title1 = "<b>" + title1;
					title2 = title2 + "</b>";
					
					if (title2.indexOf("+") != -1) {
						useFeed += title1;
						useFeed += "<font color=#008800><br>▲ " + title2 + "</font><br><br>";
					} else if (title2.indexOf("-") != -1) {
						useFeed += title1;
						useFeed += "<font color=#cc0000><br>▼ " + title2 + "</font><br><br>";
					} else {
						useFeed += title1;
						useFeed += "<font color=#ffffff><br>" + title2 + "</font><br><br>";
					}
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
		if (hour < 10) {
			hour = "0" + hour;
		}
		if (min < 10) {
			min = "0" + min;
		}
		var date = MM + "月" + DD + "日(" + day + ") " + hour + "：" + min;
		return date;
	}
//-->