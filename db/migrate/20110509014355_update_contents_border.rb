class UpdateContentsBorder < ActiveRecord::Migration
  def self.up
    add_column(:contents, :line_type, :string)
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration  
  end
end
