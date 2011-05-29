var g_hash = {
	'twit1' : 'Hosodamamoru',
	'twit2' : 'MORITAKESHI',
	'twit3' : 'togamebot',
	'twit4' : 'haluna7',
	'twit5' : 'hakokao',
	'twit6' : 'masayangest'
};
var g_cnt = 1;
var g_max = 6;

function getTl() {
	dummy();
}

function dummy() {
	if (g_cnt > g_max) {
		return;
	}
	setTimeout("createTwit()", 600);
}

function createTwit() {
	if (g_cnt > g_max) {
		return;
	}
	var tw = new Twit(g_hash["twit" + g_cnt], "twit" + g_cnt);
	setTimeout("dummy()", 600);
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
  			txt.innerHTML = omitStr(arr[i].text, 120);
			}
		}
	}
	
	if (this.cnt) {
		TwitterAPI.statuses.user_timeline($.scope(this, this.callback), this.getId, this.param);
	}
}