class CreateRuntimeConfigMails < ActiveRecord::Migration
  def self.up
    create_table :runtime_config_mails do |t|
      t.integer :content_id
      t.integer :channel_no
      t.integer :page_no
      t.string :control_no
      t.string :subject, :limit => 1024
      t.string :base_date_unit
      t.integer :base_date
      t.string :extract_period_unit
      t.integer :extract_period
      t.timestamps
    end
  end

  def self.down
    drop_table :runtime_config_mails
  end
end
