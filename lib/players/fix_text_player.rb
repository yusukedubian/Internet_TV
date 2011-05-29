module Players
  
  class Fix_text_player
    require 'gettext/utils'
    include Validate
    include ContentsHelper
    
    def initialize()
    end

    def set_request(request)
      @request = request
    end

    
    def default(channel_id,page_id)
      player_params ={
      "contents_setting" => {"text_content"=>"Welcome to VASDAQ.TV",
                             "back_color"=>"#28281C",
                             "font_size"=>"60",
                             "font_color"=>"#4AE821",
                             "control_type"=>"1",
                             "scroll_direction"=>"Left",
                             "scroll_speed"=>"50"
                             },
                        
              "contents" => {"x_pos"=>"5",
                             "line_width"=>"5",
                             "y_pos"=>"5",
                             "line_color"=>"#38382e",
                             "height"=>"120",
                             "width"=>"700"},

      "channel_id"=>channel_id,
      "page_id"=>page_id
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

      if is_empty(params["contents_setting"]["font_size"])
        raise "ERR_0x01025201"
      elsif !is_half_num(params["contents_setting"]["font_size"])
        raise "ERR_0x01025202"
      end
      
      if is_empty(params["contents_setting"]["font_color"])
        raise "ERR_0x01025203"
      elsif !is_color_code(params["contents_setting"]["font_color"])
        raise "ERR_0x01025204"
      end
      
      if is_empty(params["contents_setting"]["text_content"])
        raise "ERR_0x01025205"
      end
      if check_length(params["contents_setting"]["text_content"], 2048, Compare::MORE_THAN)
        raise "ERR_0x01025211"
      end
      
      if !is_check_select(params["contents_setting"]["control_type"],scroll_type_for_select)
        raise "ERR_0x01025206"
      end
      
      if !is_check_select(params["contents_setting"]["scroll_speed"],scroll_speed_for_select)
        raise "ERR_0x01025207"
      end
      
      if !is_check_select(params["contents_setting"]["scroll_direction"],scroll_direction_for_select)
        raise "ERR_0x01025208"
      end
      
      if is_empty(params["contents_setting"]["back_color"])
        raise "ERR_0x01025209"
      elsif !is_color_code(params["contents_setting"]["back_color"])
        raise "ERR_0x01025210"
      end
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
      
      #----------------------------
      # main process
      #----------------------------
      html=""
      speed = ""
      controltype = @content.contents_propertiess.find(:first,:conditions=>["property_key=?","control_type"])
      html << "<head>\n"
      html << "<meta http-equiv='content-type' content='text/html;charset=UTF-8' />\n"
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
      return html
    end
  end
end
