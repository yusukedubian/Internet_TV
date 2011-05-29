#チャンネルアップロード対応
class UpdateChannelMysql < ActiveRecord::Migration
  def self.up
    add_column(:channels, :uploaded_flg, :boolean, :default => true)
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration  
  end
end
