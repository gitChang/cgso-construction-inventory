class CreateInspectors < ActiveRecord::Migration
  def change
    create_table :inspectors do |t|
      t.string :name, index: true

      t.timestamps null: false
    end
  end
end
