module RuntimeSystem
  protected

  def runtime_system(contents)
    contents.each{|content|
    runtime_type = content.player.runtime_get_type 
      if !runtime_type.blank?
        p runtime_type
        get_str = "RuntimeSystem::" << runtime_type << ".new"
        obj = eval(get_str)
        obj.execute(content, current_user)
      end
    }
    contents.each{|content|
    runtime_type = content.player.runtime_create_type
      if !runtime_type.blank?
        create_str = "RuntimeSystem::" << runtime_type << ".new"
        obj = eval(create_str)
        obj.execute(content, current_user)
      end
    }
  end
  
  def self.image_gallery_save_dir(page,image_name)
    return "users_contents/backimage/" << image_name 
  end
  
  def self.template_page_save_dir(page)
    template_page_no = page.page_no.to_s
    return "users_contents/template/" << template_page_no << "/"
  end
  
  def self.template_content_save_dir(content)
    template_page_no = content.template_page_id.to_s
    template_content_id = content.id.to_s
    return "users_contents/template/" << template_page_no << "/" << template_content_id << "/"
  end
  
  def self.image_player_content_save_dir()
    return "users_contents/image_player/"
  end
  
  def self.default_content_save_dir()
    return "users_contents/default_contents/"
  end
  
  def self.content_save_dir(content)
    uid = content.page.channel.user.id.to_s
    divkey = (uid.to_i/300).to_s
    channel_no = content.page.channel.channel_no.to_s
    page_no = content.page.page_no.to_s
    content_id = content.id.to_s
    return "users_contents/" << divkey << "/" << uid << "/" << channel_no << "/" << page_no << "/" << content_id << "/"
  end

  def self.page_save_dir(page)
    uid = page.channel.user.id.to_s
    divkey = (uid.to_i/300).to_s
    channel_no = page.channel.channel_no.to_s
    page_no = page.page_no.to_s
    return "users_contents/" << divkey << "/" << uid << "/" << channel_no << "/" << page_no << "/"
  end
  
  def self.channel_save_dir(channel)
    uid = channel.user.id.to_s
    divkey = (uid.to_i/300).to_s
    channel_no = channel.channel_no.to_s
    return "users_contents/" << divkey << "/" << uid << "/" << channel_no << "/"
  end
  
  def self.recieve_client_channel_save_dir(channel)
    uid = channel.user.id.to_s
    divkey = (uid.to_i/300).to_s
    channel_no = channel.channel_no.to_s
    return "recieve/client/users_contents/" << divkey << "/" << uid << "/" << channel_no << "/"
  end
  
  def self.recieve_client_page_save_dir(content)
    uid = content.page.channel.user.id.to_s
    divkey = (uid.to_i/300).to_s
    channel_no = content.page.channel.channel_no.to_s
    page_no = content.page.page_no.to_s
    return "recieve/client/users_contents/" << divkey << "/" << uid << "/" << channel_no << "/" << page_no << "/"
  end
  
  def self.recieve_client_content_save_dir(content)
    uid = content.page.channel.user.id.to_s
    divkey = (uid.to_i/300).to_s
    channel_no = content.page.channel.channel_no.to_s
    page_no = content.page.page_no.to_s
    content_id = content.id.to_s
    return "recieve/client/users_contents/" << divkey << "/" << uid << "/" << channel_no << "/" << page_no << "/" << content_id << "/"
  end

  def self.send_client_channel_save_dir(channel)
    uid = channel.user.id.to_s
    divkey = (uid.to_i/300).to_s
    channel_no = channel.channel_no.to_s
    return "send/client/users_contents/" << divkey << "/" << uid << "/" << channel_no << "/"
  end
  
  def self.send_client_page_save_dir(content)
    uid = content.page.channel.user.id.to_s
    divkey = (uid.to_i/300).to_s
    channel_no = content.page.channel.channel_no.to_s
    page_no = content.page.page_no.to_s
    return "send/client/users_contents/" << divkey << "/" << uid << "/" << channel_no << "/" << page_no << "/"
  end
  
  def self.send_client_content_save_dir(content)
    uid = content.page.channel.user.id.to_s
    divkey = (uid.to_i/300).to_s
    channel_no = content.page.channel.channel_no.to_s
    page_no = content.page.page_no.to_s
    content_id = content.id.to_s
    return "send/client/users_contents/" << divkey << "/" << uid << "/" << channel_no << "/" << page_no << "/" << content_id << "/"
  end

  def self.yaml_db_form_upload_file_name(current_user)
    uid = current_user.id.to_s
    divkey = (uid.to_i/300).to_s
    path = "./yaml_db_forms/" << divkey << "/" << uid
    FileUtils.mkdir_p(path) unless FileTest.exist?(path)
    path << "/" << Time.now.gmtime.strftime("form_%Y_%m%d_%H%M%S.yml")    
  end
  
  def self.yaml_db_form_sample_file_name(current_user, file_name)
    uid = current_user.id.to_s
    divkey = (uid.to_i/300).to_s
    path = "./yaml_db_forms/" << divkey << "/" << uid
    FileUtils.mkdir_p(path) unless FileTest.exist?(path)
    path << "/" << file_name    
  end
  
  def self.get_upload_file(model, file_obj, storefilename)
    
    if model.class == Channel
      p "channnel"
      copy_path = RuntimeSystem.channel_save_dir(model)
      store_path = RuntimeSystem.recieve_client_channel_save_dir(model)
    elsif model.class == Page
      p "Page"
      copy_path = RuntimeSystem.page_save_dir(model)
      store_path = RuntimeSystem.recieve_client_page_save_dir(model)
    elsif model.class == Content
      p "content"
      copy_path = RuntimeSystem.content_save_dir(model)
      store_path = RuntimeSystem.recieve_client_content_save_dir(model)
    else
      p "unSupported model!"
      return nil
    end
    p store_path
    p copy_path
    FileUtils.mkdir_p(store_path)
    File.open(store_path + storefilename, "wb"){|f|
      f.write(file_obj.read)
    }
    
    FileUtils.mkdir_p(copy_path)
    if FileTest.exist?(copy_path + storefilename)
      p "file delete"
      File.unlink(copy_path + storefilename)
    end
    File.rename(store_path + storefilename, copy_path + storefilename)
    p "write ok:" + copy_path + storefilename
    return copy_path + storefilename
  end
  
  
  def self.convert_line_feed_code(string)
    # Windows系改行コード置換（"\r\n" -> "\n"）
    tmp = string.gsub("\r\n", "\n")

    # Mac系改行コード置換（"\r" -> "\n"）
    tmp.gsub("\r", "\n")
  end
end
