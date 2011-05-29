class YamlDbFormsController < ApplicationController
  CLASS_NAME = self.name
  require 'kconv'
  require 'yaml'
  before_filter :login_required, :except => [:input, :yaml_send, :send_complete]
  # yamlフォーム公開用の認証
  before_filter :auth_yaml_db_form, :only => [:input, :yaml_send, :send_complete]
  after_filter :flash_clear
  layout "application", :except => [:input,:option_update, :input, :yaml_send,:items_update,:sort_update]

  def flash_clear
    aplog.debug("START #{CLASS_NAME}#flash_clear")
    flash.discard
    aplog.debug("START #{CLASS_NAME}#flash_clear")
  end

  def index
    aplog.debug("START #{CLASS_NAME}#index")
    @yaml_db_forms = current_user.yaml_db_forms.find(:all, :order => :updated_at)
    aplog.debug("END   #{CLASS_NAME}#index")
  end

  def upload
    aplog.debug("START #{CLASS_NAME}#upload")
    yaml_db_forms = params[:yaml_db_forms]

    begin
      # アップロードファイル数チェック
      if !(current_user.yaml_db_forms.count < ConstYamlDbForm::FILE_COUNT_MAX)
        raise conv_message("ERR_0x01020201", ConstYamlDbForm::FILE_COUNT_MAX)
      end
      
      # アップロードファイル名のブランクチェック
      if yaml_db_forms[:file].blank?
        raise "ERR_0x01020202"
      end

      # リモートファイルコピー
      file = yaml_db_forms[:file]
      path = RuntimeSystem.yaml_db_form_upload_file_name(current_user)
      copy_remote_file(file, path)

      # ファイルサイズチェック
      stat = File::stat(path)
      if !stat.size.between?(ConstYamlDbForm::FILE_SIZE_MIN, ConstYamlDbForm::FILE_SIZE_MAX)
        raise conv_message("ERR_0x01020203",
                    ConstYamlDbForm::FILE_SIZE_MIN, (ConstYamlDbForm::FILE_SIZE_MAX / 1024))
      end

      # YAML構文チェック + YAML DBフォーム定義構文チェック
      form_name, form_desc = yaml_grammar_check_by_file(path)

      # DBテーブル作成
      create_record(path, form_name, form_desc, nil)

      notice("MSG_0x00000003")
      
    rescue Exception => e
      # ファイルが存在する場合は削除
      if path && File::exist?(path)
        File::delete(path)
      end     
      alert(e.message)
    end
    
    @yaml_db_forms = current_user.yaml_db_forms.find(:all, :order => :updated_at)
    render :action => 'index' 
    aplog.debug("END   #{CLASS_NAME}#upload")
  end
  
  def delete
    aplog.debug("START #{CLASS_NAME}#delete")
    begin
      # 削除データの存在チェック
      if !(yaml_db_form = current_user.yaml_db_forms.find_by_id(params[:id]))
        raise "ERR_0x01020204"
      end
      
      # ファイルが存在する場合は削除
      if yaml_db_form.file_path && File::exist?(yaml_db_form.file_path)
        File::delete(yaml_db_form.file_path)
      end
      
      # DB削除
      YamlDbForm.delete(params[:id])
      
      notice("MSG_0x00000004")

    rescue Exception => e
      alert(e.message)
    end

    @yaml_db_forms = current_user.yaml_db_forms.find(:all, :order => :updated_at)
    render :action => 'index'
    aplog.debug("END   #{CLASS_NAME}#delete")
  end  

  def modify
    aplog.debug("START #{CLASS_NAME}#modify")
    begin
      # 更新データの存在チェック
      if !(yaml_db_form = current_user.yaml_db_forms.find_by_id(params[:id]))
        raise "ERR_0x01020204"
      end
    
      # 更新ファイルの存在チェック
      if !yaml_db_form.file_path && File::exist?(yaml_db_form.file_path)
        raise "ERR_0x01020205"
      end
      
      yaml_db_form[:public_flag] = params["yaml_db_form"]["public_flag"]
      yaml_db_form[:public_flag] ||= false
      yaml_db_form[:mail_to_default] = params["yaml_db_form"]["mail_to_default"]
      yaml_db_form[:mail_cc_default] = params["yaml_db_form"]["mail_cc_default"]
      yaml_db_form[:mail_gcc_default] = params["yaml_db_form"]["mail_gcc_default"]
      yaml_db_form[:mail_subject_default] = params["yaml_db_form"]["mail_subject_default"]
      yaml_db_form[:couchdb_set_view_flag] = params["yaml_db_form"]["couchdb_set_view_flag"]
      
      if((!yaml_db_form[:mail_to_default].blank? && !is_mail_addr(yaml_db_form[:mail_to_default])) ||
         (!yaml_db_form[:mail_cc_default].blank? && !is_mail_addr(yaml_db_form[:mail_cc_default])) ||
         (!yaml_db_form[:mail_bcc_default].blank? && !is_mail_addr(yaml_db_form[:mail_bcc_default])))
            raise "ERR_0x0102023D"
      end
    
      update_items_sort(params["yaml_db_form"])
    
      # フォーム定義変換
      form_data = conv_form_data(params["yaml_db_form"])   

      # YAML構文チェック + YAML DBフォーム定義構文チェック
      form_name, form_desc = yaml_grammar_check(form_data)

      # DBテーブル更新
      update_record(yaml_db_form, form_name, form_desc, form_data)
    
      notice("MSG_0x00000005")
      
      @yaml_db_forms = current_user.yaml_db_forms.find(:all, :order => :updated_at)
      action = 'index'

    rescue Exception => e
      alert(e.message)
      @yaml_db_forms = params["yaml_db_form"]
      @yaml_db_forms["id"] = params[:id]
      action = 'edit'
    end
    render :action => action
    aplog.debug("END   #{CLASS_NAME}#index")
  end

  def text_modify
    aplog.debug("START #{CLASS_NAME}#text_modify")
    begin
      # 更新データの存在チェック
      if !(yaml_db_form = current_user.yaml_db_forms.find_by_id(params[:id]))
        raise "ERR_0x01020204"
      end
      
      # 更新ファイルの存在チェック
      if !yaml_db_form.file_path && File::exist?(yaml_db_form.file_path)
        raise "ERR_0x01020205"
      end

      # 改行コード変換
      yaml_db_forms = params[:yaml_db_forms]
      form_data = RuntimeSystem.convert_line_feed_code(yaml_db_forms[:form_data])
      
      # サイズチェック
      if !form_data.size.between?(ConstYamlDbForm::FILE_SIZE_MIN, ConstYamlDbForm::FILE_SIZE_MAX)
        raise conv_message("ERR_0x01020203",
                  ConstYamlDbForm::FILE_SIZE_MIN, (ConstYamlDbForm::FILE_SIZE_MAX / 1024))
      end

      # YAML構文チェック + YAML DBフォーム定義構文チェック
      form_name, form_desc = yaml_grammar_check(form_data)

      # DBテーブル更新
      update_record(yaml_db_form, form_name, form_desc, form_data)
      
      notice("MSG_0x00000005")
      
      @yaml_db_forms = current_user.yaml_db_forms.find(:all, :order => :updated_at)
      action = 'index'

    rescue Exception => e
      alert(e.message)
      @yaml_db_forms = {:id=>params[:id], :form_data=>yaml_db_forms[:form_data]}
      action = 'text_edit'
    end
    render :action => action
    aplog.debug("END   #{CLASS_NAME}#index")
  end
  
  def edit
    aplog.debug("START #{CLASS_NAME}#edit")
    begin
      # 更新データの存在チェック
      if !(yaml_db_form = current_user.yaml_db_forms.find_by_id(params[:id]))
        raise "ERR_0x01020204"
      end
    
      begin
        # データ読み出し
        tmp = YAML.load(File.read(yaml_db_form.file_path))
        if !tmp
          raise "ERR_0x01020206"
        end
      rescue Exception => e
        raise "ERR_0x01020206"
      end

      @yaml_db_forms = {:id=>yaml_db_form.id,
                            "form_name"=>tmp["name"],
                            "table_name"=>tmp["table"],
                            "public_flag"=>yaml_db_form.public_flag,
                            "mail_to_default"=>yaml_db_form.mail_to_default,
                            "mail_cc_default"=>yaml_db_form.mail_cc_default,
                            "mail_bcc_default"=>yaml_db_form.mail_bcc_default,
                            "mail_subject_default"=>yaml_db_form.mail_subject_default,
                            "couchdb_set_view_flag"=>yaml_db_form.couchdb_set_view_flag
                            }
                            
      if tmp.has_key?("desc")
        @yaml_db_forms["form_desc"] = tmp["desc"]
      end

      item_index = 0
      @yaml_db_forms["sort_order"] = {}

      items = tmp["items"]
      items.each do |item|
        @yaml_db_forms["sort_order"][item_index.to_s] = item_index.to_s
        @yaml_db_forms["item_" + item_index.to_s + "_name"] = item["name"]
        @yaml_db_forms["item_" + item_index.to_s + "_column"] = item["column"]
        @yaml_db_forms["item_" + item_index.to_s + "_type"] = item["type"]
        if item.has_key?("desc")
          @yaml_db_forms["item_" + item_index.to_s + "_desc"] = item["desc"]
        end
        
        if item.has_key?("option")
          options = item["option"]
          option_index = 0
          options_index = 0
          options.each do |option|
            option.each do |key, value|
              case item["type"]
              when "text"
                if key == "length"
                  @yaml_db_forms["item_" + item_index.to_s + "_length"] = value
                end
                
                if key == "width"
                  @yaml_db_forms["item_" + item_index.to_s + "_width"] = value
                end
              when "radio"
                @yaml_db_forms["item_" + item_index.to_s + "_count"] = (options_index + 1)
                if key == "name"
                  @yaml_db_forms["item_" + item_index.to_s + "_radio_" + options_index.to_s + "_name"] = value    
                end
                
                if key == "value"
                  @yaml_db_forms["item_" + item_index.to_s + "_radio_" + options_index.to_s + "_value"] = value
                end
                
                if key == "checked"
                  if (value.to_s =~ /true/i)
                    @yaml_db_forms["item_" + item_index.to_s + "_checked"] = (options_index + 1)
                  end
                end
              when "list"
                @yaml_db_forms["item_" + item_index.to_s + "_count"] = (options_index + 1)
                if key == "name"
                  @yaml_db_forms["item_" + item_index.to_s + "_list_" + options_index.to_s + "_name"] = value    
                end
                
                if key == "value"
                  @yaml_db_forms["item_" + item_index.to_s + "_list_" + options_index.to_s + "_value"] = value
                end
                
                if key == "selected"
                  if (value.to_s =~ /true/i)
                    @yaml_db_forms["item_" + item_index.to_s + "_selected"] = (options_index + 1)
                  end                  
                end
              when "check"
                
                if key == "checked"
                  @yaml_db_forms["item_" + item_index.to_s + "_checked"] = value
                end
                
                if key == "value"
                  @yaml_db_forms["item_" + item_index.to_s + "_value"] = value
                end
              when "textarea" 
                if key == "length"
                  @yaml_db_forms["item_" + item_index.to_s + "_length"] = value
                end
                
                if key == "width"
                  @yaml_db_forms["item_" + item_index.to_s + "_width"] = value
                end            
  
                if key == "hight"
                  @yaml_db_forms["item_" + item_index.to_s + "_hight"] = value
                end              
              end            
             
              option_index += 1
            end
            options_index += 1
          end
        end

        if item.has_key?("option")
          option = item["option"][0]
          if option.has_key?("validate")
            validates = option["validate"]
            validate_index = 0
            validates.each do |validate|
              validate.each do |key, value|
                case item["type"]
                when "text"
                    item_type = "text"
                else
                    item_type = "textarea"
                end
                
                case key
                when "range"
                  @yaml_db_forms["item_" + item_index.to_s + "_#{item_type}_" + validate_index.to_s + "_validate"] = key.to_s
                  @yaml_db_forms["item_" + item_index.to_s + "_#{item_type}_" + validate_index.to_s + "_min"] = validate["range"][0]
                  @yaml_db_forms["item_" + item_index.to_s + "_#{item_type}_" + validate_index.to_s + "_max"] = validate["range"][1]
                when "prohibit"
                  @yaml_db_forms["item_" + item_index.to_s + "_#{item_type}_" + validate_index.to_s + "_validate"] = key.to_s
                  @yaml_db_forms["item_" + item_index.to_s + "_#{item_type}_" + validate_index.to_s + "_prohibit"] = value
                else
                  if (value.to_s =~ /true/i)
                    @yaml_db_forms["item_" + item_index.to_s + "_#{item_type}_" + validate_index.to_s + "_validate"] = key.to_s
                  end
                end
                validate_index += 1
              end
            end
            @yaml_db_forms["item_" + item_index.to_s + "_count"] = validate_index
          end
        end
        item_index += 1
      end

      @yaml_db_forms["items_count"] = item_index
      action = 'edit'

    rescue Exception => e
      alert(e.message)
      @yaml_db_forms = current_user.yaml_db_forms.find(:all, :order => :updated_at)
      action = 'index'
    end

    render :action => action
    aplog.debug("END   #{CLASS_NAME}#edit")
  end

  def text_edit
    aplog.debug("START #{CLASS_NAME}#text_edit")
    begin
      # 更新データの存在チェック
      if !(yaml_db_form = current_user.yaml_db_forms.find_by_id(params[:id]))
        raise "ERR_0x01020204"
      end
    
      begin
        # データ読み出し
        tmp = File.read(yaml_db_form.file_path)
        if !tmp
          raise "ERR_0x01020206"
        end
      rescue Exception => e
        raise "ERR_0x01020206"
      end

      @yaml_db_forms = {:id=>yaml_db_form.id, :form_data=>tmp}
      action = 'text_edit'
      
    rescue Exception => e
      alert(e.message)
      @yaml_db_forms = current_user.yaml_db_forms.find(:all, :order => :updated_at)
      action = 'index'
    end

    render :action => action
    aplog.debug("END   #{CLASS_NAME}#text_edit")
  end


  def input
    aplog.debug("START #{CLASS_NAME}#input")
    begin
      
      # データの存在チェック
      if !(yaml_db_form = YamlDbForm.find_by_id(params[:id]))
        raise "ERR_0x01020204"
      end
      @couch_view = yaml_db_form.couchdb_set_view_flag
      begin
        # データ読み出し
        tmp = YAML.load(File.read(yaml_db_form.file_path))
        if !tmp
          raise "ERR_0x01020206"
        end
      rescue Exception => e
        raise "ERR_0x01020206"
      end
    
      @yaml_db_forms = {:id=>yaml_db_form.id, :form_data=>tmp}
      action = 'input'
      
    rescue Exception => e
      alert(e.message)
      @yaml_db_forms = YamlDbForm.find(:all, :order => :updated_at)
      action = 'index'
    end

    @mailinfo = {
      "to" => yaml_db_form.mail_to_default,
      "cc" => yaml_db_form.mail_cc_default,
      "bcc" => yaml_db_form.mail_bcc_default,
      "subject" => yaml_db_form.mail_subject_default
    }
    @form_data = {}
    render :action => action
    aplog.debug("END   #{CLASS_NAME}#input_public_user")
  end


  def create_input_form(create_user, yaml_db_form_id)
    aplog.debug("START #{CLASS_NAME}#input")
    begin
      # データの存在チェック
      if !(yaml_db_form = YamlDbForm.find_by_id(params[:id]))
        raise "ERR_0x01020204"
      end
      
      begin
        # データ読み出し
        tmp = YAML.load(File.read(yaml_db_form.file_path))
        if !tmp
          raise "ERR_0x01020206"
        end
      rescue Exception => e
        raise "ERR_0x01020206"
      end
    
      @yaml_db_forms = {:id=>yaml_db_form.id, :form_data=>tmp}
      action = 'input'
      
    end

    @mailinfo = {}
    @form_data = {}
    render :action => action
    aplog.debug("END   #{CLASS_NAME}#input")
  end


  def yaml_send
    aplog.debug("START #{CLASS_NAME}#yaml_send")
    begin
      
      # データの存在チェック
      if !(yaml_db_form = YamlDbForm.find_by_id(params[:id]))
        raise "ERR_0x01020204"
      end
      @couch_view = yaml_db_form.couchdb_set_view_flag
  
      @form_data = params[:yaml_db_forms]
      @mailinfo = params[:mail_info]

      begin
        # データ読み出し
        form = YAML.load(File.read(yaml_db_form.file_path))    
        if !form
          raise "ERR_0x01020206"
        end
      rescue e
        raise "ERR_0x01020206"
      end

      # メール宛先チェック
      if @mailinfo["to"].blank? && @mailinfo["cc"].blank? && @mailinfo["bcc"].blank?
        raise "ERR_0x0102023C"
      end
      
      if (!@mailinfo["to"].blank? && !is_mail_addr(@mailinfo["to"])) ||
          (!@mailinfo["cc"].blank? && !is_mail_addr(@mailinfo["cc"])) ||
          (!@mailinfo["bcc"].blank? && !is_mail_addr(@mailinfo["bcc"]))
        raise "ERR_0x0102023D"
      end

      # メール本文作成
      mail_body = sprintf("table: %s\n", form["table"])
      items = form["items"]
      i = 0
      items.each do |item|
        if item.has_key?("option")
          validate_form_data(@form_data[i.to_s], item)
        end

        if item["type"] == "textarea"
          mail_body.concat(sprintf("%s: |\n", item["column"]))
          mail_body.concat(sprintf("  %s\n", @form_data["#{i}"].gsub("\r\n", "\r\n  ")))
        else
          mail_body.concat(sprintf("%s: %s\n", item["column"], @form_data["#{i}"]))
        end
        
        i += 1
      end
  
      # メール情報設定
      @mailinfo[:body] = mail_body

      begin
        
        create_user_property = @create_user.user_property
        aplog.debug(create_user_property)
        
        if !YamlMailer.deliver_send(@mailinfo, create_user_property)
          raise "ERR_0x01020207"
        end
      rescue Exception => e
        raise "ERR_0x01020207"
      end
       
      notice("MSG_0x00000006")
      @yaml_db_forms = YamlDbForm.find(:all, :order => :updated_at)
      action = 'send_complete'

    rescue Exception => e
      alert(e.message)
      @yaml_db_forms = {:id=>yaml_db_form.id, :form_data=>form}
      action = 'input'
    end

    render :action => action
    aplog.debug("END   #{CLASS_NAME}#yaml_send")
  end



  def new
    aplog.debug("START #{CLASS_NAME}#new")
    begin
      # アップロードファイル数チェック
      if !(current_user.yaml_db_forms.count < ConstYamlDbForm::FILE_COUNT_MAX)
        raise conv_message("ERR_0x01020258", ConstYamlDbForm::FILE_COUNT_MAX)
      end
    
      @yaml_db_forms = {"items_count" => 1, "item_0_type" => "text", "public_flag"=> false}
      @name = "item_0"
      
      action = 'new'
    rescue Exception => e
      alert(e.message)
      @yaml_db_forms = current_user.yaml_db_forms.find(:all, :order => :updated_at)
      action = 'index'
    end
    
    render :action => action
    aplog.debug("END   #{CLASS_NAME}#new")
  end

  def create
    aplog.debug("START #{CLASS_NAME}#create")
    begin
      yaml_db_form = params["yaml_db_form"]
      
