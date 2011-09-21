class ContentsController < ApplicationController
  CLASS_NAME = self.name
  before_filter :login_required, :except => :preview
  before_filter :find_pages, :except => :ajax_update
  layout "application", :except=> [:preview,:image_text_new,:image_text_edit]
  include PlayerSystem
  skip_before_filter :verify_authenticity_token ,:only=>[:ajax_update]
  
  def edit
    aplog.debug("START #{CLASS_NAME}#edit")
    @channel = @page.channel
    @content = @page.contents.find(params[:id], :include => :contents_propertiess)
    @contents_properties = @content.contents_propertiess.find(:all)
    @player = Player.find(:first,:conditions=>["id =?",@content.player_id ])
    @user_property = current_user.user_property
    aplog.debug("END   #{CLASS_NAME}#edit")
  end
  
  def new
    aplog.debug("START #{CLASS_NAME}#new")
    @user_property = current_user.user_property
    @channel = @page.channel
    @player = Player.find(:first,:conditions=>["player_no =?",params[:player_no]])
    aplog.debug("END   #{CLASS_NAME}#new")
  end
  
  def update
    p params
    aplog.debug("START #{CLASS_NAME}#update")
    contents_id = ""
    prmContents = params["contents"]
    begin
      #-----------------------------------
      # input validate check
      #-----------------------------------
      channel = @page.channel
      if @page.contents.size >= 20
        raise AplInfomationException.new("ERR_0x01025027")
      end
      
      if is_empty(prmContents["width"])
        raise AplInfomationException.new("ERR_0x01025001")
      elsif !is_half_num(prmContents["width"])
        raise AplInfomationException.new("ERR_0x01025002")
      elsif check_content_width(prmContents["width"],6,channel.width,prmContents["x_pos"]) == 1
        raise AplInfomationException.new("ERR_0x01025009")
      elsif check_content_width(prmContents["width"],6,channel.width,prmContents["x_pos"]) == 2
        raise AplInfomationException.new("ERR_0x01025015")
      elsif check_content_width(prmContents["width"],6,channel.width,prmContents["x_pos"]) == 3
        raise AplInfomationException.new("ERR_0x01025013")
      elsif check_content_width(prmContents["width"],6,channel.width,prmContents["x_pos"]) == 4
        raise AplInfomationException.new("ERR_0x01025016")
      end
      
      if is_empty(prmContents["height"])
        raise AplInfomationException.new("ERR_0x01025003")
      elsif !is_half_num(prmContents["height"])
        raise AplInfomationException.new("ERR_0x01025004")
      elsif check_content_width(prmContents["height"],6,channel.height,prmContents["y_pos"]) == 1
        raise AplInfomationException.new("ERR_0x01025010")
      elsif check_content_width(prmContents["height"],6,channel.height,prmContents["y_pos"]) == 2
        raise AplInfomationException.new("ERR_0x01025017")
      elsif check_content_width(prmContents["height"],6,channel.height,prmContents["y_pos"]) == 3
        raise AplInfomationException.new("ERR_0x01025014")
      elsif check_content_width(prmContents["height"],6,channel.height,prmContents["y_pos"]) == 4
        raise AplInfomationException.new("ERR_0x01025018")
      end
      
      if is_empty(prmContents["y_pos"])
        raise AplInfomationException.new("ERR_0x01025005")
      elsif !is_half_num(prmContents["y_pos"])
        raise AplInfomationException.new("ERR_0x01025006")
      elsif check_content_ypos(prmContents["y_pos"],6,channel.height,prmContents["height"]) == 1
        raise AplInfomationException.new("ERR_0x01025011")
      elsif check_content_ypos(prmContents["y_pos"],6,channel.height,prmContents["height"]) == 2
        raise AplInfomationException.new("ERR_0x01025019")
      elsif check_content_ypos(prmContents["y_pos"],6,channel.height,prmContents["height"]) == 3
        raise AplInfomationException.new("ERR_0x01025020")
      elsif check_content_ypos(prmContents["y_pos"],6,channel.height,prmContents["height"]) == 4
        raise AplInfomationException.new("ERR_0x01025018")
      end

      if is_empty(prmContents["x_pos"])
        raise AplInfomationException.new("ERR_0x01025007")
      elsif !is_half_num(prmContents["x_pos"])
        raise AplInfomationException.new("ERR_0x01025008")
      elsif check_content_xpos(prmContents["x_pos"],6,channel.width,prmContents["width"]) == 1
        raise AplInfomationException.new("ERR_0x01025012")
      elsif check_content_xpos(prmContents["x_pos"],6,channel.width,prmContents["width"]) == 2
        raise AplInfomationException.new("ERR_0x01025021")
      elsif check_content_xpos(prmContents["x_pos"],6,channel.width,prmContents["width"]) == 3
        raise AplInfomationException.new("ERR_0x01025022")
      elsif check_content_xpos(prmContents["x_pos"],6,channel.width,prmContents["width"]) == 4
        raise AplInfomationException.new("ERR_0x01025016")
      end

      if is_empty(prmContents["line_width"])
        raise AplInfomationException.new("ERR_0x01025023")
      elsif !is_half_num(prmContents["line_width"])
        raise AplInfomationException.new("ERR_0x01025024")
      end
      
      if is_empty(prmContents["line_color"])
        raise AplInfomationException.new("ERR_0x01025025")
      elsif !is_color_code(prmContents["line_color"])
        raise AplInfomationException.new("ERR_0x01025026")
      end
      
      
      # validate check
      player = Player.find(params[:player_id])
      config = params["contents_setting"]
      player_module = player(player)
      player_module.validate(current_user,params)
      
      #-----------------------------------
      # main process
      #-----------------------------------
      if params[:id] == "new"
        content = Content.new(:player_id=>params[:player_id])
        content = set_content(content,params)
        @page.contents << content
        contents_id = content.id
        conattributes = @page.contents.find(:all,:conditions=>["id=?",contents_id])
        conattributes.each{|conseq|
          conseq.contents_seq = @page.contents.length
          conseq.save
         }
      else
        content = @page.contents.find(params[:id])
        content = set_content(content,params)
        content.save!
        contents_id = params[:id]
      end
      
      if config != nil
        confs = @page.contents.find(contents_id).contents_propertiess.find(:all)
        config.each{|key,value|
          f = confs.find{|conf| conf.property_key == key}
          if f
            f.property_value = value
            f.save!
          else
            conf = ContentsProperties.new
            conf.property_key = key
            conf.property_value = value
            @page.contents.find(contents_id).contents_propertiess << conf
            current_user.save!
          end
        }
      end
      
      upload_object = params["contents_upload"]
      if upload_object != nil
        confs = @page.contents.find(contents_id).contents_propertiess.find(:all)
        upload_object.each{|key,fileobj|
          f = confs.find{|conf| conf.property_key == key}
          if f
            if !fileobj.blank?
              f.property_value = fileobj.original_filename
              f.save!
            end
          else
            if !fileobj.blank?
              conf = ContentsProperties.new
              conf.property_key = key
              conf.property_value = fileobj.original_filename
              @page.contents.find(contents_id).contents_propertiess << conf
              current_user.save!
            end
          end
        }
      end

      uploaded_object = params["contents_uploaded"]
      index = 0
  
      if uploaded_object != nil
        confs = @page.contents.find(contents_id).contents_propertiess.find(:all)
  
        check_object = uploaded_object["check_list"]
        check_object.each{|chk|
        chk_key = chk.split('/')[0]
        f = confs.find{|conf| conf.property_key == (chk_key)}
          if f
              f.destroy
          end
          content = @page.contents.find(:first,:conditions=>["id=?",params[:id]])
          chk_file = chk.split('/')[1]
          File.delete(RuntimeSystem.content_save_dir(content) + chk_file)
          }
          
        confs = @page.contents.find(contents_id).contents_propertiess.find(:all)
       
        arrayconf = []
        confs.each{|conf|
          if conf.property_key =~ /picture_path/
            arrayconf[conf.property_key.slice(12..13).to_i-1] = conf.property_key
          end
         }

        arrayconf.delete(nil)

        i = 1
        arrayconf.each{|conf|
          makekey = @page.contents.find(contents_id).contents_propertiess.find(:first,:conditions=>["property_key=?",conf])
          makekey.property_key = "picture_path"+i.to_s
          makekey.save
          i += 1
        }
      end

      upload_object = params["contents_multi_upload"]
      if upload_object != nil
        max_key = ""
        confs = @page.contents.find(contents_id).contents_propertiess.find(:all)
        confs.each{|conf|
          if conf.property_key =~ /picture_path/
            if conf.property_key > max_key
              max_key = conf.property_key
            end
          end
        }
        index = max_key.slice(12, max_key.length).to_i
  
        upload_object.each{|key,fileobjs|
        if fileobjs[0].size == 0
          break
        end
        fileobjs.each{|fileobj|
        index += 1
        f = confs.find{|conf| conf.property_key == (key + index.to_s)}
        if f
          #f.property_value = fileobj.original_filename
          #f.save!
        else
          time = Time.now.to_i
          imagenname = time.to_s+"-"+fileobj.original_filename
          conf = ContentsProperties.new
          conf.property_key = key + index.to_s
          conf.property_value = imagenname
          @page.contents.find(contents_id).contents_propertiess << conf
          current_user.save!
#          content = @page.contents.find(:first,:conditions=>["page_id=?",params[:page_id]])
          filepath = RuntimeSystem.get_upload_file(content, fileobj,imagenname)
        end
        }
        }
      end

      player = content.player
      player_module.set_content(current_user,content,params)
      runtime_config = player_module.config_create
      runtime_config_cls = content.player.runtime_config_table
      if !runtime_config_cls.nil? && !runtime_config_cls.blank?
        if runtime_config_model = eval("content." + runtime_config_cls)
          runtime_config_model.update_attributes(runtime_config)
        else
          runtime_config["content_id"] = content.id
          runtime_config_model = eval(runtime_config_cls.classify + ".new(runtime_config)")
          runtime_config_model.save!
        end
      end
      ContentsController.make_player(content,player_module,current_user,params)

      # プレビュー画面を作ります
      @channel = Channel.find(params[:channel_id])
      PagesController.make_page(@channel,@page)

    rescue AplInfomationException => e
      alert(e.message)
      player = Player.find_by_id(params[:player_id])
