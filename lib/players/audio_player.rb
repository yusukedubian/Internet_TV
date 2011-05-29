module Players
  
  class Audio_player
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
        "contents_setting" => {"audio_set_type"=>"audio_url",
                               "audio1_audio_url_ogg"=>"http://" + @request.env["HTTP_HOST"] + "/audio_player_default/sample1.ogg",
                               "audio1_audio_url_mp3"=>"http://" + @request.env["HTTP_HOST"] + "/audio_player_default/sample1.mp3",
                               "audio1_audio_url_wav"=>"http://" + @request.env["HTTP_HOST"] + "/audio_player_default/sample1.wav",
                               "current_music"=>"1"},
        
                "contents" => {"x_pos"=>"5",
                               "line_width"=>"5",
                               "y_pos"=>"5",
                               "line_color"=>"#38382e",
                               "height"=>"30",
                               "width"=>"300"},
        "contents_upload" => "flag",
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
      @properties_id = {}
      @storage_properties = {}
      @content.contents_propertiess.each{|property|
        @content_properties[property[:property_key]] = property[:property_value]
        @storage_properties[property[:property_key]] = property[:property_value]
        @properties_id[property[:property_key]] = property[:id] 
      }
      @params = params
      aplog.debug("END   #{CLASS_NAME}#set_content")
    end
    
    # 画面入力項目チェック
    def validate(current_user,params)
      aplog.debug("START #{CLASS_NAME}#validate")
      # オーディオ設定タイプのチェック
=begin
      if is_empty(params["contents_setting"]["audio_set_type"])
        raise "ERR_0x01027401"
      end
=end

      if params["contents_upload"]!= nil
      if !params["contents_upload"]["audio_file_ogg"].blank?
        file_ogg_obj = params["contents_upload"]["audio_file_ogg"]
      end
      if !params["contents_upload"]["audio_file_mp3"].blank?
        file_mp3_obj = params["contents_upload"]["audio_file_mp3"]
      end
      if !params["contents_upload"]["audio_file_wav"].blank?
        file_wav_obj = params["contents_upload"]["audio_file_wav"]
      end
      end
      current_music = params["contents_setting"]["current_music"]
      
      # MP3ファイルアップロードされてるかチェック
      if !is_empty(file_mp3_obj)
        file_mp3_ext = File.extname(file_mp3_obj.original_filename)
        if is_empty(file_mp3_ext) || !(file_mp3_ext.downcase == ".mp3")
            aplog.warn("ERR_0x01027403")
            raise AplInfomationException.new("ERR_0x01027403")
        end
        if !params["file_list_mp3"].blank?
          5.size.times do |i|
            i += 1
            if params["file_list_mp3"][i.to_s+"mp3"] != nil
              if params["file_list_mp3"][i.to_s+"mp3"] == file_mp3_obj.original_filename.to_s
                aplog.warn("ERR_0x01027407")
                raise AplInfomationException.new("ERR_0x01027407")
              end
            end
          end
        end
      end

      # OGGファイルアップロードされてるかチェック
      if !is_empty(file_ogg_obj)
        file_ogg_ext = File.extname(file_ogg_obj.original_filename)
        if is_empty(file_ogg_ext) || !(file_ogg_ext.downcase == ".ogg")
            aplog.warn("ERR_0x01027404")
            raise AplInfomationException.new("ERR_0x01027404")
        end
        if !params["file_list_ogg"].blank?
          5.times do |i|
            i += 1
            if params["file_list_ogg"][i.to_s+"ogg"] != nil
              if params["file_list_ogg"][i.to_s+"ogg"].to_s == file_ogg_obj.original_filename.to_s
                aplog.warn("ERR_0x01027407")
                raise AplInfomationException.new("ERR_0x01027407")
              end
            end
          end
        end
      end

      # WAVファイルアップロードされてるかチェック
      if !is_empty(file_wav_obj)
        file_wav_ext = File.extname(file_wav_obj.original_filename)
        if is_empty(file_wav_ext) || !(file_wav_ext.downcase == ".wav")
            aplog.warn("ERR_0x01027405")
            raise AplInfomationException.new("ERR_0x01027405")
        end
        if !params["file_list_wav"].blank?
          5.times do |i|
            i += 1
            if params["file_list_wav"][i.to_s+"wav"] != nil
              if params["file_list_wav"].to_s == file_wav_obj.original_filename.to_s
                aplog.warn("ERR_0x01027407")
                raise AplInfomationException.new("ERR_0x01027407")
              end
            end
          end
        end
      end
      
      url_ogg = params["contents_setting"]["audio_url_ogg"]
      url_mp3 = params["contents_setting"]["audio_url_mp3"]
      url_wav = params["contents_setting"]["audio_url_wav"]
       
      # MP3のURLのチェック
      if !is_empty(params["contents_setting"]["audio_url_mp3"])
        file_mp3_ext = File.extname(url_mp3)
        if is_empty(file_mp3_ext) || !(file_mp3_ext.downcase == ".mp3")
            aplog.warn("ERR_0x01027403")
            raise AplInfomationException.new("ERR_0x01027403")
        end
      end
      
      # OGGのURLのチェック
      if !is_empty(params["contents_setting"]["audio_url_ogg"])
        file_ogg_ext = File.extname(url_ogg)
        if is_empty(file_ogg_ext) || !(file_ogg_ext.downcase == ".ogg")
            aplog.warn("ERR_0x01027404")
            raise AplInfomationException.new("ERR_0x01027404")
        end
      end
      
      # WAVのURLのチェック
      if !is_empty(params["contents_setting"]["audio_url_wav"])
        file_wav_ext = File.extname(url_wav)
        if is_empty(file_wav_ext) || !(file_wav_ext.downcase == ".wav")
            aplog.warn("ERR_0x01027405")
            raise AplInfomationException.new("ERR_0x01027405")
        end
      end
      

