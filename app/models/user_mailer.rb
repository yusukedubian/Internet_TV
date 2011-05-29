class UserMailer < ActionMailer::Base
  CLASS_NAME = self.name
  cattr_accessor :aplog
  @@aplog ||= SystemSettings::APL_LOGGER
  require "net/pop"
  
  def signup_notification(user)
    aplog.debug("START #{CLASS_NAME}#signup_notification")
    setup_email(user)
    @subject    += _('アカウントのアクティベートについて。')
    @body[:url]  = SystemSettings::HOST_NAME + "activate/#{user.activation_code}"
    aplog.debug("END   #{CLASS_NAME}#signup_notification")
  end
  
  def activation(user)
    aplog.debug("START #{CLASS_NAME}#activation")
    setup_email(user)
    @subject    += _('アクティベートされました。')
    @body[:url]  = SystemSettings::HOST_NAME
    aplog.debug("END   #{CLASS_NAME}#activation")
  end
  
  def change_password_notification(user)
    aplog.debug("START #{CLASS_NAME}#change_password_notification")
    setup_email(user)
    @subject    += _('パスワードを変更してください。')
    @body[:url]  = SystemSettings::HOST_NAME + "activate/#{user.activation_code}"
    aplog.debug("END   #{CLASS_NAME}#change_password_notification")
  end

  protected
    def setup_email(user)
      aplog.debug("START #{CLASS_NAME}#setup_email")
      Net::POP3.auth_only("mail.vasdaqj.jp", "110", "vinfo@vasdaqj.jp","vasdaqtv99")

      @recipients  = "#{user.email}"
      @from        = "vinfo@vasdaqj.jp"
      @subject     = _("[VASDAQ.TVからのお知らせ] ")
      @sent_on     = Time.now
      @body[:user] = user
      aplog.debug("END   #{CLASS_NAME}#setup_email")
    end
end
