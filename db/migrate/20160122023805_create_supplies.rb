class CreateSupplies < ActiveRecord::Migration
  def change
    create_table :supplies do |t|
      t.string :kind, index: true

      t.timestamps null: false
    end
  end
end
