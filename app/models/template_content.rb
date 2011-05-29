class TemplateContent < ActiveRecord::Base
  belongs_to :player
  belongs_to :template_page
  has_many :contents_properties, :dependent => :destroy

end
