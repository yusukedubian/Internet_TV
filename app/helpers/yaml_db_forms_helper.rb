module YamlDbFormsHelper
  
  def yaml_db_form_text_field_tag(name, item, value)
    tag_opt = {}
    
    if item.has_key?("option")
      option = item["option"][0]
 
      # 入力可能最大文字数
      if option.has_key?("length")
        tag_opt[:maxlength] = option["length"]
      end
      
      # テキストフィールド幅
      if option.has_key?("width")
        tag_opt[:size] = option["width"]
      end
    end

    # テキストフィールドタグ作成
    text_field_tag(name, value, tag_opt)   
  end
  
  def yaml_db_form_text_area_tag(name, item, value)
    tag_opt = {}
    
    if item.has_key?("option")
      option = item["option"][0]
      
      # 入力可能最大文字数
      if option.has_key?("length")
        tag_opt[:onKeyUp] = "limitChars(this, #{option["length"]})"
      end

      # テキストエリア幅、高さ
      if option.has_key?("width") && option.has_key?("hight")
        tag_opt[:style] = "width:#{option["width"]}px; height:#{option["hight"]}px;"
      else
        # 片方のみ
        if option.has_key?("width")
          tag_opt[:style] = "width:#{option["width"]}px;"
        else
          tag_opt[:style] = "height:#{option["hight"]}px;"
        end
      end
    end
 
    # テキストエリアタグ作成
    text_area_tag(name, value, tag_opt)     
  end
  
  def yaml_db_form_check_box_tag(name, item, value)
    db_value = 0

    if item.has_key?("option")
      option = item["option"][0]
    
      # DB書き込み値
      if option.has_key?("value")
        db_value = option["value"]
      end

      if value
        if db_value == value.to_i
          checked = true
        else
          checked = false
        end
      else
        if option.has_key?("checked") && (option["checked"].to_s =~ /true/i)
          checked = true
        else
          checked = false
        end        
      end
      
      # チェックボックスタグ作成
      check_box_tag(name, db_value, checked)
    end
  end

  def yaml_db_form_select_tag(name, item, value)
    lists = Array.new()

    if item.has_key?("option")
      option = item["option"]

      selected = value
   
      option.each do |list|
         lists << [list["name"].to_s, list["value"]]

        if !value
          if list.has_key?("selected") && (list["selected"].to_s =~ /true/i)
            selected = list["value"]
          end
        end
      end
    end

    select_tag(name, options_for_select(lists, selected))
  end
  
  def yaml_db_form_radio_button_tag(name, item, value)
    buttons = ""
    if item.has_key?("option")
      option = item["option"]
      option.each do |radio|
        if value
          if radio["value"] == value
            checked = true
          else
            checked = false
          end
        else
          if radio.has_key?("checked") && (radio["checked"].to_s =~ /true/i)
            checked = true
          else
            checked = false
          end
        end
        buttons.concat(radio_button_tag(name, radio["value"], checked))
        buttons.concat(radio["name"].to_s)
        buttons.concat("<br>")
      end
    end

    return buttons
  end
  
  def yaml_db_form_num_select_tag(name, min, max, selected)
    lists = Array.new()
    count = min
    
    while count <= max
      lists << [count.to_s, count]
      count += 1
    end
    
    select_tag(name, options_for_select(lists, selected.to_i))
  end
  
  def yaml_db_form_type_select_tag(name, selected)
    lists = [_("テキストボックス"), "text"], [_("チェックボックス"), "check"], [_("ラジオボタン"), "radio"],
              [_("選択リスト"), "list"], [_("テキストエリア"), "textarea"]
    
    select_tag(name, options_for_select(lists, selected))
  end
  
  def yaml_db_form_validate_select_tag(name, selected)
    lists = [_("空白チェック"), "is_blank"], [_("整数チェック"), "not_integer"], [_("少数点数チェック"), "not_float"],
            [_("アルファベットチェック"), "not_alpha"], [_("全角文字チェック"), "is_full_char"], [_("半角文字チェック"), "is_half_char"],
            [_("範囲チェック"), "range"], [_("禁止文字チェック"), "prohibit"]
            
    select_tag(name, options_for_select(lists, selected))
  end
end