#      if((!yaml_db_form[:mail_to_default].blank? && !is_mail_addr(yaml_db_form[:mail_to_default])) ||
#         (!yaml_db_form[:mail_cc_default].blank? && !is_mail_addr(yaml_db_form[:mail_cc_default])) ||
#         (!yaml_db_form[:mail_bcc_default].blank? && !is_mail_addr(yaml_db_form[:mail_bcc_default])))
#            raise "ERR_0x0102023D"
#      end
      
      
      update_items_sort(yaml_db_form)

      form = conv_form_data(yaml_db_form)      
      
      # YAML構文チェック + YAML DBフォーム定義構文チェック
      form_name, form_desc = yaml_grammar_check(form)

      path = RuntimeSystem.yaml_db_form_upload_file_name(current_user)

      begin
        # ローカルファイルオープン
        File.open(path, "wb") do |f|
          # ローカルファイルへの書き込み
          if !f.write(form)
            raise "ERR_0x0102023A"
          end
        end
      rescue Exception => e
        raise "ERR_0x0102023A"
      end

      create_record(path, form_name, form_desc, yaml_db_form)

      @yaml_db_forms = current_user.yaml_db_forms.find(:all, :order => :updated_at)
      action = 'index'
      notice("MSG_0x0000000A")
    rescue Exception => e
      @yaml_db_forms = yaml_db_form
      action = 'new'
      alert(e.message)
    end

    render :action => action
    aplog.debug("END   #{CLASS_NAME}#create")
  end

  def sort_update
    aplog.debug("START #{CLASS_NAME}#sort_update")
    @order = params["items"]
    aplog.debug("END   #{CLASS_NAME}#sort_update")
  end

  def items_update
    aplog.debug("START #{CLASS_NAME}#items_update")
    @yaml_db_forms = params["yaml_db_form"]
    update_items_sort(@yaml_db_forms)
    aplog.debug("END   #{CLASS_NAME}#items_update")
  end

  def option_update
    aplog.debug("START #{CLASS_NAME}#option_update")
    @type = params["type"]
    @name = params["name"]
    @yaml_db_forms = {}

    case @type
    when "text"
      render :action => 'text_option'
    when "list"
      @yaml_db_forms["#{@name}_count"] = 2
      render :action => 'list_option'  
    when "radio"
      @yaml_db_forms["#{@name}_count"] = 2
      render :action => 'radio_option'
    when "check"
      render :action => 'check_option'
    when "textarea"
      render :action => 'textarea_option'
    else
      alert("ERR_0x01020235")
    end
    aplog.debug("END   #{CLASS_NAME}#option_update")
  end

  def text_option_update
    aplog.debug("START #{CLASS_NAME}#text_option_update")
    @yaml_db_forms = params["yaml_db_form"]
    @name = update_option(@yaml_db_forms)
    aplog.debug("END   #{CLASS_NAME}#text_option_update")
  end

  def textarea_option_update
    aplog.debug("START #{CLASS_NAME}#textarea_option_update")
    @yaml_db_forms = params["yaml_db_form"]
    @name = update_option(@yaml_db_forms)
    aplog.debug("END   #{CLASS_NAME}#textarea_option_update")
  end
  
  def radio_option_update
    aplog.debug("START #{CLASS_NAME}#radio_option_update")
    @yaml_db_forms = params["yaml_db_form"]
    @name = update_option(@yaml_db_forms)
    aplog.debug("END   #{CLASS_NAME}#radio_option_update")
  end

  def list_option_update
    aplog.debug("START #{CLASS_NAME}#list_option_update")
    @yaml_db_forms = params["yaml_db_form"]
    @name = update_option(@yaml_db_forms)
    aplog.debug("END   #{CLASS_NAME}#list_option_update")
  end

  def text_validate_option_update
    aplog.debug("START #{CLASS_NAME}#text_validate_option_update")
    @name = params["name"]
    @yaml_db_forms = {"#{@name}_validate" => params["type"]}
    @validate = "#{@name}"
    aplog.debug("END   #{CLASS_NAME}#text_validate_option_update")
  end

  def textarea_validate_option_update
    aplog.debug("START #{CLASS_NAME}#textarea_validate_option_update")
    @name = params["name"]
    @yaml_db_forms = {"#{@name}_validate" => params["type"]}
    @validate = "#{@name}"
    aplog.debug("END   #{CLASS_NAME}#textarea_validate_option_update")
  end

