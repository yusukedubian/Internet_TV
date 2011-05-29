class CreateContentsProperties < ActiveRecord::Migration
  def self.up
    create_table :contents_properties do |t|
      t.integer :content_id
      t.string :property_key
      t.string :property_value, :limit => 2048
      t.timestamps
    end
  end

  def self.down
    drop_table :contents_properties
  end
end
