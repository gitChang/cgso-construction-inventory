class RemoveEndorsedOnProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :endorsed
  end
end
