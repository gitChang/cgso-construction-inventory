class AddRefEndorsementsOnProjects < ActiveRecord::Migration
  def up
    add_reference :projects, :endorsement, index: true
  end

  def down
  end
end
