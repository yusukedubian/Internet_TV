/**
 * @author vasdaq
 */
<!--
	function clock() {
		var time = changeTime();
		var date = changeDate();
		document.getElementById("clock").innerHTML = date + ' ' + time;
		setTimeout("clock()", 1000);
	}
	
	function changeDate() {
	    var myDate = new Date();
	    var YYYY = myDate.getFullYear();
	    var MM = myDate.getMonth()+1;
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
	    var date = YYYY + "年" + MM + "月" + DD + "日(" + day + ")";
	    return date;
	}
	
	function changeTime() {
	    var myTime = new Date();
	    var hh = myTime.getHours();
	    var MI = myTime.getMinutes();
	    var ss = myTime.getSeconds();
	    if (MI < 10) {
	    	MI = "0" + MI
	    }
		if (ss < 10) {
			ss = "0" + ss
		}
	    var time = hh + ":" + MI + ":" + ss; 
	    return time;
	}
//-->