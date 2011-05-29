
class Session < ActiveRecord::Base
  CLASS_NAME = self.name
  cattr_accessor :aplog
  @@aplog ||= SystemSettings::APL_LOGGER

  def self.cleanup
    aplog.debug("START #{CLASS_NAME}#cleanup")
    Session.delete_all(["updated_at < ?",30.days.ago])
    aplog.debug("START #{CLASS_NAME}#cleanup")
  end
end
