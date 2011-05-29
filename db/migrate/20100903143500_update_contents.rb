class UpdateContents < ActiveRecord::Migration
  def self.up
   #contentsテーブル関連
    add_column(:contents, :line_width, :integer)
    add_column(:contents, :line_color, :string, :limit => 7)
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration  
  end
end
