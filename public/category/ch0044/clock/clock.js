/**
 * @author vasdaq
 */
function clock(){

	var time = changeTime();
	var date = changeDate();
	document.getElementById("clock").innerHTML = date + time;

	
	setTimeout("clock()", 1000);
}

function changeDate(){
    var myDate=new Date();
    var YYYY=myDate.getFullYear();
    var MM=myDate.getMonth()+1;
    if(MM<10){MM="0"+MM;}
    var DD=myDate.getDate();
    if(DD<10){DD="0"+DD;}
    var date=YYYY+"年"+MM+"月"+DD+"日";
    return date;
}

function changeTime(){
	
    var myTime=new Date();
    var hh=myTime.getHours();
    var MI=myTime.getMinutes();
    if(MI < 10){MI = "0" + MI}
    var ss=myTime.getSeconds();
	if(ss < 10){ss = "0" + ss}
    var time=hh +"時" + MI+ "分" + ss+"秒"; 
    return time;
}

//onload = function(){
//	clock();
//};
