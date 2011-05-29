  class AplInfomationException < BaseInfomationException
    cattr_accessor :aplog
    @@aplog ||= RAILS_DEFAULT_LOGGER
    
    def initialize(message)
      super(message)
    end
  end
