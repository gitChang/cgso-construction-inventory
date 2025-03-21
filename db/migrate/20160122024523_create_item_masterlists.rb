class CreateItemMasterlists < ActiveRecord::Migration
  def up
    create_table :item_masterlists do |t|
      t.string :item_code
      t.string :name, index: true
      t.string :name_parameterize, index: true
      t.references :unit, index: true, foreign_key: true
      t.references :supply, index: true, foreign_key: true
      t.decimal :cost, precision: 10, scale: 2, default: 0.00

      t.boolean :stock, default: true

      t.timestamps null: false
    end
  end


  def down
    # add_column :item_masterlists, :name_parameterize, :string, index: true
  end
end
