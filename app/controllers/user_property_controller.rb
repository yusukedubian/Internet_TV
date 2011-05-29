class UserPropertyController < ApplicationController
  CLASS_NAME = self.name
  def edit
    aplog.debug("START #{CLASS_NAME}#edit")
    @user = current_user
    @user_property = (current_user.user_property || {"smtp_port" => "25", "pop3_port" => "110"})
    aplog.debug("END   #{CLASS_NAME}#edit")
  end
  
  def update
    aplog.debug("START #{CLASS_NAME}#update")
    begin
      user_property = (current_user.user_property ||= UserProperty.new)
      user_property.attributes = params["user_property"]
      if !user_property.save
        alert("ERR_0x01020702")
      end
      notice("MSG_0x00000008")
    rescue => e
      alert(e.message)
    end
    @user = current_user
    @user_property = current_user.user_property.attributes
    @user_property.merge params["user_property"]
    begin
      user = params["user_property"]
      if user.key?('google_key')
        redirect_to :controller => 'user_property', :id => params[:id], :action => 'edit' ,:anchor=>'page3'
      elsif user.key?("smtp_address") 
        redirect_to :controller => 'user_property', :id => params[:id], :action => 'edit' ,:anchor=>'page2'
      else
        render :action => 'edit' , :id => params[:id]
      end
    rescue Exception => e
      alert(e.message)
    end
    aplog.debug("END   #{CLASS_NAME}#update")
  end
end