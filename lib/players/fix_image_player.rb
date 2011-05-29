module Players
  
  class Fix_image_player
    require 'gettext/utils'
    include Validate
    
    def initialize()
    end

    def set_request(request)
      @request = request
    end
    
    def default(content)
      player_params ={
      "contents_setting" => {"fiximage_path"=>"sample-001.jpg"},
      "contents_upload"  => "flag",                        
              "contents" => {"x_pos"=>"5",
                             "line_width"=>"5",
                             "y_pos"=>"5",
                             "line_color"=>"#38382e",
                             "height"=>"300",
                             "width"=>"300"},

      "channel_id"=>content.page.channel_id,
      "page_id"=>content.page_id
      }
      
      sample_img_path = RuntimeSystem.default_content_save_dir() << "sample-001.jpg"
      store_path = RuntimeSystem.content_save_dir(content)
      FileUtils.mkdir_p(store_path)
      FileUtils.cp(sample_img_path,store_path)
           
      return player_params
    end
    
    def set_content(current_user,content,params)
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
    end
    
    # 画面入力項目チェック
    def validate(current_user,params)

      if is_empty(params["contents_upload"]["fiximage_path"])
        raise "ERR_0x01025301"
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
      html=""
      storefilename = ""
      if @params["contents_upload"] == "flag"
        extension = File.extname(@content_properties["fiximage_path"])
        storefilename = "fiximage" + extension
      else
        fileobj = @params["contents_upload"]["fiximage_path"]
  
        #----------------------------
        # main process
        #----------------------------
        extension = File.extname(fileobj.original_filename)
        storefilename = "fiximage" + extension
        filepath = RuntimeSystem.get_upload_file(@content, @params["contents_upload"]["fiximage_path"], storefilename)
        RuntimeSystem.content_save_dir(@content)
      end
      html << "<body style='margin:0px;'>\n"
      html << "<div>"
      html << "    <img src="+ERB::Util.h(storefilename)+" width='"+@content.width.to_s+"px' height='"+@content.height.to_s+"px'>"
      html << "</div>"
      html << "</body>"
      return html
    end
  end
end
