class CreateProcurementForms < ActiveRecord::Migration
  def change
    create_table :procurement_forms do |t|
      t.string :long_name
      t.string :short_name
      t.string :effect

      t.timestamps null: false
    end
  end
end
