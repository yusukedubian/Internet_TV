<!--
	google.load("feeds", "1");
	
	function initialize() {
		var rss = "http://worris2.sakura.ne.jp/worris/rate/raterss.cgi?USD=on&EUR=on&GBP=on&AUD=on&CAD=on&CHF=on&NZD&lang=en";
		var feed = new google.feeds.Feed(rss);
		feed.setNumEntries(10);
		
		feed.load(function(result) {
			if (!result.error) {
				var container = document.getElementById("feed");
				var useFeed = "";
				var date = result.feed.entries[0].publishedDate;
				var arr1 = new Array();
				var arr2 = new Array();
				for (var i = 0; i < result.feed.entries.length; i++) {
					var entry = result.feed.entries[i];
					var ss = entry.title.indexOf("(");
					var title1 = entry.title.substr(0, ss); //1xxx=xxx円
					title1 = title1.replace("=", " = ");
					var title2 = entry.title.substr(ss); //前日比 (+)(-)xxx
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
						title1 = "<img src=img/usd.gif>&nbsp;" + title1;
						break;
						case 1:
						title1 = "<img src=img/eur.gif>&nbsp;" + title1;
						break;
						case 2:
						title1 = "<img src=img/gbp.gif>&nbsp;" + title1;
						break;
						case 3:
						title1 = "<img src=img/aud.gif>&nbsp;" + title1;
						break;
						case 4:
						title1 = "<img src=img/chf.gif>&nbsp;" + title1;
						break;
						case 5:
						title1 = "<img src=img/cad.gif>&nbsp;" + title1;
						break;
						case 6:
						title1 = "<img src=img/nzd.gif>&nbsp;" + title1;
						break;
					}
					
					if (title2.indexOf("+") != -1) {
						title2 = "<font color=red>" + title2 + "</font>";
					} else if (title2.indexOf("-") != -1) {
						title2 = "<font color=blue>" + title2 + "</font>";
					} else {
						title2 = "<font color=#ffffff>" + title2 + "</font>";
					}
					arr1[i] = title1;
					arr2[i] = title2;
				}
				useFeed += "<table width=700 align=center border=0>";
				useFeed += "<tr>";
				useFeed += "<td height=35 valign=top><font color=#c0c0c0>" + result.feed.title + "</font></td>";
				useFeed += "</tr>";
				useFeed += "<tr height=30>";
				useFeed += "<td>" + arr1[0] + " " + arr2[0] + "</td>";
				useFeed += "<td>" + arr1[1] + " " + arr2[1] + "</td>";
				useFeed += "</tr>";
				useFeed += "<tr height=30>";
				useFeed += "<td>" + arr1[2] + " " + arr2[2] + "</td>";
				useFeed += "<td>" + arr1[3] + " " + arr2[3] + "</td>";
				useFeed += "</tr>";
				useFeed += "<tr height=30>";
				useFeed += "<td>" + arr1[4] + " " + arr2[4] + "</td>";
				useFeed += "<td>" + arr1[5] + " " + arr2[5] + "</td>";
				useFeed += "</tr>";
				useFeed += "<tr height=30>";
				useFeed += "<td colspan=2>" + arr1[6] + " " + arr2[6] + "</td>";
				useFeed += "</tr>";
				useFeed += "</table>";
				
				container.innerHTML = "<font color=#ffffff size=4><b>" + useFeed + "</b></font></font>";
			}
		});
	}
	google.setOnLoadCallback(initialize);
	
	function dateForm(str) {
		var myDate = new Date(str);
		var YYYY = myDate.getFullYear();
		var MM = myDate.getMonth() + 1;
		var DD = myDate.getDate();
		var hour = myDate.getHours();
		var min = myDate.getMinutes();
		var sec = myDate.getSeconds();
		if (MM < 10) {
			MM = "0" + MM;
		}
		if (DD < 10) {
			DD = "0" + DD;
		}
		if (hour < 10) {
			hour = "0" + hour;
		}
		if (min < 10) {
			min = "0" + min;
		}
		if (sec < 10) {
			sec = "0" + sec;
		}
		var date = YYYY + "-" + MM + "-" + DD + " " + hour + ":" + min + ":" + sec;
		return date;
	}
//-->