module Players
  
  class Youtube_player
    require 'gettext/utils'
    include Validate
    
    def initialize()
    end

    def set_request(request)
      @request = request
    end
    
    def default(content)
      player_params ={
      "contents_setting" => {"keyword"=>"エコロジー"},
                        
              "contents" => {"x_pos"=>"5",
                             "line_width"=>"5",
                             "y_pos"=>"5",
                             "line_color"=>"#38382e",
                             "height"=>"300",
                             "width"=>"300"},

      "channel_id"=>content.page.channel_id,
      "page_id"=>content.page_id
      }
      
      return player_params
    end
    
    def set_content(current_user,content,params)
      @current_user = current_user
      @content = content
      @content_properties = {}
      @content.contents_propertiess.each{|property|
        @content_properties[property[:property_key]] = property[:property_value]
      }
      @params = params
    end
    
    # 画面入力項目チェック
    def validate(current_user,params)
      if is_empty(params["contents_setting"]["keyword"])
          raise "ERR_0x01025601"
      end
    end
    
    # プレーヤー設定保存時の処理
    def config_save      
    end
            
    #コンフィグデータが必要な場合
    def config_create

    end
    
    #出力用HTML
    def get_html
      return create_html
    end
    
    
    def create_html
      keyword = @content_properties["keyword"]
      width =  @content["width"].to_i
      height = @content["height"].to_i
      #-----------------------------------
      # main process
      #-----------------------------------
      html =""
      html << "<html>"
      html << "<head>"
      html << '<meta http-equiv="content-type" content="text/html; charset=utf-8"/>'
      html << '<meta http-equiv="cache-control" content="non-cache" />'
      html << '<title></title>'
      html << '<script src="/javascripts/swfobject.js" type="text/javascript"></script>'
      html << '</head>'
      html << '<body style="margin:0">'
      
      html << '    <div id="ytapiplayer">'
      html << '      You need Flash player 8+ and JavaScript enabled to view this video.'
      html << '    </div>'

      html << '    <script type="text/javascript">'
      html << '      var params = { allowScriptAccess: "always", bgcolor: "#ffffff"};'
      html << '      var atts = { id: "myytplayer" };'
      html << '      swfobject.embedSWF("http://www.youtube.com/apiplayer?enablejsapi=1&amp;autoplay=1&playerapiid=ytplayer",' 
      html << '        "ytapiplayer", "'+width.to_s+'", "'+height.to_s+'", "8", null, null, params, atts);'
      html << '    </script>'
      html << '      <span style="display:none;" id="playerstate">--</span>'
      html << '      <span style="display:none;" id="videoduration">--:--</span>'
      html << '      <span style="display:none;" id="videotime">--:--</span>'
      html << '      <span style="display:none;" id="bytestotal"> </span>'
      html << '      <span style="display:none;" id="startbytes"> </span>'
      html << '      <span style="display:none;" id="bytesloaded"> </span>'
      html << '      <span style="display:none;" id="volume"> </span>'
      html << '  <input type="hidden" id="keyword" value="'+ ERB::Util.h(keyword)+'">'
      html << '  <div id="videos"></div>'
      
      html << '<script type="text/javascript">'
      html << 'var stopflg = 0;'
      html << 'var gword = "";'
      html << 'var gvideoid = "";'
      html << 'function onYouTubePlayerReady(playerId) {'
      html << 'ytplayer = document.getElementById("myytplayer");'
      html << 'setInterval(updateytplayerInfo, 250);'
      html << 'updateytplayerInfo();'
      html << 'ytplayer.addEventListener("onStateChange", "onytplayerStateChange");'
      html << 'ytplayer.addEventListener("onError", "onPlayerError");'
      html << 'stopflg = 0;'
      html << 'setVolume(50);'
      html << '}'
      html << 'function updateHTML(elmId, value) {'
      html << 'document.getElementById(elmId).innerHTML = value;'
      html << '}'
      html << '    function setytplayerState(newState) {'
      html << '      updateHTML("playerstate", newState);'
      html << '    }'
    
      html << '    function onytplayerStateChange(newState) {'
      html << '      setytplayerState(newState);'
      
      html << '      if (newState == 0 || newState == 5){'
      html << '        if (stopflg != 1){'
      html << '          var myurl = ytplayer.getVideoUrl();'
      html << '          getNextContent();'
      html << '        }else{'
      html << '          stopflg = 0;'
      html << '        }'
      html << '      }'
      html << '    }'
    
      html << '    function onPlayerError(errorCode) {'
      html << '      stop();'
      html << '    }'
    
      html << '    function getNextContent() {'
      html << '      var myurl = ytplayer.getVideoUrl();'
        
      html << '      var searchindex = myurl.indexOf("?v=");'
      html << '      if (searchindex != -1){'
      html << '        var videoid = myurl.substring(searchindex+3, searchindex+14);'
        
      html << '        relatedSearch(videoid);'
      html << '      }'
      html << '    }'
    
      html << '    function setytplayerState(newState) {'
      html << '          var nst="";'
      html << '          if(newState == -1){nst = "stop";}'
      html << '          else if(newState == 0){nst = "end";} '
      html << '          else if(newState == 1){nst = "play";} '
      html << '          else if(newState == 2){nst = "stop";} '
      html << '          else if(newState == 3){nst = "loading";}'
      html << '          else if(newState == 5){nst = "loading";}'
      html << '          updateHTML("playerstate", nst);'
      html << '        }'

      html << '    function updateytplayerInfo() {'
      html << '      updateHTML("bytesloaded", getBytesLoaded());'
      html << '      updateHTML("bytestotal", getBytesTotal());'
      html << '      updateHTML("videoduration", getDuration());'
      html << '      updateHTML("videotime", getCurrentTime());'
      html << '      updateHTML("startbytes", getStartBytes());'
      html << '      updateHTML("volume", getVolume());'
      html << '    }'
    
      html << '    function getPlayerState() {'
      html << '      if (ytplayer) {'
      html << '        return ytplayer.getPlayerState();'
      html << '      }'
      html << '    }'

      html << '    function seekTo(seconds) {'
      html << '      if (ytplayer) {'
      html << '        ytplayer.seekTo(seconds, true);'
      html << '      }'
      html << '    }'

      html << '    function endJump() {'
      html << '      if (ytplayer) {'
      html << '        ytplayer.seekTo(ytplayer.getDuration()-1, true);'
      html << '      }'
      html << '    }'
    
      html << '    function getBytesLoaded() {'
      html << '      if (ytplayer) {'
      html << '        return ytplayer.getVideoBytesLoaded();'
      html << '      }'
      html << '    }'

      html << '    function getBytesTotal() {'
      html << '      if (ytplayer) {'
      html << '        return ytplayer.getVideoBytesTotal();'
      html << '      }'
      html << '    }'

      html << '    function getCurrentTime() {'
      html << '      if (ytplayer) {'
      html << '        return ytplayer.getCurrentTime();'
      html << '      }'
      html << '    }'

      html << '    function getDuration() {'
      html << '      if (ytplayer) {'
      html << '        return ytplayer.getDuration();'
      html << '      }'
      html << '    }'

      html << '    function getStartBytes() {'
      html << '      if (ytplayer) {'
      html << '        return ytplayer.getVideoStartBytes();'
      html << '      }'
      html << '    }'

      html << '    function setVolume(newVolume) {'
      html << '      if (ytplayer) {'
      html << '        ytplayer.setVolume(newVolume);'
      html << '      }'
      html << '    }'

      html << '    function getVolume() {'
      html << '      if (ytplayer) {'
      html << '        return ytplayer.getVolume();'
      html << '      }'
      html << '    }'

      html << '    function clearVideo() {'
      html << '      if (ytplayer) {'
      html << '        ytplayer.clearVideo();'
      html << '      }'
      html << '    }'

      html << '    function loadNewVideo(id, startSeconds) {'
      html << '      if (ytplayer) {'
      html << '        ytplayer.loadVideoById(id, parseInt(startSeconds));'
      html << '      }'
      html << '    }'
    
      html << '    function cueNewVideo(id, startSeconds) {'
      html << '      if (ytplayer) {'
      html << '        ytplayer.cueVideoById(id, startSeconds);'
      html << '      }'
      html << '    }'
      html << '    function setVideoSize(width, height) {'
      html << '      if (ytplayer) {'
      html << '        ytplayer.setSize(width, height);'
      html << '      }'
      html << '    }'
      html << '    function search(word) {'
      html << '      gword = word;'
      html << '      var playerstate = getPlayerState();'
      html << '      if (playerstate == -1 || playerstate == 0 || (playerstate == 5 && stopflg != 1)){'
      html << '        var enckeyword = encodeURIComponent(word);'
      html << '        var query = "http://gdata.youtube.com/feeds/api/videos?"'
      html << '            + "vq=" + enckeyword'
      html << '            + "&max-results=10"'
      html << '            + "&alt=json-in-script"'
      html << '            + "&callback=view";'

      html << '        var script = document.createElement("script");'
      html << '        script.type = "text/javascript";'
      html << '        script.src = query;'

      html << '        videos.appendChild(script);'
      html << '      } else {'
      html << '        stop();'
      html << '      }'
      html << '    }'
      html << '    function relatedSearch(vid) {'
      html << '      gvideoid = vid;'

      html << '      var query = "http://gdata.youtube.com/feeds/api/videos/"'
      html << '          + vid'
      html << '          + "/related"'
      html << '          + "?max-results=5"'
      html << '          + "&alt=json-in-script"'
      html << '          + "&callback=view";'
      html << '      var script = document.createElement("script");'
      html << '      script.type = "text/javascript";'
      html << '      script.src = query;'
      html << '       document.getElementById("videos").innerHTML = "";'
      html << '      videos.appendChild(script);'
      html << '    }'
    
      html << '    function view(data) {'
      html << '      var es = data.feed.entry;'
      html << '      var rnd = Math.floor( Math.random() * es.length );'
      
      html << '      var group = es[rnd].media$group;'
      html << '      var myurl = group.media$player[0].url;'

      html << '      var searchindex = myurl.indexOf("?v=");'
      html << '      var videoid = myurl.substring(searchindex+3, searchindex+14);'
      html << '      loadNewVideo(videoid, 0);'
      html << '      var tid=setTimeout("reSearch()",3000);'
      html << '    }'

      html << '    function reSearch() {'
      html << '      var playerstate = getPlayerState();'

      html << '      if (playerstate == 5 && stopflg != 1){'
      html << '        search(gword);'
      html << '      }else{'
      html << '      }'
      html << '    }'
      html << '    function showPlayerUIDialog() {'
      html << '    }'
      
#      html << '   window.onload=function(){'
#      html << '     search(document.getElementById("keyword").value);'
#      html << '   }'
      html << '   window.onload=function(){'      
      html << '   setTimeout("search(document.getElementById(\'keyword\').value)",2000);'
      html << '   }'     
      html << '  </script>'
      html << '</body>'
      html << '</html>'

      
      return html
    end
    
    
  end
end