class CreateRuntimeConfigRsses < ActiveRecord::Migration
  def self.up
    create_table :runtime_config_rsses do |t|
      t.integer :content_id
      t.integer :channel_no
      t.integer :page_no
      t.string :control_no
      t.string :line_no
      t.string :rss_site_url
      t.timestamps
    end
  end

  def self.down
    drop_table :runtime_config_rsses
  end
end
