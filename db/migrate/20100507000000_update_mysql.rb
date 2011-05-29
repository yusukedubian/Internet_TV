class UpdateMysql < ActiveRecord::Migration
  def self.up
    change_column :users, :login, :string, :limit => 40
    change_column :users, :email, :string,  :limit => 200
    change_column :users, :crypted_password, :string,  :limit => 40
    change_column :users, :salt, :string,  :limit => 40
    change_column :users, :activation_code, :string,  :limit => 40
    change_column :users, :user_name, :string,  :limit => 40
    
    change_column :contents_properties, :property_value, :string,  :limit => 2048
    
    change_column :pages, :name, :string,  :limit => 80
    change_column :pages, :category, :string,  :limit => 80
    
    change_column :channels, :name, :string,  :limit => 80
    change_column :channels, :category, :string,  :limit => 80
    change_column :channels, :description, :string,  :limit => 2048
    change_column :channels, :link_info, :string,  :limit => 512
    change_column :channels, :other_info, :string,  :limit => 512
    
    change_column :runtime_config_mails, :subject, :string,  :limit => 1024
    
    change_column :runtime_data_mails, :mail_from, :string,  :limit => 1024
    change_column :runtime_data_mails, :mail_to, :string,  :limit => 1024
    change_column :runtime_data_mails, :mail_cc, :string,  :limit => 1024
    change_column :runtime_data_mails, :subject, :string,  :limit => 1024
    change_column :runtime_data_mails, :body, :string,  :limit => 4096
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration  
  end
end
