class CopyContent < ActiveRecord::Base
  belongs_to :channel
  has_many :copy_contents_propertiess , :dependent => :destroy
end