module Players

  class Html_Player
    require 'gettext/utils'
    cattr_accessor :aplog
    @@aplog ||= SystemSettings::APL_LOGGER
    CLASS_NAME = self.name
    include Validate
    include ContentsHelper
    
    def initialize()
    end

    def set_request(request)
      @request = request
    end
    
    def default(content)
      aplog.debug("START #{CLASS_NAME}#default")
      player_params ={
      "contents_setting" => {"outurl_0"=>"http://" + @request.env["HTTP_HOST"] + "/html_player_default/htmlplayer1.html",
                             "outurl_1"=>"http://" + @request.env["HTTP_HOST"] + "/html_player_default/htmlplayer2.html",
                             "outurl_2"=>"http://" + @request.env["HTTP_HOST"] + "/html_player_default/htmlplayer3.html",
                             "outurl_3"=>"http://" + @request.env["HTTP_HOST"] + "/html_player_default/htmlplayer4.html",
                             "outurl_4"=>"http://" + @request.env["HTTP_HOST"] + "/html_player_default/htmlplayer5.html",
                             "outurl_5"=>"",
                             "outurl_6"=>"",
                             "outurl_7"=>"",
                             "outurl_8"=>"",
                             "outurl_9"=>"",
                             "refreshtime"=>"5"},
                        
              "contents" => {"x_pos"=>"5",
                             "line_width"=>"5",
                             "y_pos"=>"5",
                             "line_color"=>"#38382e",
                             "height"=>"509",
                             "width"=>"345"},

      "channel_id"=>content.page.channel_id,
      "page_id"=>content.page_id
      }
      aplog.debug("END   #{CLASS_NAME}#default")
      return player_params
    end
    
    
    def set_content(current_user,content,params)
      aplog.debug("START #{CLASS_NAME}#set_content")
      @page = current_user.channels.find_by_id(params["channel_id"]).pages.find_by_id(params["page_id"])
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
      #----------------------------
      # input validate check
      #----------------------------
      if is_empty(params["contents_setting"]["outurl_0"])
        aplog.warn("ERR_0x01027001")
        raise AplInfomationException.new("ERR_0x01027001")
      elsif !is_url(params["contents_setting"]["outurl_0"])
        aplog.warn("ERR_0x01027002")
        raise AplInfomationException.new("ERR_0x01027002")
      end
      
      if !is_empty(params["contents_setting"]["outurl_1"])
        if !is_url(params["contents_setting"]["outurl_1"])
          aplog.warn("ERR_0x01027002")
          raise AplInfomationException.new("ERR_0x01027002")
        end
      end

      if !is_empty(params["contents_setting"]["outurl_2"])
        if !is_url(params["contents_setting"]["outurl_2"])
          aplog.warn("ERR_0x01027002")
          raise AplInfomationException.new("ERR_0x01027002")
        end
      end

      if !is_empty(params["contents_setting"]["outurl_3"])
        if !is_url(params["contents_setting"]["outurl_3"])
          aplog.warn("ERR_0x01027002")
          raise AplInfomationException.new("ERR_0x01027002")
        end
      end

      if !is_empty(params["contents_setting"]["outurl_4"])
        if !is_url(params["contents_setting"]["outurl_4"])
          aplog.warn("ERR_0x01027002")
          raise AplInfomationException.new("ERR_0x01027002")
        end
      end

      if !is_empty(params["contents_setting"]["outurl_5"])
        if !is_url(params["contents_setting"]["outurl_5"])
          aplog.warn("ERR_0x01027002")
          raise AplInfomationException.new("ERR_0x01027002")
        end
      end
      
      if !is_empty(params["contents_setting"]["outurl_6"])
        if !is_url(params["contents_setting"]["outurl_6"])
          aplog.warn("ERR_0x01027002")
          raise AplInfomationException.new("ERR_0x01027002")
        end
      end
      
      if !is_empty(params["contents_setting"]["outurl_7"])
        if !is_url(params["contents_setting"]["outurl_7"])
          aplog.warn("ERR_0x01027002")
          raise AplInfomationException.new("ERR_0x01027002")
        end
      end      
      
      if !is_empty(params["contents_setting"]["outurl_8"])
        if !is_url(params["contents_setting"]["outurl_8"])
          aplog.warn("ERR_0x01027002")
          raise AplInfomationException.new("ERR_0x01027002")  
        end
      end

      if !is_empty(params["contents_setting"]["outurl_9"])
        if !is_url(params["contents_setting"]["outurl_9"])
          aplog.warn("ERR_0x01027002")
          raise AplInfomationException.new("ERR_0x01027002")  
        end
      end
      
      if is_empty(params["contents_setting"]["refreshtime"])
        aplog.warn("ERR_0x01027004")
        raise AplInfomationException.new("ERR_0x01027004")
      elsif !is_half_num(params["contents_setting"]["refreshtime"])
        aplog.warn("ERR_0x01027003")
        raise AplInfomationException.new("ERR_0x01027003")
      end
      aplog.debug("END   #{CLASS_NAME}#validate")
    end
    
    def config_create
      
    end    
    
    # プレーヤ設定保存時の処理
    def config_save

    end

    # URLと数を取得
    def get_urlcount
      aplog.debug("START #{CLASS_NAME}#get_urlcount")
      urlcount = 0
      @url = ""
      if @content_properties["outurl_0"] != ""
        urlcount += 1
        @url = @content_properties["outurl_0"]
      end
      if @content_properties["outurl_1"] != ""
        urlcount += 1
        @url += ";"+@content_properties["outurl_1"]
      end
      if @content_properties["outurl_2"] != ""
        urlcount += 1
        @url += ";"+@content_properties["outurl_2"]
      end
      if @content_properties["outurl_3"] != ""
        urlcount += 1
        @url += ";"+@content_properties["outurl_3"]
      end
      if @content_properties["outurl_4"] != ""
        urlcount += 1
        @url += ";"+@content_properties["outurl_4"]
      end
      if @content_properties["outurl_5"] != ""
        urlcount += 1
        @url += ";"+@content_properties["outurl_5"]
      end
      if @content_properties["outurl_6"] != ""
        urlcount += 1
        @url += ";"+@content_properties["outurl_6"]
      end
      if @content_properties["outurl_7"] != ""
        urlcount += 1
        @url += ";"+@content_properties["outurl_7"]
      end
      if @content_properties["outurl_8"] != ""
        urlcount += 1
        @url += ";"+@content_properties["outurl_8"]
      end
      if @content_properties["outurl_9"] != ""
        urlcount += 1
        @url += ";"+@content_properties["outurl_9"]
      end
      aplog.debug("END #{CLASS_NAME}#get_urlcount")
      return urlcount
    end
    
    def get_html
      aplog.debug("START #{CLASS_NAME}#get_html")
      html=""
      
      html << "<html>"
      html << "<meta http-equiv='cache-control' content='non-cache' />\n"
      html << "<body style='margin:0px;'>"
      #URLの数を取得
      urlcount = get_urlcount()
      
      if urlcount == 1 && @content_properties['refreshtime'] != "0" 
        html << "<meta http-equiv='refresh'content='"+@content_properties['refreshtime']+";url='/index.html''>"
        html << "<IFRAME style='background:white;' src="+ @content_properties['outurl_0']+" frameborder='0' height="+ @content['height'].to_s+"px width="+ @content['width'].to_s+"px>"
        html << "</IFRAME>"
        html << "</body>"
        html << "</html>"
      elsif @content_properties['refreshtime'] == "0"
        html << "<IFRAME style='background:white;' src="+ @content_properties['outurl_0']+" frameborder='0' height="+ @content['height'].to_s+"px width="+ @content['width'].to_s+"px>"
        html << "</IFRAME>"
        html << "</body>"
        html << "</html>"
      else
        html << "<IFRAME id='ifid' style='background:white;' src="+ @content_properties['outurl_0']+" frameborder='0' height="+ @content['height'].to_s+"px width="+ @content['width'].to_s+"px>"
        html << "</IFRAME>"
        html << "<script language='javascript'> \n"
        html << "  var urls = new Array();\n"
        i = 0
        array = @url.split(";")
        while i < array.length()
          html << "  urls["+i.to_s+"]='"+array[i]+"';"
          i += 1
        end
        
        html << "  setInterval(show,"+@content_properties['refreshtime']+"*1000);\n"
        html << "  var num=0;"
        html << "  function show() \n"
        html << "  { \n"
        html << "    if(num=="+(urlcount-1).to_s+")\n"
        html << "    {\n"
        html << "      num=0;\n"
        html << "    }\n"
        html << "    else\n"
        html << "    {\n"
        html << "      num+=1;\n"
        html << "    }\n"
        html << "    document.getElementById('ifid').src=urls[num];\n"
        html << "  } \n"
        html << "</script>"
        html << "</body>"
        html << "</html>"
      end
      aplog.debug("END   #{CLASS_NAME}#get_html")
      return html
    end   
  end

end