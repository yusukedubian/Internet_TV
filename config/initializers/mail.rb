# ---------- config/initializers/mail.rb ----------

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => "mail.vasdaqj.jp",
  :port => 587,
  :domain => "www.example-domain.com",
  :authentication => :login,
#  :user_name => "xxxxxxx@xxxxx.jp", #=>メールアドレス
  :authentication => :plain
  #:password => "パスワード"
}