#update 11/08/24 [jing an qu] begin
      if !params["exception_player"].blank?
        if params[:id] == "new"
          next_action = eval(params["exception_player"]["name"]+"_new_channel_page_content_path(params[:channel_id], params[:page_id],'new',{:player_no => player.player_no})")
        else
          next_action = edit_channel_page_content_path(params[:channel_id],params[:page_id],params[:id])
        end
      else
        if params[:id] == "new"
          next_action = new_channel_page_content_path(params[:channel_id], params[:page_id], {:player_no => player.player_no})
        else
          next_action = edit_channel_page_content_path(params[:channel_id],params[:page_id],params[:id])
        end
      end
#update 11/08/24 [jing an qu] end
    else
      notice("MSG_0x00000017")
      if !params["submit"].blank?
        if params["submit"]["flag"] == "normal"
          next_action = edit_channel_page_content_path(params[:channel_id],params[:page_id],content.id)
        elsif params["submit"]["flag"] == "return"
          next_action = edit_channel_page_path(params[:channel_id],params[:page_id])
        end
      else
        next_action = edit_channel_page_content_path(params[:channel_id],params[:page_id],content.id)
      end
    end

    redirect_to(next_action)
    aplog.debug("END   #{CLASS_NAME}#update")
  end
  
  def self.make_player(content,player_module,current_user,params)
    aplog.debug("START #{CLASS_NAME}#make_player")
    
    player = Player.find(content.player_id)
    player = content.player

    if params["dragflag"] != "flag"
      adjustment_width = params["contents"]["width"].to_i - (params["contents"]["line_width"].to_i*2)
      adjustment_height = params["contents"]["height"].to_i - (params["contents"]["line_width"].to_i*2)
      content.width = adjustment_width
      content.height = adjustment_height
    end
    
      player_module.set_content(current_user,content,params)
      #player_module.set_content(current_user,content,params)      
    if params["dragflag"] != "flag"
      content.width = params["contents"]["width"]
      content.height = params["contents"]["height"]
    end
    FileUtils.mkdir_p(RuntimeSystem.content_save_dir(content))
    File.open(RuntimeSystem.content_save_dir(content)+"index.html", "wb"){|f|
      f.write(player_module.get_html())
    }
    
    aplog.debug("END   #{CLASS_NAME}#make_player")
  end
  
  def preview
    aplog.debug("START #{CLASS_NAME}#preview")
    
    @content = @page.contents.find(params[:id])
    @content_properties = @content.contents_propertiess.find(:all)
    @player = @content.player
    runtime_system([@content])
    if params[:from] == "contents"
      runtime_system([@content])
    end
    player_url = root_path + RuntimeSystem.content_save_dir(@content) + "index.html"
    redirect_to(player_url)
    aplog.debug("END   #{CLASS_NAME}#preview")
  end
  
  def destroy
    aplog.debug("START #{CLASS_NAME}#destroy")
    Contents.delete(params[:id]) if  @page.contents.find(params[:id])
    redirect_to channel_pages_path(channel)
    aplog.debug("END   #{CLASS_NAME}#destroy")
  end
  
  def drag
    aplog.debug("START #{CLASS_NAME}#drag")
    contents = @page.contents.find(:all,:conditions=>["page_id=?",params[:id]])
    contents.each{|content|
      contentid = content.id
      dragupdates = @page.contents.find(:all,:conditions=>["id=?",content.id])
      f = 0
      dragupdates.each{|dragupdate|
        if dragupdate.width.to_s != params["width"+contentid.to_s] || dragupdate.height.to_s != params["height"+contentid.to_s]
          dragupdate.width = params["width"+contentid.to_s]
          dragupdate.height = params["height"+contentid.to_s]
          
          player_id = dragupdate.player_id
          player = Player.find(player_id)
          player_module = player(player)
          content_id = dragupdate.id
#--make params
          contentsetting = Hash.new
          contentsetting["dragflag"] = "flag"
          contentsetting["channel_id"] = params[:channel_id]
          contentsetting["page_id"] = params[:page_id]
          ContentsController.make_player(dragupdate,player_module,@current_user,contentsetting)
          f = 1
        end
        if dragupdate.x_pos.to_s != params["x_pos"+contentid.to_s] || dragupdate.y_pos.to_s != params["y_pos"+contentid.to_s]
          dragupdate.x_pos = params["x_pos"+contentid.to_s]
          dragupdate.y_pos = params["y_pos"+contentid.to_s]
          f = 1
        end
        if f == 1
          dragupdate.save!
        end
       }
    }
    # プレビュー画面を作ります
    @channel = Channel.find(params[:channel_id])
    PagesController.make_page(@channel,@page)
    save_params = params[:save_type_params].split("*")
    if params[:save_type] == "page_select"
      if save_params[0] == "edit"
        html = "<script>parent.location.href='/channels/"+params[:channel_id]+"/pages/"+save_params[1].to_s+"/edit';</script>"
        render :text => html
      elsif save_params[0] == "new"
        html = "<script>parent.location.href='/channels/"+params[:channel_id]+"/pages/new?page_no="+save_params[1].to_s+"';</script>"
        render :text => html
      end
    elsif params[:save_type] == "new_player" 
      html = "<script>parent.location.href='/channels/"+params[:channel_id]+"/pages/"+params[:page_id]+"/contents/new?player_no="+params[:save_type_params]+"';</script>"
      render :text => html
    elsif params[:save_type] == "edit_player"||params[:save_type] == "list_edit_player"
      html = "<script>parent.location.href='/channels/"+save_params[0].to_s+"/pages/"+save_params[1].to_s+"/contents/"+save_params[2].to_s+"/edit';</script>"
      render :text => html
    elsif params[:save_type] == "delete_player"
      #html = "<script>parent.location.href='/channels/"+save_params[0].to_s+"/pages/"+save_params[1].to_s+"/contents/"+save_params[2].to_s+"/contentdelete';</script>"
      #render :text => html
      redirect_to layout_channel_page_path(params[:channel_id],params[:page_id])
    elsif params[:save_type] == "normal"
      redirect_to layout_channel_page_path(params[:channel_id],params[:page_id])
    end
    aplog.debug("END   #{CLASS_NAME}#drag")
  end
  
  def ajax_update
    aplog.debug("START #{CLASS_NAME}#ajax_update")
    player = Player.find(params[:player_id])
    player_module = player(player)
    
    if params.has_key?(:ajax_param)
      html = player_module.get_ajax(params[:ajax_param])
    else
      html = player_module.get_ajax()
    end
    render :text => html
    aplog.debug("END   #{CLASS_NAME}#ajax_update")
  end
  
  def contentdelete
    aplog.debug("START #{CLASS_NAME}#contentdelete")
    Content.destroy(params[:id])
    reconattributes = @page.contents.find(:all, :order=>"contents_seq")
    i = 0
    reconattributes.each{|content|
      i += 1
      content.contents_seq = i
      content.save
    }
    # プレビュー画面を作ります
    @channel = Channel.find(params[:channel_id])
    PagesController.make_page(@channel,@page)
    redirect_to edit_channel_page_path(params[:channel_id],params[:page_id] )
    aplog.debug("END   #{CLASS_NAME}#contentdelete")
  end
  
  #content player agin sortable
  def contentseq 
    aplog.debug("START #{CLASS_NAME}#contentseq")
    content_list = params[:li_name].split(/,/)
    i = 1
    content_list.each{|content_id|
      content = @page.contents.find(content_id)
      content.contents_seq = i
      content.save
      i += 1
    }
    redirect_to edit_channel_page_path(params[:channel_id],params[:page_id] )
    aplog.debug("END   #{CLASS_NAME}#contentseq")
  end
  
  def player_copy
    contents = Content.find(params[:id])
    contents_propertiess = contents.contents_propertiess.find(:all)
    
    player = Player.find(contents.player_id)
    html = ""
    html <<  "current copy : #{player.name.to_s}"
