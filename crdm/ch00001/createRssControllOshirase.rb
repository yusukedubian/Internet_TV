#!ruby -Ku
require 'rubygems'
require 'rss'
require 'fileutils'
require 'date'
require 'time'
require "yaml"
require "crdm/createRssDao"
class CreateRssControllOshirase
  def initialize
    @dao = CreateRssDao.new
    @rssElement = {}
    @channel = {}
  end
  
  def createRssControll
    begin
       getPeriod
       selectRss
       createRss
    rescue
      p $!
      p $@
    end
  end
  
  def createRss
    if !@rssElement.nil?
      channel = @rssElement["channel"]
      r_items = @rssElement["items"]
      rss = RSS::Maker.make("2.0") do | maker |
        maker.channel.title = channel["rssChannelTitle"] 
        maker.channel.link = " "
        maker.channel.description = " "
        maker.items.do_sort = true
        r_items.each{|obj|
          maker.items.new_item do |item|
            item.title = obj["title"]
            item.description = obj["description"]
            item.date = Time.parse(obj["date"])
        end
        }
      end
        FileUtils.mkdir_p("./public/category/ch0001/rss")
        File.open("./public/category/ch0001/rss/oshirase.xml", "wb"){|file|
          file.puts(rss)
        }
      end
  end
  
  def getPeriod
    timeE = Date.today
    timeS = timeE - 30

    @timeS = timeS.strftime("%Y%m%d")+ "000000"
    @timeE = timeE.strftime("%Y%m%d")+ "235900"
  end

  def selectRss
    channel = {}
    channel["rssChannelTitle"] = "お知らせ"
    channel["rssChannelDescriptsion"] = " "

    results = @dao.selectRssChannel("お知らせ",@timeS, @timeE)
    items = []
    results.each{|result|
      item = {}
      item["title"] = "お知らせ"
#      item["description"] =  result["BODY"]
      item["date"] = result["SEND_DATE"]
      body = YAML.load result["BODY"]
      if body["お知らせ"]
        item["description"] = body["お知らせ"] + "　　"
      else
        item["description"] =  "　　"
      end
      items << item 
    }
    
    if !channel.empty?
      @rssElement["channel"] = channel
      @rssElement["items"] = items
    else
      @rssElement = nil
    end
  end
end