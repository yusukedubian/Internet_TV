module Players
  
  class Camera_player
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
      player_params ={
      "contents_setting" => {"camera_path"=>"http://vasdaq.dyndns.org:8009/admin",
                             "account_code"=>"YWRtaW46dnNoaWJhdXJh"},
                        
              "contents" => {"x_pos"=>"5",
                             "line_width"=>"5",
                             "y_pos"=>"5",
                             "line_color"=>"#38382e",
                             "height"=>"240",
                             "width"=>"300"},

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
      if is_empty(params["contents_setting"]["camera_path"])
        aplog.warn("ERR_0x01025501")
        raise AplInfomationException.new("ERR_0x01025501")
      end
      
      if is_empty(params["contents_setting"]["account_code"])
        aplog.warn("ERR_0x01025502")
        raise AplInfomationException.new("ERR_0x01025502")
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
      #-----------------------------------
      # main process
      #-----------------------------------
      html = ""
      html << "<html>\n"
      html << "<head>\n"
      html << "<meta http-equiv='cache-control' content='non-cache' />\n"
      html << "</head>\n"
      html << "<body style='margin:0px;'>\n"
      html << "<div> \n"
      html << "<embed \n"
      html << "TYPE = 'application/x-java-applet' \\ \n"
      html << "CODE = 'ultracam.class' \\ \n"
      html << "ARCHIVE = 'ultracam.jar' \\ \n"
      html << "NAME = 'ucx' \\ \n"
      
        html << "WIDTH = '"+@content["width"].to_s+"' \\ \n"
        html << "HEIGHT = '"+@content["height"].to_s+"' \\ \n"
    
      html << "accountcode ='"+ERB::Util.h(@content_properties["account_code"])+"' / \\ \n"
      html << "codebase ='"+ERB::Util.h(@content_properties["camera_path"])+"' / \\ \n"
      html << "mode ='0' / \\ \n"
      html << "scriptable = false \n"
      html << "pluginspage = 'http://java.sun.com/products/plugin/index.html#download'> \n"
      html << "</embed>\n"
      html << "</div> \n"
      html << "</body>"
      html << "</html>"
      aplog.debug("END   #{CLASS_NAME}#get_html")
      return html
    end
  end
end