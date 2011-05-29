class UserProperty < ActiveRecord::Base
  CLASS_NAME = self.name
  cattr_accessor :aplog
  @@aplog ||= SystemSettings::APL_LOGGER
  include Validate
  belongs_to :user
  
#  validates_length_of :auth_password, :within => 6..40

  validates_length_of :email, :within => 0..256, :if => :email_check
  validates_length_of :domain, :within => 0..255, :if => :domain_check
  validates_length_of :smtp_address, :within => 0..255, :if => :smtp_address_check
  validates_length_of :pop3_address, :within => 0..255, :if => :pop3_address_check
  validates_length_of :smtp_port, :within => 0..5, :if => :smtp_port_check
  validates_length_of :pop3_port, :within => 0..5, :if => :pop3_port_check
#  validates_numericality_of :authentication, :within => 1..4
  validates_length_of :auth_user_name, :within => 0..64, :if => :auth_user_name_check
  validates_length_of :auth_password, :within => 0..64, :if => :auth_password_check

  def email_check
    aplog.debug("START #{CLASS_NAME}#email_check")
    if !email.blank? && !is_mail_addr(email)
      raise "ERR_0x01011801"
    end
    aplog.debug("END   #{CLASS_NAME}#email_check")
  end

  def domain_check
    aplog.debug("START #{CLASS_NAME}#domain_check")
    if !domain.blank? && !is_half_char(domain)
      raise "ERR_0x01011802"
    end
    aplog.debug("END   #{CLASS_NAME}#domain_check")
  end

  def smtp_address_check
    aplog.debug("START #{CLASS_NAME}#smtp_address_check")
    if !smtp_address.blank? && !is_half_char(smtp_address)
      raise "ERR_0x01011803"
    end
    aplog.debug("END   #{CLASS_NAME}#smtp_address_check")
  end

  def pop3_address_check
    aplog.debug("START #{CLASS_NAME}#pop3_address_check")
    if !pop3_address.blank? && !is_half_char(pop3_address)
      raise "ERR_0x01011804"
    end
    aplog.debug("END   #{CLASS_NAME}#pop3_address_check")
  end

  def smtp_port_check
    aplog.debug("START #{CLASS_NAME}#smtp_port_check")
    if !smtp_port.blank?
      if (smtp_port =~ /[^0-9]+/)
        raise "ERR_0x01011805"
      end

      if !smtp_port.to_i.between?(0, 65535)
        raise "ERR_0x01011809"
      end
    end
    aplog.debug("END   #{CLASS_NAME}#smtp_port_check")
  end

  def pop3_port_check
    aplog.debug("START #{CLASS_NAME}#pop3_port_check")
    if !pop3_port.blank?
      if (pop3_port =~ /[^0-9]+/)
        raise "ERR_0x01011806"
      end

      if !pop3_port.to_i.between?(0, 65535)
        raise "ERR_0x0101180A"
      end
    end
    aplog.debug("END   #{CLASS_NAME}#pop3_port_check")
  end
  
  def auth_user_name_check
    aplog.debug("START #{CLASS_NAME}#auth_user_name_check")
    if !auth_user_name.blank? && !is_half_char(auth_user_name)
      raise "ERR_0x01011807"
    end
    aplog.debug("END   #{CLASS_NAME}#auth_user_name_check")
  end

  def auth_password_check
    aplog.debug("START #{CLASS_NAME}#auth_password_check")
    if !auth_password.blank? && !is_half_char(auth_password)
      raise "ERR_0x01011808"
    end
    aplog.debug("END   #{CLASS_NAME}#auth_password_checks")
  end
end
