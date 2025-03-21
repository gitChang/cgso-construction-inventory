class CreateEndorsementCeos < ActiveRecord::Migration

  def up
    create_table :endorsement_ceos do |t|
      t.string :control_number
      t.string :recipient
      t.string :recipient_designation
      t.string :thru
      t.string :thru_designation
      t.string :sender
      t.string :sender_designation
      t.string :cc

      t.timestamps null: false
    end
  end

  def down
  end
end
