<!--
	google.load("feeds", "1");
	
	function initialize() {
		var rss = "http://pipes.yahoo.com/pipes/pipe.run?_id=Pn_3JOUk3RG2F4FLODY80A&_render=rss&m1=%5EDJI&m2=%5EFTSE&m3=%5ESSEC";
		var feed = new google.feeds.Feed(rss);
		feed.setResultFormat(google.feeds.Feed.XML_FORMAT);
		feed.setNumEntries(10);
		
		feed.load(function(result) {
			if (!result.error) {
				var container = document.getElementById("feed");
				var items = result.xmlDocument.getElementsByTagName("item");
				var pubdate = result.xmlDocument.getElementsByTagName("pubDate")[0].firstChild.nodeValue;
				
				var useFeed = "";
				useFeed += "<b><font color=#c0c0c0><center>Global Stock Market</center></font></b><br>";
				var date = new Date(pubdate);
				date = date.toGMTString();
				//useFeed += '<font size="2">last updated: ' + date + "</font><br><br>";
				useFeed += '<marquee behavior="scroll" direction="up" scrollamount="2">';
				
				for (var i = 0; i < items.length; i++) {
					var desc = getNodeValue(items[i], "description");
					var title = new Array();
					if (desc.indexOf("Dow") != -1) {
						title[i] = desc.replace("Average (^DJI)", "");
					}
					if (desc.indexOf("FTSE") != -1) {
						title[i] = desc.replace("(^FTSE)", "");
					}
					if (desc.indexOf("SSE") != -1) {
						title[i] = desc.replace("(000001.SS)", "");
					}
					useFeed += title[i] + '<br>';
					container.innerHTML = '<font color=#ffffff>' + useFeed + '</font>';
				}
				useFeed += "</marquee>";
			}
		});
	}
	google.setOnLoadCallback(initialize);
	
	function getNodeValue(node, nodeName) {
		return node.getElementsByTagName(nodeName)[0].firstChild.nodeValue;
	}
//-->