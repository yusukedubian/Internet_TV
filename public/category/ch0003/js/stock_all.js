<!--
	google.load("feeds", "1");
	
	function initialize() {
		var rss1 = "http://worris2.sakura.ne.jp/worris/stock/stockrss.cgi?code=&market=t&NIKKEI=on&TOPIX=on&JASDAQ=on";
		var rss2 = "http://pipes.yahoo.com/pipes/pipe.run?_id=Pn_3JOUk3RG2F4FLODY80A&_render=rss&m1=%5EDJI&m2=%5EFTSE&m3=%5ESSEC";
		var feed1 = new google.feeds.Feed(rss1);
		var feed2 = new google.feeds.Feed(rss2);
		feed1.setResultFormat(google.feeds.Feed.XML_FORMAT);
		feed2.setResultFormat(google.feeds.Feed.XML_FORMAT);
		feed1.load(dispfeed1);
		feed2.load(dispfeed2);
		
		function dispfeed1(result) {
			if (!result.error) {
				var container = document.getElementById("feed1");
				var useFeed1 = "";
				var items = result.xmlDocument.getElementsByTagName("item");
				useFeed1 += '<marquee behavior="scroll" direction="up" scrollamount="1" height="22px">';
				for (var i = 0; i < items.length; i++) {
					var title = getNodeValue(items[i], "title");
					title = title.replace("前日比 ", "");
					if (i == 0) {
						title = title.replace("日経平均", "NIKKEI");
					}
					var title1 = title.substr(0, title.indexOf("("));
					var title2 = title.substr(title.indexOf("("));
					if (title2.indexOf("+") != -1) {
						useFeed1 += "<b>" + title1 + " ";
						useFeed1 += '<img width="10" height="14" border="0" src="http://l.yimg.com/a/i/us/fi/03rd/up_g.gif" alt="Up"> <font color=#008800>' + title2 + '</font></b>&nbsp;&nbsp;';
						useFeed1 += "<br><br>";
					} else if (title2.indexOf("-") != -1) {
						useFeed1 += "<b>" + title1 + " ";
						useFeed1 += '<img width="10" height="14" border="0" src="http://l.yimg.com/a/i/us/fi/03rd/down_r.gif" alt="Down"> <font color=#cc0000>' + title2 + '</font></b>&nbsp;&nbsp;';
						useFeed1 += "<br><br>";
					} else {
						useFeed1 += "<b>" + title1 + " ";
						useFeed1 += "<font color=#ffffff>-" + title2 + "</font></b>&nbsp;&nbsp;";
						useFeed1 += "<br><br>";
					}
					container.innerHTML = "<font color=#ffffff>" + useFeed1 + "</font>";
				}
			}
		}
		
		function dispfeed2(result) {
			if (!result.error) {
				var container = document.getElementById("feed2");
				var useFeed2 = "";
				var items = result.xmlDocument.getElementsByTagName("item");
				useFeed2 += '<marquee behavior="scroll" direction="left" scrollamount="3">';
				for (var i = 0; i < items.length; i++) {
					var desc = getNodeValue(items[i], "description");
					//名称
					var mei = "";
					var mf = 0;
					var mt = desc.indexOf("(");
					switch (i) {
						case 0:
						mf = desc.indexOf("Dow");
						break;
						case 1:
						mf = desc.indexOf("FTSE");
						break;
						case 2:
						mf = desc.indexOf("SSE");
						break;
					}
					mei = desc.substring(mf, mt);
					//指数
					var sisu = "";
					var sf = desc.indexOf("<big>");
					var st = desc.indexOf("</big>");
					sisu = desc.substring(sf, st);
					var search = sisu.search(/[0-9]/);
					if (i == 2) {
						var ss = sisu.indexOf('ss">') + 4;
						sisu = sisu.substring(ss);
					} else {
						sisu = sisu.substring(search);
					}
					//騰落
					var touraku = "";
					var tf = desc.indexOf("<img");
					if (tf != -1) {
						touraku = desc.substring(tf);
					} else {
						touraku = "<b>-0.00 (0.00%)</b>";
					}
					
					mei = mei.replace("<br>", "&nbsp;&nbsp;");
					sisu = sisu.replace("<br>", "&nbsp;&nbsp;");
					touraku = touraku.replace("<br>", "&nbsp;&nbsp;");
					
					useFeed2 += "<font color=#ffffff><b>" + mei + " " + sisu + " " + touraku + "</b></font>";
					container.innerHTML = useFeed2;
				}
			}
		}
	}
	google.setOnLoadCallback(initialize);
	
	function getNodeValue(node, nodeName) {
		return node.getElementsByTagName(nodeName)[0].firstChild.nodeValue;
	}
//-->