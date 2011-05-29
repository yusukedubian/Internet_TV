class BatchIkouStringToText
  
  def self.execute
    
    # String Player -> TextPlayer
    p "start String -> Text"
    
    player = Player.find_by_id('987777811', :include => {:contents => :contents_propertiess}, :order =>"contents.id asc")
    
    player.contents.each{|content|
      
      result_set = content.contents_propertiess.find_by_sql(["select CP.content_id as content_id, CP.property_key as property_key, CP.property_value as property_value, case CP.property_key when 'radio' then '0' else '9' end as seq from contents_properties as CP where CP.content_id = ? order by CP.content_id asc, seq asc", content.id])
#      p result_set
      result_set.each{|result|
        p result
        if result.property_key == 'radio' and result.property_value == 'txt'
          p "txt"
          ContentsProperties.update_all("property_key='billboard_text_content'",    ["content_id = ? and property_key = ?",result.content_id, "text_content"])
          ContentsProperties.update_all("property_key='billboard_font_size'",       ["content_id = ? and property_key = ?",result.content_id, "font_size"])
          ContentsProperties.update_all("property_key='billboard_font_color'",      ["content_id = ? and property_key = ?",result.content_id, "font_color"])
          ContentsProperties.update_all("property_key='billboard_scroll_direction'",["content_id = ? and property_key = ?",result.content_id, "scroll_direction"])
          ContentsProperties.update_all("property_key='billboard_scroll_speed'",    ["content_id = ? and property_key = ?",result.content_id, "scroll_speed"])
          ContentsProperties.update_all("property_key='billboard_local_url'",       ["content_id = ? and property_key = ?",result.content_id, "local_url"])
          content.contents_propertiess << ContentsProperties.new({"property_key" => "viewtype", "property_value" => "billboard"})
          Content.update_all("player_id=104332056", ["id = ?", result.content_id])
        end
      }
    }
    
    p "end String -> Text"
    
    
    
    p "start Clock -> Text"
    
    # ClockPlayerの《contents properties》.property_keyとproperty_valueをTextPlayer用に変更
    player_clock = Player.find_by_id("104332053", :include => {:contents => :contents_propertiess})
    player_clock.contents.each{|content|
      ContentsProperties.update_all("property_key='clock_back_color'",      ["content_id = ? and property_key = ?",content.id, "back_color"])
      ContentsProperties.update_all("property_key='clock_font_size'",       ["content_id = ? and property_key = ?",content.id, "font_size"])
      ContentsProperties.update_all("property_key='clock_font_color'",      ["content_id = ? and property_key = ?",content.id, "font_color"])
    }
    # ClockPlayerの《contents》.player_idをTextPlayerに変更
    Content.update_all("player_id=104332056", ["player_id=?","104332053"])
    p "end Clock -> Text"
    
  end
  
end
