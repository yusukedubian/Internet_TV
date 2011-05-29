class Acceptance < ActiveRecord::Base
  has_many :acceptance_masters
  belongs_to :user
end
