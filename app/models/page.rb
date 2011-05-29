class Page < ActiveRecord::Base
  CLASS_NAME = self.name
  cattr_accessor :aplog
  @@aplog ||= SystemSettings::APL_LOGGER
  include Validate
  has_many :contents, :dependent => :destroy
  belongs_to :channel
  
  def before_update
    aplog.debug("START #{CLASS_NAME}#before_update")
    check_switchtime
    aplog.debug("END   #{CLASS_NAME}#before_update")
  end
  
  def after_destroy
    aplog.debug("START #{CLASS_NAME}#after_destroy")
    uid = self.channel.user.id.to_s
    divkey = (uid.to_i/300).to_s
    channel_no = self.channel.channel_no.to_s
    page_no = self.page_no.to_s
    path = "./users_contents/" << divkey << "/" << uid << "/" << channel_no << "/" << page_no
    FileUtils.rm_r(path) if FileTest.exist?(path)
    aplog.debug("END   #{CLASS_NAME}#after_destroy")
  end
  
  def check_switchtime
    aplog.debug("START #{CLASS_NAME}#check_switchtime")
    if !(switchtime >= 0 && switchtime <= 9999)
      raise _("ページ切替は0以上の4桁以内の数字で入力してください。")
    end
    aplog.debug("END   #{CLASS_NAME}#check_switchtime")
  end
end
