class Player < ActiveRecord::Base
  has_many :contents
  has_many :player_access_authorities, :dependent => :destroy
end
