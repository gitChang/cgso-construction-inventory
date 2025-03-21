class ItemMasterlistsAddOnHandCount < ActiveRecord::Migration
  def up
    add_column :item_masterlists, :on_hand_count, :integer
  end

  def down
  #  remove_column :item_masterlists, :on_hand_count
  end
end
