class UpdateAddViewNameToPlayers < ActiveRecord::Migration
  def self.up
    add_column(:players, :view_name, :string)
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration  
  end
end
