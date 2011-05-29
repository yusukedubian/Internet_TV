class CreateTemplateContents < ActiveRecord::Migration
  def self.up
    create_table :template_contents do |t|
      t.integer :player_id
      t.integer :template_page_id
      t.integer :width
      t.integer :height
      t.integer :x_pos
      t.integer :y_pos
      t.integer :contents_seq
      t.timestamps
    end
  end

  def self.down
    drop_table :template_contents
  end
end
