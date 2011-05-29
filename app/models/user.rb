require 'digest/sha1'
class User < ActiveRecord::Base
  CLASS_NAME = self.name
  include Validate
  cattr_accessor :aplog
  @@aplog ||= SystemSettings::APL_LOGGER
    
  N_("User|login")
  N_("User|email")
  N_("User|user_name")
  N_("User|Password")
  N_("User|Password confirmation")
  N_("User|Old password")
  N_("%{fn} doesn't match confirmation")
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login,                      :if => :login_check
  validates_presence_of     :email,                      :if => :email_check
  validates_presence_of     :user_name
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 6..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?, :if => :password_check
  validates_length_of       :login,    :within => 3..40, :if => :login_length_check
  validates_length_of       :email,    :within => 3..100, :if => :email_length_check
  validates_length_of       :user_name,:within => 1..20, :if => :user_name_length_check
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  
  has_many :yaml_db_forms, :dependent => :destroy
  has_one :user_property, :dependent => :destroy
  has_many :channels, :dependent => :destroy
  has_many :permissions, :dependent => :destroy
  has_many :roles, :through => :permissions
  has_many :mypages, :dependent => :destroy
  has_many :runtime_data_mails, :dependent => :destroy
  
  belongs_to :contract
  
  before_save :encrypt_password
  before_create :make_activation_code 
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :delflg, :user_name


  def login_check
    aplog.debug("START #{CLASS_NAME}#login_check")
    if !is_half_char(login)
      raise "ERR_0x01010101"
    end
    aplog.debug("END   #{CLASS_NAME}#login_check")
  end

  def login_length_check
    aplog.debug("START #{CLASS_NAME}#login_length_check")
    if login.size < 3 || login.size > 40
      raise "ERR_0x01010111"
    end
    aplog.debug("END   #{CLASS_NAME}#login_length_check")
  end
  
  def email_check
    aplog.debug("START #{CLASS_NAME}#login_length_check")
    if !email.blank? && !is_mail_addr(email)
      raise "ERR_0x01010102"
    end
    aplog.debug("END   #{CLASS_NAME}#login_length_check")
  end
  
  def email_length_check
    aplog.debug("START #{CLASS_NAME}#email_length_check")
    raise "ERR_0x01010112" if email.size < 3 || email.size > 40
    aplog.debug("END   #{CLASS_NAME}#email_length_check")
  end
  
  def user_name_length_check
    aplog.debug("START #{CLASS_NAME}#user_name_length_check")
    raise "ERR_0x01010113" if user_name.size < 1 || user_name.size > 20
    aplog.debug("END   #{CLASS_NAME}#user_name_length_check")
  end
  
  def password_check
    aplog.debug("START #{CLASS_NAME}#password_check")
    if password
      if !is_half_char(password)
        raise "ERR_0x0101010A"
      elsif !check_length(password, 6, Compare::MORE_THAN)
        raise "ERR_0x0101010B"
      elsif !check_length(password, 40, Compare::LESS_THAN)
        raise "ERR_0x0101010C"
      elsif password != password_confirmation
        raise "ERR_0x0101010D"
      end
    end
    aplog.debug("END   #{CLASS_NAME}#password_check")
  end

  # Activates the user in the database.
  def activate
    aplog.debug("START #{CLASS_NAME}#activate")
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
    aplog.debug("END   #{CLASS_NAME}#activate")
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  def deactivate
    @activated = false
    self.activated_at = nil
    self.make_activation_code
    
    # 引数をfalseにすると、validationが無効になる
    # save(perform_validation=true)
    save(false)
  end

  def has_role?(rolename)
    self.roles.find_by_name(rolename) ? true : false
  end

  def self.cleanup
    User.delete_all(["enabled = ? and updated_at < ?",false,1.days.ago])
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
end
