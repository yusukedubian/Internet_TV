class RemoteController < ApplicationController
  CLASS_NAME = self.name
  before_filter :login_required
  before_filter :find_channels
  def index
    aplog.debug("START #{CLASS_NAME}#index")
    if @page = @channel.pages.find(:first, :order=> "page_no")
      redirect_to channel_page_previews_path(@channel, @page)
    else
      alert("ERR_0x01020901")
      render root_path
    end
    aplog.debug("END   #{CLASS_NAME}#index")
  end
  
  private
  def find_channels
    aplog.debug("START #{CLASS_NAME}#find_channels")
    if @channel = current_user.channels.find(:first, :include => :pages, :conditions=> ["channels.channel_no = ?", params[:channel_no]])
    else
      alert("ERR_0x01020902")
      redirect_to root_path
    end
    aplog.debug("END   #{CLASS_NAME}#find_channels")
  end
end
