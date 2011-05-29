//window.onload = scrMsg;
//横
var cnt = 0;
var stpX = 10;  //停止座標
var stpY = 0;  //停止座標
var stpTime = 400;  //停止時間
var posLeft = 1800;  //開始座標
var str="";
var opt="";
//縦
var posTop = 40;


var i = 0; //配列変数
var list = new Array();
function scrMsg(_list, _str, _opt){
	

	list = _list;
	str = _str;
	opt = _opt;
	if (opt == 1) {
		document.getElementById(str).innerHTML = msgTxtH();
	}else if (opt == 3){
		document.getElementById(str).innerHTML = msgTxtV2();
	}else{
		document.getElementById(str).innerHTML = msgTxtV();
	}
	
	cnt++;
	if(cnt > stpTime){
		cnt = 0;
		i++;
		if(i==list.length){i=0;}
	}
	setTimeout("scrMsg(list,str,opt)",120);
}

function msgTxtH() {

	var drift = "";
	var speed = 7;  //テキストの流れる速さ
	var posX = posLeft-cnt*speed;  //テキストの X座標

	if( posX < stpX){ posX = stpX;} //スクロール停止
	{
		drift = '<div style="position:absolute;left:' + posX + 'px;">' + list[i] + "</div>";
	}
	return drift;
}


function msgTxtV(){
	var drift = "";
	var speed = 1;  //テキストの流れる速さ
	var posY = posTop-cnt*speed;  //テキストの X座標

	if( posY < stpY){ posY = stpY;} //スクロール停止
	{
		drift = '<div style="position:absolute;top:' + posY + 'px;">' + list[i] + "</div>";
		//alert(drift);
	}
	return drift;
}

function msgTxtV2(){
	var drift = "";
	var speed = 1;  //テキストの流れる速さ
	var posY = posTop-cnt*speed;  //テキストの X座標

	if( posY < stpY){ posY = stpY;} //スクロール停止
	{
		drift = '<div style="position:absolute;right:0px;top:' + posY + 'px;">' + list[i] + "</div>";
		//alert(drift);
	}
	return drift;
}
