
class WelcomeController < ApplicationController
  CLASS_NAME = self.name
  
  def index
    aplog.debug("START #{CLASS_NAME}#index")
    @message = IndexMessage.find(:all, :conditions=> "start_date < UTC_TIMESTAMP() and
                                                  (end_date > UTC_TIMESTAMP() or
                                                  no_end_flg = true) and
                                                  del_flg = false",
                                            :order=> "start_date desc")
    
    @message
    aplog.debug("END   #{CLASS_NAME}#index")
  end
end
