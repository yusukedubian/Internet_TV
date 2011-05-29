class BatchIkouHtmlUp
  
  def self.execute
    
    p " start HtmlPlayer_up"
    player = Player.find_by_id("987777807", :include => {:contents => :contents_propertiess})
    
    player.contents.each{|content|
      
      ContentsProperties.update_all("property_key='outurl_0'", ["content_id = ? and property_key = ?",content.id, "outurl"])
      
    }
    p " end HtmlPlayer_up"
    
  end
  
end
