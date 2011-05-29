module Players
  
  class WidgetPlayer
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
      widget = ""
      widget << "<script src='http://www.gmodules.com/ig/ifr?"
      widget << "url=http://ralph.feedback.googlepages.com/googlecalendarviewer.xml"
      widget << "&amp;synd=open&amp;w=320&amp;h=200&amp;title=&amp;"
      widget << "border=%23ffffff%7C3px%2C1px+solid+%23999999&amp;output=js'></script>"
      player_params ={
      
      "contents_setting" => {"widget"=>widget,
                             "refreshtime"=>"5"},
                        
              "contents" => {"x_pos"=>"5",
                             "line_width"=>"5",
                             "y_pos"=>"5",
                             "line_color"=>"#38382e",
                             "height"=>"190",
                             "width"=>"340"},

            "channel_id" => content.page.channel_id,
            
               "page_id" => content.page_id
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
      if is_empty(params["contents_setting"]["widget"])
        aplog.warn("ERR_0x01027301")
        raise AplInfomationException.new("ERR_0x01027301")
      end
      
      if check_length(params["contents_setting"]["widget"], 2049, Compare::MORE_THAN)
        aplog.warn("ERR_0x01027304")
        raise AplInfomationException.new("ERR_0x01027304")
      end
      
      if is_empty(params["contents_setting"]["refreshtime"])
        aplog.warn("ERR_0x01027302")
        raise AplInfomationException.new("ERR_0x01027302")
      elsif !is_half_num(params["contents_setting"]["refreshtime"])
        aplog.warn("ERR_0x01027303")
        raise AplInfomationException.new("ERR_0x01027303")
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
      html << "<html>"
      html << "<head>"
      html << "<meta http-equiv='cache-control' content='non-cache' />\n"
     if @content_properties['refreshtime'] != "0"
      html << "<meta http-equiv='refresh'content='"+@content_properties['refreshtime']+";url='/index.html''>"
     end
      html << "</head>"
      html << "<body style='margin:0px;'>"
      html << @content_properties['widget']
      html << "</body>"
      html << "</html>"
      aplog.debug("END   #{CLASS_NAME}#get_html")
      return html
    end
  end
end
