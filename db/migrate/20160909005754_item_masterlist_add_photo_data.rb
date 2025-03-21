class ItemMasterlistAddPhotoData < ActiveRecord::Migration
  def up
    add_column :item_masterlists, :photo_data, :text
  end

  def down
    remove_column :item_masterlists, :photo_data
  end
end
