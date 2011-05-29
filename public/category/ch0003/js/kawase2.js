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
				useFeed += '<marquee behavior="scroll" direction="left" scrollamount="3">';
				
				for (var i = 0; i < result.feed.entries.length; i++) {
					var entry = result.feed.entries[i];
					var yenStr = entry.title.indexOf("円") + 1;
					var title1 = entry.title.substr(0, yenStr); //1xxx=xxx円
					var title2 = entry.title.substr(yenStr + 1); //前日比 (+)(-)xxx
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
						useFeed += "<img src=img/usd.gif>&nbsp;" + title1 + "&nbsp;";
						break;
						case 1:
						useFeed += "<img src=img/eur.gif>&nbsp;" + title1 + "&nbsp;";
						break;
						case 2:
						useFeed += "<img src=img/gbp.gif>&nbsp;" + title1 + "&nbsp;";
						break;
						case 3:
						useFeed += "<img src=img/aud.gif>&nbsp;" + title1 + "&nbsp;";
						break;
						case 4:
						useFeed += "<img src=img/chf.gif>&nbsp;" + title1 + "&nbsp;";
						break;
						case 5:
						useFeed += "<img src=img/cad.gif>&nbsp;" + title1 + "&nbsp;";
						break;
						case 6:
						useFeed += "<img src=img/nzd.gif>&nbsp;" + title1 + "&nbsp;";
						break;
					}
					
					if (title2.indexOf("+") != -1) {
						useFeed += "<font color=red>(" + title2 + ")</font>";
						useFeed += "&nbsp;&nbsp;&nbsp;";
					} else if (title2.indexOf("-") != -1) {
						useFeed += "<font color=blue>(" + title2 + ")</font>";
						useFeed += "&nbsp;&nbsp;&nbsp;";
					} else {
						useFeed += "<font color=white>(" + title2 + ")</font>";
						useFeed += "&nbsp;&nbsp;&nbsp;";
					}
					container.innerHTML = '<font color=#ffffff><b>' + useFeed + '</b></font>';
				}
				useFeed += '</marquee>';
			}
		});
	}
	google.setOnLoadCallback(initialize);
//-->