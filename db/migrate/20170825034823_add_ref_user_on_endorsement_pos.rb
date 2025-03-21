class AddRefUserOnEndorsementPos < ActiveRecord::Migration

  def up
    add_reference :endorsement_pos, :user, index: true
  end

  def down
  end

end
