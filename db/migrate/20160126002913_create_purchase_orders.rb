class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.string :po_number, index: true, unique: true, null: false
      t.date :date_issued

      t.references :project, index: true
      t.references :supplier, index: true, foreign_key: true
      t.references :mode_of_procurement, index: true, foreign_key: true

      t.string :iar_number, index: true
      t.references :inspector, index: true, foreign_key: true
      t.date :date_of_delivery
      t.boolean :complete

      t.text :remarks

      t.timestamps null: false
    end
  end
end
