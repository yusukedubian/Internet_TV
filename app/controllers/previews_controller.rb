class PreviewsController < ApplicationController
  CLASS_NAME = self.name
  #before_filter :login_required
  def index
    aplog.debug("START #{CLASS_NAME}#index")
    aplog.debug("END   #{CLASS_NAME}#index")
  end
  
  def show
    aplog.debug("START #{CLASS_NAME}#show")
    aplog.debug("END   #{CLASS_NAME}#show")
  end
  
  def makePreviewPage()
    aplog.debug("START #{CLASS_NAME}#makePreviewPage")
    aplog.debug("END   #{CLASS_NAME}#makePreviewPage")
  end
  
end
