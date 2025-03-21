class AddRefEndorsementPoOnPurchaseOrders < ActiveRecord::Migration
  def up
    add_reference :purchase_orders, :endorsement_po, index: true
  end

  def down
  end
end