=begin
      # オーディオ設定タイプがアップロードか確認
      if (params["contents_setting"]["audio_set_type"].to_s == "audio_upload")
        
        # １つも設定されてないかチェック
        if is_empty(params["contents_upload"]["audio_file_ogg"]) && 
           is_empty(params["contents_upload"]["audio_file_mp3"]) && 
           is_empty(params["contents_upload"]["audio_file_wav"])
          raise "ERR_0x01027402"
        end
      end

      # オーディオ設定タイプがURLか確認
      elsif(params["contents_setting"]["audio_set_type"].to_s == "audio_url")
        # １つも設定されてないかチェック
        if is_empty(params["contents_setting"]["audio_url_ogg"]) && is_empty(params["contents_setting"]["audio_url_mp3"]) && is_empty(params["contents_setting"]["audio_url_wav"])
            raise "ERR_0x01027406"
        end
      end
=end
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
      if @params["contents_upload"]== nil
        @params["contents_upload"]=""
      end
      html = ""
      if @params["contents_upload"] == "flag"||@params["dragflag"] == "flag"
        #pass
      else
#Delete music start
        if !@params["delfile"].blank?
          #propertiese = @content.contents_propertiess
          @params["delfile"].each {|file|
            delkey = @content.contents_propertiess.find(:first,:conditions=>["property_key=?",file])
            aplog.debug("削除する音楽ファイル1件")
            ContentsProperties.destroy(delkey.id)
            File.delete(RuntimeSystem.content_save_dir(@content) + @content_properties[file])
            #delkey.property_value = ""
            #delkey.save
            @content_properties[file] =""
            @storage_properties[file] =""
            @properties_id[file] =""
          }
        end
        
        if !@params["delurl"].blank?
          @params["delurl"].each {|url|
            delkey = @content.contents_propertiess.find(:first,:conditions=>["property_key=?",url])
            aplog.debug("削除する音楽URL1件")
            ContentsProperties.destroy(delkey.id)
            @content_properties[url] =""
            @storage_properties[url] =""
            @properties_id[url] =""
          }
        end
        if !@params["delfile"].blank? || !@params["delurl"].blank?
          if @params["current_order"] != [""]
            audio_lists = @params["current_order"][0].split(",")
            
            if !@params["delfile"].blank?
              @params["delfile"].each{|file|
                delno = file.split("_")[0]
                
                @params["file_count"].length.times do |i|
                  i += 1
                  count = @params["file_count"][delno.slice(5..delno.length).to_s]
                  if count == "0"
                    audio_lists.delete(delno.slice(5..delno.length))
                  end
                end
              }
            end
            if !@params["delurl"].blank?
              @params["delurl"].each{|file|
                delno = file.split("_")[0]
                
                @params["file_count"].length.times do |i|
                  i += 1
                  count = @params["file_count"][delno.slice(5..delno.length).to_s]
                  if count == "0"
                    audio_lists.delete(delno.slice(5..delno.length))
                  end
                end
              }
            end

            new_lists = []
            lists_length = audio_lists.length
            lists_length.times do|i|
              new_lists << ""  
            end
          end
          n = 1
          c = 1
          5.times do |i|
            i += 1
            j = 0
            flag = false

            if @params["current_order"] != [""]
              audio_lists.each{|list|
                if list == i.to_s
                  new_lists[j] << c.to_s
                  c += 1
                end
                j += 1
              }
            end

            #change key File
            if !@content_properties["audio"+i.to_s+"_audio_file_mp3"].blank?
                flag = true
                file = "audio"+i.to_s+"_audio_file_mp3"
                delkey = @content.contents_propertiess.find(:first,:conditions=>["property_key=?",file])
                aplog.debug("順番変更するmp３ファイル1件")
                delkey.property_key = "audio"+n.to_s+"_audio_file_mp3"
                delkey.save
              
            end

            if !@content_properties["audio"+i.to_s+"_audio_file_ogg"].blank?
                flag = true
                file = "audio"+i.to_s+"_audio_file_ogg"
                delkey = @content.contents_propertiess.find(:first,:conditions=>["property_key=?",file])
                aplog.debug("順番変更するoggファイル1件")
                delkey.property_key = "audio"+n.to_s+"_audio_file_ogg"
                delkey.save
              
            end

            if !@content_properties["audio"+i.to_s+"_audio_file_wav"].blank?
                flag = true
                file = "audio"+i.to_s+"_audio_file_wav"
                delkey = @content.contents_propertiess.find(:first,:conditions=>["property_key=?",file])
                aplog.debug("順番変更するwavファイル1件")
                delkey.property_key = "audio"+n.to_s+"_audio_file_wav"
                delkey.save
              
            end

            #Change key URL
            if !@content_properties["audio"+i.to_s+"_audio_url_mp3"].blank?
                flag = true
                url = "audio"+i.to_s+"_audio_url_mp3"
                delkey = @content.contents_propertiess.find(:first,:conditions=>["property_key=?",url])
                aplog.debug("順番変更するmp3url1件")
                delkey.property_key = "audio"+n.to_s+"_audio_url_mp3"
                delkey.save
              
            end

            if !@content_properties["audio"+i.to_s+"_audio_url_ogg"].blank?              
                flag = true
                url = "audio"+i.to_s+"_audio_url_ogg"
                delkey = @content.contents_propertiess.find(:first,:conditions=>["property_key=?",url])
                aplog.debug("順番変更するoggurl1件")
                delkey.property_key = "audio"+n.to_s+"_audio_url_ogg"
                delkey.save
              
            end
            if !@content_properties["audio"+i.to_s+"_audio_url_wav"].blank?
                flag = true
                url = "audio"+i.to_s+"_audio_url_wav"
                delkey = @content.contents_propertiess.find(:first,:conditions=>["property_key=?",url])
                aplog.debug("順番変更するwavurl1件")
                delkey.property_key = "audio"+n.to_s+"_audio_url_wav"
                delkey.save
              
            end
            if flag == true
              n += 1
            end
          end

          5.times do |i|
            i += 1
            if @params["file_count"][i.to_s] == "0"
              subno = @content_properties["current_music"].to_i
              @content_properties.store("current_music", subno - 1)
            end
          end
        end

