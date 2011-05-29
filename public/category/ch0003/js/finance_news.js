<!--
	google.load("feeds", "1");
	
	function initialize() {
		var rss = "http://www.zou3.net/php/rss/nikkei2rss.php?head=market";
		var feed = new google.feeds.Feed(rss);
		feed.setResultFormat(google.feeds.Feed.XML_FORMAT);
		feed.setNumEntries(15);
		
		feed.load(function(result) {
			if (!result.error) {
				var container = document.getElementById("feed");
				var titleR = result.xmlDocument.getElementsByTagName("title")[0].firstChild.nodeValue;
				var pubdate = result.xmlDocument.getElementsByTagName("pubDate")[0].firstChild.nodeValue;
				var items = result.xmlDocument.getElementsByTagName("item");
				
				var useFeed = "";
				useFeed += "<b><font color=#c0c0c0><center>" + titleR + "</center></font></b><br>";
				//useFeed += "<font size=2>" + dateForm(pubdate) + " 更新</font><br><br>";
				useFeed += '<marquee behavior="scroll" direction="up" scrollamount="2" onmouseover="this.stop();" onmouseout="this.start();">';
				
				for (var i = 0; i < items.length; i++) {
					var title = getNodeValue(items[i], "title");
					var link = getNodeValue(items[i], "link");
					//useFeed += '<a href=" ' + link + ' " target=_blank><b>' + title + '</b></a><br><br>';
					title = title.trim();
					useFeed += '<b>' + title + '</b><br><font size=2><a href=" ' + link + ' " target=_blank>[全文]</a></font><br><br>';
					container.innerHTML = '<font color=#ffffff>' + useFeed + '</font>';
				}
				useFeed += '</marquee>';
			}
		});
	}
	google.setOnLoadCallback(initialize);
	
	function getNodeValue(node, nodeName) {
		return node.getElementsByTagName(nodeName)[0].firstChild.nodeValue;
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
		var date = MM + "月" + DD + "日(" + day + ") " + hour + "：" + min + "：" + sec;
		return date;
	}
//-->