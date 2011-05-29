var YtPlayer = function() {
	this.list = [];
	this.listHtml = [];
	this.listCnt = 0;
	this.current = 0;
	this.url = 'http://gdata.youtube.com/feeds/videos';

	/*==============================================================================
	 * 操作系
	 *=============================================================================*/

	/* 新規動画のロード
	 *
	 * 指定された動画を新規に読込む
	 * @param   string   動画ID
	 * @param   string   読込開始位置(秒指定、指定がない場合ははじめから)
	 * @return  boolean  実行結果
	 */
	this.load = function(id, seconds) {
	  var res = false;
	  seconds = seconds || 0;
		if (ytplayer) {
			ytplayer.loadVideoById(id, parseInt(seconds));
	    res = true;
		}
	  return res;
	}

	/* 新規動画のキュー入れ
	 *
	 * 指定された動画を読込みキュー待ち状態にする
	 * @param   string   動画ID
	 * @param   string   読込開始位置(秒指定、指定がない場合ははじめから)
	 * @return  boolean  実行結果
	 */
	this.cue = function(id, seconds) {
		var res = false;
		seconds = seconds || 0;
		if (ytplayer) {
			ytplayer.cueVideoById(id, parseInt(seconds));
			res = true;
		}
		return res;
	}

	/* 動画再生
	 *
	 * 読み込まれた動画を再生する
	 * @param   void
	 * @return  boolean  実行結果
	 */
	this.play = function() {
		var res = false;
		if (ytplayer) {
			ytplayer.playVideo();
			res = true;
		}
		return res;
	}

	/* 一時停止
	 *
	 * 再生中の動画を一時停止する
	 * @param   void
	 * @return  boolean  実行結果
	 */
	this.pause = function() {
		var res = false;
		if (ytplayer) {
			ytplayer.pauseVideo();
			res = true;
		}
		return res;
	}

	/* 動画停止
	 *
	 * 再生中の動画を停止する
	 * @param   void
	 * @return  boolean  実行結果
	 */
	this.stop = function() {
		var res = false;
		if (ytplayer) {
			ytplayer.stopVideo();
			res = true;
		}
		return res;
	}

	/* 後続動画読込み
	 *
	 * 動画リストに保存された次の動画を読込む
	 * @param   int      再生位置(秒、指定しない場合ははじめから)
	 * @return  boolean  実行結果
	 */
	this.loadNext = function(seconds) {
		res = false;
		if (ytplayer) {
			seconds = seconds || 0;
			if (this.listCnt > 0 && this.current + 1 <= this.listCnt) {
				this.current = this.current + 1;
				this.load(this.list[this.current], seconds);
				res = true;
			}
		}
		return res;
	}

	/* 先番動画読込み
	 *
	 * 動画リストに保存された前の動画を読込む
	 * @param   int      再生位置(秒、指定しない場合ははじめから)
	 * @return  boolean  実行結果
	 */
	this.loadPriv = function(seconds) {
		res = false;
		if (ytplayer) {
			seconds = seconds || 0;
			if (this.listCnt > 0 && this.current - 1 >= 0) {
				this.current = this.current - 1;
				this.load(this.list[this.current], seconds);
				res = true;
			}
		}
		return res;
	}

	/* 指定動画読込み
	 *
	 * 動画リストに保存された動画の中からインデックス指定されたものを読込む
	 * @param   int      リスト番号(リストの範囲を超えている場合は読込まない)
	 * @param   int      再生位置(秒、指定しない場合ははじめから)
	 * @return  boolean  実行結果
	 */
	this.loadList = function(num, seconds) {
		res = false;
		if (ytplayer) {
			seconds = seconds || 0;
			if (this.listCnt > 0 && num >= 0 && num <= this.listCnt) {
				this.current = num;
				this.load(this.list[this.current], seconds);
				res = true;
			}
		}
		return res;
	}

	/* 最初動画読込み
	 *
	 * 動画リストに保存された動画の中のうち一番はじめの動画を読込む
	 * @param   int      再生位置(秒、指定しない場合ははじめから)
	 * @return  boolean  実行結果
	 */
	this.loadFirst = function(seconds) {
		res = false;
		if (ytplayer) {
			seconds = seconds || 0;
			if (this.listCnt > 0) {
				this.current = 0;
				this.load(this.list[this.current], seconds);
				res = true;
			}
		}
		return res;
	}

	/* 最後動画読込み
	 *
	 * 動画リストに保存された動画の中のうち一番最後の動画を読込む
	 * @param   int      再生位置(秒、指定しない場合ははじめから)
	 * @return  boolean  実行結果
	 */
	this.loadLast = function(seconds) {
		res = false;
		if (ytplayer) {
			seconds = seconds || 0;
			if (this.listCnt > 0) {
				this.current = this.listCnt - 1;
				this.load(this.list[this.current], seconds);
				res = true;
			}
		}
		return res;
	}

	/* 動画位置変更
	 *
	 * 指定された動画位置を検索する
	 * @param   int      検索する動画位置(秒)
	 * @param   boolean  指定された動画位置が読み込まれている動画データの範囲を超えた場合に、プレーヤからサーバに新たな要求を送信するかどうか(指定しない場合は送信されない)
	 * @return  boolean  実行結果
	 */
	this.seek = function(seconds, allowSeekAhead) {
		var res = false;
		allowSeekAhead = allowSeekAhead || false;
		if (ytplayer) {
			ytplayer.seekTo(seconds, allowSeekAhead);
			res = true;
		}
		return res;
	}

	/* 動画終了位置ジャンプ
	 *
	 * 動画の最後にジャンプする
	 * @param   void
	 * @return  boolean  実行結果
	 */
	this.jump = function() {
		var res = false;
		if (ytplayer) {
			ytplayer.seekTo(ytplayer.getDuration()-1, true);
			res = true;
		}
		return res;
	}

	/* ミュート
	 *
	 * 再生中の動画をミュートする
	 * @param   void
	 * @return  boolean  実行結果
	 */
	this.mute = function() {
		var res = false;
		if (ytplayer) {
			ytplayer.mute();
			res = true;
		}
		return res;
	}

	/* ミュート解除
	 *
	 * 再生中の動画のミュートを解除する
	 * @param   void
	 * @return  boolean  実行結果
	 */
	this.unMute = function() {
		var res = false;
		if (ytplayer) {
			ytplayer.unMute();
			res = true;
		}
		return res;
	}

	/* 動画表示クリア
	 *
	 * 動画停止後の残像をクリアする
	 * @param   void
	 * @return  boolean  実行結果
	 */
	this.clear = function() {
		var res = false;
		if (ytplayer) {
			ytplayer.clearVideo();
			res = true;
		}
		return res;
	}

	/* リサイズ
	 *
	 * 動画の画面サイズを変更する
	 * @param   int      画面幅
	 * @param   int      画面高さ
	 * @return  boolean  実行結果
	 */
	this.resize = function(width, height) {
		var res = false;
		if (ytplayer) {
			ytplayer.setSize(width, height);
			res = true;
		}
		return res;
	}

	/* ボリューム設定
	 *
	 * 動画のボリュームを設定する
	 * @param   int      ボリューム(1～100)
	 * @return  mixed    実行結果
	 */
	this.volume = function(newVolume) {
		var res = false;
		if (newVolume < 0) {
			newVolume = 1;
		} else if (newVolume > 100) {
			newVolume = 100;
		}
		if (ytplayer) {
			ytplayer.setVolume(newVolume);
			res = true;
		}
		return res;
	}

	/*==============================================================================
	 * パラメータ取得系
	 *=============================================================================*/

	/* プレーヤステータス取得
	 *
	 * プレーヤの現在の状態を取得する。
	 * @param   void
	 * @return  mixed    ステータス(-1=未開始、0=終了、1=再生中、2=一時停止中、3=バッファ中、5=動画キュー、false=取得失敗)
	 */
	this.getState = function() {
		var res = false;
	  if (ytplayer) {
			res = ytplayer.getPlayerState();
		}
		return res;
	}

	/* 読込みサイズ取得
	 *
	 * 読込分の動画のサイズを返す
	 * @param   void
	 * @return  mixed    動画サイズ(バイト、false=取得失敗)
	 */
	this.getSizeLoaded = function() {
		var res = false;
		if (ytplayer) {
			res = ytplayer.getVideoBytesLoaded();
		}
		return res;
	}

	 /*
	 * 動画のトータルサイズを返す
	 * @param   void
	 * @return  mixed    動画サイズ(バイト、false=取得失敗)
	 */
	this.getSizeTotal = function() {
		var res = false;
		if (ytplayer) {
			res = ytplayer.getVideoBytesTotal();
		}
		return res;
	}

	/* 残りサイズ取得
	 *
	 * 未読込分の動画サイズを返す
	 * @param   void
	 * @return  mixed    動画サイズ(バイト、false=取得失敗)
	 */
	this.getSizeLeft = function() {
		var res = false;
		if (ytplayer) {
			res = getBytesTotal() - getBytesLoaded();
		}
		return res;
	}

	/* 動画開始時点サイズ取得
	 *
	 * 動画の読込を開始した時点でのサイズを返す(バイト)
	 * @param   void
	 * @return  mixed    読込開始時点サイズ(バイト、false=取得失敗)
	 */
	this.getSizeStart = function() {
		var res = false;
		if (ytplayer) {
			res = ytplayer.getVideoStartBytes();
		}
		return res;
	}

	/* 再生時間取得
	 *
	 * 動画の再生時間を返す
	 * @param   void
	 * @return  mixed    再生時間(秒、false=取得失敗)
	 */
	this.getTimeLoaded = function() {
		var res = false;
		if (ytplayer) {
			res = ytplayer.getCurrentTime();
		}
		return res;
	}

	/* 経過時間取得
	 *
	 * 動画の全体時間を返す
	 * @param   void
	 * @return  mixed    全体時間(秒、false=取得失敗)
	 */
	this.getTimeTotal = function() {
		var res = false;
		if (ytplayer) {
			res = ytplayer.getDuration();
		}
		return res;
	}

	/* 動画残り時間取得
	 *
	 * 動画の残り時間を返す
	 * @param   void
	 * @return  mixed    残り時間(秒、false=取得失敗)
	 */
	this.getTimeLeft = function() {
		var res = false;
		if (ytplayer) {
			res = Math.round((ytplayer.getDuration() - ytplayer.getCurrentTime()) * 1000 + 0.05) / 1000;
			
		}
		return res;
	}

	/* ボリューム取得
	 *
	 * 動画のボリュームを取得する
	 * @param   void
	 * @return  mixed    ボリューム(false=取得失敗)
	 */
	this.getVolume = function() {
		var res = false;
		if (ytplayer) {
			res = ytplayer.getVolume();
		}
		return res;
	}

	/* 埋め込みコード取得
	 *
	 * 読込済みまたは再生中の動画の埋め込みコードを返す
	 * @param   void
	 * @return  mixed    埋め込みコード(false=取得失敗)
	 */
	this.getEmbedCode = function() {
		var res = false;
		if (ytplayer) {
			res = ytplayer.getVideoEmbedCode();
		}
		return res;
	}

	/* 動画URL取得
	 *
	 * 読込み済み、再生中の動画のYouTube.comURLを返す
	 * @param   void
	 * @return  mixed    動画URL(false=取得失敗)
	 */
	this.getVideoUrl = function() {
		var res = false;
		if (ytplayer) {
			res = ytplayer.getVideoUrl();
		}
		return res;
	}

	/*==============================================================================
	 * 検索系
	 *=============================================================================*/

	/* 検索
	 *
	 * @param   int      
	 * @param   mixed
	 * @param   
	 * @param   void
	 * @return  mixed    動画URL(false=取得失敗)
	 */
	 this.find = function(flg, condition, max, callback) {
		var query = this.url;
		if (flg == 1) {
			query += "?vq=" + encodeURIComponent(condition);
		} else {
			query += "/" + parseInt(condition) + "/related";
		}
		max = max || 10;
		callback = callback || 'setList';
		query += "&max-result=" + max
			+ "&alt=json-in-script"
			+ "&callback=" + callback;
		var tag = document.createElement("script");
		var head = document.getElementsByTagName("head")[0];
		tag.type = "text/javascript";
		tag.src = query;
		head.appendChild(tag);
	}

	this.findByWord = function(word, max, callback) {
		this.find(1, word, max, callback);
	}

	this.findById = function(vid, max, callback) {
		this.find(1, vid, max, callback);
	}

	this.setHtml = function(data) {
		if (data.feed.openSearch$totalResults.$t>0) {
			var entries = data.feed.entry;
			var cnt = entries.length;
			for (var i=0; i<cnt; i++) {
				this.list[i] = entries[i].content.$t;
			}
		}
	}

	this.setTitle = function(data) {
		var res = false;
		var pattern = /http:\/\/www.youtube.com\/watch\?v=(.*)&amp;feature/;

		if (data.feed.openSearch$totalResults.$t>0) {
			var entries = data.feed.entry;
			this.listCnt = entries.length;
			for (var i=0; i<this.listCnt; i++) {
				var tmp = entries[i].content.$t.match(pattern);
				if (tmp[1]) {
					this.list[i] = tmp[1];
				} else {
					this.list[i] = false;
				}
			}
			res = true;
		}
		return res;
	}

	this.setTitleOnLoad = function(data) {
		if (this.setTitle(data, true)) {
			var tid = setTimeout('dummy()', 1000);
		} else {
			alert("アクセス負荷が高くなっているため、You Tube動画リストの読込に失敗しました。\n大変お手数ですが、このページを再読み込みしてください。");
		}
	}

	this.listOnLoad = function() {
		var cnt = 0;
		var res = false;
		if (this.listCnt > 0) {
			for (var i=0; i<this.listCnt; i++) {
				if (this.list[i]) {
					var video = this.list[i];
					break;
				}
			}
			var tmp = this.load(video, 0);
			if (tmp) {
				var tid = setTimeout('checkStatus', 5000);
			} else {
				var tid = setTimeout('checkStatus', 5000);
			}
		}
		return res;
	}

	/*==============================================================================
	 * イベント系
	 *=============================================================================*/
	/* エラーイベント
	 * 
	 * APIエラー発生時にエラー内容を表示する
	 * @param   string   エラーコード
	 * @return  void
	 */
	this.onError = function(errorCode) {
		alert("An error occured: " + errorCode);
	}

	/* ステータス変更
	 * 
	 * 動画ステータスが変更された際のイベント
	 * @param   int      動画ステータスコード
	 * @return  void
	 */
	this.setState = function(newState) {
		updateHTML('player_state', newState);
	}

	this.updateHTML = function(elmId, value) {
		document.getElementById(elmId).innerHTML = value;
	}

	this.onStateNextLoad = function(newState) {
		if (newState == 0 || newState == 5) {
			if (this.current < this.listCnt) {
				this.loadNext();
			} else {
				this.loadFirst();
			}
		}
	}

/*
	this.updateInfo = function() {
		res = this.getSizeLeft;
		this.updateHTML("loaded_size", this.getSizeLoaded());
		this.updateHTML("total_size", this.getSizeTotal());
		this.updateHTML("start_size", this.getSizeStart());
		this.updateHTML("left_size", this.getSizeLeft());
		this.updateHTML("total_time", this.getTimeTotal());
		this.updateHTML("loaded_time", this.getTimeLoaded());
		this.updateHTML("left_time", this.getTimeLeft());
		this.updateHTML("volume", this.getVolume());
	}
*/
}

var ytp = new YtPlayer();

function setTitleOnLoad(data) {
	ytp.setTitleOnLoad(data);
}

function setTitle(data) {
	ytp.setTitle(data);
}

function checkStatus() {
	var state = ytp.getState();
	if (state == -1) {
		ytp.play();
	} else if (state !== 2 && state !== 3) {
		alert("エラーが発生しました。お手数ですが再読み込みしてください。");
	}
}

function dummy() {
	ytp.listOnLoad();
}