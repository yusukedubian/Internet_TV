class Mypage < ActiveRecord::Base
  belongs_to :user
  belongs_to :channel
  belongs_to :mypage_group
end
