class CreateAcceptanceMasters < ActiveRecord::Migration
  def self.up
    create_table :acceptance_masters do |t|
      t.string :name
      t.integer :content_type
      t.string :table_name
      
      t.timestamps
    end
  end

  def self.down
    drop_table :acceptance_masters
  end
end
