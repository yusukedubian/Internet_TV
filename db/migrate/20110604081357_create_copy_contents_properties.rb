class CreateCopyContentsProperties < ActiveRecord::Migration
  def self.up
    create_table :copy_contents_properties do |t|
      t.integer :copy_content_id
      t.string :property_key
      t.string :property_value
    end
  end

  def self.down
    drop_table :copy_contents_properties
  end
end
