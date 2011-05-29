var g_word;
var g_vid;
var ytplayer;

var params = { allowScriptAccess: "always", bgcolor: "#ffffff"};
var atts = { id: "myytplayer" };
swfobject.embedSWF(
	"http://www.youtube.com/apiplayer?enablejsapi=1&amp;autoplay=1&playerapiid=ytplayer", 
	"ytapiplayer", "400", "300", "8", null, null, params, atts
	);

function onYouTubePlayerReady(playerId) {
	ytplayer = document.getElementById("myytplayer");
	ytplayer.addEventListener("onStateChange", "onytplayerStateChange");
	ytplayer.addEventListener("onError", "onPlayerError");
	endFlag = 0;
	setVolume(20);
}

function onytplayerState(newState) {
	if (newState == 0 || newState == 5) {
   getNextContent();
  } else {
   endFlag = 0;
  }
}

function onPlayerError(errorCode) {
	alert("An Error occurred:" + errorCode);
	stop();
}

function getNextContent() {
	var url = ytplayer.getVideoUrl();
	var searchs = url.indexOf("?v=");
	if (searchs != -1) {
   var videoId = url.substring(searchs+3, searchs+14);
   relatedSearch(videoid);
	}
}

function play() {
	if (ytplayer) {
		ytplayer.playVideo();
	}
}

function pause() {
	if (ytplayer) {
		ytplayer.pauseVideo();
	}
}

function stop() {
	if (ytplayer) {
		endFlag = 1;
		ytplayer.stopVideo();
	}
}

function seek(seconds) {
	if (ytplayer) {
		ytplayer.seekTo(seconds, true);
	}
}

function jump() {
	if (ytplayer) {
		return ytplayer.seekTo(ytplayer.getDuration()-1, true);
	}
}

function volume(newVolume) {
	if (ytplayer) {
		ytplayer.setVolume(newVolume);
	}
}

function mute() {
	if (ytplayer) {
		ytplayer.mute();
	}
}

function unMute() {
	if (ytplayer) {
		ytplayer.unMute();
	}
}

function clear() {
	if (ytplayer) {
		ytplayer.clearVideo();
	}
}

function load(id, startSeconds) {
	if (ytplayer) {
		ytplayer.loadVideoById(id, parseInt(startSeconds));
	}
}

function cue(id, startSeconds) {
	if (ytplayer) {
		ytplayer.cueVideoById(id, parseInt(startSeconds));
	}
}

function size(width, height) {
	if (ytplayer) {
		ytplayer.setSize(width, height);
	}
}


function getState() {
	if (ytplayer) {
		return ytplayer.getPlayerState();
	}
}

function getBytesLoaded() {
	if (ytplayer) {
		return ytplayer.getVideoBytesLoaded();
	}
}

function getBytesTotal() {
	if (ytplayer) {
		return ytplayer.getVideoBytesTotal();
	}	
}

function getBytesLeft() {
	if (ytplayer) {
		return getBytesTotal() - getBytesLoaded();
	}
}

function getBytesStart() {
	if (ytplayer) {
		return ytplayer.getVideoStartBytes();
	}
}

function getTimeLoaded() {
 if (ytplayer) {
  return ytplayer.getCurrentTime();
 }
}

function getTimeTotal() {
 if (ytplayer) {
  return ytplayer.getDuration();
 }
}

function getTimeLeft() {
 if (ytplayer) {
  return getTimeTotal() - getTimeLoaded();
 }
}

function getVolume() {
	if (ytplayer) {
		return ytplayer.getVolume();
	}
}

function getEmbedCode() {
	if (ytplayer) {
		return ytplayer.getVideoEmbedCode();
	}
}

function getVideoUrl() {
	if (ytplayer) {
		return ytplayer.getVideoUrl();
	}
}

function searchByWord(word, max) {
	g_word = word;
	var playerState = getPlayerState();
	if (playerState == -1 || playerState == 0 || (palyerState == 5 && endFlag != 1)) {
		var encodedWord = encodeURIComponent(word);
		var query = "http://gdata.youtube.com/feeds/api/videos?"
			+ "vq=" + word
			+ "&max-results=" + max
			+ "&alt=json-in-script"
			+ "&callback=view";
		var script = document.createElement("script");
		script.type = "text/javascript";
		script.src = "query";
		videos.appendChild(script);
	} else {
		stop();
	}
}

function searchById(vid, max) {
	g_vid = vid;
}

function view(data, mode) {
	
	var entry = data.feed.entry;
	var rnd = Math.floor(Math.random() * entry.length);
	var group = entry[rnd].media$group;
	var myurl = group.media$player[0].url;

}