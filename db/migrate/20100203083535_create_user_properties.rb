class CreateUserProperties < ActiveRecord::Migration
  def self.up
    create_table :user_properties do |t|
      t.integer :user_id
      t.string :email
      t.string :domain
      t.string :smtp_address
      t.string :pop3_address
      t.string :smtp_port
      t.string :pop3_port
      t.string :authentication
      t.string :auth_user_name
      t.string :auth_password
      t.string :google_key
      t.timestamps
    end
  end

  def self.down
    drop_table :user_properties
  end
end