#Delete music end
        
        audio_file_ogg = @params["contents_upload"]["audio_file_ogg"]
        audio_file_mp3 = @params["contents_upload"]["audio_file_mp3"]
        audio_file_wav = @params["contents_upload"]["audio_file_wav"]
        audio_url_ogg = @params["contents_setting"]["audio_url_ogg"]
        audio_url_mp3 = @params["contents_setting"]["audio_url_mp3"]
        audio_url_wav = @params["contents_setting"]["audio_url_wav"]
        current_music = @content_properties["current_music"]
        
        if !audio_file_ogg.blank?
#change name unique 
          if !change_key = @content.contents_propertiess.find(:first,:conditions=>["property_key=?","audio"+current_music.to_s+"_audio_file_ogg"])
            aplog.debug("key名変更するoggファイル1件")
            change_key = @content.contents_propertiess.find(:first,:conditions=>["property_key=?","audio_file_ogg"])
            change_key.property_key = "audio"+current_music.to_s+"_audio_file_ogg"
          end
          change_key.save
          #make properties
          @content_properties.store(change_key.property_key, change_key.property_value)
          RuntimeSystem.get_upload_file(@content, audio_file_ogg, change_key.property_value)
        end

        if !audio_file_mp3.blank?
#change name unique
          if !change_key = @content.contents_propertiess.find(:first,:conditions=>["property_key=?","audio"+current_music.to_s+"_audio_file_mp3"])
            aplog.debug("key名変更するmp3ファイル1件")
            change_key = @content.contents_propertiess.find(:first,:conditions=>["property_key=?","audio_file_mp3"])
            change_key.property_key = "audio"+current_music.to_s+"_audio_file_mp3"
          end
          change_key.save
          #make properties
          @content_properties.store(change_key.property_key, change_key.property_value)
          RuntimeSystem.get_upload_file(@content, audio_file_mp3, change_key.property_value)
        end

        if !audio_file_wav.blank?
