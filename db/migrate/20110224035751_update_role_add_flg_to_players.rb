class UpdateRoleAddFlgToPlayers < ActiveRecord::Migration
  def self.up
   #Playersテーブル関連
    add_column(:players, :role_add_flg, :boolean, :default => true, :null =>false)
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration  
  end
end
