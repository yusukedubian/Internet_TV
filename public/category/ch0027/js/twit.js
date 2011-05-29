var g_hash = {
	'twit1' : 'DAVID_LYNCH',
	'twit2' : 'Jon_Favreau',
	'twit3' : 'RWZombie',
	'twit4' : 'RealHughJackman',
	'twit5' : 'DameElizabeth',
	'twit6' : 'aplusk',
	'twit7' : 'mrskutcher',
	'twit8' : 'tomhanks',
	'twit9' : 'ZacharyQuinto',
	'twit10' : 'KevinSpacey'
}

var g_cnt = 1;
var g_max = 10;

function getTl() {
	dummy();
}

function dummy() {
	if (g_cnt > g_max) {
		return;
	}
	setTimeout("createTwit()", 750);
}

function createTwit() {
	if (g_cnt > g_max) {
		return;
	}
	var tw = new Twit(g_hash["twit" + g_cnt], "twit" + g_cnt);
	setTimeout("dummy()", 750);
	g_cnt++;
}

var Twit = function(getId, outId) {
	this.getId = getId;
	this.outId = outId;
	this.param = "count=10";
	this.cnt = document.getElementById(outId + "_nickname");

	this.callback = function(arr) {
		var img = document.getElementById(this.outId + "_image");
		this.cnt.innerHTML = arr[0].user.name;

		if (img) {
			img.innerHTML = '<img src="' + arr[0].user.profile_image_url + '" height="80" width="80" alt="" />';
		}
		var len = arr.length;
		for (var i = 0; i < len; i++) {
			var txt = document.getElementById(this.outId + '_text_' + (i + 1));
			if (txt) {
  			txt.innerHTML = arr[i].text;
			}
		}
	}
	
	if (this.cnt) {
		TwitterAPI.statuses.user_timeline($.scope(this, this.callback), this.getId, this.param);
	}
}

function callback(arr) {
var str = '';
var outId = "test";
var cnt = document.getElementById(outId + '_nickname');
if (cnt) {
	cnt.innerHTML = arr[0].user.screen_name;
}

for (var i=0; i<arr.length; i++) {
  var cnt = document.getElementById(outId + "_text_" + (i + 1));
  if (cnt) {
  	cnt.innerHTML = arr[i].text;
  }
}
}
  
function getTL(getID, outID){
var param = 'count=10';
TwitterAPI.statuses.user_timeline(callback, getID, param);
}
