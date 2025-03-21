class CreateEndorsementCeoSupports < ActiveRecord::Migration

  def up
    create_table :endorsement_ceo_supports do |t|
    	t.references :endorsement_ceo_supports, index: true
    	t.references :projects, index: true
    	t.decimal :cca_number, precision: 10, scale: 2
    	t.decimal :project_cost, precision: 10, scale: 2
    	t.date :date_completed, precision: 10, scale: 2
    	t.references :user, index: true

      t.timestamps null: false
    end
  end

  def down
  end

end
