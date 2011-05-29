module Players

  class String_player
    require 'gettext/utils'
    include Validate

    def initialize()
    end

    def set_request(request)
      @request = request
    end
    
    def default(channel_id,page_id)
      player_params ={
      "contents_setting" => {"radio"=>"txt",
                             "urlpath1"=>"http://weather.livedoor.com/forecast/rss/index.xml",
                             "text_content"=>"VASDAQ.TVへようこそ",
                             "font_size"=>"15",
                             "font_color"=>"#4AE821",
                             "scroll_direction"=>"Left",
                             "scroll_speed"=>"5",
                             "local_url"=>"" # request.env["HTTP_HOST"]必要！
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
      #----------------------------
      # input validate check
      #----------------------------
      if (is_empty(params["contents_setting"]["urlpath1"]) && 
        params["contents_setting"]["radio"].to_s != "txt")
        raise "ERR_0x01025401"
      elsif (!is_url(params["contents_setting"]["urlpath1"]) && 
        params["contents_setting"]["radio"].to_s != "txt")
        raise "ERR_0x01025402"
      end

      if (is_empty(params["contents_setting"]["text_content"]) && 
        params["contents_setting"]["radio"].to_s == "txt")
        raise "ERR_0x01025205"
      end
      
    end
    

    #コンフィグデータが必要な場合
    def config_create

    end

    # プレーヤ設定保存時の処理
    def config_save
      
    end
    
    #出力用HTML
    def get_html

      width = @content["width"]
      height = @content["height"]
      urlpath1 = @content_properties["urlpath1"].to_s
      txt_type = @content_properties["radio"].to_s
      text_content = @content_properties["text_content"].to_s
      font_color = @content_properties["font_color"].to_s
      font_size = @content_properties["font_size"].to_s
      scroll_speed = @content_properties["scroll_speed"].to_s
      scroll_direction = @content_properties["scroll_direction"].to_s
      local_url = @content_properties["local_url"]
      scroll_speed = @content_properties["scroll_speed"]

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
      html << "<body style='margin:0px;'> \n"          
      html << "<object> \n"
      html << "<embed width='"+width.to_s+"' height='"+height.to_s+"' src='Main.swf' type='application/x-shockwave-flash'"
      html << "allowscriptaccess='always' allowfullscreen='true'> \n"
      html << "</embed></object> \n"
      html << "</body> \n" 
      html << "</html>"

      return html
    end
  end
end