class CreateChannels < ActiveRecord::Migration
  def self.up
    create_table :channels do |t|
      t.integer :user_id
      t.integer :channels_type_id
      t.integer :channel_no
      t.string :name, :limit => 80
      t.string :category, :limit => 80
      t.string :background
      t.integer :public_flag
      t.integer :width
      t.integer :height
      t.integer :create_type
      t.string :description, :limit => 2048
      t.string :link_info, :limit => 512
      t.string :other_info, :limit => 512
      t.string :thumbnail_filename
      t.timestamps
    end
  end

  def self.down
    drop_table :channels
  end
end
