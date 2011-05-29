class CreateTemplateContentProperties < ActiveRecord::Migration
  def self.up
    create_table :template_content_properties do |t|
      t.integer :template_content_id
      t.string :property_key
      t.string :property_value
      t.timestamps
      t.timestamps
    end
  end

  def self.down
    drop_table :template_content_properties
  end
end
