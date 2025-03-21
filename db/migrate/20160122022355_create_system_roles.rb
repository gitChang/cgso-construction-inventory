class CreateSystemRoles < ActiveRecord::Migration
  def change
    create_table :system_roles do |t|
      t.string :role

      t.timestamps null: false
    end
  end
end
