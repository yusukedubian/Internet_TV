



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





function gyoumu(){
setInterval("gyoumu_f()",3000);

}

function oshirase(){
	setInterval("oshirase_f()",1000);
}


function gyoumu_f(){
	var title='';
	var description='';
	var gyoumu='';
	var xmlDoc=loadXML('./rss/gyoumu.xml');
	var cNodes = xmlDoc.getElementsByTagName("item");
	for(j=0;j<cNodes.length;j++)
	{
	   description = cNodes[j].getElementsByTagName("content:encoded")[0].childNodes[0].nodeValue;
	   
	   gyoumu += description + "<br>"; 

	}

	$("document").ready(function()
	{
	$('#gyoumu').html(gyoumu);
	})
}

function oshirase_f(){
	var title='';
	var description='';
	var oshirase='';
	var xmlDoc=loadXML('./rss/oshirase.xml');
	var cNodes = xmlDoc.getElementsByTagName("item");
	for(j=0;j<cNodes.length;j++)
	{
	   description = cNodes[j].getElementsByTagName("description")[0].childNodes[0].nodeValue;
	   oshirase += description + "    "; 
	}
	$("document").ready(function()
	{
	$('#oshirase').html(oshirase);
	})

}
