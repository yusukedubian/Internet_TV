class UpdateContentsChangeAttributeNotNull < ActiveRecord::Migration

  class TempModel < ActiveRecord::Base
    set_table_name "contents"
    # データ移行に必要な処理だけを記載
  end
 
  
  
  def self.up
    change_column(:contents, :width, :integer, :null=>false, :default=>0 )
    change_column(:contents, :height, :integer, :null=>false, :default=>0 )
    change_column(:contents, :x_pos, :integer, :null=>false, :default=>0 )
    change_column(:contents, :y_pos, :integer, :null=>false, :default=>0 )
    change_column(:contents, :contents_seq, :integer, :null=>false, :default=>0 )
    change_column(:contents, :line_width, :integer, :null=>false, :default=>0 )
    change_column(:contents, :line_color, :string, :null=>false, :default=>"#123456" )
    
    TempModel.update_all("line_color='#123456'", ["line_color = ?",""])
    
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration  
  end
end
