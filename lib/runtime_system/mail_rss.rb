require 'rubygems'
require 'rss'
require 'fileutils'
require 'date'
require 'time'


module RuntimeSystem
  class MailRss
    def execute(content, current_user)
      @content = content
      @current_user = current_user
      return if !@config = content.runtime_config_mail
      get_period
      select_rss
      create_rss     
    end
  
    def create_rss
      if !@rss_element.nil?
        channel = @rss_element["channel"]
        r_items = @rss_element["items"]
        rss = RSS::Maker.make("2.0") do | maker |
          maker.channel.title = channel["rss_channel_title"] 
          maker.channel.link = " "
          maker.channel.description = " "
          maker.items.do_sort = true
          r_items.each{|obj|
            maker.items.new_item do |item|
              item.title = obj["title"]
              item.content_encoded = obj["description"]
              item.date = obj["date"]
          end
          }
        end
          FileUtils.mkdir_p(RuntimeSystem.content_save_dir(@content))
          File.open(FileUtils.mkdir_p(RuntimeSystem.content_save_dir(@content))+ "/"+ @content.id.to_s  + ".xml", "w"){|file|
            file.puts(rss)
          }
        end
    end
    
    def get_period
      base_unit = @config.base_date_unit
      end_time = DateTime.now
      if base_unit == "Today"
        end_time
      elsif base_unit == "D"
        end_time = end_time - @config.base_date.to_i
      elsif base_unit == "W"
        end_time = end_time - @config.base_date.to_i*7
      elsif base_unit == "M"
        end_time = end_time << @config.base_date
      end
      extract_unit = @config.extract_period_unit
      if extract_unit == "Day"
        start_time = end_time - @config.extract_period
      elsif extract_unit == "Week"
        start_time = end_time - @config.extract_period*7
      elsif extract_unit == "Month"
        start_time = end_time << @config.extract_period
      end  
      
      @end_time = end_time
      @start_time = start_time
    end
  
    def select_rss
      @rss_element = {}
      channel = {}
      channel["rss_channel_title"] = @config.subject
      channel["rss_channel_descriptsion"] = ""
      results = @current_user.runtime_data_mails.find(:all, :conditions => ["subject = ? and send_date >= ? and send_date <= ?",@config.subject, @start_time, @end_time])
      items = []
      results.each{|result|
        item = {}
        begin
          yaml = YAML.load(result["body"])
          if yaml["title"] && yaml["body"]
            item["title"] = yaml["title"]
            item["description"] =  yaml["body"]
            item["date"] = result["send_date"]
            items << item
          end
        rescue
        
        end
      }
      
      if !channel.empty?
        @rss_element["channel"] = channel
        @rss_element["items"] = items
      else
        @rss_element = nil
      end
    end
  end
end