=begin
    html <<  "  <div class='copy_deteal'>"
    html <<  "      <span onclick='copy_deteal_onoff(\"block\")'>詳細</span>"
    html <<  "      <div id='deteal_player'>"
    html <<  "        <span class='link_copy' onclick='copy_deteal_onoff(\"none\")'>close</span><br/>"
    html <<  "        <span class='title_copy'>width</span>"
    html <<  "        <input class='copy_data' disabled='disabled' maxlength='3' type='text' value='345' />" 
    html <<  "        <span class='title_copy'>height</span>" 
    html <<  "        <input class='copy_data' disabled='disabled' maxlength='3' type='text' value='509' />" 
    html <<  "      </div>" 
    html <<  "  </div>"
=end
    html <<  "  <div style='text-align:right;'>" 
    html <<  "    <a href='/channels/#{params[:channel_id]}/pages/#{params[:page_id]}/contents/#{contents.player_id}/player_paste'>Paste</a>" 
    html <<  "    </div><div align='right' id='lists_save' style='display:none;'>"           
    html <<  "    <input type='hidden' name='li_name'  id='list_items' >" 
    html <<  "    <input name='commit' type='submit' value='プレーヤの順番を保存' />" 
    html <<  "  </div> "
     
    content_copy = @page.channel.copy_contents.find_by_id(params[:channel_id])
    content_copy.page_no = @page.page_no
    content_copy.player_id = contents.player_id
    content_copy.width = contents.width
    content_copy.height = contents.height
    content_copy.line_width = contents.line_width
    content_copy.line_color = contents.line_color
    content_copy.line_type = contents.line_type
    
    content_copy.save
    
    #test 複数コピーがある状態で下指定の1レコードのみ取れるか
    if copy_property = CopyContentsProperties.find(:all,:conditions=>["copy_content_id=?",content_copy.id])
      CopyContentsProperties.destroy(copy_property)
    end
    
    contents_propertiess.each{|content_property|
      conf = CopyContentsProperties.new
      conf.copy_content_id = content_copy.id
      conf.property_key = content_property.property_key
      conf.property_value = content_property.property_value
      @page.channel.copy_contents.find(content_copy.id).copy_contents_propertiess << conf
      current_user.save!
    }
    
    path = RuntimeSystem.content_save_dir(contents)
    send_path = RuntimeSystem.channel_save_dir(@page.channel)+"copy_receive/"
    zip_path = send_path + "copy.zip"
    #zip
    ArchiveUtil::ZipUtil.zip_file(zip_path,path)
    
    #unzip
    ArchiveUtil::ZipUtil.unzip_file(send_path+"copy.zip", send_path)
    
    rename_path = send_path+"copy_content"
    send_path+contents.id.to_s
    File::rename(send_path.to_s+contents.id.to_s,rename_path)
    #send_file(zip_path)
    
    
    
    render :text => html
    #redirect_to edit_channel_page_path(params[:channel_id],params[:page_id])
  end
  
  def player_paste
    # make content
    content = Content.new(:player_id=>params[:id])
    copy_params = CopyContent.find(params[:channel_id])

    content = set_copy_content(content,copy_params)
    @page.contents << content
    contents_id = content.id
    conattributes = @page.contents.find(:all,:conditions=>["id=?",contents_id])
    conattributes.each{|conseq|
      conseq.contents_seq = @page.contents.length
      conseq.save
     }
     
     # make content_property
     content_properties = ContentsProperties.new(:content_id=>contents_id)
     copy_properties_params = CopyContentsProperties.find(:all,:conditions=>["copy_content_id=?",copy_params.id])
     
     save_copy_properties_content(content_properties.content_id,copy_properties_params)
     
     content = @page.contents.find(contents_id)
     @page.contents.find(:all,:conditions=>["id=?",contents_id])
     path = RuntimeSystem.channel_save_dir(@page.channel)+"copy_receive/copy_content/"
     zip_path= RuntimeSystem.channel_save_dir(@page.channel)+"zipsave/test.zip"
     #zip
     ArchiveUtil::ZipUtil.zip_file(zip_path,path)

     #zipfileをコピーして移動する
     recieve_path = RuntimeSystem.copy_content_save_dir(content)
     send_path = recieve_path+"copy.zip"
     
     open(zip_path){|input|
       open(send_path, "w"){|output|
        output.write(input.read)
        }
      }
     
     #unzip
     ArchiveUtil::ZipUtil.unzip_file(send_path, recieve_path)
     
     #directry change name
     File::rename(recieve_path+"copy_content",recieve_path+content.id.to_s)
     
     redirect_to edit_channel_page_path(params[:channel_id],params[:page_id])
  end
  
  def image_text_new
    p params
    if params[:id] != "new"
      @player = Player.find(:first,:conditions=>["id =?",@content.player_id ])
      @content = @page.contents.find(params[:id], :include => :contents_propertiess)
      @contents_properties = @content.contents_propertiess.find(:all)
    else
      @channel = @page.channel
      @player = Player.find(:first,:conditions=>["player_no =?",params[:player_no]])
    end
     p "kkkkkkkk"
  end
  
  def image_text_edit
    if params[:id] != "new"
      @player = Player.find(:first,:conditions=>["id =?",@content.player_id ])
      @content = @page.contents.find(params[:id], :include => :contents_propertiess)
      @contents_properties = @content.contents_propertiess.find(:all)
    else
      @channel = @page.channel
      @player = Player.find(:first,:conditions=>["player_no =?",params[:player_no]])
    end
  end

  private
  def find_pages
    aplog.debug("START #{CLASS_NAME}#find_pages")
    channel = Channel.find_by_id(params[:channel_id])
    if channel.public_flag == 0
      @page = current_user.channels.find_by_id(params[:channel_id]).pages.find_by_id(params[:page_id], :include =>:contents)
    else
      @page = channel.pages.find_by_id(params[:page_id])
    end
    aplog.debug("END   #{CLASS_NAME}#find_pages")
  end
  
  def set_content(content, params)
      content[:width] = params["contents"]["width"]
      content[:height] = params["contents"]["height"]
      content[:x_pos] = params["contents"]["x_pos"]
      content[:y_pos] = params["contents"]["y_pos"]
      content[:line_width] = params["contents"]["line_width"]
      content[:line_color] = params["contents"]["line_color"]
      content[:line_type] = params["contents"]["line_type"]
      return content
  end
  
  def set_copy_content(content,params)
    content[:width] = params.width
    content[:height] = params.height
    content[:x_pos] = 5
    content[:y_pos] = 5
    content[:line_width] = params.line_width
    content[:line_color] = params.line_color
    content[:line_type] = params.line_type
    return content
  end
  
  def save_copy_properties_content(content_id,params)
    params.each{|param|
        conf = ContentsProperties.new(:content_id=>content_id)
        conf[:property_key] = param.property_key
        conf[:property_value]= param.property_value
        conf.save
     }
     return
 end
end
