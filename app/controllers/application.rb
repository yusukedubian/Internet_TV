# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  include SystemSettings
  cattr_accessor :aplog
  @@aplog ||= SystemSettings::APL_LOGGER
  mattr_accessor :aplerr
  @@aplerr ||= SystemSettings::APLERR_LOGGER
  
  before_filter :request_log
  helper :all # include all helpers, all the time
  include CommonLog
  include AuthenticatedSystem
  include MessagePrint
  include RuntimeSystem
  include Validate
  include ConstYamlDbForm
  GetText.locale = ConstLocale::LOCALE
  init_gettext "vasdaqtv"
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  :secret => 'c35e9fd695f2e7ca0e33dc6712cf4376'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password
  
  Time.zone = 'Tokyo'
  
  def redirect_to(options = {}, response_status = {})
    super
    redirect_log(options, response_status)
  end
  
  def render(options = nil, extra_options = {}, &block)
    super
    render_log(options, extra_options, &block)
  end

  
  def rescue_action_in_public(exception)
    error_log(exception)
    super
  end
  
  def rescue_action_locally(exception)
    error_log(exception)
    super
  end
  
  
#  def local_request?
#    false
#  end
  
end
