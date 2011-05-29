class CreateAcceptances < ActiveRecord::Migration
  def self.up
    create_table :acceptances do |t|
      t.integer :user_id
      t.integer :content_id
      t.integer :acceptance_master_id
      t.timestamps
    end
  end

  def self.down
    drop_table :acceptances
  end
end
