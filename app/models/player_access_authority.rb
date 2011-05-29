class PlayerAccessAuthority < ActiveRecord::Base
  belongs_to :contract
  belongs_to :player
end
