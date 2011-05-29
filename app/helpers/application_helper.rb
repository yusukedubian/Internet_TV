# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  mattr_accessor :aplog
  @@aplog ||= SystemSettings::APL_LOGGER
  
  def simple_time(time)
    time.strftime("%Y-%m-%d<br />%H:%M:%S")
  end

end
