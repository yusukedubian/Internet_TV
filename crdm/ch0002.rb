require "./crdm/ch00002/createRssControll01"
require "./crdm/ch00002/createRssControll02"
require "./crdm/ch00002/createRssControll03"
require "./crdm/ch00002/createRssControll04"

class Ch0002
  def ch0002
    create_rss = CreateRssControll01.new
    create_rss.createRssControll
    create_rss = CreateRssControll02.new
    create_rss.createRssControll
    create_rss = CreateRssControll03.new
    create_rss.createRssControll
    create_rss = CreateRssControll04.new
    create_rss.createRssControll
    
  end
  
end