class PlayerInfosController < ApplicationController
  CLASS_NAME = self.name
  #before_filter :login_required
  before_filter :not_logged_in_required, :only => [:new, :create]
  before_filter :login_required, :only => [:show, :edit, :update]

  
  def index
    aplog.debug("START #{CLASS_NAME}#index")
    aplog.debug("END   #{CLASS_NAME}#index")
  end
  
  def new
    aplog.debug("START #{CLASS_NAME}#new")
    aplog.debug("END   #{CLASS_NAME}#new")
  end
  
  def show
    aplog.debug("START #{CLASS_NAME}#show")
    company_params = Contract.find(:all,:conditions=>["id=?",params[:id]])
    company_params.each{|company_param|
      @company_code = company_param.contract_code
      @company_name = company_param.company_name
    }
    records = PlayerAccessAuthority.find(:all,:conditions=>["contract_id=?",params[:id]],:order=>"id")
    @access_players = Array.new
    record_players = Array.new
    records.each{|record|
      record_players << record.player_id
      player_records = Player.find(:all,:conditions=>["id=?",record.player_id])
      player_records.each{|player_record|
        @access_players << player_record.name
      }
    }
    aplog.debug("END   #{CLASS_NAME}#show")
  end
  
  def edit
    aplog.debug("START #{CLASS_NAME}#edit")
    company_params = Contract.find(:all,:conditions=>["id=?",params[:id]])
    company_params.each{|company_param|
      @company_code = company_param.contract_code
      @company_name = company_param.company_name
    }
    records = PlayerAccessAuthority.find(:all,:conditions=>["contract_id=?",params[:id]],:order=>"id")
    @access_players = Array.new
    record_players = Array.new
    records.each{|record|
      record_players << record.player_id
      player_records = Player.find(:all,:conditions=>["id=?",record.player_id])
      player_records.each{|player_record|
        @access_players << player_record.name
      }
    }
    
    players = Player.find(:all,:order=>"player_no")
    @offset_players_id = Array.new
    players.each{|player|
      @offset_players_id << player.id
    }
    record_players.each{|record_player|
      @offset_players_id.delete(record_player)
    }
    @offset_players_name = Array.new
    @offset_players_id.each{|player_id|
      player_records = Player.find(:all,:conditions=>["id=?",player_id])
      player_records.each{|player_record|
        @offset_players_name << player_record.name
      }
    }
    aplog.debug("END   #{CLASS_NAME}#edit")
  end
  
  def update
    aplog.debug("START #{CLASS_NAME}#update")
    delete_players = PlayerAccessAuthority.find(:all,:conditions=>["contract_id=?",params[:id]])
    delete_players.each{|delete_player|
      delete_player.destroy
    }
    params_order = params[:order]
    set_players = params_order.split(",")
    players_id = Array.new
    set_players.each{|set_player|
      player_records = Player.find(:all,:conditions=>["name=?",set_player])
      player_records.each{|player_record|
        players_id << player_record.id
      }
    }
    players_id.each{|player_id|
      set_players = PlayerAccessAuthority.new
      set_players.contract_id = params[:id]
      set_players.player_id = player_id
      set_players.save
    }
    redirect_to edit_player_info_path(params[:id])
    aplog.debug("END   #{CLASS_NAME}#update")
  end
end