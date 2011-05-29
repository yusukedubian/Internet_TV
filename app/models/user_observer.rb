# Users table 変更監視class
# ※このclassは現在使用されてません。使用する場合はenvironment.rb に
#　config.active_record.observers = :user_observer
# を宣言する必要があります。
class UserObserver < ActiveRecord::Observer
  CLASS_NAME = self.name
  cattr_accessor :aplog
  @@aplog ||= SystemSettings::APL_LOGGER
  
  def after_create(user)
    aplog.debug("START #{CLASS_NAME}#after_create")
    user.reload
    UserMailer.deliver_signup_notification(user)
    aplog.debug("END   #{CLASS_NAME}#after_create")
  end

  def after_save(user)
    aplog.debug("START #{CLASS_NAME}#after_save")
    user.reload
    return if user.recently_activated?.nil?
    UserMailer.deliver_activation(user) if user.recently_activated?
    UserMailer.deliver_change_password_notification(user) unless user.recently_activated?
    aplog.debug("END   #{CLASS_NAME}#after_save")
  end
end
