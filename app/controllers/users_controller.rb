class UsersController < ApplicationController
  CLASS_NAME = self.name
  before_filter :not_logged_in_required, :only => [:new, :create] 
  before_filter :login_required, :only => [:show, :edit, :update, :settings]
  before_filter :check_administrator_role, :only => [:index, :destroy, :enable]

  def index
    aplog.debug("START #{CLASS_NAME}#index")
    @user = User.find(:all)
    aplog.debug("END   #{CLASS_NAME}#index")
  end
  
  # GET /users/1
  # GET /users/1.xml
  def show
    aplog.debug("START #{CLASS_NAME}#show")
    @user = current_user
    aplog.debug("END   #{CLASS_NAME}#show")
  end
  
  def search
    aplog.debug("START #{CLASS_NAME}#search")
    @user = search_user params
    render :action => 'index'
    aplog.debug("END   #{CLASS_NAME}#search")
  end
  
  # render new.rhtml
  def new
    aplog.debug("START #{CLASS_NAME}#new")
    @user = User.new
    aplog.debug("END   #{CLASS_NAME}#new")
  end

  def create
    aplog.debug("START #{CLASS_NAME}#create")
    cookies.delete :auth_token
    @user = User.find(:first, :conditions => ["login=? or email=?", params[:user][:login], params[:user][:email]])
    if !@user.blank? && !@user.activation_code.blank?
      @user.attributes = params[:user]
      @user.save!
      # ここでsignup_notification Mailを送信
      UserMailer.deliver_signup_notification(@user)
      notice("MSG_0x00000011")
      redirect_to login_path
    else
      @user = User.new(params[:user])
      role = Role.find(2)
      permission = Permission.new
      permission.role = role
      permission.user = @user
      permission.save!
      @user.save!
  
      # YAML  DBフォームのサンプル作成
      YamlDbForm.make_sample_form(@user, _("サンプル"),_("サンプルです。"), "#{YAML_DB_FORM_ROOT}/sample_form_01.yml")
      YamlDbForm.make_sample_form(@user, _("業務報告"),_("業務報告用の入力フォームです。"), "#{YAML_DB_FORM_ROOT}/sample_form_03.yml")
      YamlDbForm.make_sample_form(@user, _("TODOリスト"),_("TODOリスト用の入力フォームです。"), "#{YAML_DB_FORM_ROOT}/sample_form_04.yml")
      YamlDbForm.make_sample_form(@user, _("TVアンケート"),_("VASDAQ.TVアンケート用の入力フォームです。"), "#{YAML_DB_FORM_ROOT}/sample_form_05.yml")
      YamlDbForm.make_sample_form(@user, _("お問い合わせ"),_("お問い合わせ用の入力フォームです。"), "#{YAML_DB_FORM_ROOT}/sample_form_06.yml")
      
      # ここでsignup_notification Mailを送信
      UserMailer.deliver_signup_notification(@user)
      
      notice("MSG_0x00000011")
      redirect_to login_path
  #   rescue ActiveRecord::RecordInvalid
  #     alert("ERR_0x01010103")
  #     render :action => 'new'
  end
  aplog.debug("END   #{CLASS_NAME}#create")
  rescue =>e
    alert(e.message)
    render :action => 'new'
    aplog.debug("END   #{CLASS_NAME}#create")
  end

  def activate
    aplog.debug("START #{CLASS_NAME}#activate")
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if !self.current_user.nil?
      if logged_in? && !current_user.active?
        current_user.activate
        notice("MSG_0x00000012")
      end
      UserMailer.deliver_activation(self.current_user)
    end
    redirect_back_or_default('/')
    aplog.debug("END   #{CLASS_NAME}#activate")
  end
  

  def deactivate
    aplog.debug("START #{CLASS_NAME}#deactivate")
    if forget_user = User.find_by_email(params[:user][:email])
      forget_user.deactivate
    end
    notice("MSG_0x00000013")
    render :action => 'input_email_address'
    aplog.debug("END   #{CLASS_NAME}#deactivate")
  end
  
  def edit
    aplog.debug("START #{CLASS_NAME}#edit")
    check_administrator_role ? id = params[:id] : id = current_user.id
    @user = User.find(id)
    @role = Role.find(:all)
    aplog.debug("END   #{CLASS_NAME}#edit")
  end

   def update
     aplog.debug("START #{CLASS_NAME}#update")
     begin
       user = params[:user]
       if user.has_key?("password") && user["password"].blank?
         raise "ERR_0x01010104"
       end
       
       if user.has_key?("user_name") && user["user_name"].blank?
         raise "ERR_0x01010105"
       end
       
       if user.has_key?("email") && user["email"].blank?
         raise "ERR_0x01010106"
       end
       
       @user = User.find(current_user)
        if !@user.update_attributes(user)
          if user.has_key?("password")
            raise "ERR_0x01010107"
          end
          
          if user.has_key?("user_name")
            raise "ERR_0x01010108"
          end
          
          if user.has_key?("email")
            raise "ERR_0x01010109"
          end
        end
      notice("MSG_0x00000014")
     rescue Exception => e
       alert(e.message)
     end

    @user_property = current_user.user_property
    redirect_to :controller => 'user_property', :action => 'edit', :id => params[:id]
    aplog.debug("END   #{CLASS_NAME}#update")
  end

  def destroy
    aplog.debug("START #{CLASS_NAME}#destroy")
    @user = User.find(params[:id])
    if @user.update_attribute(:enabled, false)
      flash[:notice] = _("%{user_login} disabled") % {:user_login=>@user.login}
    else
      flash[:error] = _("There was a problem disabling this user.")
      flash[:error] = _(Message.error("Err_0x010101"))
    end
    redirect_to :action => 'index'
    aplog.debug("END   #{CLASS_NAME}#destroy")
  end
  
  def enable
    aplog.debug("START #{CLASS_NAME}#enable")
    @user = User.find(params[:id])
    if @user.update_attribute(:enabled, true)
      flash[:notice] = _("%{user_login} enabled") % {:user_login=>@user.login}
    else
      flash[:error] = _("There was a problem enabling this user.")
    end
    redirect_to :action => 'index'
    aplog.debug("END   #{CLASS_NAME}#enable")
  end

  def delete_user
    aplog.debug("START #{CLASS_NAME}#delete_user")
    if User.find(params[:id])
      User.destroy(params[:id])
      divkey = (params[:id]/300).to_i
      uid = params[:id]
      path = "./yaml_db_forms/" << divkey << "/" << uid
      FileUtils.rm_r(path) if FileTest.exist?(path)
    end
    redirect_to :action => 'index'
    aplog.debug("END   #{CLASS_NAME}#delete_user")
  end
end
