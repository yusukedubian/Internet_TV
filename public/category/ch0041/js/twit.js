function createTwit() {
	var tw = new Twit("vocaloid_j", "twit");
}

var Twit = function(getId, outId) {
	this.getId = getId;
	this.outId = outId;
	this.param = "count=20";
	this.cnt = document.getElementById(outId + "_nickname");

	this.callback = function(arr) {
		var img = document.getElementById(this.outId + "_image");
		if (typeof(cnt) != 'undefined') {
			this.cnt.innerHTML = arr[0].user.name;
		}
		if (img) {
			img.innerHTML = '<img src="' + arr[0].user.profile_image_url + '" height="110" width="110" alt="" />';
		}
		var len = arr.length;
		for (var i = 0; i < len; i++) {
			var txt = document.getElementById(this.outId + '_text_' + (i + 1));
			if (txt) {
  			txt.innerHTML = omitStr(arr[i].text, 120);
			}
		}
	}
	
	TwitterAPI.statuses.user_timeline($.scope(this, this.callback), this.getId, this.param);
}