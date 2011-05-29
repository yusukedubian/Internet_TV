class CreateYamlDbForms < ActiveRecord::Migration
  def self.up
    create_table :yaml_db_forms do |t|
      t.integer :user_id
      t.string :file_path
      t.string :form_name
      t.string :form_desc

      t.timestamps
    end
  end

  def self.down
    drop_table :yaml_db_forms
  end
end
