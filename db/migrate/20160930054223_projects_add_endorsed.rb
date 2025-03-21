class ProjectsAddEndorsed < ActiveRecord::Migration
  def up
    add_column :projects, :endorsed, :boolean, default: false
  end

  def down
  end
end
