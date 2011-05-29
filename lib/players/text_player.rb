module Players
  
  class Text_player
    require 'gettext/utils'
#    require 'apl_exceptions'
    cattr_accessor :aplog
    @@aplog ||= SystemSettings::APL_LOGGER
    CLASS_NAME = self.name
    include Validate
    include ContentsHelper
    #include MessagePrint
    
    def initialize()
    end
  
    def set_request(request)
      @request = request
    end
    
    def default(content)
      aplog.debug("START #{CLASS_NAME}#default")
      player_params ={
      "contents_setting" => {"viewtype"=>"billboard",
                             "billboard_text_content"=>"Welcome to VASDAQ.TV",
                             "text_content"=>"Welcome to VASDAQ.TV",
                             "back_color"=>"#123456",
                             "font_size"=>"60",
                             "font_color"=>"#4AE821",
                             "control_type"=>"1",
                             "scroll_direction"=>"Left",
                             "scroll_speed"=>"70",
                             "billboard_font_size"=>"15",
                             "billboard_font_color"=>"0xFF0000",
                             "billboard_scroll_direction"=>"Left",
                             "billboard_scroll_speed"=>"10",
                             "billboard_local_url"=>@request.env["HTTP_HOST"]
                             },
                        
              "contents" => {"x_pos"=>"5",
                             "line_width"=>"5",
                             "y_pos"=>"5",
                             "line_color"=>"#38382e",
                             "height"=>"120",
                             "width"=>"700"},

      "channel_id"=>content.page.channel_id,
      "page_id"=>content.page_id
      }
      
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
      
      if (params["contents_setting"]["viewtype"].to_s != "classic" && 
          params["contents_setting"]["viewtype"].to_s != "billboard" &&
          params["contents_setting"]["viewtype"].to_s != "clock")
        aplog.warn("ERR_0x01025201")
        raise AplInfomationException.new("ERR_0x01025201")
      end

      # classic表示のチェック
      if params["contents_setting"]["viewtype"].to_s == "classic"
        if is_empty(params["contents_setting"]["font_size"])
          aplog.warn("ERR_0x01025201")
          raise AplInfomationException.new("ERR_0x01025201")
        elsif !is_half_num(params["contents_setting"]["font_size"])
          aplog.warn("ERR_0x01025202")
          raise AplInfomationException.new("ERR_0x01025202")
        end
        if is_empty(params["contents_setting"]["font_color"])
          aplog.warn("ERR_0x01025203")
          raise AplInfomationException.new("ERR_0x01025203")
        elsif !is_color_code(params["contents_setting"]["font_color"])
          aplog.warn("ERR_0x01025204")
          raise AplInfomationException.new("ERR_0x01025204")
        end

        if is_empty(params["contents_setting"]["text_content"])
          aplog.warn("ERR_0x01025205")
          raise AplInfomationException.new("ERR_0x01025205")
        end
        if check_length(params["contents_setting"]["text_content"], 2049, Compare::MORE_THAN)
          aplog.warn("ERR_0x01025211")
          raise AplInfomationException.new("ERR_0x01025211")
        end
      end
      
      #billboard
      if params["contents_setting"]["viewtype"].to_s == "billboard"
        if is_empty(params["contents_setting"]["billboard_text_content"])
          aplog.warn("ERR_0x01025205")
          raise AplInfomationException.new("ERR_0x01025205")
        end
        if check_length(params["contents_setting"]["billboard_text_content"], 2048, Compare::MORE_THAN)
          aplog.warn("ERR_0x01025211")
          raise AplInfomationException.new("ERR_0x01025211")
        end
      end
      
      if !is_check_select(params["contents_setting"]["control_type"],scroll_type_for_select)
        aplog.warn("ERR_0x01025206")
        raise AplInfomationException.new("ERR_0x01025206")
      end
      
      if !is_check_select(params["contents_setting"]["scroll_speed"],scroll_speed_for_select)
        aplog.warn("ERR_0x01025207")
        raise AplInfomationException.new("ERR_0x01025207")
      end
      
      if !is_check_select(params["contents_setting"]["scroll_direction"],scroll_direction_for_select)
        aplog.warn("ERR_0x01025208")
        raise AplInfomationException.new("ERR_0x01025208")
      end
      
      if is_empty(params["contents_setting"]["back_color"])
        aplog.warn("ERR_0x01025209")
        raise AplInfomationException.new("ERR_0x01025209")
      elsif !is_color_code(params["contents_setting"]["back_color"])
        aplog.warn("ERR_0x01025210")
        raise AplInfomationException.new("ERR_0x01025210")
      end
      
      aplog.debug("END   #{CLASS_NAME}#validate")
    end
    
    # プレーヤ設定保存時の処理
    def config_save
      
    end
    
    #コンフィグデータが必要な場合
    def config_create
