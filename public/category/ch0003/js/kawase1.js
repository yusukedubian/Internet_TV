<!--
	google.load("feeds", "1");
	
	function initialize() {
		var rss = "http://worris2.sakura.ne.jp/worris/rate/raterss.cgi?USD=on&EUR=on&GBP=on&AUD=on&CAD=on&CHF=on&NZD";
		var feed = new google.feeds.Feed(rss);
		feed.setNumEntries(10);
		
		feed.load(function(result) {
			if (!result.error) {
				var container = document.getElementById("feed");
				var useFeed = "";
				useFeed += '<b><font color=#c0c0c0><center>' + result.feed.title + '</center></font></b><br>';
				var date = result.feed.entries[0].publishedDate;
				//useFeed += '<font size=2>' + dateForm(date) + ' 更新</font><br><br>';
				
				useFeed += '<marquee behavoir="scroll" direction="up" scrollamount="2">';
				for (var i = 0; i < result.feed.entries.length; i++) {
					var entry = result.feed.entries[i];
					var yenStr = entry.title.indexOf("円") + 1;
					var title1 = entry.title.substr(0, yenStr); //1xxx=xxx円
					var title2 = entry.title.substr(yenStr + 1); //前日比 (+)(-)xxx
					title1 = "<b>" + title1;
					title2 = title2 + "</b>";
					/* 
					 * [0] usd ： アメリカ
					 * [1] eur ： ヨーロッパ連合
					 * [2] gbp ： イギリス
					 * [3] aud ： オーストラリア
					 * [4] chf ： スイス
					 * [5] cad ： カナダ
					 * [6] nzd ： ニュージーランド
					 */
					switch (i) {
						case 0:
						useFeed += "<img src=img/usd.gif align=top>&nbsp;" + title1 + "<br>";
						break;
						case 1:
						useFeed += "<img src=img/eur.gif align=top>&nbsp;" + title1 + "<br>";
						break;
						case 2:
						useFeed += "<img src=img/gbp.gif align=top>&nbsp;" + title1 + "<br>";
						break;
						case 3:
						useFeed += "<img src=img/aud.gif align=top>&nbsp;" + title1 + "<br>";
						break;
						case 4:
						title1 = title1.replace("スイス", "");
						useFeed += "<img src=img/chf.gif align=top>&nbsp;" + title1 + "<br>";
						break;
						case 5:
						useFeed += "<img src=img/cad.gif align=top>&nbsp;" + title1 + "<br>";
						break;
						case 6:
						useFeed += "<img src=img/nzd.gif align=top>&nbsp;" + title1 + "<br>";
						break;
					}
					
					if (title2.indexOf("+") != -1) {
						useFeed += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
						useFeed += "<font color=red>(" + title2 + ")</font><br><br>";
					} else if (title2.indexOf("-") != -1) {
						useFeed += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
						useFeed += "<font color=blue>(" + title2 + ")</font><br><br>";
					} else {
						useFeed += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
						useFeed += "<font color=#ffffff>(" + title2 + ")</font><br><br>";
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