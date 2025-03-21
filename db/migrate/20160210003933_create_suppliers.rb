class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :name, index: true
      t.string :address

      t.timestamps null: false
    end
  end
end
