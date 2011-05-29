module Players
  
  class Flash_player
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
      "contents_setting" => {"flashtype"=>"path",
                             "flash_url"=>"http://www.youtube.com/embed/ojCKdPl35AQ",
                             "flash_path"=>"flash.swf"},
                        
              "contents" => {"x_pos"=>"5",
                             "line_width"=>"5",
                             "y_pos"=>"5",
                             "line_color"=>"#38382e",
                             "height"=>"300",
                             "width"=>"400"},
      "contents_upload"  => "flag",

      "channel_id"=>content.page.channel_id,
      "page_id"=>content.page_id
      }

      sample_flash_path = RuntimeSystem.default_content_save_dir() << "flash.swf"
      store_path = RuntimeSystem.content_save_dir(content)
      FileUtils.mkdir_p(store_path)
      FileUtils.cp(sample_flash_path,store_path)
      
      sample_flash_path = RuntimeSystem.default_content_save_dir() << "message_txt.xml"
      store_path = RuntimeSystem.content_save_dir(content)
      FileUtils.mkdir_p(store_path)
      FileUtils.cp(sample_flash_path,store_path)
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
      if !params["dragflag"]
        @params = params
      else
        flagparams = Hash.new
        flagparams = params
        flagparams["contents_upload"]="flag"
        @params = flagparams
      end
      aplog.debug("END   #{CLASS_NAME}#set_content")
    end
    
    # 画面入力項目チェック
    def validate(current_user,params)
      aplog.debug("START #{CLASS_NAME}#validate")
      #----------------------------
      # input validate check
      #----------------------------
      if is_empty(params["contents_setting"]["flashtype"])
        aplog.warn("ERR_0x01025701")
        raise AplInfomationException.new("ERR_0x01025701")
      end
      params["contents_setting"]["flashtype"]
      if params["contents_setting"]["flashtype"] =="url"
        if params["contents_setting"]["flashtype"]=="url"
          if is_empty(params["contents_setting"]["flash_url"])
            aplog.warn("ERR_0x01025702")
            raise AplInfomationException.new("ERR_0x01025702")
          end
          if !is_url(params["contents_setting"]["flash_url"])
            aplog.warn("ERR_0x01025704")
            raise AplInfomationException.new("ERR_0x01025704")
          end
        end
      else
        if params["contents_setting"]["flashtype"]=="path"
          if is_empty(params["contents_upload"]["flash_path"])
              aplog.warn("ERR_0x01025703")
              raise AplInfomationException.new("ERR_0x01025703")
          end
          filepath = params["contents_upload"]["flash_path"]
            extension = File.extname(filepath.original_filename)
          if extension == ".SWF"||extension == ".swf"
            #pass
          else
            aplog.warn("ERR_0x01025705")
            raise AplInfomationException.new("ERR_0x01025705")
          end
        end
      end
      aplog.debug("END   #{CLASS_NAME}#validate")
    end
    
    #コンフィグデータが必要な場合
    def config_create
#      aaaa
    end
    
    # プレーヤ設定保存時の処理
    def config_save
        
    end
    
    #出力用HTML
    def get_html
      aplog.debug("START #{CLASS_NAME}#get_html")
      #-----------------------------------
      # main process
      #-----------------------------------
      html = ""
      if @content_properties["flashtype"] == "url"
        html = ""
        html << "<html>\n"
        html << "<head>\n"
        html << "<meta http-equiv='cache-control' content='non-cache' />\n"
        html << "</head>\n"
        html << "<body style='margin:0px;'>\n"
        html << "<div> \n"
        html << "<iframe width='"+@content["width"].to_s+"px' height='"+@content["height"].to_s+"px' src='" +@content_properties["flash_url"].to_s+ "></iframe>\n"
=begin
        html << "<object> \n"
        html << "<param name='movie' value='" +ERB::Util.h(@content_properties["flash_url"]).to_s+ "'></param> \n"
        html << "<param name='allowFullScreen' value='true'></param> \n"
        html << "<param name='allowscriptaccess' value='always'></param> \n"
        html << "<embed width='"+@content["width"].to_s+"px' height='"+@content["height"].to_s+"px' src='" +@content_properties["flash_url"].to_s+ "' type='application/x-shockwave-flash'"
        html << "allowscriptaccess='always' allowfullscreen='true'> \n"
        html << "</embed></object>"
=end
        html << "</div>"
        html << "</body>"
        html << "</html>"
      else
        if @params["contents_upload"] == "flag"
          #pass
        else
          fileobj = @params["contents_upload"]["flash_path"]
          if !fileobj.blank?
            filepath = RuntimeSystem.get_upload_file(@content, @params["contents_upload"]["flash_path"], "flash.swf")
          end
        end
        #RuntimeSystem.content_save_dir(@content)
        html = ""
        html << "<html>\n"
        html << "<head>\n"
        html << "<meta http-equiv='cache-control' content='non-cache' />\n"
        html << "</head>\n"
        html << "<body style='margin:0px;'>\n"
        html << "<div>"
        html << "    <embed src='flash.swf' width='"+@content.width.to_s+"px' height='"+@content.height.to_s+"px'></embed>"
        html << "</div>"
        html << "</body>"
        html << "</html>"
      end
      aplog.debug("END   #{CLASS_NAME}#get_html")
      return html
    end
  end
end