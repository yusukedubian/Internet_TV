class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.integer :player_no
      t.string :name
      t.string :guide_text
      t.string :playerclass
      t.string :playerview
      t.string :runtime_get_type
      t.string :runtime_create_type
      t.string :runtime_config_table
      t.timestamps
    end
  end

  def self.down
    drop_table :players
  end
end
