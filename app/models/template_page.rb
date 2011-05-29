class TemplatePage < ActiveRecord::Base
  has_many :template_contents, :dependent => :destroy

end
