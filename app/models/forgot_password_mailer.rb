class ForgotPasswordMailer < ActionMailer::Base
  CLASS_NAME = self.name
  cattr_accessor :aplog
  @@aplog ||= SystemSettings::APL_LOGGER

  def forgot_password(password)
    aplog.debug("START #{CLASS_NAME}#forgot_password")
    setup_email(password.user)
    @subject    += '下記URLからパスワードの再設定をお願い致します。'
    @body[:url]  = SystemSettings::HOST_NAME + "change_password/#{password.reset_code}"
    aplog.debug("END   #{CLASS_NAME}#forgot_password")
  end

  def reset_password(user)
    aplog.debug("START #{CLASS_NAME}#reset_password")
    setup_email(user)
    @subject    += 'パスワードはリセットされました。'
    aplog.debug("END   #{CLASS_NAME}#reset_password")
  end

  protected
    def setup_email(user)
      aplog.debug("START #{CLASS_NAME}#setup_email")
      @recipients  = "#{user.email}"
      @from        = "vinfo@vasdaqj.jp"
      @subject     = "[VASDAQ.TVからのお知らせ] "
      @sent_on     = Time.now
      @body[:user] = user
      aplog.debug("END   #{CLASS_NAME}#setup_email")
    end
end