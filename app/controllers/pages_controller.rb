class PagesController < ApplicationController
  CLASS_NAME = self.name
  before_filter :login_required
  before_filter :find_channels
  layout "application", :except => :layout
  include PlayerSystem

  def index
    aplog.debug("START #{CLASS_NAME}#index")
    #Through edit
    redirect_to channels_path
    #Through edit
    @pages = @channel.pages
    @players = Player.find(:all)
    aplog.debug("END   #{CLASS_NAME}#index")
  end
  
  def new
    aplog.debug("START #{CLASS_NAME}#new")
    #page_no check. page_no has to be between 1 to 10.
    begin
      raise if !(params[:page_no].to_i >= 1 && params[:page_no].to_i <= 10)
    rescue
      @pages = @channel.pages
      alert("ERR_0x01010901")
      return if redirect_to channel_pages_path(params[:channel_id]) 
    end
    
    if !page = @channel.pages.find_by_page_no(params[:page_no])
      page = Page.new(:name=>"page"+params[:page_no],:page_no => params[:page_no],:switchtime =>60,:background_display_type=>2)
      @channel.pages << page
      current_user.save!
      
      #make backimage
      extension =  File.extname("1_1024_768.png")
      storefilename = "gallary" + extension
      galleryimage = RuntimeSystem.image_gallery_save_dir(page,"1_1024_768.png")
      path = RuntimeSystem.page_save_dir(page)
      FileUtils.mkdir_p(path)
      original = File.open(galleryimage, "rb")
      copy = File.open(path+"#{storefilename}", "wb")
      copy.write(original.read)

      page.background = nil
      page.backgroundfile = storefilename
      if page.background_display_type == nil
        page.background_display_type = "0"
      end
      page.save
    end
    
    aplog.debug("END PagesController#new")
    redirect_to edit_channel_page_path(params[:channel_id],  page)
  end

  def edit
    aplog.debug("START #{CLASS_NAME}#edit")
    begin
      if !@channel.uploaded_flg
        @pages = @channel.pages
        @players = Player.find(:all, :order => "player_no asc")
      else
        @pages = @channel.pages
        if !@pages.blank?
          @page = @pages.find(params[:id])
        else
          page = Page.new(:name=>"page1",:page_no => "1",:switchtime =>60,:background_display_type=>2)
          @channel.pages << page
          current_user.save!
          
          #make backimage
          extension =  File.extname("1_1024_768.png")
          storefilename = "gallary" + extension
          galleryimage = RuntimeSystem.image_gallery_save_dir(page,"1_1024_768.png")
          path = RuntimeSystem.page_save_dir(page)
          FileUtils.mkdir_p(path)
          original = File.open(galleryimage, "rb")
          copy = File.open(path+"#{storefilename}", "wb")
          copy.write(original.read)
    
          page.background = nil
          page.backgroundfile = storefilename
          if page.background_display_type == nil
            page.background_display_type = "0"
          end
          page.save
          params[:id] = page.id.to_s
          @page = page
        end
        @players = Player.find(:all, :order => "player_no asc")
        @contents = @page.contents.find(:all,:conditions=>["page_id=?",params[:id]],:order=>"contents_seq")
      end
    rescue ActiveRecord::RecordNotFound=> e
      alert("ERR_0x01010902")
      redirect_to channels_path
      #redirect_to channel_pages_path(params[:channel_id])
    end
    aplog.debug("END   #{CLASS_NAME}#edit")
  end
  
  def update
    aplog.debug("START #{CLASS_NAME}#update")
    #channel update start
    channel = current_user.channels.find(params[:channel_id])
    @page = @channel.pages.find(params[:id])
    prmChannel = params["channel_propertie"]
    # uploadfile get
    file_obj = prmChannel["thumbnailfile"]

    begin
      if ! check_length(prmChannel["name"], 40, Compare::LESS_THAN)
        raise "ERR_0x01010304"  
      end
      if ! check_length(prmChannel["category"], 40, Compare::LESS_THAN)
        raise "ERR_0x01010305"  
      end
      if ! check_length(prmChannel["description"], 1024, Compare::LESS_THAN)
        raise "ERR_0x01010306"  
      end
      if ! check_length(prmChannel["link_info"], 256, Compare::LESS_THAN)
        raise "ERR_0x01010307"  
      end
      if ! check_length(prmChannel["other_info"], 256, Compare::LESS_THAN)
        raise "ERR_0x01010308"  
      end
      if is_empty(prmChannel["name"])
        raise "ERR_0x01020401"
      end
      if !is_color_code(prmChannel["background"])
        raise "ERR_0x01025106"
      end
      if is_empty(prmChannel["width"])
        raise "ERR_0x01020402"
      elsif !is_half_num(prmChannel["width"])
        raise "ERR_0x01020403"
      if is_empty(prmChannel["height"])
        raise "ERR_0x01020404"
      elsif !is_half_num(prmChannel["height"])
        raise "ERR_0x01020405"
      elsif !(prmChannel["width"].to_i >= 1 && prmChannel["width"].to_i <= 999999)
        raise "ERR_0x01020406"
      end
      elsif !(prmChannel["height"].to_i >= 1 && prmChannel["height"].to_i <= 999999)
        raise "ERR_0x01020407"
      end
      
      prmChannel.delete("thumbnailfile")
      channel.update_attributes(prmChannel)
      channel.create_type = 1 # 1:original
      if !file_obj.nil? && !file_obj.blank?
        extname = File.extname(file_obj.original_filename)
        RuntimeSystem.get_upload_file(channel, file_obj, "thumbnail"+extname)
        channel.thumbnail_filename = "thumbnail" + extname
      end
      if channel.save!
        #notice("MSG_0x00000009")
      end
    rescue => e
      if !flash[:alert]
        alert("ERR_0x01010303")
      end
      redirect_to(edit_channel_page_path(@channel, @page))
      return
    end
    
    #page update start
    fileobj = params["upload_object"]["backgroundfile"]
    if !fileobj.nil? && !fileobj.blank?
      extension = File.extname(fileobj.original_filename)
      storefilename = "background" + extension
      path = RuntimeSystem.page_save_dir(@page)
    
      FileUtils.mkdir_p(path)
      File.open(path+"#{storefilename}", "wb"){ |f|
        f.write(fileobj.read)
      }
    end

    @page[:backgroundfile] = storefilename
    prmContents = params["page_propertie"]
    begin
      if is_empty(prmContents["name"])
        raise "ERR_0x01020503"
      end
    if is_empty(prmContents["switchtime"])
      raise "ERR_0x01020501"
    elsif !is_half_num(prmContents["switchtime"])
      raise "ERR_0x01020502"
    elsif is_zero_num(prmContents["switchtime"])
      raise "ERR_0x01020504"
    end
    if !is_color_code(prmContents["background"]) && (params["backgroundtype"] == "color")
      raise "ERR_0x01025106"
    end
    if ! check_length(prmContents["name"], 40, Compare::LESS_THAN)
        raise "ERR_0x01020505"  
    end
    if ! check_length(prmContents["switchtime"], 4, Compare::LESS_THAN)
        raise "ERR_0x01020506"  
    end
    if @page.update_attributes(params[:page_propertie])
      notice("MSG_0x00000010")
      redirect_to(edit_channel_page_path(@channel, @page))
    end
    rescue => e
      alert(e.message)
      if flash[:error]
        alert("ERR_0x01010303")
      end
      redirect_to(edit_channel_page_path(@channel, @page))
      #render :action => "edit"
    end
    
    # 背景色と背景画像判断
    if params["backgroundtype"] == "color"
      @page.backgroundfile = nil
      @page.background_display_type = nil
      @page.save
    end
    if params["backgroundtype"] == "image"
      if params["selectupload"] == "upload"
        @page.background_display_type = params["Picture_type"]
        if params["selectupload"] == "upload"
          if params["hidden_background_file"] != nil && storefilename == nil
            @page.backgroundfile=params["hidden_background_file"]
          end
        end
      else
        @page.backgroundfile=params["hidden_background_file"]
      end
      @page.background = nil
      @page.background_display_type = params["Picture_type"]
      @page.save
    end
    PagesController.make_page(@channel,@page)
    aplog.debug("END   #{CLASS_NAME}#update")
  end
  
  def layout
    aplog.debug("START #{CLASS_NAME}#layout")
    @page = @channel.pages.find(params[:id])
    content = @channel.pages.find_by_id(params[:id])
    @contents = content.contents.find(:all,:conditions=>["page_id=?",params[:id]],:order=>"contents_seq")
    aplog.debug("END   #{CLASS_NAME}#layout")
  end
  
  def backimages
    aplog.debug("START #{CLASS_NAME}#backimages")
    if params[:bg]!=nil
      @page = @channel.pages.find(params[:id])
      extension =  File.extname(params[:bg])
      storefilename = "gallary" + extension
      galleryimage = RuntimeSystem.image_gallery_save_dir(@page,params[:bg])
      path = RuntimeSystem.page_save_dir(@page)
      FileUtils.mkdir_p(path)
      original = File.open(galleryimage, "rb")
      copy = File.open(path+"#{storefilename}", "wb")
      copy.write(original.read)

      @page.background = nil
      @page.backgroundfile = storefilename
      if @page.background_display_type == nil
        @page.background_display_type = "0"
      end
      @page.save
      aplog.debug("END   #{CLASS_NAME}#backimages")
      redirect_to edit_channel_page_path(params[:channel_id],params[:id],:bgtype=>params[:bg])
    end
    aplog.debug("END   #{CLASS_NAME}#backimages")
  end
  
  def destroy
    aplog.debug("START #{CLASS_NAME}#destroy")
    page = @channel.pages.find(params[:id])
    page_no = page.page_no
    Page.destroy(params[:id]) if @channel.pages.find(params[:id])
    # 切替
    PagesController.make_page(@channel,@page)
    
    aplog.debug("END   #{CLASS_NAME}#destroy")
    redirect_to new_channel_page_path(:page_no=>page_no)
    #redirect_to channel_pages_path(@channel)
  end
  
  def playpage
    aplog.debug("START #{CLASS_NAME}#playpage")
    @page = @channel.pages.find(params[:id])
    @page.contents.each{|content|
      runtime_system([content])
    }
    aplog.debug("END   #{CLASS_NAME}#playpage")
    redirect_to(root_path+RuntimeSystem.page_save_dir(@page)+"preview.html")
  end
  
  
  def self.make_page(channel,page)
    aplog.debug("START #{CLASS_NAME}#make_page")
    pageW = channel["width"]
    pageH = channel["height"]
  
    pagesW = pageW
    pagesL = -pagesW/2
    pagesH = pageH
    
    pages =  channel.pages.find(:all, :order => "page_no")
    i = 0
    n = 0
    count = 0
    push_page = []
    pages.each{|page|
      if page.contents.size != 0
        push_page << count
      end
      count += 1
    }
    
    for page in pages do
      if pages[n].contents.size != 0
      contents = page.contents.find(:all, :order=>"contents_seq")
      html = ""
      html << " <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \n"
      html << " \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"> \n"
      html << "<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en' lang='en'> \n"
      html << "<head> \n"
      html << "<meta http-equiv='content-type' content='text/html;charset=UTF-8' /> \n"
      html << "<meta http-equiv='cache-control' content='non-cache' />\n"
      
      if push_page.size >= 2
        if push_page.size == (i+1)
          switchpage = pages[push_page[0]]
        else
          switchpage = pages[push_page[i+1]]
        end
        html << "<meta http-equiv='refresh' content='"+page.switchtime.to_s+";url="+"/"+RuntimeSystem.page_save_dir(switchpage)+"preview.html'/> \n"
      end
      
      html << "<title>VASDAQ.TV</title> \n"
      html << "<style type='text/css'> \n"
      html << "<!-- \n"
      html << "body { \n"
      html << "color:#FFFFFF; \n"
      html << "background-color:"+channel.background+"; \n"
      html << "font-family:Verdana,sans-serif; \n"
      html << "font-size:70%;} \n"

      html << "#Page{ \n"
      html << "position: absolute; \n"
      html << "top: 0px; \n"
      html << "left: 50%; \n"
      html << "height:"+pagesH.to_s+"px; \n"
      html << "width:"+pagesW.to_s+"px; \n"
      html << "margin-left:"+pagesL.to_s+"px; \n"
      #html << "background-repeat: no-repeat; \n"
      #html << "background-position:top center;} \n"
      time = Time.now.to_i
      if page["background"] != nil
        html << "background-color:"+page["background"]+"; \n"
      end
      if page["backgroundfile"] != nil
        html << "background-image:url("+page["backgroundfile"]+"?"+time.to_s+"); \n"
      end
      if page["background_display_type"] == 0
        html << "background-position:center center;background-repeat:no-repeat; \n"
      end
      if page["background_display_type"] == 1
        html << "background-repeat:repeat; \n"
      end
      if page["background_display_type"] == 2
        html << "-moz-background-size: 100% 100%;           /* Gecko 1.9.2 (Firefox 3.6) */\n"
        html << "-o-background-size: 100% 100%;           /* Opera 9.5 */\n"
        html << "-webkit-background-size: 100% 100%;           /* Safari 3.0 */\n"
        html << "-khtml-background-size: 100% 100%;           /* Konqueror 3.5.4 */\n"
        html << "filter: progid:DXImageTransform.Microsoft.AlphaImageLoader(Src="+page["backgroundfile"].to_s+"?"+time.to_s+",SizingMethod=scale);\n"
        html << "-ms-filter: 'progid:DXImageTransform.Microsoft.AlphaImageLoader(Src="+page["backgroundfile"].to_s+"?"+time.to_s+",SizingMethod=scale)';\n"
      end
      html << "}\n"

      contents.each{|content|
          if content.line_type == "gradation"
            html << ".flame_"+content.id.to_s+"{\n"
            html << "margin:"+content.line_width.to_s+"px 0px 0px "+content.line_width.to_s+"px;"
            html << "-webkit-box-shadow: 0 0 "+content.line_width.to_s+"px "+content.line_width.to_s+"px "+content.line_color+";\n"
            html << "-moz-box-shadow: 0 0 "+content.line_width.to_s+"px "+content.line_width.to_s+"px "+content.line_color+";\n"
            html << "box-shadow: 0 0 "+content.line_width.to_s+"px "+content.line_width.to_s+"px "+content.line_color+";\n"
            html << "}\n"
          else
            html << ".flame_"+content.id.to_s+"{border:"+content.line_width.to_s+"px solid "+content.line_color.to_s+";}\n"
          end
       }
      html << "--> \n"
      html << "</style> \n"
      html << "</head> \n"
      html << "<body> \n"
      html << "<div id='Box'> \n"
      html << "    <div id='Page'> \n"
      contents.each{|content|
        adjustment_width = content.width - (content.line_width*2)
        adjustment_height = content.height - (content.line_width*2)
        html << "<div id='"+content.id.to_s+"' style='position: absolute;top:"+content.y_pos.to_s+"px;left:"+content.x_pos.to_s+"px;width:"+content.width.to_s+"px;height:"+content.height.to_s+"px;'> \n"
        html << "  <iframe class='flame_"+content.id.to_s+"' style='width:"+adjustment_width.to_s+"px;height:"+adjustment_height.to_s+"px;' src='"+content.id.to_s+"/index.html' scrolling='no' frameborder='0' allowtransparency='true'> \n"
        html << "  </iframe> \n"
        html << "</div> \n"
      }
      html << "    </div> \n"
      html << "</div> \n"
      html << "</body>"
      html << "</html>"    
      FileUtils.mkdir_p(RuntimeSystem.page_save_dir(page))
      File.open(RuntimeSystem.page_save_dir(page)+"preview.html", "wb"){|f|
        f.write(html)
      }
      i += 1
    end
    n += 1
    end
    aplog.debug("END   #{CLASS_NAME}#make_page")
  end

  def addplayer
    aplog.debug("START #{CLASS_NAME}#addplayer")
    page = @channel.pages.find_by_id(params[:id],:include =>:contents);
    pages = @channel.pages(:include =>:contents)
    player_size_flag = 1
    if page.contents.size >= 20
      player_size_flag = 2
      channel_id = params[:channel_id]
      page_id = params[:id]
    end
