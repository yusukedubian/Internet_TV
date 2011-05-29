class BatchIkouStringToRss
  
  def self.execute
    
    # String Player -> RssPlayer
    p "start String -> Rss"
    
    # StringPlayerの《contents properties》.property_keyとproperty_valueをRssPlayer用に変更
    player = Player.find_by_id('987777811', :include => {:contents => :contents_propertiess}, :order =>"contents.id asc")
    
    player.contents.each{|content|
      
      result_set = content.contents_propertiess.find_by_sql(["select CP.content_id as content_id, CP.property_key as property_key, CP.property_value as property_value, case CP.property_key when 'radio' then '0' else '9' end as seq from contents_properties as CP where CP.content_id = ? order by CP.content_id asc, seq asc", content.id])
#      p result_set
      result_set.each{|result|
        p result
        if result.property_key == 'radio' and result.property_value == 'rss'
          p "rss"
          
          ContentsProperties.update_all("property_key='urlpath1'",                  ["content_id = ? and property_key = ?", result.content_id, "urlpath1"])
          ContentsProperties.update_all("property_key='billboard_font_size'",       ["content_id = ? and property_key = ?", result.content_id, "font_size"])
          ContentsProperties.update_all("property_key='billboard_font_color'",      ["content_id = ? and property_key = ?", result.content_id, "font_color"])
          ContentsProperties.update_all("property_key='billboard_scroll_direction'",["content_id = ? and property_key = ?", result.content_id, "scroll_direction"])
          ContentsProperties.update_all("property_key='billboard_scroll_speed'",    ["content_id = ? and property_key = ?", result.content_id, "scroll_speed"])
          ContentsProperties.update_all("property_key='billboard_local_url'",       ["content_id = ? and property_key = ?", result.content_id, "local_url"])
          content.contents_propertiess << ContentsProperties.new({"property_key" => "title1", "property_value" => "タイトル"})
          content.contents_propertiess << ContentsProperties.new({"property_key" => "viewtype", "property_value" => "billboard"})
          content.contents_propertiess << ContentsProperties.new({"property_key" => "title_font_size", "property_value" => "#123456"})
          content.contents_propertiess << ContentsProperties.new({"property_key" => "billboard_title_font_size", "property_value" => "11"})
          Content.update_all("player_id=104332058", ["id = ?", result.content_id])
        end
      }
      
    }

    
    # StringPlayerの《contents》.player_idをRssPlayerに変更
#    Content.update_all("player_id=104332058", ["player_id=?","987777811"])
    p "end String -> Rss"
  end
  
end
