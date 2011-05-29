class Channel < ActiveRecord::Base
  CLASS_NAME = self.name
  cattr_accessor :aplog
  @@aplog ||= SystemSettings::APL_LOGGER
  acts_as_taggable
  include Validate
  
  belongs_to :user
  belongs_to :channels_type
  has_many :pages, :dependent => :destroy
  has_many :mypages, :dependent => :destroy

  
  def before_save
    aplog.debug("START #{CLASS_NAME}#before_save")
    channel_no_check
    #width_check
    #height_check
    aplog.debug("END   #{CLASS_NAME}#before_save")
  end
  
  def after_destroy
    aplog.debug("START #{CLASS_NAME}#after_destroy")
    uid = self.user.id.to_s
    divkey = (uid.to_i/300).to_s
    channel_no = self.channel_no.to_s
    path = "./users_contents/" << divkey << "/" << uid << "/" << channel_no
    FileUtils.rm_r(path) if FileTest.exist?(path)
    aplog.debug("END   #{CLASS_NAME}#after_destroy")
  end
  
  def channel_no_check
    aplog.debug("START #{CLASS_NAME}#channel_no_check")
    if !(channel_no >= 1 && channel_no <= 12)
      raise _("チャンネルを新規作成することが出来ませんでした。")
    end
    aplog.debug("END   #{CLASS_NAME}#channel_no_check")
  end
=begin  
  def width_check
    if !(width >= 1 && width <= 999999)
      raise _("ページ幅は1px以上の6桁以内の数字で入力してください。")
    end
  end
  
  def height_check
    if !(height >= 1 && height <= 999999)
      raise _("ページ高さは1px以上の6桁以内の数字で入力してください。")
    end
  end
=end
end
