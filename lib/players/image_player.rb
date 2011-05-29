module Players

  class Image_player
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
      "contents_setting" => {"time"=>"3000",
                             "effecttime"=>"3000",
                             "effect_type"=>"fade",
                             "picture_path1"=>"sample-001.jpg",
                             "picture_path2"=>"sample-002.jpg",
                             "picture_path3"=>"sample-003.jpg",
                             "picture_path4"=>"sample-004.jpg",
                             "picture_path5"=>"sample-005.jpg",
                             "picture_path6"=>"sample-006.jpg",
                             "picture_path7"=>"sample-007.jpg",
                             "picture_path8"=>"sample-008.jpg"},

              "contents" => {"x_pos"=>"5",
                             "line_width"=>"5",
                             "y_pos"=>"5",
                             "line_color"=>"#38382e",
                             "height"=>"300",
                             "width"=>"400"},

      "channel_id"=>content.page.channel_id,
      "page_id"=>content.page_id
      }
      
      sample_img_path = RuntimeSystem.default_content_save_dir() << "sample-001.jpg"
      store_path = RuntimeSystem.content_save_dir(content)
      FileUtils.mkdir_p(store_path)
      FileUtils.cp(sample_img_path,store_path)

      sample_img_path = RuntimeSystem.default_content_save_dir() << "sample-002.jpg"
      store_path = RuntimeSystem.content_save_dir(content)
      FileUtils.mkdir_p(store_path)
      FileUtils.cp(sample_img_path,store_path)

      sample_img_path = RuntimeSystem.default_content_save_dir() << "sample-003.jpg"
      store_path = RuntimeSystem.content_save_dir(content)
      FileUtils.mkdir_p(store_path)
      FileUtils.cp(sample_img_path,store_path)

      sample_img_path = RuntimeSystem.default_content_save_dir() << "sample-004.jpg"
      store_path = RuntimeSystem.content_save_dir(content)
      FileUtils.mkdir_p(store_path)
      FileUtils.cp(sample_img_path,store_path)
      
      sample_img_path = RuntimeSystem.default_content_save_dir() << "sample-005.jpg"
      store_path = RuntimeSystem.content_save_dir(content)
      FileUtils.mkdir_p(store_path)
      FileUtils.cp(sample_img_path,store_path)
      
      sample_img_path = RuntimeSystem.default_content_save_dir() << "sample-006.jpg"
      store_path = RuntimeSystem.content_save_dir(content)
      FileUtils.mkdir_p(store_path)
      FileUtils.cp(sample_img_path,store_path)
      
      sample_img_path = RuntimeSystem.default_content_save_dir() << "sample-007.jpg"
      store_path = RuntimeSystem.content_save_dir(content)
      FileUtils.mkdir_p(store_path)
      FileUtils.cp(sample_img_path,store_path)
      
      sample_img_path = RuntimeSystem.default_content_save_dir() << "sample-008.jpg"
      store_path = RuntimeSystem.content_save_dir(content)
      FileUtils.mkdir_p(store_path)
      FileUtils.cp(sample_img_path,store_path)
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
      if is_empty(params["contents_setting"]["time"])
        aplog.warn("ERR_0x01026003")
        raise AplInfomationException.new("ERR_0x01026003")
      end
      if !is_half_num(params["contents_setting"]["time"])
        aplog.warn("ERR_0x01026001")
        raise AplInfomationException.new("ERR_0x01026001")
      end
      if !check_length(params["contents_setting"]["time"],6,Compare::LESS_THAN)
        aplog.warn("ERR_0x01026001")
        raise AplInfomationException.new("ERR_0x01026001")
      end
      if is_empty(params["contents_setting"]["effecttime"])
        aplog.warn("ERR_0x01026004")
        raise AplInfomationException.new("ERR_0x01026004")
      end
      if !is_half_num(params["contents_setting"]["effecttime"])
        aplog.warn("ERR_0x01026002")
        raise AplInfomationException.new("ERR_0x01026002")
      end
      if !check_length(params["contents_setting"]["effecttime"],6,Compare::LESS_THAN)
        aplog.warn("ERR_0x01026002")
        raise AplInfomationException.new("ERR_0x01026002")
      end

      check_count = 0
      new_count = 0
      if params.key?("contents_uploaded")
        check_count = params["contents_uploaded"]["check_list"].length if !params["contents_uploaded"]["check_list"].blank?
      end
      new_count = params["new_list"].length if !params["new_list"].blank?

      if (params[:length].to_i + new_count) - check_count < 1
        aplog.warn("ERR_0x01026007")
        raise AplInfomationException.new("ERR_0x01026007")
      elsif (params[:length].to_i + new_count) - check_count > 10
        aplog.warn("ERR_0x01026006")
        raise AplInfomationException.new("ERR_0x01026006")
      end
      aplog.debug("END   #{CLASS_NAME}#validate")
    end
  
    # プレーヤ設定保存時の処理
    def config_save

    end

    #コンフィグデータが必要な場合
    def config_create

    end

    #出力用HTML
    def get_html
      aplog.debug("START #{CLASS_NAME}#get_html")
      html=""
      imagehtml = ""
