class BaseSystemException < StandardError
  
  attr_accessor :cause

  def initialize(message, cause=nil)
    @cause ||= cause
    super message
  end
  
end
