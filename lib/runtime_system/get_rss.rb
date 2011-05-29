require "open-uri"
require 'net/http'
require 'rss'
require 'fileutils'
module RuntimeSystem
  class GetRss
    def execute(content, current_user)
      return if !config = content.runtime_config_rss
      rss = open(config.rss_site_url)
      if !rss
        rss.puts = "url is not valid"
      end
      FileUtils.mkdir_p(RuntimeSystem.getSaveDir(content))
      File.open(RuntimeSystem.getSaveDir(content) +content.id.to_s + ".xml", "w"){|file|
        file.write(rss.read)
      }
    end
  end  
end