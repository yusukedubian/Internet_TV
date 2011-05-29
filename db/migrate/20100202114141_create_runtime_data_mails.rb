class CreateRuntimeDataMails < ActiveRecord::Migration
  def self.up
    create_table :runtime_data_mails do |t|
      t.integer :user_id
      t.string :mail_recieved_id
      t.datetime :send_date
      t.string :mail_from, :limit => 1024
      t.string :mail_to, :limit => 1024
      t.string :mail_cc, :limit => 1024
      t.string :subject, :limit => 1024
      t.string :body, :limit => 4096
      t.timestamps
    end
  end

  def self.down
    drop_table :runtime_data_mails
  end
end