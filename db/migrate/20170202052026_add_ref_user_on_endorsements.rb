class AddRefUserOnEndorsements < ActiveRecord::Migration
  def up
    add_reference :endorsements, :user, index: true
  end

  def down
  end
end
