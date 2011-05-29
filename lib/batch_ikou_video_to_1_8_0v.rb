class BatchIkouVideoTo_1_8_0v
  
  def self.execute
    
    # Youtube -> Video
    p "start Video -> 1.8.0 Start"
    player = Player.find_by_id("104332051", :include => {:contents => :contents_propertiess})
    
    player.contents.each{|content|
      ContentsProperties.update_all("property_key='video_file_mp4'", ["content_id = ? and property_key = ?",content.id, "video_path_1"])
      ContentsProperties.update_all("property_key='video_file_webm'", ["content_id = ? and property_key = ?",content.id, "video_path_2"])
    }

    p "end  Video -> 1.8.0 end"
    
  end
  
end