=begin    
    begin
      if page.contents.size >= 20
        raise "ERR_0x01025027"
      end
    rescue => e
      alert(e.message)
      if flash[:error]
        alert("ERR_0x01010303")
      end
      render :update do |page|
        p page
        page.redirect_to(root_path)
      end

      #redirect_to(edit_channel_page_path(@channel, page))
      #render :action => "edit"
    end
=end

    if player_size_flag == 1
      check_content = false
      pages.each{|page_obj|
        if page_obj.contents.size != 0
          check_content = true
        end
      }
      
      player = Player.find(:first,:conditions=>["player_no =?",params[:player_no]])
      player_module = player(player)
      
      content = Content.new(:player_id=>player.id)
      
      page.contents << content
      
  
      player_module.set_request(request)
      params = player_module.default(content)
      
      config = params["contents_setting"]
      content = set_content(content,params)
      content.contents_seq = page.contents.length
      content.save
      
      config.each{|key,value|
        contents_property = ContentsProperties.new
        contents_property.property_key = key
        contents_property.property_value = value
        content.contents_propertiess << contents_property
      }
      content.save
      
      ContentsController.make_player(content,player_module,current_user,params)
      
      # プレビュー画面を作ります
      PagesController.make_page(@channel,page)
  
      html = layout_html(content,page.contents,check_content)
    else
      html = player_list(page.contents,channel_id,page_id)
      html << "<script type='text/javascript'>\n"
      html << "var alert_element = document.getElementById('alert_messege_player');\n"
      html << "alert_element.style.display = 'block';\n"
      html << "alert_element.innerHTML = 'プレーヤは２０個以上設定できません。';\n"
      html << "</script>\n"
    end

    aplog.debug("END   #{CLASS_NAME}#addplayer")
    render :text => html
  end
  
  
  def layout_html(new_content,page_contents,check_content)
    aplog.debug("START #{CLASS_NAME}#layout_html")
    add_player_no = page_contents.size
    channel_id = new_content.page.channel.id
    page_id = new_content.page.id
    player_logo = new_content.player.logo_img
    
    page_contents = page_contents
