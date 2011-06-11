class CreateCopyContents < ActiveRecord::Migration
  def self.up
    create_table :copy_contents do |t|
      t.integer :channel_id
      t.integer :page_no
      t.integer :player_id
      t.integer :width
      t.integer :height
      t.integer :line_width
      t.string :line_color
      t.string :line_type
    end
  end

  def self.down
    drop_table :copy_contents
  end
end
