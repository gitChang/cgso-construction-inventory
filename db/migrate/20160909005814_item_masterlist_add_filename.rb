class ItemMasterlistAddFilename < ActiveRecord::Migration
  def up
    add_column :item_masterlists, :filename, :string
  end

  def down
  end
end