#    content = new_content
    
    
    html = ""
    if add_player_no == 1
      html << "<script>document.getElementById('layout_frame').contentWindow.location.reload();</script>"
      html << "<script>document.getElementById('preview_gard').style.display = 'none';</script>"
    else
      #idobj.sort!
      idobj = []
      page_contents.each do |re_id|
        idobj[re_id.contents_seq-1] = re_id.id.to_s+","
      end
      flag = "0"
      flame_width = new_content.width - 2
      flame_height = new_content.height - 2
      html << "
      <script><!--
        function appendChild(node, text) { 
          if (null == node.canHaveChildren || node.canHaveChildren) { 
            node.appendChild(document.createTextNode(text)); 
          } else { 
            node.text = text; 
          } 
        }
  
        function iframeDoc(id)
        {
          if (document.all) {
            // IE
            return frames[id].document;
          } else {
            // Mozilla
            return document.getElementById(id).contentDocument;
          }
        }
  
        var doc = iframeDoc('layout_frame');
  
        // iframe'document make element
        var container = doc.createElement('div')
        container.id = 'player"+add_player_no.to_s+"';
        container.setAttribute ('classname','jqDnR'); //IE
        container.setAttribute ('class','jqDnR');
        container.style.cssText = 'width:"+flame_width.to_s+"px;'
                                  + 'height:"+flame_height.to_s+"px;'
                                  + 'position:absolute;'
                                  + 'top:"+new_content.y_pos.to_s+"px;'
                                  + 'left:"+new_content.x_pos.to_s+"px;'
                                  + 'background:white;'\n
        add_HTML =\"<span class='popchecker' onMouseOver='mousepop([&quot;over&quot;,&quot;"+add_player_no.to_s+"&quot;]);' onMouseOut='mousepop([&quot;out&quot;,&quot;"+add_player_no.to_s+"&quot;]);'></span>\";
        add_HTML +=\" <table id='pname"+add_player_no.to_s+"' border='0' cellspacing='0' cellpadding='0'  onMouseOver='player_drag("+add_player_no.to_s+","+new_content.id.to_s+");' onMouseDown='dragposition("+add_player_no.to_s+","+new_content.width.to_s+","+new_content.height.to_s+","+new_content.id.to_s+","+new_content.x_pos.to_s+","+new_content.y_pos.to_s+");'>\"
        add_HTML +=\" <tr>\"
        add_HTML +=\"   <td align='center' valign='middle'>\"
        add_HTML +=\"     <div class='player_no' id='pop"+add_player_no.to_s+"'>NO."+add_player_no.to_s+"</div>\"
        add_HTML +=\"     <span class='a_player_no' id='a_pop"+add_player_no.to_s+"'>NO."+add_player_no.to_s+"</span>\"
        add_HTML +=\"     <img alt='' width='43px' height='43px' style='cursor: pointer;' onDblClick='to_setting("+channel_id.to_s+","+page_id.to_s+","+new_content.id.to_s+")' src='/images/../../../../images/players/"+player_logo.to_s+"' /> \"
        add_HTML +=\"   </td>\"
        add_HTML +=\" </tr>\"
        add_HTML +=\" </table>\"
        add_HTML +=\" <div class='jqResize' onMouseOver='player_size("+add_player_no.to_s+","+new_content.width.to_s+","+new_content.height.to_s+","+new_content.id.to_s+","+new_content.x_pos.to_s+","+new_content.y_pos.to_s+");' onMouseDown='dragresize("+add_player_no.to_s+","+new_content.id.to_s+")'></div>\"
        
        add_HTML +=\" <input id='current_player_id' name='current_player_id' type='hidden' />\"
        add_HTML +=\" <input id='"+new_content.id.to_s+"reserve' name='"+new_content.id.to_s+"reserve' type='hidden' value='"+new_content.width.to_s+"*"+new_content.height.to_s+"'/>\"
        add_HTML +=\" <input id='"+new_content.id.to_s+"preserve' name='"+new_content.id.to_s+"preserve' type='hidden' value='"+new_content.x_pos.to_s+"*"+new_content.y_pos.to_s+"'/>\"
        add_HTML +=\" <input id='"+new_content.id.to_s+"width' name='width"+new_content.id.to_s+"' type='hidden' value='"+new_content.width.to_s+"'/>\"
        add_HTML +=\" <input id='"+new_content.id.to_s+"height' name='height"+new_content.id.to_s+"' type='hidden' value='"+new_content.height.to_s+"'/>\"
        add_HTML +=\" <input id='"+new_content.id.to_s+"x' name='x_pos"+new_content.id.to_s+"' type='hidden' value='"+new_content.x_pos.to_s+"'/>\"
        add_HTML +=\" <input id='"+new_content.id.to_s+"y' name='y_pos"+new_content.id.to_s+"' type='hidden' value='"+new_content.y_pos.to_s+"'/>\"
        container.innerHTML = add_HTML;
        
        var script_container = doc.createElement('script');
        script_container.setAttribute('type','text/javascript'); 
        
        add_script =\"element = document.getElementById('return_params'); \"
        add_script +=\"element_no = document.getElementById('players_no'); \"
        add_script +=\"element.onclick = new Function('reservedate(["+idobj.to_s+"],"+flag.to_s+");'); \"
        add_script +=\"element_no.onclick = new Function('no_btn(["+page_contents.length.to_s+"]);'); \"
        add_script +=\"document.getElementById('content_length').value = "+add_player_no.to_s+"; \"
        appendChild(script_container,add_script);        
        script_container.textContent = add_script;

          doc.getElementById('drag_frame').appendChild(container);
          doc.body.appendChild(script_container);
        -->
      </script>
      "
    end
    
    html << player_list(page_contents,channel_id,page_id)

    if !check_content
      html << "<script>\n"
      html << "$('#up_down_form').load('/channels/"+channel_id.to_s+"/pages/"+page_id.to_s+"/up_down_ref');"
      html << "</script>\n"
    end
    aplog.debug("END   #{CLASS_NAME}#layout_html")
    return html
  end
  
  def player_list(page_contents,channel_id,page_id)
    aplog.debug("START #{CLASS_NAME}#player_list")
    i= 1
    list_html = ""
    
    list_html << "<span id='on_player_list'>"
    list_html << "  <img alt='List_opne' onclick='player_lists(\"on\")' src='/images/./imagefile/list_opne.png' />"
    list_html << "</span>"
    list_html << "<div id='lists_horizon_frame'>"
    list_html << "  <span id='off_player_list' class='bt1'>"
    list_html << "    <img alt='List_close' onclick='player_lists(\"off\")' src='/images/./imagefile/list_close.png' />"
    list_html << "  </span>"
    list_html << "  <span id='lists_horizon'>Player List</span>"
    list_html << "</div>"
    list_html << "<div id='lists_vertical_frame'>"
    list_html << "  <div id='lists_vertical'>"
    list_html << "    <p><br/>P<br/>l<br/>a<br/>y<br/>e<br/>r<br/> <br/>L<br/>i<br/>s<br/>t</p>"
    list_html << "  </div>"
    list_html << "</div>"
    list_html << "<div id='lists_frame'>"
    list_html << "<div id='gard_player_list'></div>"
    list_html << "<ul id='ul_list'>\n"
    #list_contents = page.contents.find(:all,:conditions=>["page_id=?",page_id],:order=>"contents_seq")
    list_contents = []
    page_contents.each{|content|
      if content.contents_seq != nil
        list_contents[content.contents_seq-1] = content
      else
        list_contents[page_contents.size-1] = content
      end
    }
    list_contents.each{|content|
    list_html << "<li id='"+content.id.to_s+"'>\n"
    list_html << "   <span class='handle'>NO,"+i.to_s+" - </span>\n"
    
    list_html << "   <span class='player_del'>
                  <a href='/channels/"+channel_id.to_s+"/pages/"+page_id.to_s+"/contents/"+content.id.to_s+"/contentdelete' onclick='gard_player_delete()'>削除</a>
                </span>\n"
    list_html << "   <span class='space'></span>\n"
    list_html << "   <div class='player_name'>
                  <a href='/channels/"+channel_id.to_s+"/pages/"+page_id.to_s+"/contents/"+content.id.to_s+"/edit'>"+content.player.name.to_s+"</a>
                </div>\n"
    list_html << "</li>\n"
    
     i += 1
    }
    list_html << "</ul>\n"
    list_html << "</div>\n"
    
    list_html << "<script type='text/javascript'>\n"
    list_html << "var view_State_param = document.getElementById('lists_view_State').value;"
    list_html << "if (view_State_param == 'open'){"
    list_html << " player_lists('on')"
    list_html << "}"
    list_html << "else{"
    list_html << " player_lists('off')"
    list_html << "}"
    list_html << "</script>\n"
    
    list_html << "<script type='text/javascript'>\n"
    list_html << "$(document).ready(function() { \n"
    list_html << " $('#ul_list').sortable({ \n"
    list_html << "   handle : '.handle',\n"
    list_html << "   revert: false,\n"
    list_html << "   axis:'y',\n"
    list_html<< "   update : function () {\n"
    list_html << "     $('#list_items').val($('#ul_list').sortable('toArray') );\n"
    list_html << "     $('#lists_save').css('display','block');\n"
    list_html << "   }\n"
    list_html << " });\n"
    list_html << "});\n"
    list_html << "</script>\n"
    aplog.debug("END   #{CLASS_NAME}#layout_html")
    return list_html
  end
  
  def up_down_ref
    aplog.debug("START #{CLASS_NAME}#up_down_ref")
    html = ""
    html << "<table style='margin:5px;''>"
    html << "  <tr>"
    html << "    <td colspan='2'>"
    html << "      <b>ページファイルのダウンロード/アップロード</b>"
    html << "    </td>"
    html << "  </tr>"
    html << "  <tr>"
    html << "    <td width='100px'>ダウンロード</td>"
    html << "    <td>"
    
    content_flg = false
    pages = @channel.pages
    pages.each{|page|
      if page.contents.size != 0
        content_flg = true
      end
    }

    if content_flg
      html << "<input type='button' value='ダウンロード' onClick='location.href=\"/channels/"+params[:channel_id].to_s+"/download\"'>"
    else
      html << "ページを作成後、ダウンロード可能になります。"
    end

    html << "    </td>"
    html << "    <td></td>"
    html << "  </tr>"
    html << "  <tr>"
    html << "    <td>アップロード</td>"
    html << "    <td>"
    
    if @channel.uploaded_flg && !content_flg
      html << "<input name='commit' type='submit' value='アップロード' />"
    else
      html << "チャンネルのページを削除、またはクリアされていないためアップロードできません。"
    end
    
    html << "</td>"
    html << "    <td>"
    
    if @channel.uploaded_flg && !content_flg
      html << "<input id='channel_zip_upload[zipfile_path]' name='channel_zip_upload[zipfile_path]' size='60' type='file' />"
    end
    
    html << "    </td>"
    html << "  </tr>"
    html << "  <tr>"
    html << "    <td>クリア</td>"
    html << "    <td>"
    
    if !@channel.uploaded_flg
      html << "<input type='button' value='クリア' onClick='location.href=\"/channels/"+params[:channel_id]+"/pages/"+params[:id]+"/clear\"'>"
    else
      html << "アップロードされたクリア可能なファイルがありません。"
    end
    
    html << "    </td>"
    html << "    <td></td>"
    html << "  </tr>"
    html << "</table>"

    aplog.debug("END   #{CLASS_NAME}#up_down_ref")
    render :text => html
  end
  
  def upload
    aplog.debug("START #{CLASS_NAME}#upload")
    begin
      @page = @channel.pages.find_by_id(params[:id], :include =>:contents)
      content = @page.contents
      del_pages = @channel.pages
      #channel = @user.channels.find(params[:channel_id])

      if @channel.pages.size != 0
        del_pages.each{|page|
           Page.destroy(page.id)
        }
      end

      
      file = params["channel_zip_upload"]["zipfile_path"]
      #tmpフォルダのpath
      recieve_channel_path = RuntimeSystem.recieve_client_channel_save_dir(@channel)
      #users_contentsフォルダのpath
      user_contents_path = RuntimeSystem.channel_save_dir(@channel)
      #直前のuploaded_flagを取得
      channel_uploaded_flg = @channel.uploaded_flg
      ActiveRecord::Base.transaction do
        #zipファイルが選択されたかどうか？
        raise "ERR_0x01010304" if file.blank?
        #ファイルアップロードフラグチェック
        raise "ERR_0x01010305" if !channel_uploaded_flg
        #ページ情報が消されているかどうか
        raise "ERR_0x01010305" if !content.empty?
        #zipファイルかどうかのチェック
        raise "ERR_0x01010306" if !file.content_type == "application/zip"
        @channel.uploaded_flg = false
        #tmpにファイルを作成する前にclear
        FileUtils.rm_rf(recieve_channel_path)
      end

      ActiveRecord::Base.transaction do
        #zipファイル保存フォルダ作成
        FileUtils.mkdir_p(recieve_channel_path)
        #tmpフォルダへのzipファイルの書き込み
        File.open(recieve_channel_path + file.original_filename,"wb"){|f|
          f.write(file.read) 
        }
        #zipファイルの展開
        zipfile = ArchiveUtil::ZipUtil.unzip_file(recieve_channel_path + file.original_filename, recieve_channel_path)
        #zipファイルの削除
        FileUtils.rm(recieve_channel_path + file.original_filename)
        
        #解凍後のチェック
        #zipファイルサイズチェック 10M以内
        raise "ERR_0x01010307" if user_contents_dir_size_check(recieve_channel_path) > 30.megabytes

        #解凍後のディレクトリのコピーの準備
        count = 0
        ##2階層目のパス
        paths = []
        ##パスの確認
        Dir.open(recieve_channel_path).each{|dirPath|
          next if dirPath == "." || dirPath == ".."
          #ディレクトリチェック用
          dir_flg = false
          Dir.open(File.join(recieve_channel_path, dirPath)).each{|dirPaths|
          next if dirPaths == "." || dirPaths == ".."
            paths << path = File.join(recieve_channel_path, dirPath, dirPaths)
            if dir_flg = FileTest.directory?(path)
                raise "ERR_0x01010308" if !user_contents_dir_check(path)
                raise "ERR_0x01010309" if !is_half_num(dirPaths)
                raise "ERR_0x01010308" if (dirPaths.to_s > 1.to_s && dirPaths.to_i > 10)
            end
          }
 
          count += 1
          raise "ERR_0x01010308" if dir_flg && (count >= 2)
        }
        #ページテーブルへのデータ追加
        paths.each{|path|
          page_no = File.basename(path)
          page = Page.new(:page_no => page_no)
          @channel.pages << page
        }

        #チャンネルのフォルダ作成
        FileUtils.mkdir_p(user_contents_path)
        #解凍したフォルダのコピー    
        FileUtils.cp_r(paths, user_contents_path)
        #tmpzipファイル削除
        FileUtils.rm_rf(recieve_channel_path)
  
        @channel.save!
            notice("MSG_0x00000015")
      end
    rescue => e
      FileUtils.rm_rf(recieve_channel_path)
      @channel.uploaded_flg = channel_uploaded_flg
      alert(e.message)
    end
    
    aplog.debug("END   #{CLASS_NAME}#upload")
    #チェックしたディレクトリ構成を画面に表示
    redirect_to(edit_channel_page_path(params[:channel_id],params[:id]))
  end
  
  def user_contents_dir_size_check(file_path)
    aplog.debug("START #{CLASS_NAME}#user_contents_dir_size_check")
    s = file_path + "/**/*"
    size = 0
    Dir.glob(s).each{|file|
      next if File.directory?(file)
       size += File.size?(file)       
    }
    aplog.debug("END   #{CLASS_NAME}#user_contents_dir_size_check")
    return size
  end
  
  #user_contentsディレクトリチェック
  def user_contents_dir_check(path)
    aplog.debug("START #{CLASS_NAME}#user_contents_dir_check")
    flg = false
    Dir.open(path).each{|dirPath|
    next if dirPath == "." || dirPath == ".."
      dirPath == "preview.html"
      flg = true if dirPath == "preview.html"
    }
    aplog.debug("END   #{CLASS_NAME}#user_contents_dir_check")
    return flg
  end
  
  def clear
    aplog.debug("START #{CLASS_NAME}#clear")
    begin
      page = @channel.pages(params[:id])
      channel = current_user.channels.find(params[:channel_id])
      #アップロードフラグが立っているかどうかのチェック
      raise "ERR_0x0101030A" if channel.uploaded_flg
      channel.pages.destroy_all
      channel.uploaded_flg = true
      channel.save!
      notice("MSG_0x00000016")
    rescue => e
      alert(e.message)
    end
    aplog.debug("END   #{CLASS_NAME}#clear")
    redirect_to channels_path
    #redirect_to edit_channel_page_path(channel.id,  page)
    #redirect_to edit_channel_path(channel)
  end 
  
  def set_content(content, params)
      aplog.debug("START #{CLASS_NAME}#set_content")
      content[:width] = params["contents"]["width"]
      content[:height] = params["contents"]["height"]
      content[:x_pos] = params["contents"]["x_pos"]
      content[:y_pos] = params["contents"]["y_pos"]
      content[:line_width] = params["contents"]["line_width"]
      content[:line_color] = params["contents"]["line_color"]
      aplog.debug("END   #{CLASS_NAME}#set_content")
      return content
  end
  
  private
  def find_channels
    aplog.debug("START #{CLASS_NAME}#find_channels")
    @channel = current_user.channels.find(:first, :include => :pages, :conditions=> ["channels.id = ?", params[:channel_id]])
    aplog.debug("END   #{CLASS_NAME}#find_channels")
  end
  
  def find_page
    aplog.debug("START #{CLASS_NAME}#find_page")
    @page = current_user.channels.find(:first, :include => :pages, :conditions=> ["channels.id = ? and pages.id = ?", params[:channel_id], params[:id]])
    aplog.debug("END   #{CLASS_NAME}#find_page")
  end
  
end
