class Contract < ActiveRecord::Base
  has_many :users, :dependent => :destroy
  has_many :player_access_authorities, :dependent => :destroy
end
