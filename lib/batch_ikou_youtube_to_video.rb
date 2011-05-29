class BatchIkouYoutubeToVideo
  
  def self.execute
    
    # Youtube -> Video
    p "start Youtube -> Video Start"
    player = Player.find_by_id("104332051", :include => {:contents => :contents_propertiess})
    
    player.contents.each{|content|
#      ContentsProperties.update_all("property_key='keyword'", ["content_id = ? and property_key = ?",content.id, "keyword"])
      content.contents_propertiess << ContentsProperties.new({"property_key" => "video_set_type", "property_value" => "youtube_keyword_search"})
      content.contents_propertiess << ContentsProperties.new({"property_key" => "video_path_1", "property_value" => ""})
      content.contents_propertiess << ContentsProperties.new({"property_key" => "video_path_2", "property_value" => ""})
      content.contents_propertiess << ContentsProperties.new({"property_key" => "embed_tag", "property_value" => ""})
    }
#    Content.update_all("player_id=104332051", ["player_id=?","104332051"])

    p "end  Youtube -> Video end"
    
  end
  
end
