class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|

      t.integer :source_stock_id, index: true # index id of source stock item.

      t.references :purchase_order, index: true
      t.boolean :savings, index: true, default: false
      t.references :req_issued_slip, index: true
      t.references :project, index: true

      t.integer :item_number # item order in actual document.
      t.references :item, index: true, foreign_key: 'item_masterlist_id'

      t.decimal :cost, precision: 10, scale: 2

      t.decimal :stock_in, precision: 8, scale: 2, default: 0 # original quantity.
      t.decimal :stock_out, precision: 8, scale: 2, default: 0 # released quantity.
      t.decimal :prs_quantity, precision: 8, scale: 2 # declared quantity on prs.
      t.decimal :stock_bal, precision: 8, scale: 2, default: 0 # stock balance.
      t.string :remarks

      t.timestamps  null: false
    end
  end
end
