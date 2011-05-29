require "./crdm/ch00001/createRssControll"
require "./crdm/ch00001/createRssControllOshirase"



class Ch0001
  def ch0001
    create_rss = CreateRssControll.new
    create_rss_ochirase = CreateRssControllOshirase.new
    create_rss.createRssControll
    create_rss_ochirase.createRssControll
    
  end
  
end