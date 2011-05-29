class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer :channel_id
      t.integer :page_no
      t.string :name, :limit => 80
      t.string :category, :limit => 80
      t.integer :switchtime
      t.string :background
      t.string :backgroundfile
      t.integer :background_display_type
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
