class CreateTemplatePages < ActiveRecord::Migration
  def self.up
    create_table :template_pages do |t|
      t.integer :template_page_no
      t.string :name
      t.string :category
      t.integer :switchtime
      t.string :background
      t.string :backgroundfile
      t.integer :width
      t.integer :height
      t.string :description
      t.string :link_info
      t.string :other_info
      t.string :thumbnail_filename
      t.timestamps
    end
  end

  def self.down
    drop_table :template_pages
  end
end