#change name unique
          if !change_key = @content.contents_propertiess.find(:first,:conditions=>["property_key=?","audio"+current_music.to_s+"_audio_file_wav"])
            aplog.debug("key名変更するwavファイル1件")
            change_key = @content.contents_propertiess.find(:first,:conditions=>["property_key=?","audio_file_wav"])
            change_key.property_key = "audio"+current_music.to_s+"_audio_file_wav"
          end
          change_key.save
          @content_properties.store(change_key.property_key, change_key.property_value)
          RuntimeSystem.get_upload_file(@content, audio_file_wav, change_key.property_value)
        end

        if !audio_url_mp3.blank?
          if !change_key = @content.contents_propertiess.find(:first,:conditions=>["property_key=?","audio"+current_music.to_s+"_audio_url_mp3"])
            aplog.debug("key名変更するmp3url1件")
            change_key = @content.contents_propertiess.find(:first,:conditions=>["property_key=?","audio_url_mp3"])
            change_key.property_key = "audio"+current_music.to_s+"_audio_url_mp3"
          end
          change_key.property_value = @content_properties["audio_url_mp3"]
          change_key.save
          #make properties
          @content_properties.store(change_key.property_key, change_key.property_value)
        end
        
        if !audio_url_ogg.blank?
          if !change_key = @content.contents_propertiess.find(:first,:conditions=>["property_key=?","audio"+current_music.to_s+"_audio_url_ogg"])
            aplog.debug("key名変更するoggurl1件")
            change_key = @content.contents_propertiess.find(:first,:conditions=>["property_key=?","audio_url_ogg"])
            change_key.property_key = "audio"+current_music.to_s+"_audio_url_ogg"
          end
          change_key.property_value = @content_properties["audio_url_ogg"]
          change_key.save
          #make properties
          @content_properties.store(change_key.property_key, change_key.property_value)
        end
        
        if !audio_url_wav.blank?
          if !change_key = @content.contents_propertiess.find(:first,:conditions=>["property_key=?","audio"+current_music.to_s+"_audio_url_wav"])
            aplog.debug("key名変更するmp3wav1件")
            change_key = @content.contents_propertiess.find(:first,:conditions=>["property_key=?","audio_url_wav"])
            change_key.property_key = "audio"+current_music.to_s+"_audio_url_wav"
          end
          change_key.property_value = @content_properties["audio_url_wav"]
          change_key.save
          #make properties
          @content_properties.store(change_key.property_key, change_key.property_value)
        end
        
      end
      
