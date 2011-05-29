class CreateChannelsTypes < ActiveRecord::Migration
  def self.up
    create_table :channels_types do |t|
      t.string :name
      t.string :channels_type
      t.timestamps
    end
  end

  def self.down
    drop_table :channels_types
  end
end
