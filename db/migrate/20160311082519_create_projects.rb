class CreateProjects < ActiveRecord::Migration
  def up
    create_table :projects do |t|
      t.references :department, index: true
      t.references :project_in_charge, index: true
      t.string :pr_number, index: true
      t.string :pow_number, index: true
      t.string :prs_number, index: true, default: ''
      t.string :cert_number, index: true, default: ''
      t.string :purpose, index: true

      t.timestamps null: false
    end
  end

  def down
    #drop_table :projects
    #add_column :projects, :cert_number, :string, :default => ''
  end
end
