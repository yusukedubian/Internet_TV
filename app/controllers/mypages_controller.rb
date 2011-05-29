class MypagesController < ApplicationController
  CLASS_NAME = self.name
  before_filter :login_required
  require 'will_paginate'

  def index
    aplog.debug("START #{CLASS_NAME}#index")
    @mypages = current_user.mypages.find(:all, :include => {:channel => :user}, :order => "created_at")
    aplog.debug("END   #{CLASS_NAME}#index")
  end
  
  
  def search
    aplog.debug("START #{CLASS_NAME}#search")
    if params["search_condition"].blank?
      @channels = Channel.paginate(:page => params[:page],
                                   :include => [:pages,:mypages],
                                   :conditions => {:public_flag => 1}, 
                                   :order => "updated_at asc",
                                   :per_page => 10)
    else
      @channels = Channel.paginate(:page => params[:page],
                                   :include => [:pages,:mypages],
                                   :conditions => ["public_flag = ? and ( name LIKE ? or description LIKE ? or link_info LIKE ? or other_info LIKE ? )", 
                                                   "1",
                                                   "%"+params["search_condition"]+"%",
                                                   "%"+params["search_condition"]+"%",
                                                   "%"+params["search_condition"]+"%",
                                                   "%"+params["search_condition"]+"%"],
                                   :order => "updated_at asc",
                                   :per_page => 10)
    end
    aplog.debug("END   #{CLASS_NAME}#search")
  end
  
  def edit
    aplog.debug("START #{CLASS_NAME}#edit")
    @mypage = Mypage.new
    aplog.debug("END   #{CLASS_NAME}#edit")
  end
  
  def create
    aplog.debug("START #{CLASS_NAME}#create")
    prmMypage = params["mypage"]
    if current_user.mypages.count >= 20
      notice("MSG_0x0000000B")
    elsif !(current_user.mypages.find_by_channel_id(prmMypage["channel_id"]))
      newMypage = Mypage.new(
        :channel_id => prmMypage["channel_id"],
        :user_id => current_user
      )
      current_user.mypages << newMypage
      current_user.save
      notice("MSG_0x0000000C")
    end
    redirect_to search_mypages_path(:search_condition => params["search_condition"])
    aplog.debug("END   #{CLASS_NAME}#create")
  end
  
  def update
    aplog.debug("START #{CLASS_NAME}#update")
    aplog.debug("END   #{CLASS_NAME}#update")
  end
  
  def show
    aplog.debug("START #{CLASS_NAME}#show")
    @mypage = current_user.mypages.find(params[:id])
    aplog.debug("END   #{CLASS_NAME}#show")
  end
  
  def delete_confirm
    aplog.debug("START #{CLASS_NAME}#delete_confirm")
    @mypage = current_user.mypages.find(params[:id])
    aplog.debug("END   #{CLASS_NAME}#delete_confirm")
  end
  
  def destroy
    aplog.debug("START #{CLASS_NAME}#destroy")
    flg = current_user.mypages.find(:first, params[:id])
    if flg
      Mypage.delete(params[:id])
      redirect_to mypages_path
    else
      redirect_to mypages_path
    end
    aplog.debug("END   #{CLASS_NAME}#destroy")
  end
end
