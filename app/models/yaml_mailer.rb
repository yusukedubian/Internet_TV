class YamlMailer < ActionMailer::Base
  CLASS_NAME = self.name
  cattr_accessor :aplog
  @@aplog ||= SystemSettings::APL_LOGGER
  require 'net/pop'

  def send(mail_info, setting)
    aplog.debug("START #{CLASS_NAME}#send")
    from       setting["email"]
    recipients mail_info["to"]
    cc         mail_info["cc"]
    bcc        mail_info["bcc"]
    
    if mail_info["subject"].blank?
      subject    " "
    else
      subject    mail_info["subject"]
    end

    body       mail_info["body"]
    sent_on    Time.now    
    setup_email(setting)
    aplog.debug("END   #{CLASS_NAME}#send")
  end

  protected
    def setup_email(setting)
      aplog.debug("START #{CLASS_NAME}#setup_email")
      tmp = { :address => setting["smtp_address"],
            :port => setting["smtp_port"],
            :domain => setting["domain"]}

      case setting["authentication"]
        when "1"
          tmp[:authentication] = :plain
          tmp[:user_name] = setting["auth_user_name"]
          tmp[:password] = setting["auth_password"]
        when "2"
          tmp[:authentication] = :login
          tmp[:user_name] = setting["auth_user_name"]
          tmp[:password] = setting["auth_password"]
        when "3"
          tmp[:authentication] = :cram_md5
          tmp[:user_name] = setting["auth_user_name"]
          tmp[:password] = setting["auth_password"]
        else
          Net::POP3.auth_only(setting["pop3_address"], setting["pop3_port"],
                              setting["auth_user_name"], setting["auth_password"])
        end
     
      ActionMailer::Base.delivery_method = :smtp
      ActionMailer::Base.raise_delivery_errors = true
      ActionMailer::Base.smtp_settings = tmp
      aplog.debug("END   #{CLASS_NAME}#setup_email")
    end
end
