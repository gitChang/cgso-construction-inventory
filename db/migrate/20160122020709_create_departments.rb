class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name, unique: true

      t.timestamps null: false
    end
  end
end
