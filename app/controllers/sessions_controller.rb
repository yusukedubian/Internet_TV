# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  CLASS_NAME = self.name
  # Be sure to include AuthenticationSystem in Application Controller instead
#  include AuthenticatedSystem
  before_filter :login_required, :only => :destroy
  before_filter :not_logged_in_required, :only => [:new, :create]

  # render new.rhtml
  def new
    aplog.debug("START #{CLASS_NAME}#new")
    aplog.debug("END   #{CLASS_NAME}#new")
  end

  def create
    aplog.debug("START #{CLASS_NAME}#create")
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      notice("MSG_0x00000001")
    else
      alert("ERR_0x01010201")
      sleep 2
      render :action => 'new'
    end
    aplog.debug("END   #{CLASS_NAME}#create")
  end

  def destroy
    aplog.debug("START #{CLASS_NAME}#destroy")
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    notice("MSG_0x00000002")
    redirect_back_or_default('/')
    aplog.debug("END   #{CLASS_NAME}#destroy")
  end
end
