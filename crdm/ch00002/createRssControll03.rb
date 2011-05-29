#!ruby -Ku
require 'rubygems'
require 'rss'
require 'fileutils'
require 'date'
require 'time'
require "yaml"
require "crdm/createRssDao"
class CreateRssControll03
  
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
            item.content_encoded = obj["description"]
            item.date = Time.parse(obj["date"])
        end
        }
      end
        FileUtils.mkdir_p("./public/category/ch0002/rss")
        File.open("./public/category/ch0002/rss/info03.xml", "wb"){|file|
          file.puts(rss)
        }
      end
  end
    
  def getPeriod
    timeE = Date.today
    timeS = timeE - 30
    @timeS = timeS.strftime("%Y%m%d")+ "000000"
    @timeE = timeE.strftime("%Y%m%d")+ "235959"
  end

  def selectRss
    channel = {}
    channel["rssChannelTitle"] = "お知らせ"
    channel["rssChannelDescriptsion"] = " "
    results = @dao.selectRssChannel("お知らせ03",@timeS, @timeE)
    items = []
    results.each{|result|
      item = {}
      item["title"] = result["SUBJECT"]
      item["date"] = result["SEND_DATE"]
      body = YAML.load(result["BODY"])
      item["description"] =  body["お知らせ"] + "   "
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