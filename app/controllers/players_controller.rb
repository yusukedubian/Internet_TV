class PlayersController < ApplicationController
  CLASS_NAME = self.name
  require 'will_paginate'
  include Validate
  # GET /players
  # GET /players.xml
  def index
    aplog.debug("START #{CLASS_NAME}#index")
    @players = Player.paginate(:all, :order=> "player_no asc",:page=>params[:page], :per_page=>10)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @players }
    end
    aplog.debug("END   #{CLASS_NAME}#index")
  end

  # GET /players/1
  # GET /players/1.xml
  def show
    aplog.debug("START #{CLASS_NAME}#show")
    @player = Player.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @player }
    end
    aplog.debug("END   #{CLASS_NAME}#show")
  end

  # GET /players/new
  # GET /players/new.xml
  def new
    aplog.debug("START #{CLASS_NAME}#new")
    @player = Player.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @player }
    end
    aplog.debug("END   #{CLASS_NAME}#new")
  end

  # GET /players/1/edit
  def edit
    aplog.debug("START #{CLASS_NAME}#edit")
    @player = Player.find(params[:id])
    aplog.debug("END   #{CLASS_NAME}#edit")
  end

  # POST /players
  # POST /players.xml
  def create
    aplog.debug("START #{CLASS_NAME}#create")
    begin
    raise "ERR_0x01010501" if Player.count(:conditions =>["player_no = ?", params[:player_id]]) != 0
    @player = Player.new(params[:player])
    respond_to do |format|
      if @player.save
        notice("MSG_0x00000014")
        format.html { redirect_to(@player) }
        format.xml  { render :xml => @player, :status => :created, :location => @player }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @player.errors, :status => :unprocessable_entity }
      end
    end
    rescue => e
      alert(e)
      redirect_to :action => :index
    end
    aplog.debug("END   #{CLASS_NAME}#create")
  end

  # PUT /players/1
  # PUT /players/1.xml
  def update
    aplog.debug("START #{CLASS_NAME}#update")
    begin
      raise "ERR_0x01010501" if Player.count(:conditions =>["player_no = ?", params[:player_id]]) != 0
      @players = Player.find(params[:id])
      respond_to do |format|
        if @players.update_attributes(params[:player])
          notice("MSG_0x00000014")
          format.html { redirect_to(@players) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @players.errors, :status => :unprocessable_entity }
        end
      end
    rescue => e
      alert(e)
    end
    aplog.debug("END   #{CLASS_NAME}#update")
  end

  def disable
    aplog.debug("START #{CLASS_NAME}#disable")
    @player = Player.find(params[:id])
    if @player.contents(:all).size > 0
      alert("ERR_0x01010502")
      redirect_to :action => 'index'
      return
    end
    
    if @player.update_attribute(:del_flg, true)
      notice("MSG_0x00000014")
    else
      alert("ERR_0x01010503")
    end
    redirect_to :action => 'index'
    aplog.debug("END   #{CLASS_NAME}#disable")
  end
  
  def enable
    aplog.debug("START #{CLASS_NAME}#enable")
    @player = Player.find(params[:id])
    if @player.update_attribute(:del_flg, false)
            notice("MSG_0x00000014")
    else
      alert("ERR_0x01010503")
    end
    redirect_to :action => 'index'
    aplog.debug("END   #{CLASS_NAME}#enable")
  end

  # DELETE /players/1
  # DELETE /players/1.xml
  def destroy
    aplog.debug("START #{CLASS_NAME}#destroy")
    @players = Player.find(params[:id])
    @players.destroy

    respond_to do |format|
      format.html { redirect_to(players_url) }
      format.xml  { head :ok }
    end
    aplog.debug("END   #{CLASS_NAME}#destroy")
  end 
end
