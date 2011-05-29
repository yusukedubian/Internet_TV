module Players
  
  class Video_player
    require 'gettext/utils'
    cattr_accessor :aplog
    @@aplog ||= SystemSettings::APL_LOGGER
    CLASS_NAME = self.name
    include Validate
    
    def initialize()
    end

    def set_request(request)
      @request = request
    end
    
    def default(content)
      aplog.debug("START #{CLASS_NAME}#default")
      embed_tag="<object style='margin:0px;' width='650' height='400'>"
      embed_tag+="<param name='movie' value='http://www.youtube.com/v/ojCKdPl35AQ?fs=1&amp;hl=ja_JP&amp;rel=0'></param>"
      embed_tag+="<param name='allowFullScreen' value='true'></param>"
      embed_tag+="<param name='allowscriptaccess' value='always'></param>"
      embed_tag+="<embed src='http://www.youtube.com/v/ojCKdPl35AQ?fs=1&amp;hl=ja_JP&amp;rel=0&autoplay=1' type='application/x-shockwave-flash' allowscriptaccess='always' allowfullscreen='true' width='640' height='390'></embed></object>"
      player_params ={
        "contents_setting" => {"video_set_type"=>"embed_tag",
                               "video_file_mp4"=>"",
                               "video_file_webm"=>"",
                               "video_file_ogv"=>"",
                               "keyword"=>"テレビ",
                               "embed_tag"=>embed_tag},
  
                "contents" => {"x_pos"=>"5",
                               "line_width"=>"5",
                               "y_pos"=>"5",
                               "line_color"=>"#38382e",
                               "height"=>"400",
                               "width"=>"650"},
        "contents_upload" => "flag",
        "channel_id"=>content.page.channel_id,
        "page_id"=>content.page_id
      }

=begin      
      sample_flash_path = RuntimeSystem.default_content_save_dir() << "vasdaq-it_full.mp4"
      store_path = RuntimeSystem.content_save_dir(content)
      FileUtils.mkdir_p(store_path)
      FileUtils.cp(sample_flash_path, store_path)

      sample_flash_path = RuntimeSystem.default_content_save_dir() << "vasdaq-it_full.webm"
      store_path = RuntimeSystem.content_save_dir(content)
      FileUtils.mkdir_p(store_path)
      FileUtils.cp(sample_flash_path, store_path)
