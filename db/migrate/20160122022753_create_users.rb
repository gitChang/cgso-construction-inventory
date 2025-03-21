class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :designation

      t.references :department, index: true, foreign_key: true
      t.references :department_division, index: true, foreign_key: true

      t.string :username, index: true
      t.references :system_role, index: true, foreign_key: true

      # sorcery core
      t.string :email, unique: true
      t.string :crypted_password
      t.string :salt

      t.timestamps null: false
    end
  end
end
