module Players

  class Rss_player
    require 'gettext/utils'
    cattr_accessor :aplog
    @@aplog ||= SystemSettings::APL_LOGGER
    CLASS_NAME = self.name
    include Validate
    include ContentsHelper
    include ConstUserSettings
    
    
    def initialize()
    end
    
    def set_request(request)
      @request = request
    end

    def default(content)
      aplog.debug("START #{CLASS_NAME}#default")
      player_params ={
      "contents_setting" => {"viewtype"=>"classic",
                             "back_color"=>"#28281C",
                             "title_font_color"=>"#4AE821",
                             "title_color"=>"#28281C",
                             "font_size"=>"30",
                             "title_font_size"=>"15",
                             "font_color"=>"#4AE821",
                             "title1"=>"live door Weather NEWS",
                             "scroll_direction"=>"Left",
                             "scroll_speed"=>"70",
                             "urlpath1"=>"http://weather.livedoor.com/forecast/rss/index.xml",
                             "billboard_font_size"=>"10",
                             "billboard_font_color"=>"#0xFF0000",
                             "billboard_title_font_size"=>"15",
                             "billboard_title_font_color"=>"#4AE821",
                             "billboard_title_color"=>"#28281C",
                             "billboard_scroll_direction"=>"Left",
                             "billboard_scroll_speed"=>"70",
                             "billboard_local_url"=>@request["HTTP_HOST"]
                             },
                        
              "contents" => {"x_pos"=>"5",
                             "line_width"=>"5",
                             "y_pos"=>"5",
                             "line_color"=>"#38382e",
                             "height"=>"80",
                             "width"=>"700"},

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
      #if current_user.user_property.blank? || current_user.user_property.google_key.blank?
      #  raise "ERR_0x01025416"
      #end
      
      if is_empty(params["contents_setting"]["urlpath1"])
        aplog.warn("ERR_0x01025401")
        raise AplInfomationException.new("ERR_0x01025401")
      elsif !is_url(params["contents_setting"]["urlpath1"])
        aplog.warn("ERR_0x01025402")
        raise AplInfomationException.new("ERR_0x01025402")
      end
      
      if is_empty(params["contents_setting"]["title1"])
        aplog.warn("ERR_0x01025403")
        raise AplInfomationException.new("ERR_0x01025403")
      end
      
      if is_empty(params["contents_setting"]["font_size"])
        aplog.warn("ERR_0x01025404")
        raise AplInfomationException.new("ERR_0x01025404")
      elsif !is_half_num(params["contents_setting"]["font_size"])
        aplog.warn("ERR_0x01025405")
        raise AplInfomationException.new("ERR_0x01025405")
      end
      
      if is_empty(params["contents_setting"]["font_color"])
        aplog.warn("ERR_0x01025406")
        raise AplInfomationException.new("ERR_0x01025406")
      elsif !is_color_code(params["contents_setting"]["font_color"])
        aplog.warn("ERR_0x01025407")
        raise AplInfomationException.new("ERR_0x01025407")
      end
      
      if is_empty(params["contents_setting"]["title_font_color"])
        aplog.warn("ERR_0x01025408")
        raise AplInfomationException.new("ERR_0x01025408")
      elsif !is_color_code(params["contents_setting"]["title_font_color"])
        aplog.warn("ERR_0x01025409")
        raise AplInfomationException.new("ERR_0x01025409")
      end
      
      if is_empty(params["contents_setting"]["title_color"])
        aplog.warn("ERR_0x01025410")
        raise AplInfomationException.new("ERR_0x01025410")
      elsif !is_color_code(params["contents_setting"]["title_color"])
        aplog.warn("ERR_0x01025411")
        raise AplInfomationException.new("ERR_0x01025411")
      end
      
      if !is_check_select(params["contents_setting"]["scroll_speed"],scroll_speed_for_select)
        aplog.warn("ERR_0x01025412")
        raise AplInfomationException.new("ERR_0x01025412")
      end
      
      if !is_check_select(params["contents_setting"]["scroll_direction"],scroll_direction_for_select)
        aplog.warn("ERR_0x01025413")
        raise AplInfomationException.new("ERR_0x01025413")
      end
      
      if is_empty(params["contents_setting"]["back_color"])
        aplog.warn("ERR_0x01025414")
        raise AplInfomationException.new("ERR_0x01025414")
      elsif !is_color_code(params["contents_setting"]["back_color"])
        aplog.warn("ERR_0x01025415")
        raise AplInfomationException.new("ERR_0x01025415")
      end
      aplog.debug("END   #{CLASS_NAME}#validate")
    end
    
    def config_create
      
    end    
    
    # プレーヤ設定保存時の処理
    def config_save
      
    end
    
    def get_html
      aplog.debug("START #{CLASS_NAME}#get_html")
      if @content_properties["viewtype"]=="classic"
        #-----------------------------------
        # main process
        #-----------------------------------
        html=""
        strLine = delEnter(@content_properties["linecontrol"])
        html << getHtmlHead()
        html << getRSS(@content.id.to_s+"_1",
                       @content.width.to_s,
                       @content.height.to_s,
                       delEnter(@content_properties["title_font_color"]),
                       delEnter(@content_properties["font_size"]),
                       delEnter(@content_properties["font_color"]),
                       delEnter(@content_properties["title1"]),
                       delEnter(@content_properties["scroll_direction"]),
                       delEnter(@content_properties["scroll_speed"]),
                       delEnter(@content_properties["urlpath1"]))
        html << getHtmlFoot
      elsif @content_properties["viewtype"]=="billboard"
        html = ""
        html << getHtmlHead()
        html << get_billboard_html()
        html << getHtmlFoot
      end
      aplog.debug("END   #{CLASS_NAME}#get_html")
      return html
    end
    
    def get_billboard_html()
      aplog.debug("START   #{CLASS_NAME}#get_billboard_html")
      width = @content["width"]
      height = @content["height"]
      urlpath1 = @content_properties["urlpath1"].to_s
      txt_type = "rss"
      #text_content = @content_properties["text_content"].to_s
      font_color = @content_properties["billboard_font_color"].to_s
      font_size = @content_properties["billboard_font_size"].to_s
      title_font_size = @content_properties["billboard_title_font_size"].to_s
      scroll_direction = @content_properties["billboard_scroll_direction"].to_s
      local_url = @content_properties["billboard_local_url"]
      strTitle = @content_properties["title1"]
      
      # scroll_speed
      if @content_properties["billboard_scroll_speed"] == "70"
        scroll_speed = "10"
      elsif @content_properties["billboard_scroll_speed"] == "50"
        scroll_speed = "5"
      elsif @content_properties["billboard_scroll_speed"] == "30"
        scroll_speed = "1"
      end
      
      if width == "545" && height == "545"
        width = "546"
        height = "546"
      end
      
      if font_size == "小"
        font_size = "10";
      elsif font_size == "中"
        font_size = "15";
      elsif font_size == "大"
        font_size = "30";
      end
      
      FileUtils.copy_file("./users_contents/" + "Main.swf", RuntimeSystem.content_save_dir(@content) + "Main.swf")
      File.open(RuntimeSystem.content_save_dir(@content)+"index.xml", "wb"){|xml|
        html = ""

        html << "<?xml version=\"1.0\" encoding=\"UTF-8\"?> \n"
        html << "<設定> \n"
        html << "<rss_url>http://"+ERB::Util.h(local_url)+"/string/show?url="+urlpath1+"</rss_url> \n"
        html << "<text_width>"+width.to_s+"</text_width> \n"
        html << "<text_height>"+height.to_s+"</text_height> \n"        
        html << "<text_type>"+txt_type+"</text_type> \n"
        html << "<text_content>""</text_content> \n"
        html << "<font_color>" +font_color+ "</font_color> \n"
        html << "<font_size>" +font_size+ "</font_size> \n"
        html << "<scroll_speed>"+scroll_speed+"</scroll_speed> \n"
        html << "<scroll_direction>" +scroll_direction+ "</scroll_direction> \n" 
        html << "</設定>"

        xml.write(html)
      }
      
      # title
      rss=""
#      rss << "<html> \n"
#      rss << "<body style='margin:0px;'> \n"
      
      rss << "<div style='background-color:"+@content_properties["billboard_title_color"]+"' width='"+@content['width'].to_s+"px'> \n"
      rss << "<font style='"
      #rss << "  font-family:" + strFontname + ";"
      rss << "  font-size:" + title_font_size + "px;"
      rss << "  color:"+@content_properties["billboard_title_font_color"].to_s+";"
      rss << "  '>"
      rss << ERB::Util.h(strTitle)
      rss << "</font> \n"
      rss << "</div> \n"
      
      rss << "<embed width='"+width.to_s+"' height='"+height.to_s+"' src='Main.swf' type='application/x-shockwave-flash'"
      rss << "allowscriptaccess='always' allowfullscreen='true'> \n"
      rss << "</embed> \n"
      
#      rss << "</body> \n" 
#      rss << "</html>"
      aplog.debug("END   #{CLASS_NAME}#get_billboard_html")
      return rss
    end
    
    def delEnter(strSource)
      return strSource.to_s.delete("\n")
    end
    
    def getHtmlHead
      aplog.debug("START   #{CLASS_NAME}#getHtmlHead")
      head = ""
      user_property = UserProperty.find(:first,:conditions=>["user_id=?",@current_user.id])
      google_key=""
      if user_property.blank? || user_property.google_key.blank?
        google_key = ConstUserSettings::DEFAULT_GOOGLE_API_KEY
      else
        google_key = @current_user.user_property.google_key
      end

      head << "<?xml version='1.0'> \n"
      head << "<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='ja' lang='ja'> \n"
      head << "<head> \n"
      head << "<meta http-equiv='Content-type' content='text/html; charset=utf-8' /> \n"
      head << "<meta http-equiv='cache-control' content='non-cache' /> \n"
      #head << "<meta http-equiv='refresh' content='300' /> \n"
      head << "<script type='text/javascript' src='http://www.google.com/jsapi?key=" + ERB::Util.h(google_key) + "'></script> \n"
      head << "<script type='text/javascript' src='../../../../../../javascripts/jquery-1.2.6.pack.js'></script>"
      head << "<script type='text/javascript'> \n"
      head << "google.load('feeds', '1');  \n"
      head << "</script> \n"
      head << "</head> \n"
      head << "<body style='margin:0px;'>\n"
      head << "<div style='background:"+@content_properties["back_color"].to_s+"; width:"+@content['width'].to_s+"px;' height:"+@content['height'].to_s+"px;>\n"
      aplog.debug("END   #{CLASS_NAME}#getHtmlHead")
      return head
    end
    
    def getHtmlFoot
      aplog.debug("START   #{CLASS_NAME}#getHtmlFoot")
      foot = ""
      foot << "</div>\n"
      foot << "</body> \n"
      foot << "</html> \n"
      aplog.debug("END   #{CLASS_NAME}#getHtmlFoot")
      return foot
    end
    
    def getRSS(strDivID,strWidth,strHeight,strTfontcolor,strFontsize,strFontcolor,strTitle,strDirection,strSpeed,strURL)
      aplog.debug("START   #{CLASS_NAME}#getRSS")
      rss = ""
      speed = ""
      # scroll speed
      if strSpeed == "70"
        speed = " scrolldelay = '70' scrollamount='4' "
      elsif strSpeed == "50"
        speed = " scrolldelay = '90' scrollamount='3'"
      elsif strSpeed == "30"
        speed = " scrolldelay = '120' scrollamount='1'"
      end

      # title
      rss << "<div style='background-color:"+@content_properties["title_color"]+"' width='"+@content['width'].to_s+"px'> \n"
      rss << "<font style='"
      #rss << "  font-family:" + strFontname + ";"
      rss << "  font-size:" +@content_properties["title_font_size"].to_s+ "px;"
      rss << "  color:"+@content_properties["title_font_color"].to_s+";"
      rss << "  '>"
      rss << ERB::Util.h(strTitle)
      rss << "</font> \n"
      rss << "</div> \n"
      # rss内容 
      rss << "<Marquee height='"+@content['height'].to_s+"px' width='"+@content['width'].to_s+"px' direction ='"+ strDirection.to_s+"'"
      rss << speed
      rss << "> \n"
      rss << "    <div id='"+strDivID.to_s+"' style='WORD-WRAP:break-word;'>  \n"
      rss << "    </div> \n"
      rss << "</Marquee> \n"
      
      rss << getJavaScript(strDivID,strTfontcolor,strFontsize,strFontcolor,strDirection,strURL) 
      rss << "\n"
      aplog.debug("END   #{CLASS_NAME}#getRSS")
      return rss
    end
    
    def getJavaScript(divID,strTfontcolor,strFontsize,strFontcolor,strDirection,strURL)
      aplog.debug("START   #{CLASS_NAME}#getJavaScript")
      strJavascript = ""
      
      strJavascript +="<script type='text/javascript'> \n"
      strJavascript +="update(); \n"
      strJavascript +="setInterval('update()', 60000); \n"
      strJavascript +="function update(){\n"
      strJavascript +="google.load('feeds', '1'); \n"
      strJavascript +="var feed = new google.feeds.Feed('"+ ERB::Util.h(strURL).to_s+"'); \n"
      strJavascript +="feed.setNumEntries(5); \n"
      strJavascript +="feed.load(function(result){ \n"
      strJavascript +="var temp = ''; \n"
      strJavascript +="if (!result.error) \n"
      strJavascript +="{ \n"
      strJavascript +="for (var i = 0; i < result.feed.entries.length; i++) \n"
      strJavascript +="{ \n"
      strJavascript +="var entry = result.feed.entries[i]; \n"
      strJavascript +="temp += '<font '; \n"
      #strJavascript +="temp += 'face=\""+strFontname+"\"';  \n"
      strJavascript +="temp += ' color=\""+strFontcolor.to_s+"\"'; \n"
      strJavascript +="temp += 'style=\"font-size:"+strFontsize.to_s+"px;\">&nbsp;'; \n"
      strJavascript +="temp +=entry.title; \n"
      
      if strDirection == "up"
        strJavascript +="temp += '<br>'; \n"
      end
      strJavascript +="temp +=entry.content; \n"
      strJavascript +="temp += '</font>'; \n"
      if strDirection == "up"
        strJavascript +="temp += '<br><br>'; \n"
      end
      strJavascript +="} \n"
      strJavascript +="$(\"#"+divID.to_s+"\").html(temp); \n"
      strJavascript +="} \n"
      strJavascript +="}); \n"
      strJavascript +="}\n"
  
      strJavascript +="</script> \n"
      aplog.debug("END   #{CLASS_NAME}#getJavaScript")
      return strJavascript 
    end
    
    
  end

end      