=end
      aplog.debug("END   #{CLASS_NAME}#default")
      return player_params
    end
    
    def set_content(current_user,content,params)
      aplog.debug("START #{CLASS_NAME}#set_content")
      @current_user = current_user
      @content = content
      @content_properties = {}
      @content.contents_propertiess.each{|property|
        @content_properties[property[:property_key]] = property[:property_value]
      }
      @params = params
      aplog.debug("END   #{CLASS_NAME}#set_content")
    end
    
    # 画面入力項目チェック
    def validate(current_user,params)
      aplog.debug("START #{CLASS_NAME}#validate")
      if is_empty(params["contents_setting"]["video_set_type"])
        aplog.warn("ERR_0x01027201")
        raise AplInfomationException.new("ERR_0x01027201")
      end
      
      # 動画設定タイプがアップロードか確認
      if (params["contents_setting"]["video_set_type"].to_s == "video_upload")
        
        file_mp4_obj = params["contents_upload"]["video_file_mp4"]
        file_webm_obj = params["contents_upload"]["video_file_webm"]
        file_ogv_obj = params["contents_upload"]["video_file_ogv"]
        
        # １つも設定されてないかチェック
        if is_empty(file_mp4_obj) && is_empty(file_webm_obj) && is_empty(file_ogv_obj)
          aplog.warn("ERR_0x01027202")
          raise AplInfomationException.new("ERR_0x01027202")
        end
        
        # MP4ファイルがアップロードされてるかチェック
        if !is_empty(file_mp4_obj)
          file_1_ext = File.extname(file_mp4_obj.original_filename)
          if is_empty(file_1_ext) || !(file_1_ext.downcase == ".mp4")
            aplog.warn("ERR_0x01027203")
            raise AplInfomationException.new("ERR_0x01027203")
          end
        end

        # webmファイルがアップロードされてるかチェック
        if !is_empty(file_webm_obj)
          file_2_ext = File.extname(file_webm_obj.original_filename)
          if is_empty(file_2_ext) || !(file_2_ext.downcase == ".webm")
            aplog.warn("ERR_0x01027204")
            raise AplInfomationException.new("ERR_0x01027204")
          end
        end

        # ogvファイルがアップロードされてるかチェック
        if !is_empty(file_ogv_obj)
          file_3_ext = File.extname(file_ogv_obj.original_filename)
          if is_empty(file_3_ext) || !(file_3_ext.downcase == ".ogv")
            aplog.warn("ERR_0x01027204")
            raise AplInfomationException.new("ERR_0x01027204")
          end
        end
        
      end
      
      # 動画設定タイプがyoutubeキーワード検索か確認
      if (params["contents_setting"]["video_set_type"].to_s == "youtube_keyword_search")
        
        # キーワードが設定されてるかチェック
        if is_empty(params["contents_setting"]["keyword"])
            aplog.warn("ERR_0x01025601")
            raise AplInfomationException.new("ERR_0x01025601")
        end
      end

      # 動画設定タイプが埋め込みタグか確認
      if (params["contents_setting"]["video_set_type"].to_s == "embed_tag")
        
        # 埋め込みタグが設定されてるかチェック
        if is_empty(params["contents_setting"]["embed_tag"])
            aplog.warn("ERR_0x01025601")
            raise AplInfomationException.new("ERR_0x01025601")
        end
      end
      aplog.debug("END   #{CLASS_NAME}#validate")
    end
    
    # プレーヤー設定保存時の処理
    def config_save
    end
            
    #コンフィグデータが必要な場合
    def config_create

    end
    
    #出力用HTML
    def get_html
      aplog.debug("START #{CLASS_NAME}#get_html")
      html = ""
      if (@content_properties["video_set_type"].to_s == "video_upload")
        html = create_video_upload_html()
      elsif (@content_properties["video_set_type"].to_s == "youtube_keyword_search")
        html = create_youtube_keyword_search_html()
      else
        html = create_embed_tag_html()
      end
      aplog.debug("END   #{CLASS_NAME}#get_html")
      return html
    end
    
    
    
    def create_video_upload_html
      aplog.debug("START #{CLASS_NAME}#create_video_upload_html")
      if @params["contents_upload"] == "flag"||@params["dragflag"] == "flag"
        #pass
      else
        file_mp4_obj = @params["contents_upload"]["video_file_mp4"]
        file_webm_obj = @params["contents_upload"]["video_file_webm"]
        file_ogv_obj = @params["contents_upload"]["video_file_ogv"]
        if !is_empty(file_mp4_obj)
          RuntimeSystem.get_upload_file(@content, file_mp4_obj, file_mp4_obj.original_filename)
        end
        if !is_empty(file_webm_obj)
          RuntimeSystem.get_upload_file(@content, file_webm_obj, file_webm_obj.original_filename)
        end
        if !is_empty(file_ogv_obj)
          RuntimeSystem.get_upload_file(@content, file_ogv_obj, file_ogv_obj.original_filename)
        end
      end
      
      sourcehtml=""
      @content_properties.each{|key, value|
        if key =~ /video_file/
          if !is_empty(value)
            sourcehtml << '<source src="'+ value + '">'
          end
        end
      }
      #RuntimeSystem.content_save_dir(@content)
      html = ''
      html << '<html>'
      html << '<head>'
      html << '<meta http-equiv="cache-control" content="non-cache" />'
#      html << '<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>'
#      html << '<script src="http://html5media.googlecode.com/svn/trunk/src/jquery.html5media.min.js"></script>'
      html << '</head>'
      html << '<body style="margin:0px;">'
#      html << '<video width="'+@content.width.to_s+'"px height="'+@content.height.to_s+'"px src="'+ fileobj.original_filename + '" autoplay>\n'
      html << '<video controls autoplay autobuffer width="'+@content.width.to_s+'"px height="'+@content.height.to_s+'"px>'
      html << sourcehtml
#      html << '<source src="'+ fileobj.original_filename + '">'
#      html << '<source src="'+ fileobj.original_filename + '">'
#      html << '<source src="sample.ogm">'
      html << '</video>'
      html << "</body>\n"
      html << "</html>\n"
      aplog.debug("END   #{CLASS_NAME}#create_video_upload_html")
      return html
    end
    
    
    
    def create_youtube_keyword_search_html
      aplog.debug("START   #{CLASS_NAME}#create_youtube_keyword_search_html")
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
      html << '<body style="margin:0px;">'
      
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

      aplog.debug("END   #{CLASS_NAME}#create_youtube_keyword_search_html")
      return html
    end
    
    
    def create_embed_tag_html()
      aplog.debug("START   #{CLASS_NAME}#create_embed_tag_html")
      html = ""
      html << "<html>\n"
      html << "<head>\n"
      html << "<meta http-equiv='cache-control' content='non-cache' />\n"
#      html << "<script src='http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js'></script>"
#      html << "<script src='http://html5media.googlecode.com/svn/trunk/src/jquery.html5media.min.js'></script>"
      html << "</head>\n"
      html << "<body style='margin:0px;'>\n"
      html << @content_properties["embed_tag"]
      html << "</body>\n"
      html << "</html>\n"
      aplog.debug("END   #{CLASS_NAME}#create_embed_tag_html")
      return html
    end
    
  end
end
