class CreateModeOfProcurements < ActiveRecord::Migration
  def change
    create_table :mode_of_procurements do |t|
      t.string :mode

      t.timestamps null: false
    end
  end
end
