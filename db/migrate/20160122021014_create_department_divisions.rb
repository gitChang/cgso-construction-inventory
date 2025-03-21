class CreateDepartmentDivisions < ActiveRecord::Migration
  def change
    create_table :department_divisions do |t|
      t.references :department, index: true, foreign_key: true
      t.string :division

      t.timestamps null: false
    end
  end
end