# Change oreder
      if @params["contents_upload"] == "flag"||@params["dragflag"] == "flag"
      else
        music_length = ""
        @params["music_length"].to_i.times do |i|
          i+=1
          if @params["music_length"].to_i != i 
            music_length += i.to_s+","
          else
            music_length += i.to_s
          end
        end
        normal_order = []
        normal_order << music_length
        if @params["current_order"] != [""] && @params["current_order"] != normal_order
          i = 1
          if new_lists == nil
            new_lists = ""
            new_lists = @params["current_order"][0].split(",")
          end

          new_lists.each{|list|
            if list.to_s != i.to_s

              if !@storage_properties["audio"+list.to_s+"_audio_url_mp3"].blank?
                new_value = @storage_properties["audio"+list.to_s+"_audio_url_mp3"]
                id = @properties_id["audio"+i.to_s+"_audio_url_mp3"]
                if !id.blank?
                  new_property = @content.contents_propertiess.find(id)
                  aplog.debug("曲順変更するmp3url1件")
                  new_property.property_value = new_value
                  new_property.save
                  @content_properties.store("audio"+i.to_s+"_audio_url_mp3", new_value)
                else
                  new_property = ContentsProperties.new(:property_key => "audio"+i.to_s+"_audio_url_mp3",:property_value=>new_value)
                  @content.contents_propertiess << new_property
                  new_property.save
                  @content_properties.store("audio"+i.to_s+"_audio_url_mp3", new_value)
                end
              else
                if !@storage_properties["audio"+i.to_s+"_audio_url_mp3"].blank?

                  new_value = ""
                  id = @properties_id["audio"+i.to_s+"_audio_url_mp3"]
                  if !id.blank?
                    ContentsProperties.destroy(id)
                  end
=begin
                  if !id.blank?
                    new_property = @content.contents_propertiess.find(id)
                    new_property.property_value = new_value
                    new_property.save
                    @content_properties.store("audio"+i.to_s+"_audio_url_mp3", new_value)
                  end
=end
                end
              end
            
              if !@storage_properties["audio"+list.to_s+"_audio_file_mp3"].blank?
                new_value = @storage_properties["audio"+list.to_s+"_audio_file_mp3"]
                id = @properties_id["audio"+i.to_s+"_audio_file_mp3"]
                if !id.blank?
                  new_property = @content.contents_propertiess.find(id)
                  aplog.debug("曲順変更するmp3file1件")
                  new_property.property_value = new_value
                  new_property.save
                  @content_properties.store("audio"+i.to_s+"_audio_file_mp3", new_value)
                else
                  new_property = ContentsProperties.new(:property_key => "audio"+i.to_s+"_audio_file_mp3",:property_value=>new_value)
                  @content.contents_propertiess << new_property
                  new_property.save
                  @content_properties.store("audio"+i.to_s+"_audio_file_mp3", new_value)
                end
              else
                if !@storage_properties["audio"+i.to_s+"_audio_file_mp3"].blank?
                  id = @properties_id["audio"+i.to_s+"_audio_file_mp3"]
                  if !id.blank?
                    ContentsProperties.destroy(id)
                  end
=begin
                  new_value = ""
                  id = @properties_id["audio"+i.to_s+"_audio_file_mp3"]
                  if !id.blank?
                    new_property = @content.contents_propertiess.find(id)
                    new_property.property_value = new_value
                    new_property.save
                    @content_properties.store("audio"+i.to_s+"_audio_file_mp3", new_value)
                  end
=end
                end
              end

              if !@storage_properties["audio"+list.to_s+"_audio_url_ogg"].blank?
                new_value = @storage_properties["audio"+list.to_s+"_audio_url_ogg"]
                id = @properties_id["audio"+i.to_s+"_audio_url_ogg"]
                if !id.blank?
                  new_property = @content.contents_propertiess.find(id)
                  aplog.debug("曲順変更するoggurl1件")
                  new_property.property_value = new_value
                  new_property.save
                  @content_properties.store("audio"+i.to_s+"_audio_url_ogg", new_value)
                else
                  new_property = ContentsProperties.new(:property_key => "audio"+i.to_s+"_audio_url_ogg",:property_value=>new_value)
                  @content.contents_propertiess << new_property
                  new_property.save
                  @content_properties.store("audio"+i.to_s+"_audio_url_ogg", new_value)
                end
              else
                  new_value = ""
                  id = @properties_id["audio"+i.to_s+"_audio_url_ogg"]
                  if !id.blank?
                    ContentsProperties.destroy(id)
                  end
              end
              
              if !@storage_properties["audio"+list.to_s+"_audio_file_ogg"].blank?
                new_value = @storage_properties["audio"+list.to_s+"_audio_file_ogg"]
                id = @properties_id["audio"+i.to_s+"_audio_file_ogg"]
                if !id.blank?
                  new_property = @content.contents_propertiess.find(id)
                  aplog.debug("曲順変更するoggfile1件")
                  new_property.property_value = new_value
                  new_property.save
                  @content_properties.store("audio"+i.to_s+"_audio_file_ogg", new_value)
                else
                  new_property = ContentsProperties.new(:property_key => "audio"+i.to_s+"_audio_file_ogg",:property_value=>new_value)
                  @content.contents_propertiess << new_property
                  new_property.save
                  @content_properties.store("audio"+i.to_s+"_audio_file_ogg", new_value)
                end
              else
                if !@storage_properties["audio"+i.to_s+"_audio_file_ogg"].blank?
                  id = @properties_id["audio"+i.to_s+"_audio_file_ogg"]
                  if !id.blank?
                    ContentsProperties.destroy(id)
                  end
                end
              end

              if !@storage_properties["audio"+list.to_s+"_audio_url_wav"].blank?
                new_value = @storage_properties["audio"+list.to_s+"_audio_url_wav"]
                id = @properties_id["audio"+i.to_s+"_audio_url_wav"]
                if !id.blank?
                  new_property = @content.contents_propertiess.find(id)
                  aplog.debug("曲順変更するwavurl1件")
                  new_property.property_value = new_value
                  new_property.save
                  @content_properties.store("audio"+i.to_s+"_audio_url_wav", new_value)
                else
                  new_property = ContentsProperties.new(:property_key => "audio"+i.to_s+"_audio_url_wav",:property_value=>new_value)
                  @content.contents_propertiess << new_property
                  new_property.save
                  @content_properties.store("audio"+i.to_s+"_audio_url_wav", new_value)
                end
              else
                new_value = ""
                  id = @properties_id["audio"+i.to_s+"_audio_url_wav"]
                  if !id.blank?
                    ContentsProperties.destroy(id)
                  end
              end
              
              if !@storage_properties["audio"+list.to_s+"_audio_file_wav"].blank?
              new_value = @storage_properties["audio"+list.to_s+"_audio_file_wav"]
                id = @properties_id["audio"+i.to_s+"_audio_file_wav"]
                if !id.blank?
                  new_property = @content.contents_propertiess.find(id)
                  aplog.debug("曲順変更するwavfile1件")
                  new_property.property_value = new_value
                  new_property.save
                  @content_properties.store("audio"+i.to_s+"_audio_file_wav", new_value)
                else
                  new_property = ContentsProperties.new(:property_key => "audio"+i.to_s+"_audio_file_wav",:property_value=>new_value)
                  @content.contents_propertiess << new_property
                  new_property.save
                  @content_properties.store("audio"+i.to_s+"_audio_file_wav", new_value)
                end
              else
                if !@storage_properties["audio"+i.to_s+"_audio_file_wav"].blank?
                  id = @properties_id["audio"+i.to_s+"_audio_file_wav"]
                  if !id.blank?
                    ContentsProperties.destroy(id)
                  end
                end
              end
            end
            i +=1
          }
        end
      end
      
      i = 1
      all_music = [];
      cups = [audio1 ="",audio2 ="",audio3 ="",audio4 ="",audio5 =""]
      cups.each {|cup|
        
        if !@content_properties["audio"+i.to_s+"_audio_file_mp3"].blank?
          cup << "<source src='"+ @content_properties["audio"+i.to_s+"_audio_file_mp3"] +"' type='audio/mp3'>\n"
        else
          if !@content_properties["audio"+i.to_s+"_audio_url_mp3"].blank?
            cup << "<source src='"+ @content_properties["audio"+i.to_s+"_audio_url_mp3"] +"' type='audio/mp3'>\n"
          end
        end
        
        if !@content_properties["audio"+i.to_s+"_audio_file_ogg"].blank?
          cup << "<source src='"+ @content_properties["audio"+i.to_s+"_audio_file_ogg"] +"' type='audio/ogg'>\n"
        else
          if !@content_properties["audio"+i.to_s+"_audio_url_ogg"].blank?
            cup << "<source src='"+ @content_properties["audio"+i.to_s+"_audio_url_ogg"] +"' type='audio/ogg'>\n"
          end
        end
        
        if !@content_properties["audio"+i.to_s+"_audio_file_wav"].blank?
          cup << "<source src='"+ @content_properties["audio"+i.to_s+"_audio_file_wav"] +"' type='audio/wav'>\n"
        else
          if !@content_properties["audio"+i.to_s+"_audio_url_wav"].blank?
            cup << "<source src='"+ @content_properties["audio"+i.to_s+"_audio_url_wav"] +"' type='audio/wav'>\n"
          end
        end
        
        if !cup.blank?
          all_music << i.to_s
        end
        
        i +=1
      }
      
      html << "<!DOCTYPE html>\n"
      html << "<html lang='ja'>\n"
      html << "<head>\n"
      html << "<meta http-equiv='cache-control' content='non-cache' />\n"
      html << "</head>\n"
      html << "<body style='margin:0px;'>\n"
      
      first_music = false
      if !audio1.blank?
        html << "<div id='audio1'>\n"
        #html << "<audio id='music1' controls='controls' autoplay='autoplay'>\n"
        html << "<audio id='music1' controls autoplay>\n"
        html << audio1
        html << "</audio>\n"
        html << "</div>\n"
        first_music = true
      end
      if !audio2.blank?
        if first_music == true
          html << "<div id='audio2' style='display:none;'>\n"
          html << "<audio id='music2' controls>\n"
          html << audio2
          html << "</audio>\n"
          html << "</div>\n"
        else
          html << "<div id='audio2'>\n"
          html << "<audio id='music2' controls autoplay>\n"
          html << audio2
          html << "</audio>\n"
          html << "</div>\n"
          first_music = true
        end
      end
      if !audio3.blank?
        if first_music == true
          html << "<div id='audio3' style='display:none;'>\n"
          html << "<audio id='music3' controls>\n"
          html << audio3
          html << "</audio>\n"
          html << "</div>\n"
        else
          html << "<div id='audio3'>\n"
          html << "<audio id='music3' controls autoplay>\n"
          html << audio3
          html << "</audio>\n"
          html << "</div>\n"
          first_music = true
        end
      end
      if !audio4.blank?
        if first_music == true
          html << "<div id='audio4' style='display:none;'>\n"
          html << "<audio id='music4' controls>\n"
          html << audio4
          html << "</audio>\n"
          html << "</div>\n"
        else
          html << "<div id='audio4'>\n"
          html << "<audio id='music4' controls autoplay>\n"
          html << audio4
          html << "</audio>\n"
          html << "</div>\n"
          first_music = true
        end
      end
      if !audio5.blank?
        if first_music == true
          html << "<div id='audio5' style='display:none;'>\n"
          html << "<audio id='music5' controls>\n"
          html << audio5
          html << "</audio>\n"
          html << "</div>\n"
        else
          html << "<div id='audio5'>\n"
          html << "<audio id='music5' controls autoplay>\n"
          html << audio5
          html << "</audio>\n"
          html << "</div>\n"
          first_music = true
        end
      end
      
      html << "<input type='hidden' id='current_music' value='music"+all_music[0].to_s+"'/>\n"
      html << "<script type='text/javascript'>\n"
      html << "window.setTimeout('nextmusic"+all_music[0].to_s+"()',2000)\n"

      i = 1
      all_music.each{|music|      
        html << "function nextmusic"+music.to_s+"(){\n"
        html << "  var current_music = document.getElementById('current_music').value;\n"
        html << "  var current_element = document.getElementById(current_music);\n"

        if i != all_music.size
# "next-play"
          next_no = all_music[i]
        else
# "end-music"
          next_no = all_music[0]
        end
        
#reference data => http://www.mwsoft.jp/programming/firefox3_5/audio_test.html
        html << "  if(current_music == ''){\n"
        html << "    setTimeout('nextmusic"+music.to_s+"()',2000)\n"
        html << "  }\n"
        html << "  else if(current_music != ''){\n"
        html << "    if (current_element.ended == true){\n"
        
          #html << "      current_element.ended=false;\n"
          html << "      document.getElementById('audio"+music.to_s+"').style.display = 'none';\n"
          html << "      document.getElementById('audio"+next_no.to_s+"').style.display = 'block';\n"
        if i != all_music.size
#chrome can not play from the start. So page updates.chrome's bug.
          html << "      var audioObj = document.getElementById('music"+next_no.to_s+"');\n"
          html << "      audioObj.play();\n"
        end
          html << "      var current_music = document.getElementById('current_music');\n"
          html << "      current_music.value = 'music"+next_no.to_s+"';\n"
        #html << "      current_element.currentTime = 0;\n"
        #html << "      current_element.pause();\n"
        if i != all_music.size
          html << "      setTimeout('nextmusic"+next_no.to_s+"()',2000);\n"
        else
#chrome can not play from the start. So page updates.chrome's bug.
          html << "      location.reload();\n"
        end
        #html << "      setTimeout('nextmusic"+next_no.to_s+"()',2000)\n"
        html << "    }\n"
        html << "    else{\n"
        #html << "      current_element.pause();\n"
        #html << "      current_element.currentTime = 0;\n"
        html << "      if (document.getElementById('music"+music.to_s+"').networkState ==4 ||document.getElementById('music"+music.to_s+"').networkState ==3 || document.getElementById('music"+music.to_s+"').networkState ==0){\n"
        html << "        document.getElementById('audio"+music.to_s+"').style.display = 'none';\n"
        html << "        document.getElementById('audio"+next_no.to_s+"').style.display = 'block';\n"
        if i != all_music.size
#chrome can not play from the start. So page updates.chrome's bug.
          html << "      var audioObj = document.getElementById('music"+next_no.to_s+"');\n"
          html << "      audioObj.play();\n"
        end
          html << "      var current_music = document.getElementById('current_music');\n"
          html << "      current_music.value = 'music"+next_no.to_s+"';\n"
        if i != all_music.size
          html << "         setTimeout('nextmusic"+next_no.to_s+"()',2000);\n"
        else
          html << "         location.reload();\n"
        end
        html << "      }\n"
        html << "      else{\n"
        html << "        setTimeout('nextmusic"+music.to_s+"()',2000);\n"
        html << "      }\n"
        html << "    }\n"
        html << "  }\n"
        html << "}\n"
      i +=1
      }
      
      html << "</script>\n"
      
      html << "</body>\n"
      html << "</html>\n"

