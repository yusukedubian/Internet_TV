class SearchEngineController < ApplicationController
  CLASS_NAME = self.name
  require 'will_paginate'
  def index
    aplog.debug("START #{CLASS_NAME}#index")
    if params["search_condition"].blank?
      @channels = Channel.paginate(:page => params[:page],
                                   :include => :pages,
                                   :conditions => {:public_flag => 1}, 
                                   :order => "updated_at asc",
                                   :per_page => 10)
    else
      @channels = Channel.paginate(:page => params[:page],
                                   :include => :pages,
                                   :conditions => ["public_flag = ? and ( name LIKE ? or description LIKE ? or link_info LIKE ? or other_info LIKE ? )", 
                                                   "1",
                                                   "%"+params["search_condition"]+"%",
                                                   "%"+params["search_condition"]+"%",
                                                   "%"+params["search_condition"]+"%",
                                                   "%"+params["search_condition"]+"%"],
                                   :order => "updated_at asc",
                                   :per_page => 10)
    end
    aplog.debug("START #{CLASS_NAME}#index")
  end
end
