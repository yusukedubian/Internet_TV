class PermissionsController < ApplicationController
  CLASS_NAME = self.name
  before_filter :check_administrator_role
  
  def index
    aplog.debug("START #{CLASS_NAME}#index")
    @user = User.find(params[:user_id])
    @all_roles = Role.find(:all)
    aplog.debug("END   #{CLASS_NAME}#index")
  end
  
  def update
    aplog.debug("START #{CLASS_NAME}#update")
    @user = User.find(params[:user_id])
    @role = Role.find(params[:id])
    if @user.has_role?(@role.name)
      @user.roles.delete(@role)
    else
    @user.roles << @role
  end
    redirect_to :action => 'index', :user_id => params[:user_id]
    aplog.debug("END   #{CLASS_NAME}#update")
  end
end
