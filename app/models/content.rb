class Content < ActiveRecord::Base
  CLASS_NAME = self.name
  cattr_accessor :aplog
  @@aplog ||= SystemSettings::APL_LOGGER
  belongs_to :player
  belongs_to :page
  has_many :contents_propertiess, :dependent => :destroy
  has_one :runtime_config_mail, :dependent => :destroy
  has_one :runtime_config_rss, :dependent => :destroy

  def after_destroy
    aplog.debug("START #{CLASS_NAME}#after_destroy")
    uid = self.page.channel.user.id.to_s
    divkey = (uid.to_i/300).to_s
    channel_no = self.page.channel.channel_no.to_s
    page_no = self.page.page_no.to_s
    content_id = self.id.to_s
    path = "./users_contents/" << divkey << "/" << uid << "/" << channel_no << "/" << page_no << "/" << content_id << "/"
    FileUtils.rm_r(path) if FileTest.exist?(path)
    aplog.debug("END   #{CLASS_NAME}#after_destroy")
  end
end
