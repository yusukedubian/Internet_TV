module Players
  
  class Clock_player
    require 'gettext/utils'
    include Validate
    
    def initialize()
    end

    def set_request(request)
      @request = request
    end

    def default(content)
      player_params ={
      "contents_setting" => {"back_color"=>"#28281C",
                             "font_size"=>"15",
                             "font_color"=>"#4AE821",
      },
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

      if is_empty(params["contents_setting"]["font_size"])
        raise "ERR_0x01025101"
      elsif !is_half_num(params["contents_setting"]["font_size"])
        raise "ERR_0x01025102"
      end
      
      if is_empty(params["contents_setting"]["font_color"])
        raise "ERR_0x01025103"
      elsif !is_color_code(params["contents_setting"]["font_color"])
        raise "ERR_0x01025104"
      end
      
      if is_empty(params["contents_setting"]["back_color"])
        raise "ERR_0x01025105"
      elsif !is_color_code(params["contents_setting"]["back_color"])
        raise "ERR_0x01025106"
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
      html = ""
      html << "<script>" 
      html << "var obj = null; \n"
      html << "function clock(){ \n"
      html << "var time = changeTime(); \n"
      html << "var date = changeDate(); \n"
      html << "var temp = ''; \n"
      html << "temp += '<font '; \n"
      html << "temp += ' style=\" '; \n"
      html << "temp += ' font-size:"+@content_properties["font_size"].to_s+"px;\'; \n"
      html << "temp += ' color:"+@content_properties["font_color"].to_s+";\'; \n"
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
      html << "<table cellpading=0 cellspacing=0 style='width:"+@content.width.to_s+"px; height:"+@content.height.to_s+"px; background:"+@content_properties["back_color"].to_s+";'>\n"
      html << " <tr>\n"
      html << "   <td valign='middle'>\n"
      html << "     <div id='clock' style='width:100%; text-align:center;'> \n"
      html << "     </div>\n"
      html << "   </td>\n"
      html << " </tr>\n"
      html << "</table>\n"
      html << "</body>"
      return html
    end
  end
end
