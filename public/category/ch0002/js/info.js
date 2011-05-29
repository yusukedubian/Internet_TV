
var temp='';
loadXML = function(fileRoute)
{
  xmlDoc=null;
  if (window.ActiveXObject)
  {
    xmlDoc = new ActiveXObject('Msxml2.DOMDocument');
    xmlDoc.async=false;
    xmlDoc.load(fileRoute);
  }
  else if (document.implementation && document.implementation.createDocument)
  {
    var xmlhttp = new window.XMLHttpRequest();
    xmlhttp.open("GET",fileRoute,false);
    xmlhttp.send(null);
    var xmlDoc = xmlhttp.responseXML.documentElement;
  }
  else
  {
    xmlDoc=null;
  }  
  return xmlDoc;
}

function info01(){
	info('./rss/info01.xml','info01');
	setInterval("info('./rss/info01.xml','info01')",3000);

}

function info02(){
	info('./rss/info02.xml','info02');
	setInterval("info('./rss/info02.xml','info02')",3000);
}

function info03(){
	info('./rss/info03.xml','info03');
	setInterval("info('./rss/info03.xml','info03')",3000);
}

function info04(){
	info('./rss/info04.xml','info04');
	setInterval("info('./rss/info04.xml','info04')",3000);

}

function info(path, id){
	var title='';
	var description='';
	var gyoumu='';
	var xmlDoc=loadXML(path);
	var cNodes = xmlDoc.getElementsByTagName("item");
	for(j=0;j<cNodes.length;j++)
	{
	   description = cNodes[j].getElementsByTagName("content:encoded")[0].childNodes[0].nodeValue;
	   
	   gyoumu += description + " "; 

	}
	document.getElementById(id).innerHTML = gyoumu;
}




function rss(){
	rss_f();
	setInterval("rss_f()",3000);
}
function rss_f(){
	google.load('feeds', '1'); 
	var feed = new google.feeds.Feed('http://dailynews.yahoo.co.jp/fc/economy/rss.xml'); 
	feed.setNumEntries(5); 
	feed.load(function(result){ 
		var temp = ''; 
		if (!result.error) 
		{ 
			for (var i = 0; i < result.feed.entries.length; i++) { 
				var entry = result.feed.entries[i]; 

				temp +=entry.title; 
				temp += ' '; 
				temp +=entry.content; 
				temp += ' '; 
			} 
			$("#news").html(temp); 
		} 
	}); 
}

