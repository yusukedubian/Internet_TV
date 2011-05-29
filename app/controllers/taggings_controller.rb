class TaggingsController < ApplicationController
  CLASS_NAME = self.name
  before_filter :login_required => :update
  def index
    aplog.debug("START #{CLASS_NAME}#index")
    Channel.find_tagged_with(:all, :conditions=> ["user_id is null"])
    aplog.debug("END   #{CLASS_NAME}#index")
  end
  
  def show
    aplog.debug("START #{CLASS_NAME}#show")
    @channels_tag = Channel.find_tagged_with(params[:id], :conditions=> ["user_id is null"])
    aplog.debug("END   #{CLASS_NAME}#show")
  end

  def update
    aplog.debug("START #{CLASS_NAME}#update")
    arr =[]
    params[:tagging].each{|key, value|
      arr << value
    }
    obj = eval(params[:class] + ".find(params[:id])")
    obj.tag_list = arr
    obj.save!
    Tag.destroy_unused = true
    redirect_to :controller => params[:class] + "s"
    aplog.debug("END   #{CLASS_NAME}#update")
  end
end
