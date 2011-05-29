class IndexMessagesController < ApplicationController
  CLASS_NAME = self.name
  require 'will_paginate'
  include Validate
  # GET /index_messages
  # GET /index_messages.xml
  def index
    aplog.debug("START #{CLASS_NAME}#index")
    @index_messages = IndexMessage.paginate(:all, :order=>"del_flg asc,end_date < UTC_TIMESTAMP() and no_end_flg = false asc,
                                               start_date desc, start_date <  UTC_TIMESTAMP() asc
                                               ",
                                     :page=>params[:page], :per_page=>10)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @index_messages }
    end
    aplog.debug("END   #{CLASS_NAME}#index")
  end

  
  # GET /index_messages/1
  # GET /index_messages/1.xml
  def show
    aplog.debug("START #{CLASS_NAME}#show")
    @index_message = IndexMessage.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @index_message }
    end
    aplog.debug("END   #{CLASS_NAME}#show")
  end

  # GET /index_messages/new
  # GET /index_messages/new.xml
  def new
    aplog.debug("START #{CLASS_NAME}#new")
    @index_message = IndexMessage.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @index_message }
    end
    aplog.debug("END   #{CLASS_NAME}#new")
  end

  # GET /index_messages/1/edit
  def edit
   aplog.debug("START #{CLASS_NAME}#edit")
   @index_message = IndexMessage.find(params[:id])
   aplog.debug("START #{CLASS_NAME}#edit")
  end

  # POST /index_messages
  # POST /index_messages.xml
  def create
    aplog.debug("START #{CLASS_NAME}#create")
    begin
      validate_check
      @index_message = IndexMessage.new(params[:index_message])
      respond_to do |format|
        if @index_message.save
          notice("MSG_0x00000014")
          format.html { redirect_to(@index_message) }
          format.xml  { render :xml => @index_message, :status => :created, :location => @index_message }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @index_message.errors, :status => :unprocessable_entity }
        end
      end
    rescue => e
      alert(e)
      redirect_to :action=> :new
    end
    aplog.debug("START #{CLASS_NAME}#create")
  end

  # PUT /index_messages/1
  # PUT /index_messages/1.xml
  def update
    aplog.debug("START #{CLASS_NAME}#update")
    begin
      validate_check
      @index_messages = IndexMessage.find(params[:id])
      respond_to do |format|
        if @index_messages.update_attributes(params[:index_message])
          notice("MSG_0x00000014")
          format.html { redirect_to(@index_messages) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @index_messages.errors, :status => :unprocessable_entity }
        end
      end
    rescue => e
      alert(e)
      redirect_to :action=> :edit
    end
    aplog.debug("END   #{CLASS_NAME}#update")
  end

  def disable
    aplog.debug("START #{CLASS_NAME}#disable")
    @index_message = IndexMessage.find(params[:id])    
    if @index_message.update_attribute(:del_flg, true)
      notice("MSG_0x00000008")
    else
      alert("ERR_0x010101")
    end
    redirect_to :action => 'index'
    aplog.debug("END   #{CLASS_NAME}#disable")
  end
  
  def enable
    aplog.debug("START #{CLASS_NAME}#enable")
    @index_message = IndexMessage.find(params[:id])
    if @index_message.update_attribute(:del_flg, false)
      notice("MSG_0x00000008")
    else
      alert("ERR_0x010101")
    end
      redirect_to :action => 'index'
      aplog.debug("END   #{CLASS_NAME}#enable")
  end

  # DELETE /index_messages/1
  # DELETE /index_messages/1.xml
  def destroy
    aplog.debug("START #{CLASS_NAME}#destroy")
    @index_messages = IndexMessage.find(params[:id])
    @index_messages.destroy

    respond_to do |format|
      format.html { redirect_to(index_messages_url) }
      format.xml  { head :ok }
    end
    aplog.debug("END   #{CLASS_NAME}#destroy")
  end
  
  private
  def validate_check
    aplog.debug("START #{CLASS_NAME}#validate_check")
    message = params["index_message"]
    raise "ERR_0x01010401" if message["body"].blank?
    raise "ERR_0x01010402" if check_length(message["body"], 200, Compare::MORE_THAN)
    s_time = Time.mktime(message["start_date(1i)"],message["start_date(2i)"],
                        message["start_date(3i)"],message["start_date(4i)"],
                        message["start_date(5i)"])
    e_time = Time.mktime(message["end_date(1i)"],message["end_date(2i)"],
                        message["end_date(3i)"],message["end_date(4i)"],
                        message["end_date(5i)"])
    if !(params["index_message"]["no_end_flg"] && (s_time < e_time))
      raise "ERR_0x01010403"
    end
    aplog.debug("END   #{CLASS_NAME}#validate_check")
  end
  
end
