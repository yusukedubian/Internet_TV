function execCrousel() {
	var twitline = {
		'twit1',
		'twit2',
		'twit3',
		'twit4',
		'twit5',
		'twit6',
		'twit7',
		'twit8',
		'twit9',
		'twit10'
		};
	var len = twitline.length;

	for (var i = 0; i < len; i++) {
		var cr = new Caro(twitline[i], 1, 2, false, 'last', 1);
	}

	var cr = new Caro('twit', 1, 20, true, 'both', 1);
}

var Caro = function(id, start, auto, vertical, wrap, scroll) {
	this.id = id;
	this.start = start||1;
	this.auto = auto||4;
	this.vertical = vertical||false;
	this.wrap = wrap||"last";
	this.scroll = scroll||5;
	
	this.callback = function(carousel) {
		carousel.clip.hover(
			function() {carousel.stopAuto();}, 
			function() {carousel.startAuto();}
		);
	}

	if (document.getElementById(this.id)) {
		jQuery(document).ready(function() {
			jQuery('#' + this.id).jcarousel({
				start: this.start,
				auto: this.auto,
				vertical: this.vertical,
				wrap: this.wrap,
				scroll: this.scroll,
				initCallback: this.callback
   	 		});
		});
	}
}
