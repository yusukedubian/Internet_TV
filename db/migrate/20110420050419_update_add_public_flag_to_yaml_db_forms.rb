class UpdateAddPublicFlagToYamlDbForms < ActiveRecord::Migration
  def self.up
    add_column(:yaml_db_forms, :public_flag, :boolean, :default => false, :null =>false)
    add_column(:yaml_db_forms, :couchdb_set_view_flag, :boolean, :default => false, :null => false)
    add_column(:yaml_db_forms, :mail_to_default, :string)
    add_column(:yaml_db_forms, :mail_cc_default, :string)
    add_column(:yaml_db_forms, :mail_bcc_default, :string)
    add_column(:yaml_db_forms, :mail_subject_default, :string)
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