=begin
      if (@content_properties["audio_set_type"].to_s == "audio_upload")
        html = create_audio_upload_html()
      else
        html = create_audio_url_html()
      end
=end
      aplog.debug("END   #{CLASS_NAME}#get_html")
      return html
    end
    
    
    def create_audio_upload_html
      
      if @params["contents_upload"] == "flag"||@params["dragflag"] == "flag"
        #pass
      else
        audio_file_ogg = @params["contents_upload"]["audio_file_ogg"]
        audio_file_mp3 = @params["contents_upload"]["audio_file_mp3"]
        audio_file_wav = @params["contents_upload"]["audio_file_wav"]
        if !audio_file_ogg.blank?
          RuntimeSystem.get_upload_file(@content, audio_file_ogg, audio_file_ogg.original_filename)
        end
        if !audio_file_mp3.blank?
          RuntimeSystem.get_upload_file(@content, audio_file_mp3, audio_file_mp3.original_filename)
        end
        if !audio_file_wav.blank?
          RuntimeSystem.get_upload_file(@content, audio_file_wav, audio_file_wav.original_filename)
        end
      end
      
      sourcehtml=""
      @content_properties.each{|key, value|
        if key =~ /audio_file/
          sourcehtml << '<source src="'+ value + '">'
        end
      }
      
      #RuntimeSystem.content_save_dir(@content)
      html = ''
      html << '<html>'
      html << '<head>'
      html << '<meta http-equiv="cache-control" content="non-cache" />'
      html << '</head>'
      html << '<body style="margin:0px;">'
      html << '<audio controls autoplay loop>'
      html << sourcehtml
      html << '</audio>'
      html << "</body>\n"
      html << "</html>\n"
      
      return html
      
    end
    
    
    def create_audio_url_html()
      
      html = ""
      html << "<html>\n"
      html << "<head>\n"
      html << '<meta http-equiv="cache-control" content="non-cache" />'
      html << "</head>\n"
      html << "<body style=\"margin:0px;\">\n"
      html << "<audio controls=\"controls\" autoplay=\"autoplay\" loop=\"loop\">\n"
      if !is_empty(@content_properties["audio_url_ogg"])
        html << "<source src=\""+ @content_properties["audio_url_ogg"] +"\" type=\"audio/ogg\">\n"
      end
      if !is_empty(@content_properties["audio_url_mp3"])
        html << "<source src=\""+ @content_properties["audio_url_mp3"] +"\" type=\"audio/mp3\">\n"
      end
      if !is_empty(@content_properties["audio_url_wav"])
        html << "<source src=\""+ @content_properties["audio_url_wav"] +"\" type=\"audio/wav\">\n"
      end
      html << "Your browser does not support the video element\n"
      html << "</audio>\n"
      html << "</body>\n"
      html << "</html>\n"
      
      return html
    end
  end
end
