class CreateWarehousemen < ActiveRecord::Migration
  def change
    create_table :warehousemen do |t|
      t.string :name, index: true

      t.timestamps null: false
    end
  end
end
