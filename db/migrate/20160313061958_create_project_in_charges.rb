class CreateProjectInCharges < ActiveRecord::Migration
  def up
    create_table :project_in_charges do |t|
      #t.references :department, index: true
      t.string :name, index: true
      t.string :designation

      t.timestamps null: false
    end
  end
end