#      aaaa
    end
    
    #出力用HTML
    def get_html
      aplog.debug("START #{CLASS_NAME}#get_html")
      result_html = ""
      if @content_properties["viewtype"]=="classic"
        result_html = get_classic_html()
      elsif @content_properties["viewtype"]=="billboard"
        result_html = get_billboard_html()
      elsif @content_properties["viewtype"]=="clock"
        result_html = get_clock_html()
      end
      aplog.debug("END   #{CLASS_NAME}#get_html")
      return result_html
    end
    
    # classic表示html
    def get_classic_html
      aplog.debug("START #{CLASS_NAME}#get_classic_html")
      # create_classic_html
      html=""
      speed = ""
      controltype = @content.contents_propertiess.find(:first,:conditions=>["property_key=?","control_type"])
      html << "<head>\n"
      html << "<meta http-equiv='content-type' content='text/html;charset=UTF-8' />\n"
      html << "<meta http-equiv='cache-control' content='non-cache' /> \n"
      html << "</head>\n"
      html << "<body style='margin:0px;'>\n"
      if controltype.property_value == "4" || controltype.property_value == "2"
        html << "<table style='width:"+@content['width'].to_s+"px; height:"+@content['height'].to_s+"px; background:"+@content_properties["back_color"].to_s+";' cellpadding=0 cellspacing=0>\n"
        html << " <tr>"
        html << "   <td valign='top'>"
        html << "     <div>\n"
        if controltype.property_value == "2"
        html << "<style>blink{behavior:url(#default#time2)}</style>\n"
        html << "<pre style='margin-top:0px'><blink id=tm begin='0;tm.end+0.4' dur=0.6>"
        end
        if controltype.property_value == "4"
        html << "<pre style='margin-top:0px'>"
        end
        html << "<font style='font-size:"+ @content_properties["font_size"] + "px; color:"+ @content_properties["font_color"] + ";'>"
        html <<       @content_properties["text_content"]
        html << "</font>"
        if controltype.property_value == "2"
        html << "</blink></pre>\n"
        end
        if controltype.property_value == "4"
        html << "</pre>\n"
        end
        html << "    </div>\n"
        html << "   </td>\n"
        html << " </tr>\n"
        html << "</table>\n"
        html << "</body>\n"
      else
        # scroll speed
        if @content_properties["scroll_speed"] == "70"
          speed = " scrolldelay = '70' scrollamount='4' "
        elsif @content_properties["scroll_speed"] == "50"
          speed = " scrolldelay = '90' scrollamount='3'"
        elsif @content_properties["scroll_speed"] == "30"
          speed = " scrolldelay = '120' scrollamount='1'"
        end
        html << "<div style='width:"+@content['width'].to_s+"px; height:"+@content['height'].to_s+"px; background:"+@content_properties["back_color"].to_s+";'>\n"
        if controltype.property_value == "1" || controltype.property_value == "3"
        html << "<Marquee height='"+@content['height'].to_s+"px' Direction = '"+ @content_properties["scroll_direction"]+"' "+speed+">\n"
        end
        if @content_properties["scroll_direction"] == "up" || @content_properties["scroll_direction"] == "Left"
        html << "    <div style='width:"+@content["width"].to_s+"px;'>\n"
        html << "<pre style='margin-top:0px'>"
        end
        if controltype.property_value == "3"
          html << "<style>blink{behavior:url(#default#time2)}</style>"
          html << "<blink id=tm begin='0;tm.end+0.4' dur=0.6>"
        end
        html << "<Font style='font-size:"+ @content_properties["font_size"] + "px; color:"+ @content_properties["font_color"] + ";'>"
        html <<       ERB::Util.h(@content_properties["text_content"])
        html << "</font>"
        if controltype.property_value == "3"
          html << "</blink>"
        end
        if @content_properties["scroll_direction"] == "up" || @content_properties["scroll_direction"] == "Left"
          html << "</pre>\n"
          html << "    </div>\n"
        end
        if controltype.property_value == "1" || controltype.property_value == "3"
          html << "</Marquee>\n"
        end
      end
      html << "</div>\n"
      html << "</body>"
      aplog.debug("END   #{CLASS_NAME}#get_classic_html")
      return html
    end
    
    # 電光掲示板風表示html
    def get_billboard_html
      aplog.debug("START #{CLASS_NAME}#get_billboard_html")
      width = @content["width"]
      height = @content["height"]
      urlpath1 = ""
      txt_type = "txt"
      text_content = @content_properties["billboard_text_content"].to_s
      font_color = @content_properties["billboard_font_color"].to_s
      font_size = @content_properties["billboard_font_size"].to_s
      scroll_speed = @content_properties["billboard_scroll_speed"].to_s
      scroll_direction = @content_properties["billboard_scroll_direction"].to_s
      local_url = @content_properties["billboard_local_url"]

      #SWFファイルをコピー
      FileUtils.copy_file("./users_contents/" + "Main.swf", RuntimeSystem.content_save_dir(@content) + "Main.swf")

      File.open(RuntimeSystem.content_save_dir(@content)+"index.xml", "wb"){|xml|
        html = ""

        html << "<?xml version=\"1.0\" encoding=\"UTF-8\"?> \n"
        html << "<設定> \n"
        html << "<rss_url>http://"+ERB::Util.h(local_url)+"/string/show?url="+urlpath1+"</rss_url> \n"
        html << "<text_width>"+width.to_s+"</text_width> \n"
        html << "<text_height>"+height.to_s+"</text_height> \n"        
        html << "<text_type>"+txt_type+"</text_type> \n"
        html << "<text_content>"+ERB::Util.h(text_content)+"</text_content> \n"
        html << "<font_color>" +font_color+ "</font_color> \n"
        html << "<font_size>" +font_size+ "</font_size> \n"
        html << "<scroll_speed>"+scroll_speed+"</scroll_speed> \n"
        html << "<scroll_direction>" +scroll_direction+ "</scroll_direction> \n" 
        html << "</設定>"

        xml.write(html)
      }
      
      html = ""
 
      html << "<html> \n"
      html << "<head>\n"
      html << "<meta http-equiv='cache-control' content='non-cache' /> \n"
      html << "</head>\n"
      html << "<body style='margin:0px;'> \n"          
      html << "<object> \n"
      html << "<embed width='"+width.to_s+"' height='"+height.to_s+"' src='Main.swf' type='application/x-shockwave-flash'"
      html << "allowscriptaccess='always' allowfullscreen='true'> \n"
      html << "</embed></object> \n"
      html << "</body> \n" 
      html << "</html>"

      aplog.debug("END   #{CLASS_NAME}#get_billboard_html")
      return html
    end

    # クロック表示html
    def get_clock_html
      aplog.debug("START #{CLASS_NAME}#get_clock_html")
      html = ""
     
      html << "<script>" 
      html << "var obj = null; \n"
      html << "function clock(){ \n"
      html << "var time = changeTime(); \n"
      html << "var date = changeDate(); \n"
      html << "var temp = ''; \n"
      html << "temp += '<font '; \n"
      html << "temp += ' style=\" '; \n"
      html << "temp += ' font-size:"+@content_properties["clock_font_size"].to_s+"px;\'; \n"
      html << "temp += ' color:"+@content_properties["clock_font_color"].to_s+";\'; \n"
      html << "temp += '\"> '; \n"
      html << "temp += date + '  ' + time; \n"
      html << "temp += '</font> '; \n"
      html << "document.getElementById('clock').innerHTML = temp; \n"      
      html << "setTimeout('clock()', 1000); \n"
      html << "} \n"
      html << " \n"
      html << "function changeDate(){ \n"
      html << "    var myDate=new Date(); \n"
      html << "    var YYYY=myDate.getFullYear(); \n"
      html << "    var MM=myDate.getMonth()+1; \n"
      html << "    if(MM<10){MM='0'+MM;} \n"
      html << "    var DD=myDate.getDate(); \n"
      html << "    if(DD<10){DD='0'+DD;} \n"
      html << "    var date=YYYY+'/'+MM+'/'+DD; \n"
      html << "    return date; \n"
      html << "} \n"
      html << " \n"
      html << "function changeTime(){ \n"
      html << " \n"
      html << "    var myTime=new Date(); \n"
      html << "    var hh=myTime.getHours(); \n"
      html << "    var MI=myTime.getMinutes(); \n"
      html << "    if(MI < 10){MI = '0' + MI} \n"
      html << "    var ss=myTime.getSeconds(); \n"
      html << "    if(ss < 10){ss = '0' + ss} \n"
      html << "    var time=hh +':' + MI+ ':' + ss; \n"
      html << "    return time; \n"
      html << "} \n"
      html << " \n"
      html << "onload = function(){ \n"
      html << "  clock(); \n"
      html << "}; \n"
      html << "</script>"
      html << "<body style='margin:0px;'>\n"
      html << "<table cellpading=0 cellspacing=0 style='width:"+@content.width.to_s+"px; height:"+@content.height.to_s+"px; background:"+@content_properties["clock_back_color"].to_s+";'>\n"
      html << " <tr>\n"
      html << "   <td valign='middle'>\n"
      html << "     <div id='clock' style='width:100%; text-align:center;'> \n"
      html << "     </div>\n"
      html << "   </td>\n"
      html << " </tr>\n"
      html << "</table>\n"
      html << "</body>"
      aplog.debug("END  #{CLASS_NAME}#get_clock_html")
      return html
    end
  end
end
