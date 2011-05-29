require 'net/pop'
class ForgotPasswordsController < ApplicationController
  CLASS_NAME = self.name
  def new
    aplog.debug("START #{CLASS_NAME}#new")
    @forgot_password = ForgotPassword.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @forgot_password }
    end
    aplog.debug("END   #{CLASS_NAME}#new")
  end

  def create
    aplog.debug("START #{CLASS_NAME}#create")
    if params["forgot_password"]["email"].blank?
      alert("メールアドレスが入力されていません。") 
    end
    @forgot_password = ForgotPassword.new(params[:forgot_password])
    @forgot_password.user = User.find_by_email(@forgot_password.email)
    
    respond_to do |format|
      if @forgot_password.save
        Net::POP3.auth_only('mail.vasdaqj.jp', 110, 'vinfo@vasdaqj.jp', 'vasdaqtv99')
        ForgotPasswordMailer.deliver_forgot_password(@forgot_password)
        flash[:notice] = "パスワードを再設定するためのURLを　 #{@forgot_password.email}　に送信しました。"
        format.html { redirect_to '/' }
        format.xml  { render :xml => @forgot_password, :status => :created, :location => @forgot_password }
      else
        # use a friendlier message than standard error on missing email address
        if @forgot_password.errors.on(:user)
          @forgot_password.errors.clear
          flash[:alert] = "入力されたメールアドレスが見つかりません。メールアドレスをご確認の上、再度入力してください。"
        end
        format.html { render :action => "new" }
        format.xml  { render :xml => @forgot_password.errors, :status => :unprocessable_entity }
      end
    end
    aplog.debug("END   #{CLASS_NAME}#create")
  end

  def reset
    aplog.debug("START #{CLASS_NAME}#reset")
    begin
      @user = ForgotPassword.find(:first, :conditions => ['reset_code = ? and expiration_date > ?', params[:reset_code], Time.now]).user
    rescue
      flash[:notice] = 'パスワード変更のURLが間違っているか、期限が切れています。'
      redirect_to(new_forgot_password_path)
    end    
  end

  def update_after_forgetting
    aplog.debug("START #{CLASS_NAME}#update_after_forgetting")
    @forgot_password = ForgotPassword.find_by_reset_code(params[:reset_code])
    @user = @forgot_password.user unless @forgot_password.nil?
    
    respond_to do |format|
      begin
      if @user.update_attributes(params[:user])
       @forgot_password.destroy
#        PasswordMailer.deliver_reset_password(@user)
        ForgotPasswordMailer.deliver_reset_password(@user)
        @user.activate
        flash[:notice] = "パスワードが再設定されました。"
        
        format.html { redirect_to login_path}
      else
        flash[:notice] = 'パスワードの再設定に失敗しました。再度設定をおこなってください。'
        format.html { render :action => :reset, :reset_code => params[:reset_code] }
      end
      Net::POP3.auth_only('mail.vasdaqj.jp', 110, 'vinfo@vasdaqj.jp', 'vasdaqtv99')
      rescue => e
        alert(e.to_s)
        format.html { render :action => :reset, :reset_code => params[:reset_code] }
      end
    end
    aplog.debug("END   #{CLASS_NAME}#edit")
  end
  
end
