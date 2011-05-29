class CreateMypages < ActiveRecord::Migration
  def self.up
    create_table :mypages do |t|
      t.integer :user_id
      t.integer :channel_id
      t.timestamps
    end
  end

  def self.down
    drop_table :mypages
  end
end