=begin
      if is_empty(@params["contents_setting"]["time"])
        raise "ERR_0x01026003"
      end
      if !is_half_num(@params["contents_setting"]["time"])
        raise "ERR_0x01026001"
      end
      if !check_length(@params["contents_setting"]["time"],6,Compare::LESS_THAN)
        raise "ERR_0x01026001"
      end
      if is_empty(@params["contents_setting"]["effecttime"])
        raise "ERR_0x01026004"
      end
      if !is_half_num(@params["contents_setting"]["time"])
        raise "ERR_0x01026002"
      end
      if !check_length(@params["contents_setting"]["time"],6,2)
        raise "ERR_0x01026002"
      end
      if @params["contents_multi_upload"]["picture_path"][0].size == 0
        raise "ERR_0x01026005"
      end
=end
      
      width = @content["width"]
      height = @content["height"]
      time = @content_properties["time"]
      effecttime = @content_properties["effecttime"]
      effecttype = @content_properties["effect_type"]
      if (time =~/^\d+$/) != 0
        time = "3000"
      end

      if (effecttime =~/^\d+$/) != 0
        effecttime = "1000"
      end
      
      if @params["contents_upload"] != "flag"
=begin
        if @params["contents_uploaded"] != nil
          check_object = @params["contents_uploaded"]["check_list"]
          check_object.each{|chk|
            chk_file = chk.split('/')[1]
            File.delete(RuntimeSystem.content_save_dir(@content) + chk_file)
          }
        end
        if @params["contents_multi_upload"]["picture_path"][0].size != 0
          @params["contents_multi_upload"]["picture_path"].each{|file_obj|
            filepath = RuntimeSystem.get_upload_file(@content, file_obj, file_obj.original_filename)
          }
        end
=end
      end

      order_key =[]
      order_value =[]
      @content_properties.each{|key,value|
        if key =~ /picture_path/
          order_key[key.slice(12..13).to_i-1] = key
          order_value[key.slice(12..13).to_i-1] = value
        end
       }
       
      for i in 1..order_key.length
        j = i - 1
        imagehtml << "    <img src=\""+ ERB::Util.h(order_value[j]) + "\" width=\""+width.to_s+"\" height=\""+height.to_s+"\">"
      end

      html << "<head> \n"
      html << "<meta http-equiv=\"content-type\" content=\"text/html;charset=UTF-8\" />\n "
      html << "<meta http-equiv='cache-control' content='non-cache' />\n"
      html << "<style type=\"text/css\"> \n"
      html << ".slideshow-content{ \n"      
      html << "overflow:hidden; \n"      
      html << "position:relative; \n"      
      html << "} \n"
      html << "</style> \n"      
      html << "<script src=\"/javascripts/jquery-1.3.2.js\" type=\"text/javascript\"></script> \n"
      html << "<script src=\"/javascripts/jquery.aslideshow.js\" type=\"text/javascript\"></script> \n"
      html << "</head> \n"
      html << "<body style='margin:0px;'>\n"
      html << "<div id=\"MySlideshow\"> \n"
      html << imagehtml
      html << "</div>"
      html << "</body>"          
      html << "<script type=\"text/javascript\">"
      html << "  $(document).ready(function(){"
      html << "    $('#MySlideshow').slideshow({effect:'"+effecttype.to_s+"',time:"+ERB::Util.h(time.to_s)+",effecttime:"+ERB::Util.h(effecttime.to_s)+",title:false,panel:false,playframe:false,play:true,width:"+width.to_s+",height:"+height.to_s+"});"
      html << "  });"
      html << "</script>"
      aplog.debug("END   #{CLASS_NAME}#get_html")
      return html
    end

    def checkbox_ceck(item)
      aplog.debug("START #{CLASS_NAME}#checkbox_ceck")
       # 配列かチェック
      if !item["option"].instance_of?(Array)
        #raise "checkbox option is not array!!"
        aplog.Error("checkbox option is not array!!")
        raise AplInfomationException.new("checkbox option is not array!!")
      end
  
      option = item["option"][0]
  
      # DB設定値チェック
      value_check(item["type"], option, LIST_VALUE_MIN, LIST_VALUE_MAX)    
      
      # 選択済みチェック
      selected_check(item["type"], option)
      aplog.debug("END   #{CLASS_NAME}#checkbox_ceck")
    end

    def selected_check(key, hash)
      aplog.debug("START #{CLASS_NAME}#selected_check")
      if hash.has_key?("selected")
        bool_check(key, hash["selected"])
      end
      aplog.debug("END #{CLASS_NAME}#selected_check")
    end
  end
end