private
  def conv_form_data(yaml_db_form)
    aplog.debug("START #{CLASS_NAME}#conv_form_data")
    check_ret, err_str = yaml_prohibit_identifier_check(yaml_db_form["form_name"])
    if !check_ret
      raise conv_message("ERR_0x01020244", conv_key_str("form"), err_str)
    end
    
    check_ret, err_char = yaml_prohibit_char_check(yaml_db_form["form_name"])
    if !check_ret
      raise conv_message("ERR_0x01020248", conv_key_str("form"), err_char)
    end
    
    form = sprintf("name: %s\n", yaml_db_form["form_name"])

    if !yaml_db_form["form_desc"].blank?
      check_ret, err_str = yaml_prohibit_identifier_check(yaml_db_form["form_desc"])
      if !check_ret
        raise conv_message("ERR_0x0102024C", conv_key_str("form"), err_str)
      end

      form.concat(sprintf("desc: |\n"))
      form.concat(sprintf("  %s\n", yaml_db_form["form_desc"].gsub("\r\n", "\r\n  ")))
    end

    check_ret, err_str = yaml_prohibit_identifier_check(yaml_db_form["table_name"])
    if !check_ret
      raise conv_message("ERR_0x01020254", err_str)
    end 
  
    check_ret, err_char = yaml_prohibit_char_check(yaml_db_form["table_name"])
    if !check_ret
      raise conv_message("ERR_0x01020255", err_char)
    end  

    form.concat(sprintf("table: %s\n", yaml_db_form["table_name"]))
    
    form.concat(sprintf("button: %s\n", _("送信")))
    form.concat(sprintf("items:\n"))

    item_count = 0
    while item_count < yaml_db_form["items_count"].to_i
      if item_count < yaml_db_form["sort_order"].length.to_i
        index = yaml_db_form["sort_order"][item_count.to_s]
      else
        index = item_count
      end

      check_ret, err_str = yaml_prohibit_identifier_check(yaml_db_form["item_#{index}_name"])
      if !check_ret
        raise conv_message("ERR_0x01020247", conv_key_str(yaml_db_form["item_#{index}_type"]), err_str)
      end 

      check_ret, err_char = yaml_prohibit_char_check(yaml_db_form["item_#{index}_name"])
      if !check_ret
        raise conv_message("ERR_0x0102024B", conv_key_str(yaml_db_form["item_#{index}_type"]), err_char)
      end

      form.concat(sprintf("- name: %s\n", yaml_db_form["item_#{index}_name"]))
      
      if !yaml_db_form["item_#{index}_desc"].blank?
        check_ret, err_str = yaml_prohibit_identifier_check(yaml_db_form["item_#{index}_desc"])
       if !check_ret
          raise conv_message("ERR_0x0102024D", conv_key_str(yaml_db_form["item_#{index}_type"]), yaml_db_form["item_#{index}_name"].to_s, err_str)
       end 

        form.concat(sprintf("  desc: |\n"))
        form.concat(sprintf("    %s\n", yaml_db_form["item_#{index}_desc"].gsub("\r\n", "\r\n    ")))
      end

      form.concat(sprintf("  type: %s\n", yaml_db_form["item_#{index}_type"]))
      
      check_ret, err_str = yaml_prohibit_identifier_check(yaml_db_form["item_#{index}_column"])
      if !check_ret
        raise conv_message("ERR_0x01020256", conv_key_str(yaml_db_form["item_#{index}_type"]), yaml_db_form["item_#{index}_name"].to_s, err_str)
      end 
  
      check_ret, err_char = yaml_prohibit_char_check(yaml_db_form["item_#{index}_column"])
      if !check_ret
        raise conv_message("ERR_0x01020257", conv_key_str(yaml_db_form["item_#{index}_type"]), yaml_db_form["item_#{index}_name"].to_s, err_char)
      end   
    
      form.concat(sprintf("  column: %s\n", yaml_db_form["item_#{index}_column"]))
      
      case yaml_db_form["item_#{index}_type"]
      when "text"
        if !yaml_db_form["item_#{index}_width"].blank?
          form.concat(sprintf("  option:\n"))
          form.concat(sprintf("  - width: %s\n", yaml_db_form["item_#{index}_width"]))
        end
      
        if !yaml_db_form["item_#{index}_length"].blank?
          if !yaml_db_form["item_#{index}_width"].blank?
            form.concat(sprintf("    length: %s\n", yaml_db_form["item_#{index}_length"]))
          else
            form.concat(sprintf("  option:\n"))
            form.concat(sprintf("  - length: %s\n", yaml_db_form["item_#{index}_length"]))
          end
        end

        if !(yaml_db_form["item_#{index}_count"] == "0")
          if (!yaml_db_form["item_#{index}_width"].blank? || !yaml_db_form["item_#{index}_length"].blank?)
            form.concat(sprintf("    validate:\n"))
          else
            form.concat(sprintf("  option:\n"))
            form.concat(sprintf("  - validate:\n"))
          end

          text = 0
          while text < yaml_db_form["item_#{index}_count"].to_i
            case yaml_db_form["item_#{index}_text_#{text}_validate"]
            when "range"
              form.concat(sprintf("    - %s: [%s, %s]\n", yaml_db_form["item_#{index}_text_#{text}_validate"], yaml_db_form["item_#{index}_text_#{text}_min"], yaml_db_form["item_#{index}_text_#{text}_max"]))
            when "prohibit"
              form.concat(sprintf("    - %s: %p\n", yaml_db_form["item_#{index}_text_#{text}_validate"], yaml_db_form["item_#{index}_text_#{text}_prohibit"].split(//, 0)))
            else
              form.concat(sprintf("    - %s: true\n", yaml_db_form["item_#{index}_text_#{text}_validate"]))
            end
            text += 1
          end
        end

      when "textarea"
        if !yaml_db_form["item_#{index}_width"].blank?
          form.concat(sprintf("  option:\n"))
          form.concat(sprintf("  - width: %s\n", yaml_db_form["item_#{index}_width"]))
        end
      
        if !yaml_db_form["item_#{index}_length"].blank?
          if !yaml_db_form["item_#{index}_width"].blank?
            form.concat(sprintf("    length: %s\n", yaml_db_form["item_#{index}_length"]))
          else
            form.concat(sprintf("  option:\n"))
            form.concat(sprintf("  - length: %s\n", yaml_db_form["item_#{index}_length"]))
          end
        end

        if !yaml_db_form["item_#{index}_hight"].blank?
          if (!yaml_db_form["item_#{index}_width"].blank? || !yaml_db_form["item_#{index}_length"].blank?)
            form.concat(sprintf("    hight: %s\n", yaml_db_form["item_#{index}_hight"]))
          else
            form.concat(sprintf("  option:\n"))
            form.concat(sprintf("  - hight: %s\n", yaml_db_form["item_#{index}_hight"]))
          end
        end

        if !(yaml_db_form["item_#{index}_count"] == "0")
          if (!yaml_db_form["item_#{index}_width"].blank? || !yaml_db_form["item_#{index}_length"].blank? || !yaml_db_form["item_#{index}_hight"].blank?)
            form.concat(sprintf("    validate:\n"))
          else
            form.concat(sprintf("  option:\n"))
            form.concat(sprintf("  - validate:\n"))
          end
        
          textarea = 0
          while textarea < yaml_db_form["item_#{index}_count"].to_i
            case yaml_db_form["item_#{index}_textarea_#{textarea}_validate"]
            when "range"
              form.concat(sprintf("    - %s: [%s, %s]\n", yaml_db_form["item_#{index}_textarea_#{textarea}_validate"], yaml_db_form["item_#{index}_textarea_#{textarea}_min"], yaml_db_form["item_#{index}_textarea_#{textarea}_max"]))
            when "prohibit"
              form.concat(sprintf("    - %s: %p\n", yaml_db_form["item_#{index}_textarea_#{textarea}_validate"], yaml_db_form["item_#{index}_textarea_#{textarea}_prohibit"].split(//, 0)))
            else
              form.concat(sprintf("    - %s: true\n", yaml_db_form["item_#{index}_textarea_#{textarea}_validate"]))
            end
            textarea += 1
          end
        end

      when "radio"
        radio = 0
        form.concat(sprintf("  option:\n"))
        while radio < yaml_db_form["item_#{index}_count"].to_i
            check_ret, err_str = yaml_prohibit_identifier_check(yaml_db_form["item_#{index}_radio_#{radio}_name"])
          if !check_ret
            raise conv_message("ERR_0x01020245", conv_key_str(yaml_db_form["item_#{index}_type"]), yaml_db_form["item_#{index}_name"].to_s, err_str)
          end 
      
          check_ret, err_char = yaml_prohibit_char_check(yaml_db_form["item_#{index}_radio_#{radio}_name"])
          if !check_ret
            raise conv_message("ERR_0x01020249", conv_key_str(yaml_db_form["item_#{index}_type"]), yaml_db_form["item_#{index}_name"].to_s, err_char)
          end        

          form.concat(sprintf("  - name: %s\n", yaml_db_form["item_#{index}_radio_#{radio}_name"]))
          
            check_ret, err_str = yaml_prohibit_identifier_check(yaml_db_form["item_#{index}_radio_#{radio}_value"])
          if !check_ret
            raise conv_message("ERR_0x01020252", conv_key_str(yaml_db_form["item_#{index}_type"]), yaml_db_form["item_#{index}_name"].to_s, err_str)
          end 
       
          check_ret, err_char = yaml_prohibit_char_check(yaml_db_form["item_#{index}_radio_#{radio}_value"])
          if !check_ret
            raise conv_message("ERR_0x01020253", conv_key_str(yaml_db_form["item_#{index}_type"]), yaml_db_form["item_#{index}_name"].to_s, err_char)
          end           
          
          form.concat(sprintf("    value: %s\n", yaml_db_form["item_#{index}_radio_#{radio}_value"]))
          
          if radio == (yaml_db_form["item_#{index}_checked"].to_i - 1)
            form.concat(sprintf("    checked: true\n"))
          else
            form.concat(sprintf("    checked: false\n"))
          end
        
          radio += 1
        end
      when "list"
        list = 0
        form.concat(sprintf("  option:\n"))
        while list < yaml_db_form["item_#{index}_count"].to_i
            check_ret, err_str = yaml_prohibit_identifier_check(yaml_db_form["item_#{index}_list_#{radio}_name"])
          if !check_ret
            raise conv_message("ERR_0x01020246", conv_key_str(yaml_db_form["item_#{index}_type"]), yaml_db_form["item_#{index}_name"].to_s, err_str)
          end 
      
          check_ret, err_char = yaml_prohibit_char_check(yaml_db_form["item_#{index}_list_#{radio}_name"])
          if !check_ret
            raise conv_message("ERR_0x0102024A", conv_key_str(yaml_db_form["item_#{index}_type"]), yaml_db_form["item_#{index}_name"].to_s, err_char)
          end         

          form.concat(sprintf("  - name: %s\n", yaml_db_form["item_#{index}_list_#{list}_name"]))
          
            check_ret, err_str = yaml_prohibit_identifier_check(yaml_db_form["item_#{index}_list_#{radio}_value"])
          if !check_ret
            raise conv_message("ERR_0x01020252", conv_key_str(yaml_db_form["item_#{index}_type"]), yaml_db_form["item_#{index}_name"].to_s, err_str)
          end 
       
          check_ret, err_char = yaml_prohibit_char_check(yaml_db_form["item_#{index}_list_#{radio}_value"])
          if !check_ret
            raise conv_message("ERR_0x01020253", conv_key_str(yaml_db_form["item_#{index}_type"]), yaml_db_form["item_#{index}_name"].to_s, err_char)
          end            
          
          form.concat(sprintf("    value: %s\n", yaml_db_form["item_#{index}_list_#{list}_value"]))
        
          if list == (yaml_db_form["item_#{index}_selected"].to_i - 1)
            form.concat(sprintf("    selected: true\n"))
          else
            form.concat(sprintf("    selected: false\n"))
          end
        
          list += 1
        end
      when "check"
        form.concat(sprintf("  option:\n"))
        form.concat(sprintf("  - value: %s\n", yaml_db_form["item_#{index}_value"]))
        
        if yaml_db_form["item_#{index}_checked"]
          form.concat(sprintf("    checked: true\n"))
        else
          form.concat(sprintf("    checked: false\n"))
        end
      else
        raise "ERR_0x01020235"
      end  
      item_count += 1
    end
    aplog.debug("END   #{CLASS_NAME}#conv_form_data")
    return form
  end

  def update_option(yaml_db_form)
    aplog.debug("START #{CLASS_NAME}#update_option")
    i = 0
    while i < ConstYamlDbForm::FORM_ITEMS_MAX
      key = "item_" + i.to_s + "_count"
      if yaml_db_form.has_key?(key)
        break
      end
      i += 1
    end
    aplog.debug("END   #{CLASS_NAME}#update_option")
    return "item_" + i.to_s    
  end

  def update_items_sort(yaml_db_form)
    aplog.debug("START #{CLASS_NAME}#update_items_sort")
    tmp = yaml_db_form.dup
    sort_oder = tmp["sort_order"]

    i = 0
    while i < yaml_db_form["items_count"].to_i
      yaml_db_form["sort_order"][i.to_s] = i
      new_item = "item_" + i.to_s

      if i < tmp["sort_order"].length.to_i
        tmp_item = "item_" + sort_oder[i.to_s].to_s
      else
        tmp_item = "item_" + i.to_s
      end

      if tmp.has_key?(tmp_item + "_name")
        yaml_db_form[new_item + "_name"] = tmp[tmp_item + "_name"]
        yaml_db_form[new_item + "_desc"] = tmp[tmp_item + "_desc"]
        yaml_db_form[new_item + "_type"] = tmp[tmp_item + "_type"]
        if tmp[tmp_item + "_column"].nil? || tmp[tmp_item + "_column"] ==""
          yaml_db_form[new_item + "_column"] = tmp[tmp_item + "_name"]
        else
        yaml_db_form[new_item + "_column"] = tmp[tmp_item + "_column"]
        end
        case tmp[tmp_item + "_type"]
        when "text"
          yaml_db_form[new_item + "_width"] = tmp[tmp_item + "_width"]
          yaml_db_form[new_item + "_length"] = tmp[tmp_item + "_length"]
          yaml_db_form[new_item + "_count"] = tmp[tmp_item + "_count"]
          l = 0
          while l < tmp[tmp_item + "_count"].to_i
            yaml_db_form[new_item + "_text_" + l.to_s + "_validate"] = tmp[tmp_item + "_text_" + l.to_s + "_validate"]
            case tmp[tmp_item + "_text_" + l.to_s + "_validate"]
            when "range"
                yaml_db_form[new_item + "_text_" + l.to_s + "_min"] = tmp[tmp_item + "_text_" + l.to_s + "_min"]
                yaml_db_form[new_item + "_text_" + l.to_s + "_max"] = tmp[tmp_item + "_text_" + l.to_s + "_max"]
            when "prohibit"
                yaml_db_form[new_item + "_text_" + l.to_s + "_prohibit"] = tmp[tmp_item + "_text_" + l.to_s + "_prohibit"]
            end
            l += 1
          end
            
        when "check"
          yaml_db_form[new_item + "_checked"] = tmp[tmp_item + "_checked"]
          yaml_db_form[new_item + "_value"] = tmp[tmp_item + "_value"]   
          
        when "list"
          yaml_db_form[new_item + "_count"] = tmp[tmp_item + "_count"]
          yaml_db_form[new_item + "_selected"] = tmp[tmp_item + "_selected"]
          l = 0
          while l < tmp[tmp_item + "_count"].to_i
            yaml_db_form[new_item + "_list_" + l.to_s + "_name"] = tmp[tmp_item + "_list_" + l.to_s + "_name"]
            yaml_db_form[new_item + "_list_" + l.to_s + "_value"] = tmp[tmp_item + "_list_" + l.to_s + "_value"]
            l += 1
          end          

        when "radio"
          yaml_db_form[new_item + "_count"] = tmp[tmp_item + "_count"]
          yaml_db_form[new_item + "_checked"] = tmp[tmp_item + "_checked"]
          l = 0
          while l < tmp[tmp_item + "_count"].to_i
            yaml_db_form[new_item + "_radio_" + l.to_s + "_name"] = tmp[tmp_item + "_radio_" + l.to_s + "_name"]
            yaml_db_form[new_item + "_radio_" + l.to_s + "_value"] = tmp[tmp_item + "_radio_" + l.to_s + "_value"]
            l += 1
          end   

        when "textarea"
          yaml_db_form[new_item + "_width"] = tmp[tmp_item + "_width"]
          yaml_db_form[new_item + "_length"] = tmp[tmp_item + "_length"]
          yaml_db_form[new_item + "_hight"] = tmp[tmp_item + "_hight"]
          yaml_db_form[new_item + "_count"] = tmp[tmp_item + "_count"]
          l = 0
          while l < tmp[tmp_item + "_count"].to_i
            yaml_db_form[new_item + "_textarea_" + l.to_s + "_validate"] = tmp[tmp_item + "_textarea_" + l.to_s + "_validate"]
            case tmp[tmp_item + "_textarea_" + l.to_s + "_validate"]
            when "range"
                yaml_db_form[new_item + "_textarea_" + l.to_s + "_min"] = tmp[tmp_item + "_textarea_" + l.to_s + "_min"]
                yaml_db_form[new_item + "_textarea_" + l.to_s + "_max"] = tmp[tmp_item + "_textarea_" + l.to_s + "_max"]
            when "prohibit"
                yaml_db_form[new_item + "_textarea_" + l.to_s + "_prohibit"] = tmp[tmp_item + "_textarea_" + l.to_s + "_prohibit"]
            end
    
            l += 1
          end

        else
          alert("ERR_0x01020235")
        end
      else
        yaml_db_form[new_item + "_type"] = "text"
      end
      i += 1
    end
    aplog.debug("END   #{CLASS_NAME}#update_items_sort")
  end

  def validate_form_data(form_data, item)
    aplog.debug("START #{CLASS_NAME}#validate_form_data")
    if (item["type"] == "text") || (item["type"] == "textarea")
      option = item["option"][0]
      if option.has_key?("validate")
        validates = option["validate"]
        validates.each do |validate|
          validate.each do |key, value|
            if (value.to_s =~ /true/i)
              case key
              when "is_blank"
                  validate_is_blank(form_data, item["name"], item["type"])
              when "not_integer"
                  validate_not_integer(form_data, item["name"], item["type"])
              when "not_float"
                  validate_not_float(form_data, item["name"], item["type"])
              when "not_alpha"
                  validate_not_alpha(form_data, item["name"], item["type"])
              when "is_full_char"
                  validate_is_full_char(form_data, item["name"], item["type"])
              when "is_half_char"
                  validate_is_half_char(form_data, item["name"], item["type"])
              end              
            end

            case key
            when "range"
                validate_range(form_data, value, item["name"], item["type"])
            when "prohibit"
                validate_prohibit(form_data, value, item["name"], item["type"])
            end
          end
        end
      end
    end
    aplog.debug("END   #{CLASS_NAME}#validate_form_data")
  end
      
  def validate_is_blank(form_data, name, type)
    aplog.debug("START #{CLASS_NAME}#validate_is_blank")
    if form_data.blank?
      raise conv_message("ERR_0x0102020B", conv_key_str(type), name)
    end
    aplog.debug("END   #{CLASS_NAME}#validate_is_blank")
  end

  def validate_not_integer(form_data, name, type)
    aplog.debug("START #{CLASS_NAME}#validate_not_integer")
    if !(form_data.blank?) && !(form_data =~ /-?[0-9]+/)
      raise conv_message("ERR_0x0102020C", conv_key_str(type), name)
    end
    aplog.debug("END   #{CLASS_NAME}#validate_not_integer")
  end

  def validate_not_float(form_data, name, type)
    aplog.debug("START #{CLASS_NAME}#validate_not_float")
    if !(form_data.blank?) && !(form_data =~ /-?[0-9]+\.[0-9]+/)
      raise conv_message("ERR_0x0102020D", conv_key_str(type), name)
    end
    aplog.debug("END   #{CLASS_NAME}#validate_not_float")
  end

  def validate_not_alpha(form_data, name, type)
    aplog.debug("START #{CLASS_NAME}#validate_not_alpha")
    if !(form_data.blank?) && !(form_data =~ /[a-zA-Z]+/)
      raise conv_message("ERR_0x0102020E", conv_key_str(type), name)
    end
    aplog.debug("END   #{CLASS_NAME}#validate_not_alpha")
  end

  def validate_is_full_char(form_data, name, type)
    aplog.debug("START #{CLASS_NAME}#validate_is_full_char")
    if !(form_data.blank?) && !is_half_char(form_data)
      raise conv_message("ERR_0x0102020F", conv_key_str(type), name)
    end
    aplog.debug("END   #{CLASS_NAME}#validate_is_full_char")
  end

  def validate_is_half_char(form_data, name, type)
    aplog.debug("START #{CLASS_NAME}#validate_is_half_char")
    if !(form_data.blank?) && is_half_char(form_data)
      raise conv_message("ERR_0x01020210", conv_key_str(type), name)
    end
    aplog.debug("END   #{CLASS_NAME}#validate_is_half_char")
  end

  def validate_range(form_data, range, name, type)
    aplog.debug("START #{CLASS_NAME}#validate_range")
    if !(form_data.blank?) && !form_data.to_i.between?(range[0], range[1])
      raise conv_message("ERR_0x01020211", name, type, range[0], range[1])
    end
    aplog.debug("END   #{CLASS_NAME}#validate_range")
  end

  def validate_prohibit(form_data, prohibit, name, type)
    aplog.debug("START #{CLASS_NAME}#validate_prohibit")
    if !(form_data.blank?)
      prohibit.each do |token|
        if form_data.index(token)
          raise conv_message("ERR_0x01020212", name, type, token)
        end
      end
    end
    aplog.debug("END   #{CLASS_NAME}#validate_prohibit")
  end

  def conv_key_str(key)
    aplog.debug("START #{CLASS_NAME}#conv_key_str")
    str_table = { "text" => _("テキストボックス"),         "radio" => _("ラジオボタン"),              "list" => _("選択リスト"),
                  "check" =>_("チェックボックス"),        "textarea" => _("_テキストエリア"),         "form" =>  _("フォーム"),
                  "desc" => _("説明"),                    "table" => _("データベースのテーブル名"),   "button" => _("ボタン名"),
                  "items" => _("項目"),                   "column" => _("データベースのカラム名"),    "option" => _("オプション"),
                  "checked" => _("初期状態のチェック"),    "value" => _("データベースへの書込み値"),   "selected" => _("初期選択"),
                  "hight" => _(_("高さ")),                   "width" => _("横幅"),                      "length" => _("入力可能な最大文字数"),
                  "validate" => _("入力値チェック"),       "is_blank" => _("空白チェック"),           "not_integer" => _("整数チェック"),
                  "not_float" => _("小数点数チェック"),    "not_alpha" => _(_("アルファベットチェック")), "is_full_char" => _("全角文字チェック"),
                  "is_half_char" => _("半角文字チェック"), "range" => _("範囲チェック"),              "prohibit" => _("禁止文字チェック")}
    aplog.debug("END   #{CLASS_NAME}#conv_key_str")
    return str_table[key]
  end

  def name_check(key, hash, min, max)
    aplog.debug("START #{CLASS_NAME}#name_check")
    # ハッシュかチェック
    if !hash.instance_of?(Hash)
      raise conv_message("ERR_0x01020208", conv_key_str(key)) 
    end
    
    # nameキーの有無チェック
    if !hash.has_key?("name")
      raise conv_message("ERR_0x01020209", conv_key_str(key))
    end

    # nameの文字列長チェック
    if !hash["name"].to_s.length.between?(min, max)
      case key
      when "form"
        raise conv_message("ERR_0x0102020A", conv_key_str(key), min, max)
      when "list_sub"
        raise conv_message("ERR_0x01020243", min, max)
      when "radio_sub"
        raise conv_message("ERR_0x01020242", min, max)
      else
        raise conv_message("ERR_0x0102023E", conv_key_str(key), min, max) 
      end
    end
    aplog.debug("END   #{CLASS_NAME}#name_check")
  end

  def description_check(key, hash, min, max)
    aplog.debug("START #{CLASS_NAME}#description_check")
    # ハッシュか、descキーの有無チェック（省略の可能性がある）
    if hash.instance_of?(Hash) && hash.has_key?("desc")
      # descの文字列長チェック
      if !hash["desc"].to_s.length.between?(min, max)
        if key == "form"
          raise conv_message("ERR_0x01020213", conv_key_str(key), min, max)
        else
          raise conv_message("ERR_0x0102023F", conv_key_str(key), hash["name"].to_s, min, max)
        end
      end
    end
    aplog.debug("END   #{CLASS_NAME}#description_check")
  end

  def button_check(key, option, min, max)
    aplog.debug("START #{CLASS_NAME}#button_check")
    # ハッシュか、buttonキーの有無チェック（省略の可能性がある）
    if option.instance_of?(Hash) && option.has_key?("button")
      # descの文字列長チェック
      if !option["button"].to_s.length.between?(min, max)
        raise conv_message("ERR_0x01020214", min, max)
      end
    end
    aplog.debug("END   #{CLASS_NAME}#button_check")
  end
  
  def hight_check(key, name, option, min, max)
    aplog.debug("START #{CLASS_NAME}#hight_check")
    # ハッシュか、hightキーの有無チェック（省略の可能性がある）
    if option.instance_of?(Hash) && option.has_key?("hight")
      # 設定値が文字列の場合
      if option["hight"].instance_of?(String)
        # 正数かチェック
        if (option["hight"] =~ /[^0-9]+/)
          raise conv_message("ERR_0x01020215", conv_key_str(key), name.to_s)
        end
      end
 
      # 範囲チェック
      if !option["hight"].to_i.between?(min, max)
        raise conv_message("ERR_0x01020216", conv_key_str(key), name.to_s, min, max)
      end
    end
    aplog.debug("END   #{CLASS_NAME}#hight_check")
  end
  
  def width_check(key, name, option, min, max)
    aplog.debug("START #{CLASS_NAME}#width_check")
    # ハッシュか、widthキーの有無チェック（省略の可能性がある）
    if option.instance_of?(Hash) && option.has_key?("width")
      # 設定値が文字列の場合
      if option["width"].instance_of?(String)
        # 正数かチェック
        if (option["width"] =~ /[^0-9]+/)
          raise conv_message("ERR_0x01020217", conv_key_str(key), name.to_s)
        end
      end
      
      # 範囲チェック
      if !option["width"].to_i.between?(min, max)
        raise conv_message("ERR_0x01020218", conv_key_str(key), name.to_s, min, max)
      end
    end
    aplog.debug("END   #{CLASS_NAME}#width_check")
  end
  
  def length_check(key, name, option, min, max)
    aplog.debug("START #{CLASS_NAME}#length_check")
    # ハッシュか、lengthキーの有無チェック（省略の可能性がある）
    if option.instance_of?(Hash) && option.has_key?("length")
      # 設定値が文字列の場合
      if option["length"].instance_of?(String)
        # 正数かチェック
        if (option["length"] =~ /[^0-9]+/)
          raise conv_message("ERR_0x01020219", conv_key_str(key), name.to_s)
        end
      end

      # 範囲チェック
      if !option["length"].to_i.between?(min, max)
        raise conv_message("ERR_0x0102021A", conv_key_str(key), name.to_s, min, max)
      end
    end
    aplog.debug("END   #{CLASS_NAME}#length_check")
  end
  
  def validate_check(type, name, option)
    aplog.debug("START #{CLASS_NAME}#validate_check")
    # ハッシュか、validateキーの有無チェック（省略の可能性がある）
    if option.instance_of?(Hash) && option.has_key?("validate")
      # validateアイテムが配列かチェック
      if !option["validate"].instance_of?(Array)
        raise conv_message("ERR_0x0102021B", conv_key_str(type), name.to_s)
      end

      option["validate"].each do |validate|
        validate.each do |key, value|
          case key
          when "is_blank", "not_integer", "not_float", "not_alpha", "is_full_char", "is_half_char"
            bool_check(value)
          when "range"
            range_check(type, name, key, value)
          when "prohibit"
            prohibit_check(type, name, key, value)
          else
            raise conv_message("ERR_0x0102021C", conv_key_str(type), name.to_s)
          end
        end
      end
    end
    aplog.debug("END   #{CLASS_NAME}#validate_check")
  end
  
  def bool_check(value)
    aplog.debug("START #{CLASS_NAME}#bool_check")
    if !((value.to_s =~ /true/i) || (value.to_s =~ /false/i))
      raise "ERR_0x0102021D"
    end
    aplog.debug("END   #{CLASS_NAME}#bool_check")
  end
  
  def range_check(type, name, key, value)
    aplog.debug("START #{CLASS_NAME}#range_check")
    # 配列かチェック
    if !value.instance_of?(Array)
      raise conv_message("ERR_0x0102021E", conv_key_str(type), name.to_s, conv_key_str(key))
    end
 
    # 配列数チェック（2個のみ許容）
    if value.count != ConstYamlDbForm::RANGE_COUNT
      raise conv_message("ERR_0x0102021F", conv_key_str(type), name.to_s, conv_key_str(key), ConstYamlDbForm::RANGE_COUNT)
    end

    # minチェック
    if value[0].instance_of?(String)
      if (value[0] =~ /[^0-9]+/)
        raise conv_message("ERR_0x01020220", conv_key_str(type), name.to_s, conv_key_str(key))
      end
    end

    if !value[0].to_i.between?(ConstYamlDbForm::RANGE_MIN, ConstYamlDbForm::RANGE_MAX)
      raise conv_message("ERR_0x01020221", conv_key_str(type), name.to_s, conv_key_str(key), ConstYamlDbForm::RANGE_MIN, ConstYamlDbForm::RANGE_MAX)
    end

    # maxチェック
    if value[1].instance_of?(String)
      if (value[1] =~ /[^0-9]+/)
        raise conv_message("ERR_0x01020240", conv_key_str(type), name.to_s, conv_key_str(key))
      end
    end

    if !value[1].to_i.between?(ConstYamlDbForm::RANGE_MIN, ConstYamlDbForm::RANGE_MAX)
      raise conv_message("ERR_0x01020241", conv_key_str(type), name.to_s, conv_key_str(key), ConstYamlDbForm::RANGE_MIN, ConstYamlDbForm::RANGE_MAX)
    end

    # 大小関係チェック（小、大の順番でない場合エラーとする）
    if value[0].to_i > value[1].to_i
      raise conv_message("ERR_0x01020222", conv_key_str(type), name.to_s, conv_key_str(key))
   end
   aplog.debug("END   #{CLASS_NAME}#range_check")
  end

  def prohibit_check(type, name, key, value)
    aplog.debug("START #{CLASS_NAME}#prohibit_check")
    # 配列かチェック
    if !value.instance_of?(Array)
      raise conv_message("ERR_0x0102021E", conv_key_str(type), name.to_s, conv_key_str(key))
    end
    
    # 配列数チェック
    if !value.count.between?(ConstYamlDbForm::PROHIBIT_MIN, ConstYamlDbForm::PROHIBIT_MAX)
      raise conv_message("ERR_0x01020223", conv_key_str(type), name.to_s, conv_key_str(key), ConstYamlDbForm::PROHIBIT_MIN, ConstYamlDbForm::PROHIBIT_MAX)
    end
    aplog.debug("END   #{CLASS_NAME}#prohibit_check")
  end
  
  def value_check(type, name, hash, min, max)
    aplog.debug("START #{CLASS_NAME}#value_check")
    # ハッシュかチェック
    if !hash.instance_of?(Hash)
      raise conv_message("ERR_0x01020224", conv_key_str(type), name.to_s)
    end
    
    # valueキーの有無チェック
    if !hash.has_key?("value")      
      raise conv_message("ERR_0x01020225", conv_key_str(type), name.to_s)
    end

    # valueの文字列長チェック
    if !hash["value"].to_s.length.between?(min, max)
      raise conv_message("ERR_0x01020226", conv_key_str(type), name.to_s, min, max)
    end
    aplog.debug("END   #{CLASS_NAME}#value_check")
  end
  
  def selected_check(key, hash)
    aplog.debug("START #{CLASS_NAME}#selected_check")
    if hash.has_key?("selected")
      bool_check(hash["selected"])
    end
    aplog.debug("END   #{CLASS_NAME}#selected_check")
  end

  def table_check(key, form, min, max)
    aplog.debug("START #{CLASS_NAME}#table_check")
    # ハッシュかチェック
    if !form.instance_of?(Hash)
      raise conv_message("ERR_0x01020227", conv_key_str(key))
    end

    # tableキーの有無チェック
    if !form.has_key?("table")
      raise conv_message("ERR_0x01020228", conv_key_str(key))
    end

    # tableの文字列長チェック
    if !form["table"].to_s.length.between?(min, max)
      raise conv_message("ERR_0x01020229", min, max)
    end
    aplog.debug("END   #{CLASS_NAME}#table_check")
  end

  def column_check(key, item, min, max)
    aplog.debug("START #{CLASS_NAME}#column_check")
    # ハッシュかチェック
    if !item.instance_of?(Hash)
      raise conv_message("ERR_0x0102022A", conv_key_str(key))
    end
    # columnキーの有無チェック
    if !item.has_key?("column") || item["column"].nil? || item["column"] == ""
#      raise conv_message("ERR_0x0102022B", conv_key_str(key))
      item["column"] = item["name"]
    end
    # columnの文字列長チェック
    if !item["column"].to_s.length.between?(min, max)
      raise conv_message("ERR_0x0102022C", conv_key_str(key), item["name"], min, max)
    end
    aplog.debug("END   #{CLASS_NAME}#column_check")
  end

  def text_check(item)
    aplog.debug("START #{CLASS_NAME}#text_check")
    # 配列かチェック
    if !item["option"].instance_of?(Array)
      raise conv_message("ERR_0x0102022D", conv_key_str(item["type"]))
    end

    option = item["option"][0]

    # 幅チェック
    width_check(item["type"], item["name"], option, ConstYamlDbForm::TEXT_WIDTH_MIN, ConstYamlDbForm::TEXT_WIDTH_MAX)
  
    # 入力最大文字数チェック
    length_check(item["type"], item["name"], option, ConstYamlDbForm::TEXT_LENGTH_MIN, ConstYamlDbForm::TEXT_LENGTH_MAX)

    # 入力値チェックオプションチェック
    validate_check(item["type"], item["name"], option)
    aplog.debug("END   #{CLASS_NAME}#text_check")
  end

  def list_check(item)
    aplog.debug("START #{CLASS_NAME}#list_check")
    # 配列かチェック
    if !item["option"].instance_of?(Array)
      raise conv_message("ERR_0x0102022D", conv_key_str(item["type"]))
    end
      
    # 配列数チェック
    if !item["option"].count.between?(ConstYamlDbForm::LIST_COUNT_MIN, ConstYamlDbForm::LIST_COUNT_MAX)
      raise conv_message("ERR_0x0102022E", conv_key_str(item["type"]), ConstYamlDbForm::LIST_COUNT_MIN, ConstYamlDbForm::LIST_COUNT_MAX)
    end
      
    item["option"].each do |option|
      # 名前チェック
      name_check((item["type"] + "_sub"), option, ConstYamlDbForm::LIST_NAME_MIN, ConstYamlDbForm::LIST_NAME_MAX)
        
      # DB設定値チェック
      value_check(item["type"], item["name"], option, ConstYamlDbForm::LIST_VALUE_MIN, ConstYamlDbForm::LIST_VALUE_MAX)
        
      # 選択済みチェック
      if option.has_key?("selected")
        bool_check(option["selected"])
      end
    end
    aplog.debug("END   #{CLASS_NAME}#list_check")
  end

  def radio_check(item)
    aplog.debug("START #{CLASS_NAME}#radio_check")
    # 配列かチェック
    if !item["option"].instance_of?(Array)
      raise conv_message("ERR_0x0102022D", conv_key_str(item["type"]))
    end
    
    # 配列数チェック
    if !item["option"].count.between?(ConstYamlDbForm::RADIO_COUNT_MIN, ConstYamlDbForm::RADIO_COUNT_MAX)
      raise conv_message("ERR_0x0102022E", conv_key_str(item["type"]), ConstYamlDbForm::RADIO_COUNT_MIN, ConstYamlDbForm::RADIO_COUNT_MAX)
    end

    item["option"].each do |option|
      # 名前チェック
      name_check((item["type"] + "_sub"), option, ConstYamlDbForm::RADIO_NAME_MIN, ConstYamlDbForm::RADIO_NAME_MAX)
      
      # DB書き込み値チェック
      value_check(item["type"], item["name"], option, ConstYamlDbForm::RADIO_VALUE_MIN, ConstYamlDbForm::RADIO_VALUE_MAX)
      
      # チェック済みチェック
      if option.has_key?("checked")
        bool_check(option["checked"])
      end
    end
    aplog.debug("END   #{CLASS_NAME}#radio_check")
  end

  def checkbox_ceck(item)
    aplog.debug("START #{CLASS_NAME}#radio_check")
     # 配列かチェック
    if !item["option"].instance_of?(Array)
      raise conv_message("ERR_0x0102022D", conv_key_str(item["type"]))
    end

    option = item["option"][0]

    # DB設定値チェック
    value_check(item["type"], item["name"], option, ConstYamlDbForm::CHECK_VALUE_MIN, ConstYamlDbForm::CHECK_VALUE_MAX)    
    
    # 選択済みチェック
#    selected_check(item["type"], option)
    aplog.debug("END   #{CLASS_NAME}#radio_check")
  end

  def textarea_chek(item)
    aplog.debug("START #{CLASS_NAME}#textarea_chek")
     # 配列かチェック
    if !item["option"].instance_of?(Array)
      raise conv_message("ERR_0x0102022D", conv_key_str(item["type"]))
    end

    option = item["option"][0]

    # 高さチェック
    hight_check(item["type"], item["name"], option, ConstYamlDbForm::TEXTAREA_HIGHT_MIN, ConstYamlDbForm::TEXTAREA_HIGHT_MAX)

    # 幅チェック
    width_check(item["type"], item["name"], option, ConstYamlDbForm::TEXTAREA_WIDTH_MIN, ConstYamlDbForm::TEXTAREA_WIDTH_MAX)
  
    # 入力最大文字数チェック
    length_check(item["type"], item["name"], option, ConstYamlDbForm::TEXTAREA_LENGTH_MIN, ConstYamlDbForm::TEXTAREA_LENGTH_MAX)

    # 入力値チェックオプションチェック
    validate_check(item["type"], item["name"], option)
    aplog.debug("END   #{CLASS_NAME}#textarea_chek")
  end

  def items_check(hash, min, max)
    aplog.debug("START #{CLASS_NAME}#items_check")
    # ハッシュかチェック
    if !hash.instance_of?(Hash)
      raise "ERR_0x0102022F"
    end
    
    # itemsキーの有無チェック
    if !hash.has_key?("items")
      raise "ERR_0x01020230"
    end
    
    # itemsの配列要素数チェック
    if !hash["items"].count.between?(min, max)
      raise conv_message("ERR_0x01020231", min, max)
    end
    
    # itemsが配列かチェック
    if !hash["items"].instance_of?(Array)
      raise "ERR_0x01020232"
    end
    aplog.debug("END   #{CLASS_NAME}#items_check")
  end
  
  def item_check(item)
    aplog.debug("START #{CLASS_NAME}#item_check")
    # ハッシュかチェック
    if !item.instance_of?(Hash)
      raise conv_message("ERR_0x01020233")
    end

     # typeキーの有無チェック
    if !item.has_key?("type")
      raise "ERR_0x01020234"
    end
   
    # 名前チェック
    name_check(item["type"], item, ConstYamlDbForm::ITEM_NAME_MIN, ConstYamlDbForm::ITEM_NAME_MAX)
    
    # 説明チェック
    description_check(item["type"], item, ConstYamlDbForm::ITEM_DESC_MIN, ConstYamlDbForm::ITEM_DESC_MAX)

    # DBカラム名チェック
    column_check(item["type"], item, ConstYamlDbForm::DB_COLUMN_MIN, ConstYamlDbForm::DB_COLUMN_MAX)

    # optionキーの有無チェック
    if item.has_key?("option")
      # typeによる分岐
      case item["type"]
      when "text"
        text_check(item)
      when "list"
        list_check(item)
      when "radio"
        radio_check(item)
      when "check"
        checkbox_ceck(item)
      when "textarea"
        textarea_chek(item)
      else
        raise "ERR_0x01020235"
      end
    end
    aplog.debug("END   #{CLASS_NAME}#item_check")
  end

  def form_items_check(form)
    aplog.debug("START #{CLASS_NAME}#form_items_check")
    # アイテムズチェック
    items_check(form, ConstYamlDbForm::FORM_ITEMS_MIN, ConstYamlDbForm::FORM_ITEMS_MAX)

    # アイテム数分ループ
    form["items"].each do |item|
      # アイテムチェック
      item_check(item)
    end
    aplog.debug("END   #{CLASS_NAME}#form_items_check")
  end

  def form_check(form)
    aplog.debug("START #{CLASS_NAME}#form_check")
    # フォーム名チェック
    name_check("form", form, ConstYamlDbForm::FORM_NAME_MIN, ConstYamlDbForm::FORM_NAME_MAX)
    
    # 説明文チェック
    description_check("form", form, ConstYamlDbForm::FORM_DESC_MIN, ConstYamlDbForm::FORM_DESC_MAX)
    
    # DBテーブル名チェック
    table_check("form", form, ConstYamlDbForm::DB_TABLE_MIN, ConstYamlDbForm::DB_TABLE_MAX)

    # ボタン名チェック
    button_check("form", form, ConstYamlDbForm::FORM_BUTTON_MIN, ConstYamlDbForm::FORM_BUTTON_MAX)
    aplog.debug("END   #{CLASS_NAME}#form_check")
  end

  def yaml_grammar_check_by_file(file)
    aplog.debug("START #{CLASS_NAME}#yaml_grammar_check_by_file")
    begin
      # YAML構文チェック
      if !tmp = YAML.load_file(file)
        raise "ERR_0x01020236"
      end
    rescue Exception => e
      raise "ERR_0x01020236"
    end
     
    # フォームチェック
    form_check(tmp)
        
    # アイテムチェック
    form_items_check(tmp)
    aplog.debug("END   #{CLASS_NAME}#yaml_grammar_check_by_file")
    return tmp["name"].to_s, tmp["desc"].to_s
  end

  def yaml_grammar_check(string)
    aplog.debug("START #{CLASS_NAME}#yaml_grammar_check")
    begin
      # YAML構文チェック
      if !tmp = YAML.load(string)
        raise "ERR_0x01020236"
      end
    rescue Exception => e
      raise "ERR_0x01020236"
    end

    # フォームチェック
    form_check(tmp)
 
    # アイテムチェック
    form_items_check(tmp)
    aplog.debug("END   #{CLASS_NAME}#yaml_grammar_check")
    return tmp["name"].to_s, tmp["desc"].to_s
  end

  def yaml_prohibit_identifier_check(str)
    aplog.debug("START #{CLASS_NAME}#yaml_prohibit_identifier_check")
    identifier = ["NULL", "TRUE", "FALSE", "YES", "NO", "ON", "OFF"]

    identifier.each do |check_str|
      if str.to_s.upcase == check_str
        aplog.debug("END   #{CLASS_NAME}#yaml_prohibit_identifier_check")
        return false, check_str.to_s
      end
    end
    aplog.debug("END   #{CLASS_NAME}#yaml_prohibit_identifier_check")
    return true, nil
  end

  def yaml_prohibit_char_check(str)
    aplog.debug("START #{CLASS_NAME}#yaml_prohibit_char_check")
    prohibit = [':', '-', '[', ']', '\"', '{', '}', '#', '\'', '!', '&',
                '*', '~', '?', '$', ',', '<', '>', '=', '\\', '%', '+', '.', '|']
    prohibit.each do |check_char|
      if str.to_s.count(check_char) != 0
        aplog.debug("END   #{CLASS_NAME}#yaml_prohibit_char_check")
        return false, check_char
      end
    end

    if (str =~ /\t/)
      aplog.debug("END   #{CLASS_NAME}#yaml_prohibit_char_check")
      return false, '\t'
    end

    if (str =~ /\n/)
      aplog.debug("END   #{CLASS_NAME}#yaml_prohibit_char_check")
      return false , '\n'
    end
    aplog.debug("END   #{CLASS_NAME}#yaml_prohibit_char_check")
    return true, nil
  end

  def copy_remote_file(remote, local)
    aplog.debug("START #{CLASS_NAME}#copy_remote_file")
    begin
      # ローカルファイルオープン
      File.open(local, "wb") do |f|
        # リモートデータ読み出し
        tmp_read = remote.read

        # 文字コードチェック
        code = Kconv.guess(tmp_read)
        case code
        when Kconv::BINARY
          raise "ERR_0x01020237"
        else
          # 文字コード変換（UTF8へ強制）
          tmp_conv = tmp_read.kconv(Kconv::UTF8, code)
          
          # 改行コード変換
          write_data = RuntimeSystem.convert_line_feed_code(tmp_conv)
        end
        
        # ローカルファイルへの書き込み
        if !f.write(write_data)
          raise "ERR_0x01020238"
        end
      end
    rescue Exception => e
      raise "ERR_0x01020238"
    end
    aplog.debug("END   #{CLASS_NAME}#copy_remote_file")
  end
  
  def create_record(path, form_name, form_desc, yaml_form=nil)
    aplog.debug("START #{CLASS_NAME}#create_record")
    aplog.debug("path=#{path}, form_name=#{form_name}, form_desc=#{form_desc}")
    # データ作成
    yaml_db_form = YamlDbForm.new
    yaml_db_form[:user_id] = current_user.id
    yaml_db_form[:file_path] = path
    yaml_db_form[:form_name] = form_name.to_s
    yaml_db_form[:form_desc] = form_desc.to_s
    
    # yaml_formが引数に渡ってる場合。引数にわたってない場合は、デフォルトをDBに設定。
    if !yaml_form.nil?
      yaml_db_form[:public_flag] = yaml_form[:public_flag]
      yaml_db_form[:public_flag] ||= false
      yaml_db_form[:mail_to_default] = yaml_form[:mail_to_default]
      yaml_db_form[:mail_cc_default] = yaml_form[:mail_cc_default]
      yaml_db_form[:mail_bcc_default] = yaml_form[:mail_bcc_default]
      yaml_db_form[:mail_subject_default] = yaml_form[:mail_subject_default]
      yaml_db_form[:couchdb_set_view_flag] = yaml_form[:couchdb_set_view_flag]
      yaml_db_form[:couchdb_set_view_flag] ||= false
    end
    
    begin
      # 保存
      if !yaml_db_form.save
        raise "ERR_0x01020239"
      end
    rescue Exception => e
      raise "ERR_0x01020239"
    end
    aplog.debug("END   #{CLASS_NAME}#create_record")
  end

  def update_record(yaml_db_form, form_name, form_desc, form_data)
    aplog.debug("START #{CLASS_NAME}#update_record")
    aplog.debug("yaml_db_form=#{yaml_db_form[:public_flag]}")
    
    begin
      # ローカルファイルオープン
      File.open(yaml_db_form.file_path, "wb") do |f|
        # ローカルファイルへの書き込み
        if !f.write(form_data)
          raise "ERR_0x0102023A"
        end
      end
   
      # フォーム名更新
      yaml_db_form[:form_name] = form_name.to_s
      yaml_db_form[:form_desc] = form_desc.to_s
   
      # 保存
      if !yaml_db_form.save
        raise "ERR_0x0102023B"
      end
    rescue Exception => e
      raise "ERR_0x0102023B"
    end
    aplog.debug("END   #{CLASS_NAME}#update_record")
  end
  
  
  # yamlフォームの公開フラグとログインユーザー、作成者を判断して、認証をおこなう。
  def auth_yaml_db_form
    
    yaml_db_form = YamlDbForm.find_by_id(params[:id])
    @create_user = yaml_db_form.user
    aplog.debug("create_user=#{@create_user}")
    
    if logged_in?
      if @create_user == current_user
        aplog.debug("ログインしてる")
        @create_yaml_form_user_flag = true
        login_required
      else
        aplog.debug("違うユーザーでログインしてる")
        @create_yaml_form_user_flag = false
        if !yaml_db_form.public_flag
          aplog.debug("非公開フォームです。")
          redirect_to root_path
        end
      end
    else
      aplog.debug("ログアウトしてる")
      @create_yaml_form_user_flag = false
      if !yaml_db_form.public_flag
        aplog.debug("非公開フォームです。")
        login_required
      end
    end
  end
  
end
