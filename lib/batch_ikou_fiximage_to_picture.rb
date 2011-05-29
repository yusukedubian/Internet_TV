class BatchIkouFiximageToPicture
  
  def self.execute
    
    # FixImagePlayer -> ImagePlayer
    p " start FixImagePlayer -> ImagePlayer(Picture)"
    player = Player.find_by_id("104332055", :include => {:contents => :contents_propertiess})
    
    player.contents.each{|content|
      
      extension = ""
      content.contents_propertiess.each{|cont_property|
        if !cont_property.property_value.nil?
          extension = File.extname(cont_property.property_value)
        end
      }
      
      ContentsProperties.update_all("property_key='picture_path1',property_value='1000000000-fiximage"+ extension + "'", ["content_id = ? and property_key = ?",content.id, "fiximage_path"])
      content.contents_propertiess << ContentsProperties.new({"property_key" => "time", "property_value" => "5000"})
      content.contents_propertiess << ContentsProperties.new({"property_key" => "effecttime", "property_value" => "5000"})
      content.contents_propertiess << ContentsProperties.new({"property_key" => "effect_type", "property_value" => "fade"})
      
    }
    Content.update_all("player_id=987777812", ["player_id=?","104332055"])
    p "end  FixImagePlayer -> ImagePlayer"
    
  end
  
end
