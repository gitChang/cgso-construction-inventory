class AddDeptAbbrev < ActiveRecord::Migration
  def change
    add_column :departments, :abbrev, :string, index: true
  end
end
