class StringController < ApplicationController
  CLASS_NAME = self.name
  require 'rss/1.0'
  require 'rss/2.0'
  require 'open-uri'

  def show
    aplog.debug("START #{CLASS_NAME}#show")
    url = params[:url]
    rss = RSS::Parser.parse(open(url).read, false)
    data = ""
    rss.items.each do |item|
      data << item.title + ";\r"
    end
    send_data(data, :type=>"text/html", :disposition=>"inline")
    aplog.debug("END   #{CLASS_NAME}#show")
  end
end
