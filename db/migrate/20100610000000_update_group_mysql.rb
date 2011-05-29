#グループ化対応
class UpdateGroupMysql < ActiveRecord::Migration
  def self.up
    #playerテーブル関連
    add_column(:players, :title_img, :string)
    add_column(:players, :logo_img, :string)
    add_column(:players, :del_flg, :boolean ,:default=> false)
    add_column(:players, :default, :boolean ,:default=> false) 
    
    #roleテーブル関連
    add_column(:roles, :name_kana, :string) 
    
    #userテーブル関連
    add_column(:users, :name, :string, :limit => 80)
    add_column(:users, :department, :string, :limit => 80)
    add_column(:users, :company_id, :integer)
    
    #channelテーブル関連
    add_column(:channels, :group_flg, :boolean, :default=> false)
    
    # 契約テーブル作成
    create_table :contracts do |t|
      t.string   :contract_code, :limit => 12
      t.string   :company_name, :limit => 128
      t.string   :company_name_kana, :limit => 255
      t.string   :president_name, :limit => 32
      t.string   :representative_phone, :limit => 32
      t.string   :headquarters_zipcode, :limit => 16
      t.string   :headquarters_address_prefecture, :limit => 128
      t.string   :headquarters_address_city, :limit => 128
      t.string   :headquarters_address_building, :limit => 128
      t.string   :base_remarks, :limit => 1024
      t.string   :accept_name, :limit => 32
      t.string   :accept_name_kana, :limit => 64
      t.string   :accept_department, :limit => 64
      t.string   :accept_post, :limit => 32
      t.string   :accept_phone, :limit => 32
      t.string   :accept_phone_ext, :limit => 32
      t.string   :accept_zipcode, :limit => 16
      t.string   :accept_prefecture, :limit => 128
      t.string   :accept_city, :limit => 128
      t.string   :accept_building, :limit => 128
      t.string   :accept_remarks, :limit => 1024
      t.integer  :max_account_count
      t.integer  :max_disc_size
      t.integer  :current_disc_size
      t.string   :register, :limit => 32
      t.boolean  :del_flg
      t.timestamps
    end
  
    # プレーヤーアクセス権限テーブル作成
    create_table :player_access_authorities do |t|
      t.integer :contract_id 
      t.integer :player_id
      t.timestamps
    end
  
    create_table :index_messages do |t|
      t.string  :body, :limit => 200
      t.boolean :no_end_flg, :default => false
      t.boolean :del_flg, :default => false
      t.datetime :start_date
      t.datetime :end_date
      t.timestamps
    end
    
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration  
  end
end
